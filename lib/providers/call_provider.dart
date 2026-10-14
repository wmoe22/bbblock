import 'package:flutter/foundation.dart';
import '../models/call_record.dart';
import '../models/blocking_stats.dart';
import '../services/mock_data_service.dart';

class CallProvider extends ChangeNotifier {
  List<CallRecord> _callHistory = [];
  BlockingStats _stats = const BlockingStats();
  String _selectedPeriod = 'Week';
  bool _isLoading = true;
  final Set<String> _blockedNumbers = {};
  bool _autoBlockScam = true;
  bool _autoBlockTelemarketing = true;
  bool _callScreeningEnabled = true;

  List<CallRecord> get callHistory => _callHistory;
  BlockingStats get stats => _stats;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  Set<String> get blockedNumbers => _blockedNumbers;
  bool get autoBlockScam => _autoBlockScam;
  bool get autoBlockTelemarketing => _autoBlockTelemarketing;
  bool get callScreeningEnabled => _callScreeningEnabled;

  int get totalBlockedToday {
    final today = DateTime.now();
    return _callHistory.where((c) =>
        c.wasBlocked &&
        c.timestamp.year == today.year &&
        c.timestamp.month == today.month &&
        c.timestamp.day == today.day).length;
  }

  int get totalIdentifiedToday {
    final today = DateTime.now();
    return _callHistory.where((c) =>
        c.timestamp.year == today.year &&
        c.timestamp.month == today.month &&
        c.timestamp.day == today.day).length;
  }

  List<CallRecord> get blockedCalls =>
      _callHistory.where((c) => c.wasBlocked).toList();

  List<CallRecord> get recentCalls =>
      _callHistory.take(10).toList();

  Map<String, int> get categoryBreakdown {
    final map = <String, int>{};
    for (final call in _callHistory.where((c) => c.wasBlocked)) {
      map[call.category] = (map[call.category] ?? 0) + 1;
    }
    return map;
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    _callHistory = MockDataService.generateCallHistory();
    _stats = MockDataService.generateStats(period: _selectedPeriod);
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    _stats = MockDataService.generateStats(period: period);
    notifyListeners();
  }

  void toggleAutoBlockScam(bool value) {
    _autoBlockScam = value;
    notifyListeners();
  }

  void toggleAutoBlockTelemarketing(bool value) {
    _autoBlockTelemarketing = value;
    notifyListeners();
  }

  void toggleCallScreening(bool value) {
    _callScreeningEnabled = value;
    notifyListeners();
  }

  void blockNumber(String number) {
    _blockedNumbers.add(number);
    notifyListeners();
  }

  void unblockNumber(String number) {
    _blockedNumbers.remove(number);
    notifyListeners();
  }

  bool isNumberBlocked(String number) => _blockedNumbers.contains(number);

  CallRecord processIncomingCall({
    required String phoneNumber,
    String? contactName,
    required String category,
    required String threatLevel,
  }) {
    final shouldBlock = isNumberBlocked(phoneNumber) ||
        (_autoBlockScam && category == 'Scam') ||
        (_autoBlockTelemarketing && category == 'Telemarketing');

    final record = CallRecord(
      phoneNumber: phoneNumber,
      contactName: contactName,
      category: category,
      threatLevel: threatLevel,
      timestamp: DateTime.now(),
      wasBlocked: shouldBlock,
      isIncoming: true,
      duration: shouldBlock ? null : const Duration(seconds: 0),
    );

    _callHistory.insert(0, record);
    notifyListeners();
    return record;
  }
}
