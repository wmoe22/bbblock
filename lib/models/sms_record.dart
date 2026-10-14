import 'package:uuid/uuid.dart';

class SmsRecord {
  final String id;
  final String sender;
  final String body;
  final DateTime timestamp;
  final bool isThreat;
  final String? threatType;
  final bool isRead;
  final List<String> maliciousLinks;

  SmsRecord({
    String? id,
    required this.sender,
    required this.body,
    DateTime? timestamp,
    this.isThreat = false,
    this.threatType,
    this.isRead = false,
    this.maliciousLinks = const [],
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get preview {
    if (body.length <= 60) return body;
    return '${body.substring(0, 57)}...';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'isThreat': isThreat,
        'threatType': threatType,
        'isRead': isRead,
        'maliciousLinks': maliciousLinks,
      };

  factory SmsRecord.fromJson(Map<String, dynamic> json) => SmsRecord(
        id: json['id'] as String,
        sender: json['sender'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isThreat: json['isThreat'] as bool? ?? false,
        threatType: json['threatType'] as String?,
        isRead: json['isRead'] as bool? ?? false,
        maliciousLinks: (json['maliciousLinks'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}
