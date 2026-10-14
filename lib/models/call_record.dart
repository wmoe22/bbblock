import 'package:uuid/uuid.dart';

class CallRecord {
  final String id;
  final String phoneNumber;
  final String? contactName;
  final String category;
  final String threatLevel;
  final DateTime timestamp;
  final bool wasBlocked;
  final bool isIncoming;
  final Duration? duration;

  CallRecord({
    String? id,
    required this.phoneNumber,
    this.contactName,
    required this.category,
    required this.threatLevel,
    DateTime? timestamp,
    this.wasBlocked = false,
    this.isIncoming = true,
    this.duration,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  String get displayName => contactName ?? phoneNumber;

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
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'contactName': contactName,
        'category': category,
        'threatLevel': threatLevel,
        'timestamp': timestamp.toIso8601String(),
        'wasBlocked': wasBlocked,
        'isIncoming': isIncoming,
        'duration': duration?.inSeconds,
      };

  factory CallRecord.fromJson(Map<String, dynamic> json) => CallRecord(
        id: json['id'] as String,
        phoneNumber: json['phoneNumber'] as String,
        contactName: json['contactName'] as String?,
        category: json['category'] as String,
        threatLevel: json['threatLevel'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        wasBlocked: json['wasBlocked'] as bool? ?? false,
        isIncoming: json['isIncoming'] as bool? ?? true,
        duration: json['duration'] != null
            ? Duration(seconds: json['duration'] as int)
            : null,
      );
}
