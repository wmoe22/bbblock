import 'dart:math';
import '../models/call_record.dart';
import '../models/sms_record.dart';
import '../models/blocking_stats.dart';

class MockDataService {
  static final _random = Random();

  static final List<String> _phoneNumbers = [
    '+1 (555) 012-3456',
    '+1 (555) 987-6543',
    '+1 (555) 246-8135',
    '+1 (555) 369-2580',
    '+1 (555) 147-2589',
    '+1 (555) 753-9514',
    '+1 (555) 864-2097',
    '+1 (555) 321-6547',
    '+1 (555) 159-7530',
    '+1 (555) 486-2073',
    '+1 (555) 628-4190',
    '+1 (555) 973-5168',
    '+44 20 7946 0958',
    '+44 20 7946 1234',
    '+91 98765 43210',
    'Unknown Number',
    'Private Number',
  ];

  static final List<Map<String, String>> _categories = [
    {'category': 'Scam', 'threat': 'High'},
    {'category': 'Scam', 'threat': 'High'},
    {'category': 'Scam', 'threat': 'High'},
    {'category': 'Telemarketing', 'threat': 'Medium'},
    {'category': 'Telemarketing', 'threat': 'Medium'},
    {'category': 'Finance', 'threat': 'Medium'},
    {'category': 'Finance', 'threat': 'Low'},
    {'category': 'Fundraising', 'threat': 'Low'},
    {'category': 'Services', 'threat': 'Low'},
    {'category': 'Healthcare', 'threat': 'None'},
    {'category': 'Government', 'threat': 'None'},
    {'category': 'Safe', 'threat': 'None'},
    {'category': 'Unknown', 'threat': 'Medium'},
  ];

  static final List<String> _scamNames = [
    'IRS Impersonator',
    'Tech Support Scam',
    'Warranty Scam',
    'Prize Winner Scam',
    'Bank Fraud Alert',
    'Social Security Scam',
    'Crypto Investment Scam',
  ];

  static final List<String> _telemarketingNames = [
    'Solar Panel Sales',
    'Insurance Offer',
    'Car Warranty Extended',
    'Credit Card Promotion',
    'Home Security Sales',
    'Internet Provider Offer',
  ];

  static List<CallRecord> generateCallHistory({int count = 30}) {
    final List<CallRecord> calls = [];
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final catInfo = _categories[_random.nextInt(_categories.length)];
      final category = catInfo['category']!;
      final threat = catInfo['threat']!;
      final phone = _phoneNumbers[_random.nextInt(_phoneNumbers.length)];

      String? name;
      if (category == 'Scam') {
        name = _scamNames[_random.nextInt(_scamNames.length)];
      } else if (category == 'Telemarketing') {
        name = _telemarketingNames[_random.nextInt(_telemarketingNames.length)];
      }

      final hoursAgo = _random.nextInt(168); // up to 7 days
      final blocked = (category == 'Scam' && _random.nextDouble() > 0.3) ||
          (category == 'Telemarketing' && _random.nextDouble() > 0.5);

      calls.add(CallRecord(
        phoneNumber: phone,
        contactName: name,
        category: category,
        threatLevel: threat,
        timestamp: now.subtract(Duration(hours: hoursAgo, minutes: _random.nextInt(60))),
        wasBlocked: blocked,
        isIncoming: true,
        duration: blocked ? null : Duration(seconds: _random.nextInt(300)),
      ));
    }

