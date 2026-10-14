import 'package:flutter/foundation.dart';
import '../models/sms_record.dart';
import '../services/mock_data_service.dart';

class SmsProvider extends ChangeNotifier {
  List<SmsRecord> _messages = [];
  bool _isLoading = true;
  bool _smsProtectionEnabled = true;
  bool _safeViewEnabled = true;

  List<SmsRecord> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get smsProtectionEnabled => _smsProtectionEnabled;
  bool get safeViewEnabled => _safeViewEnabled;

  List<SmsRecord> get threatMessages =>
      _messages.where((m) => m.isThreat).toList();

  List<SmsRecord> get safeMessages =>
      _messages.where((m) => !m.isThreat).toList();

  int get unreadThreats =>
      threatMessages.where((m) => !m.isRead).length;

  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _messages = MockDataService.generateSmsHistory();
    _isLoading = false;
    notifyListeners();
  }

  void toggleSmsProtection(bool value) {
    _smsProtectionEnabled = value;
    notifyListeners();
  }

  void toggleSafeView(bool value) {
    _safeViewEnabled = value;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      final msg = _messages[index];
      _messages[index] = SmsRecord(
        id: msg.id,
        sender: msg.sender,
        body: msg.body,
        timestamp: msg.timestamp,
        isThreat: msg.isThreat,
        threatType: msg.threatType,
        isRead: true,
        maliciousLinks: msg.maliciousLinks,
      );
      notifyListeners();
    }
  }

  void addIncomingSms({
    required String sender,
    required String body,
    required bool isThreat,
    String? threatType,
    List<String> maliciousLinks = const [],
  }) {
    final record = SmsRecord(
      sender: sender,
      body: body,
      timestamp: DateTime.now(),
      isThreat: isThreat,
      threatType: threatType,
      isRead: false,
      maliciousLinks: maliciousLinks,
    );
    _messages.insert(0, record);
    notifyListeners();
  }
}
