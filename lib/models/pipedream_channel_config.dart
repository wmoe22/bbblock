import 'channel_type.dart';

enum IntegrationMode {
  notificationListener,
  pipedreamWebhook,
  emailRelay,
  telephonyDirect,
}

extension IntegrationModeExtension on IntegrationMode {
  String get displayName {
    switch (this) {
      case IntegrationMode.notificationListener:
        return 'Android Notification Interceptor (Zero API)';
      case IntegrationMode.pipedreamWebhook:
        return 'Pipedream Webhook / OAuth';
      case IntegrationMode.emailRelay:
        return 'Inbound Email Forwarding Relay';
      case IntegrationMode.telephonyDirect:
        return 'Twilio / Mobile Carrier';
    }
  }

  String get description {
    switch (this) {
      case IntegrationMode.notificationListener:
        return 'Intercepts DM notifications on device. Works for personal accounts without Meta/Twitter developer keys.';
      case IntegrationMode.pipedreamWebhook:
        return 'Receives live events from Pipedream workflows connected to business pages and developer APIs.';
      case IntegrationMode.emailRelay:
        return 'Forwards email DM alerts (e.g. from Instagram/Twitter) into Pipedream for instant cloud screening.';
      case IntegrationMode.telephonyDirect:
        return 'Direct carrier and Twilio call screening and spam database lookup.';
    }
  }
}

class PipedreamChannelConfig {
  final ChannelType channel;
  final bool isEnabled;
  final IntegrationMode mode;
  final String webhookEndpoint;
  final int totalScanned;
  final int totalBlocked;
  final int totalEscalated;
  final DateTime? lastActiveAt;

  const PipedreamChannelConfig({
    required this.channel,
    this.isEnabled = true,
    required this.mode,
    required this.webhookEndpoint,
    this.totalScanned = 0,
    this.totalBlocked = 0,
    this.totalEscalated = 0,
    this.lastActiveAt,
  });

  PipedreamChannelConfig copyWith({
    ChannelType? channel,
    bool? isEnabled,
    IntegrationMode? mode,
    String? webhookEndpoint,
    int? totalScanned,
    int? totalBlocked,
    int? totalEscalated,
    DateTime? lastActiveAt,
  }) {
    return PipedreamChannelConfig(
      channel: channel ?? this.channel,
      isEnabled: isEnabled ?? this.isEnabled,
      mode: mode ?? this.mode,
      webhookEndpoint: webhookEndpoint ?? this.webhookEndpoint,
      totalScanned: totalScanned ?? this.totalScanned,
      totalBlocked: totalBlocked ?? this.totalBlocked,
      totalEscalated: totalEscalated ?? this.totalEscalated,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
