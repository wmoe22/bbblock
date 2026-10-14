import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

enum ChannelType {
  call,
  sms,
  instagram,
  twitter,
  facebook,
  whatsapp,
  email,
  webhook,
}

extension ChannelTypeExtension on ChannelType {
  String get displayName {
    switch (this) {
      case ChannelType.call:
        return 'Voice Call';
      case ChannelType.sms:
        return 'SMS';
      case ChannelType.instagram:
        return 'Instagram DM';
      case ChannelType.twitter:
        return 'Twitter / X';
      case ChannelType.facebook:
        return 'Facebook Messenger';
      case ChannelType.whatsapp:
        return 'WhatsApp';
      case ChannelType.email:
        return 'Email';
      case ChannelType.webhook:
        return 'Custom Webhook';
    }
  }

  IconData get icon {
    switch (this) {
      case ChannelType.call:
        return Icons.phone_rounded;
      case ChannelType.sms:
        return Icons.sms_rounded;
      case ChannelType.instagram:
        return Icons.camera_alt_rounded;
      case ChannelType.twitter:
        return Icons.tag_rounded;
      case ChannelType.facebook:
        return Icons.chat_bubble_outline_rounded;
      case ChannelType.whatsapp:
        return Icons.chat_rounded;
      case ChannelType.email:
        return Icons.alternate_email_rounded;
      case ChannelType.webhook:
        return Icons.api_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ChannelType.call:
        return AppTheme.primaryBlue;
      case ChannelType.sms:
        return const Color(0xFF2FB36B);
      case ChannelType.instagram:
        return const Color(0xFFE1306C);
      case ChannelType.twitter:
        return const Color(0xFF1D8FE8);
      case ChannelType.facebook:
        return const Color(0xFF1877F2);
      case ChannelType.whatsapp:
        return const Color(0xFF25B85C);
      case ChannelType.email:
        return const Color(0xFFF59E0B);
      case ChannelType.webhook:
        return const Color(0xFF7061E8);
    }
  }

  String get defaultSource {
    switch (this) {
      case ChannelType.instagram:
      case ChannelType.twitter:
      case ChannelType.facebook:
        return 'Notification Listener / Pipedream';
      case ChannelType.call:
      case ChannelType.sms:
        return 'Telephony / Twilio';
      case ChannelType.whatsapp:
      case ChannelType.email:
      case ChannelType.webhook:
        return 'Pipedream Webhook';
    }
  }
}