    calls.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return calls;
  }

  static List<SmsRecord> generateSmsHistory({int count = 15}) {
    final List<SmsRecord> messages = [];
    final now = DateTime.now();

    final spamMessages = [
      SmsRecord(
        sender: '+1 (555) 012-9999',
        body: 'URGENT: Your bank account has been compromised! Click here immediately to verify: http://fake-bank-verify.scam/login',
        timestamp: now.subtract(const Duration(hours: 2)),
        isThreat: true,
        threatType: 'Phishing',
        maliciousLinks: ['http://fake-bank-verify.scam/login'],
      ),
      SmsRecord(
        sender: '+1 (555) 888-0001',
        body: 'Congratulations! You\'ve won a \$1000 gift card! Claim now: http://free-prizes.scam/claim?id=12345',
        timestamp: now.subtract(const Duration(hours: 5)),
        isThreat: true,
        threatType: 'Prize Scam',
        maliciousLinks: ['http://free-prizes.scam/claim?id=12345'],
      ),
      SmsRecord(
        sender: '+1 (555) 777-0002',
        body: 'Your package delivery failed. Update your address: http://delivery-update.scam/track',
        timestamp: now.subtract(const Duration(hours: 8)),
        isThreat: true,
        threatType: 'Delivery Scam',
        maliciousLinks: ['http://delivery-update.scam/track'],
      ),
      SmsRecord(
        sender: '+44 20 7946 5555',
        body: 'HMRC: You are owed a tax refund of £849.50. Claim here: http://hmrc-refund.scam/claim',
        timestamp: now.subtract(const Duration(days: 1)),
        isThreat: true,
        threatType: 'Tax Scam',
        maliciousLinks: ['http://hmrc-refund.scam/claim'],
      ),
      SmsRecord(
        sender: '+1 (555) 666-0003',
        body: 'Your Apple ID is locked. Verify immediately: http://apple-verify.scam/id',
        timestamp: now.subtract(const Duration(days: 1, hours: 6)),
        isThreat: true,
        threatType: 'Phishing',
        maliciousLinks: ['http://apple-verify.scam/id'],
      ),
      SmsRecord(
        sender: '+1 (555) 444-0004',
        body: 'Special offer! Get 90% off all products today only. Visit: http://deals-shop.spam/offer',
        timestamp: now.subtract(const Duration(days: 2)),
        isThreat: true,
        threatType: 'Spam',
        maliciousLinks: ['http://deals-shop.spam/offer'],
      ),
    ];

    final safeMessages = [
      SmsRecord(
        sender: 'Your Bank',
        body: 'Your transaction of \$45.00 at Coffee Shop was approved. If you did not make this transaction, call us immediately.',
        timestamp: now.subtract(const Duration(hours: 1)),
        isThreat: false,
      ),
      SmsRecord(
        sender: 'Doctor Office',
        body: 'Reminder: Your appointment is scheduled for tomorrow at 2:30 PM. Reply YES to confirm or NO to cancel.',
        timestamp: now.subtract(const Duration(hours: 4)),
        isThreat: false,
      ),
      SmsRecord(
        sender: '+1 (555) 321-6547',
        body: 'Hey! Are we still on for dinner tonight? Let me know!',
        timestamp: now.subtract(const Duration(hours: 6)),
        isThreat: false,
      ),
    ];

    messages.addAll(spamMessages);
    messages.addAll(safeMessages);
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return messages.take(count).toList();
  }

  static BlockingStats generateStats({String period = 'Week'}) {
    final now = DateTime.now();
    int count;
    int stepDays;
    switch (period) {
      case 'Week':
        count = 7;
        stepDays = 1;
        break;
      case 'Month':
        count = 6;
        stepDays = 5;
        break;
      case 'Year':
        count = 12;
        stepDays = 30;
        break;
      default:
        count = 7;
        stepDays = 1;
    }

    final dailyStats = List.generate(count, (i) {
      return DailyStats(
        date: now.subtract(Duration(days: (count - 1 - i) * stepDays)),
        blocked: _random.nextInt(15) + 3,
        identified: _random.nextInt(18) + 5,
      );
    });

    final totalBlocked = dailyStats.fold(0, (sum, s) => sum + s.blocked);
    final scam = (totalBlocked * 0.45).round();
    final telemarketing = (totalBlocked * 0.35).round();
    final other = (totalBlocked - scam - telemarketing).clamp(0, totalBlocked);
    final sms = _random.nextInt(10) + 5;

    return BlockingStats(
      totalBlocked: totalBlocked,
      scamBlocked: scam,
      telemarketingBlocked: telemarketing,
      otherBlocked: other,
      smsBlocked: sms,
      dailyStats: dailyStats,
    );
  }
}
