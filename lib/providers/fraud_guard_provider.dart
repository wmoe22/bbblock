import 'package:flutter/foundation.dart';
import '../models/channel_type.dart';
import '../models/ai_threat_record.dart';
import '../models/pipedream_channel_config.dart';
import '../services/ai_fraud_engine.dart';
import '../services/pipedream_service.dart';

class FraudGuardProvider extends ChangeNotifier {
  List<AiThreatRecord> _records = [];
  List<PipedreamChannelConfig> _channelConfigs = [];
  bool _isLoading = false;

  int _autoBlockThreshold = AiFraudEngine.defaultAutoBlockThreshold;
  int _autoAllowThreshold = AiFraudEngine.defaultAutoAllowThreshold;
  String _pipedreamWebhookUrl = PipedreamService.defaultWebhookBase;
  String _pipedreamApiKey = '';
  String _customPromptTemplate = AiFraudEngine.defaultPromptTemplate;

  // Getters
  List<AiThreatRecord> get allRecords => List.unmodifiable(_records);
  List<PipedreamChannelConfig> get channelConfigs => List.unmodifiable(_channelConfigs);
  bool get isLoading => _isLoading;

  int get autoBlockThreshold => _autoBlockThreshold;
  int get autoAllowThreshold => _autoAllowThreshold;
  String get pipedreamWebhookUrl => _pipedreamWebhookUrl;
  String get pipedreamApiKey => _pipedreamApiKey;
  String get customPromptTemplate => _customPromptTemplate;

  /// The critical queue: Communications where "the AI can't decide, so it passes to the user"
  List<AiThreatRecord> get pendingEscalations =>
      _records.where((r) => r.decision == ThreatDecision.escalatedToUser).toList();

  int get pendingEscalationsCount => pendingEscalations.length;

  List<AiThreatRecord> get blockedRecords =>
      _records.where((r) => r.decision.isBlocked).toList();

  List<AiThreatRecord> get allowedRecords =>
      _records.where((r) => r.decision == ThreatDecision.autoAllowed || r.decision == ThreatDecision.userAllowed).toList();

  int get totalBlockedToday {
    final now = DateTime.now();
    return _records.where((r) =>
        r.decision.isBlocked &&
        r.timestamp.year == now.year &&
        r.timestamp.month == now.month &&
        r.timestamp.day == now.day).length;
  }

  int get totalScannedToday {
    final now = DateTime.now();
    return _records.where((r) =>
        r.timestamp.year == now.year &&
        r.timestamp.month == now.month &&
        r.timestamp.day == now.day).length;
  }

  Map<ChannelType, int> get channelThreatCounts {
    final map = <ChannelType, int>{};
    for (final r in _records.where((r) => r.decision.isBlocked)) {
      map[r.channel] = (map[r.channel] ?? 0) + 1;
    }
    return map;
  }

  FraudGuardProvider() {
    _channelConfigs = PipedreamService.getDefaultChannelConfigs();
    _records = PipedreamService.getInitialRecords();
  }

  /// Initialize and load data
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _channelConfigs = PipedreamService.getDefaultChannelConfigs();
    _records = PipedreamService.getInitialRecords();

    _isLoading = false;
    notifyListeners();
  }

  /// Resolve an escalated item: User decides to Block or Allow
  Future<void> resolveEscalation(String recordId, bool isBlock, {String? note}) async {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index == -1) return;

    final target = _records[index];
    final updated = target.copyWith(
      decision: isBlock ? ThreatDecision.userBlocked : ThreatDecision.userAllowed,
      resolutionNote: note ?? (isBlock ? 'Blocked by owner & synced to Pipedream' : 'Allowed by owner (Whitelisted)'),
    );

    _records[index] = updated;
    notifyListeners();

    // Two-Way Sync back to Pipedream!
    await PipedreamService.syncActionToPipedream(
      action: isBlock ? 'block_sender' : 'whitelist_sender',
      channel: target.channel,
      senderHandle: target.senderHandle,
      riskScore: target.riskScore,
      note: note,
    );

    // Update channel metrics
    _updateChannelMetric(target.channel, wasBlocked: isBlock);
    notifyListeners();
  }

  /// Ingest and evaluate an incoming event (from Pipedream webhook, Android notification, etc.)
  AiThreatRecord processIncomingInteraction({
    required ChannelType channel,
    required String senderHandle,
    String? senderDisplayName,
    required String content,
    String? sourceMethod,
  }) {
    // Run AI model evaluation
    final analysis = AiFraudEngine.evaluate(
      content: content,
      senderHandle: senderHandle,
      channel: channel,
      autoBlockThreshold: _autoBlockThreshold,
      autoAllowThreshold: _autoAllowThreshold,
    );

    final record = AiThreatRecord(
      channel: channel,
      senderHandle: senderHandle,
      senderDisplayName: senderDisplayName,
      content: content,
      riskScore: analysis.riskScore,
      threatCategory: analysis.threatCategory,
      aiConfidence: analysis.aiConfidence,
      decision: analysis.decision,
      aiReasoning: analysis.aiReasoning,
      riskIndicators: analysis.riskIndicators,
      sourceMethod: sourceMethod ?? channel.defaultSource,
    );

    _records.insert(0, record);

    // If auto-blocked, sync to Pipedream
    if (record.decision == ThreatDecision.autoBlocked) {
      PipedreamService.syncActionToPipedream(
        action: 'auto_block',
        channel: channel,
        senderHandle: senderHandle,
        riskScore: record.riskScore,
      );
    }

    _updateChannelMetric(
      channel,
      wasBlocked: record.decision == ThreatDecision.autoBlocked,
      wasEscalated: record.decision == ThreatDecision.escalatedToUser,
    );

    notifyListeners();
    return record;
  }

  void _updateChannelMetric(ChannelType channel, {bool wasBlocked = false, bool wasEscalated = false}) {
    final idx = _channelConfigs.indexWhere((c) => c.channel == channel);
    if (idx != -1) {
      final config = _channelConfigs[idx];
      _channelConfigs[idx] = config.copyWith(
        totalScanned: config.totalScanned + 1,
        totalBlocked: wasBlocked ? config.totalBlocked + 1 : config.totalBlocked,
        totalEscalated: wasEscalated ? config.totalEscalated + 1 : config.totalEscalated,
        lastActiveAt: DateTime.now(),
      );
    }
  }

  void toggleChannel(ChannelType channel, bool isEnabled) {
    final idx = _channelConfigs.indexWhere((c) => c.channel == channel);
    if (idx != -1) {
      _channelConfigs[idx] = _channelConfigs[idx].copyWith(isEnabled: isEnabled);
      notifyListeners();
    }
  }

  void updateThresholds({int? autoBlock, int? autoAllow}) {
    if (autoBlock != null) _autoBlockThreshold = autoBlock;
    if (autoAllow != null) _autoAllowThreshold = autoAllow;
    notifyListeners();
  }

  void updatePipedreamSettings({
    String? webhookUrl,
    String? apiKey,
    String? promptTemplate,
  }) {
    if (webhookUrl != null) _pipedreamWebhookUrl = webhookUrl;
    if (apiKey != null) _pipedreamApiKey = apiKey;
    if (promptTemplate != null) _customPromptTemplate = promptTemplate;
    notifyListeners();
  }
}
