import 'package:uuid/uuid.dart';
import 'channel_type.dart';

enum ThreatDecision {
  autoBlocked,
  autoAllowed,
  escalatedToUser,
  userBlocked,
  userAllowed,
}

extension ThreatDecisionExtension on ThreatDecision {
  String get label {
    switch (this) {
      case ThreatDecision.autoBlocked:
        return 'Auto-Blocked by AI';
      case ThreatDecision.autoAllowed:
        return 'Allowed (Safe)';
      case ThreatDecision.escalatedToUser:
        return 'Escalated to Owner';
      case ThreatDecision.userBlocked:
        return 'Blocked by Owner';
      case ThreatDecision.userAllowed:
        return 'Allowed by Owner';
    }
  }

  bool get isBlocked =>
      this == ThreatDecision.autoBlocked || this == ThreatDecision.userBlocked;

  bool get isPendingEscalation => this == ThreatDecision.escalatedToUser;
}

class AiThreatRecord {
  final String id;
  final ChannelType channel;
  final String senderHandle;
  final String? senderDisplayName;
  final String content;
  final DateTime timestamp;
  final int riskScore; // 0 - 100
  final String threatCategory; // e.g. "Crypto Scam", "Phishing Link", "Impersonation", "Urgent Wire Fraud", "Safe Inquiry"
  final double aiConfidence; // 0.0 - 1.0
  final ThreatDecision decision;
  final String aiReasoning;
  final List<String> riskIndicators;
  final String? resolutionNote;
  final String sourceMethod; // e.g. "Android Notification Listener", "Pipedream Webhook", "Twilio"
  final bool isRead;

  AiThreatRecord({
    String? id,
    required this.channel,
    required this.senderHandle,
    this.senderDisplayName,
    required this.content,
    DateTime? timestamp,
    required this.riskScore,
    required this.threatCategory,
    required this.aiConfidence,
    required this.decision,
    required this.aiReasoning,
    this.riskIndicators = const [],
    this.resolutionNote,
    this.sourceMethod = 'Pipedream Webhook',
    this.isRead = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  String get displaySender => senderDisplayName != null && senderDisplayName!.isNotEmpty
      ? '$senderDisplayName ($senderHandle)'
      : senderHandle;

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  AiThreatRecord copyWith({
    String? id,
    ChannelType? channel,
    String? senderHandle,
    String? senderDisplayName,
    String? content,
    DateTime? timestamp,
    int? riskScore,
    String? threatCategory,
    double? aiConfidence,
    ThreatDecision? decision,
    String? aiReasoning,
    List<String>? riskIndicators,
    String? resolutionNote,
    String? sourceMethod,
    bool? isRead,
  }) {
    return AiThreatRecord(
      id: id ?? this.id,
      channel: channel ?? this.channel,
      senderHandle: senderHandle ?? this.senderHandle,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      riskScore: riskScore ?? this.riskScore,
      threatCategory: threatCategory ?? this.threatCategory,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      decision: decision ?? this.decision,
      aiReasoning: aiReasoning ?? this.aiReasoning,
      riskIndicators: riskIndicators ?? this.riskIndicators,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      sourceMethod: sourceMethod ?? this.sourceMethod,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'channel': channel.name,
        'senderHandle': senderHandle,
        'senderDisplayName': senderDisplayName,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'riskScore': riskScore,
        'threatCategory': threatCategory,
        'aiConfidence': aiConfidence,
        'decision': decision.name,
        'aiReasoning': aiReasoning,
        'riskIndicators': riskIndicators,
        'resolutionNote': resolutionNote,
        'sourceMethod': sourceMethod,
        'isRead': isRead,
      };

  factory AiThreatRecord.fromJson(Map<String, dynamic> json) => AiThreatRecord(
        id: json['id'] as String,
        channel: ChannelType.values.byName(json['channel'] as String),
        senderHandle: json['senderHandle'] as String,
        senderDisplayName: json['senderDisplayName'] as String?,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        riskScore: json['riskScore'] as int,
        threatCategory: json['threatCategory'] as String,
        aiConfidence: (json['aiConfidence'] as num).toDouble(),
        decision: ThreatDecision.values.byName(json['decision'] as String),
        aiReasoning: json['aiReasoning'] as String,
        riskIndicators: (json['riskIndicators'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        resolutionNote: json['resolutionNote'] as String?,
        sourceMethod: json['sourceMethod'] as String? ?? 'Pipedream Webhook',
        isRead: json['isRead'] as bool? ?? false,
      );
}
