import 'dart:convert';
import '../models/channel_type.dart';
import '../models/ai_threat_record.dart';
import '../models/pipedream_channel_config.dart';

class PipedreamService {
  static const String defaultWebhookBase = 'https://eoworkflow.m.pipedream.net/bbblock-fraud-guard';

  /// Generates initial channel configurations for all communication channels
  static List<PipedreamChannelConfig> getDefaultChannelConfigs() {
    return [
      const PipedreamChannelConfig(
        channel: ChannelType.instagram,
        isEnabled: true,
        mode: IntegrationMode.notificationListener,
        webhookEndpoint: '$defaultWebhookBase/instagram-inbound',
        totalScanned: 24,
        totalBlocked: 9,
        totalEscalated: 3,
      ),
      const PipedreamChannelConfig(
        channel: ChannelType.twitter,
        isEnabled: true,
        mode: IntegrationMode.notificationListener,
        webhookEndpoint: '$defaultWebhookBase/twitter-inbound',
        totalScanned: 18,
        totalBlocked: 7,
        totalEscalated: 2,
      ),
      const PipedreamChannelConfig(
        channel: ChannelType.facebook,
        isEnabled: true,
        mode: IntegrationMode.pipedreamWebhook,
        webhookEndpoint: '$defaultWebhookBase/facebook-inbound',
        totalScanned: 15,
        totalBlocked: 4,
        totalEscalated: 1,
      ),
      const PipedreamChannelConfig(
        channel: ChannelType.whatsapp,
        isEnabled: true,
        mode: IntegrationMode.pipedreamWebhook,
        webhookEndpoint: '$defaultWebhookBase/whatsapp-inbound',
        totalScanned: 31,
        totalBlocked: 6,
        totalEscalated: 2,
      ),
      const PipedreamChannelConfig(
        channel: ChannelType.email,
        isEnabled: true,
        mode: IntegrationMode.emailRelay,
        webhookEndpoint: '$defaultWebhookBase/email-relay',
        totalScanned: 42,
        totalBlocked: 14,
        totalEscalated: 4,
      ),
      const PipedreamChannelConfig(
        channel: ChannelType.call,
        isEnabled: true,
        mode: IntegrationMode.telephonyDirect,
        webhookEndpoint: '$defaultWebhookBase/voice-twilio',
        totalScanned: 63,
        totalBlocked: 28,
        totalEscalated: 3,
      ),
      const PipedreamChannelConfig(
        channel: ChannelType.sms,
        isEnabled: true,
        mode: IntegrationMode.telephonyDirect,
        webhookEndpoint: '$defaultWebhookBase/sms-twilio',
        totalScanned: 57,
        totalBlocked: 19,
        totalEscalated: 2,
      ),
      const PipedreamChannelConfig(
        channel: ChannelType.webhook,
        isEnabled: true,
        mode: IntegrationMode.pipedreamWebhook,
        webhookEndpoint: '$defaultWebhookBase/universal-inbound',
        totalScanned: 12,
        totalBlocked: 3,
        totalEscalated: 1,
      ),
    ];
  }

  /// Initial cross-channel mock dataset showcasing:
  /// 1. Auto-blocked items (High confidence)
  /// 2. Pending escalations ("if he can't pass on to the user")
  /// 3. Allowed items
  static List<AiThreatRecord> getInitialRecords() {
    final now = DateTime.now();

    return [
      // 1. PENDING ESCALATION: Twitter / X DM Sponsorship inquiry
      AiThreatRecord(
        channel: ChannelType.twitter,
        senderHandle: '@tech_nexus_media',
        senderDisplayName: 'Tech Nexus Marketing',
        content: 'Hi! We love your company profile. We have an exclusive paid brand promotion budget (\$2,500). Please review our attached campaign brief link: http://tech-nexus-brief.xyz/pdf-download',
        timestamp: now.subtract(const Duration(minutes: 12)),
        riskScore: 68,
        threatCategory: 'Suspicious Brand Collab / Link',
        aiConfidence: 0.72,
        decision: ThreatDecision.escalatedToUser,
        aiReasoning: 'Offer looks like a standard sponsorship offer, but URL uses unusual TLD (.xyz). The model cannot verify company legitimacy with high certainty. Escalated to owner.',
        riskIndicators: [
          'External unverified download link (.xyz)',
          'Account created recently with modest engagement',
          'High financial incentive offered immediately upfront',
        ],
        sourceMethod: 'Android Notification Listener',
      ),

      // 2. PENDING ESCALATION: Instagram DM Collaboration / Model agency
      AiThreatRecord(
        channel: ChannelType.instagram,
        senderHandle: '@aurora_creatives_mgmt',
        senderDisplayName: 'Aurora Creatives',
        content: 'Hey there! We are interested in ordering 50 units of your merchandise for a corporate gifting event next week. Can you send payment invoice details and your direct WhatsApp number?',
        timestamp: now.subtract(const Duration(minutes: 45)),
        riskScore: 54,
        threatCategory: 'Unverified Wholesale Lead',
        aiConfidence: 0.65,
        decision: ThreatDecision.escalatedToUser,
        aiReasoning: 'Legitimate-sounding corporate bulk purchase request, but requests moving communication off-platform to personal WhatsApp. AI cannot discern between real buyer or social engineering.',
        riskIndicators: [
          'Request to divert transaction off-platform',
          'Urgent timeline (next week delivery)',
          'Profile has 200 followers and 3 posts',
        ],
        sourceMethod: 'Android Notification Listener',
      ),

      // 3. PENDING ESCALATION: Email Vendor Banking Change
      AiThreatRecord(
        channel: ChannelType.email,
        senderHandle: 'billing@apex-logistics-supplies.com',
        senderDisplayName: 'Apex Logistics Billing',
        content: 'URGENT: Please be advised that our banking routing numbers have changed due to our annual audit. Remit outstanding invoice #8841 via wire transfer to our new account within 48h to avoid shipping delays.',
        timestamp: now.subtract(const Duration(hours: 2)),
        riskScore: 74,
        threatCategory: 'Potential BEC / Wire Fraud',
        aiConfidence: 0.78,
        decision: ThreatDecision.escalatedToUser,
        aiReasoning: 'High risk of Business Email Compromise (BEC). Urgently requesting wire transfer diversion, but sender domain matches previous vendor structure. Human verification required before paying.',
        riskIndicators: [
          'Urgent wire transfer redirection',
          'Audit pretext for bank account alteration',
          'Time pressure (48h deadline)',
        ],
        sourceMethod: 'Pipedream Email Relay',
      ),

      // 4. AUTO-BLOCKED: Instagram Crypto Scam
      AiThreatRecord(
        channel: ChannelType.instagram,
        senderHandle: '@elon_musk_airdrop_official_291',
        senderDisplayName: 'Tesla Community Airdrop',
        content: 'Congratulations! Your profile was selected in our weekly crypto giveaway. Claim 1.5 BTC right now at: http://claim-tesla-rewards.ru/auth?wallet=connect. Act fast before it expires in 15 mins!',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 15)),
        riskScore: 96,
        threatCategory: 'Crypto Investment Scam',
        aiConfidence: 0.98,
        decision: ThreatDecision.autoBlocked,
        aiReasoning: 'AI Model detected 100% textbook crypto giveaway phishing scheme. Known lookalike handle and high-risk credential harvester domain.',
        riskIndicators: [
          'Known phishing TLD (.ru)',
          'Celebrity impersonation pattern',
          'Cryptocurrency wallet connection hook',
        ],
        sourceMethod: 'Android Notification Listener',
      ),

      // 5. AUTO-BLOCKED: Facebook Messenger Impersonation
      AiThreatRecord(
        channel: ChannelType.facebook,
        senderHandle: 'Meta Business Support [Ticket #9914]',
        senderDisplayName: 'Meta Help Desk',
        content: 'Your Facebook Page has violated Community Guidelines regarding Intellectual Property. Your account will be permanently banned within 24 hours. Submit verification appeal here: http://meta-appeal-form.xyz/login',
        timestamp: now.subtract(const Duration(hours: 5)),
        riskScore: 94,
        threatCategory: 'Account Extortion Phishing',
        aiConfidence: 0.97,
        decision: ThreatDecision.autoBlocked,
        aiReasoning: 'Classic Meta Business impersonation phishing attempt. Auto-blocked and notification silenced.',
        riskIndicators: [
          'Fake copyright extortion prompt',
          '24-hour termination ultimatum',
          'Spoofed corporate login page',
        ],
        sourceMethod: 'Pipedream Webhook',
      ),

      // 6. AUTO-BLOCKED: Voice Call IRS Scam
      AiThreatRecord(
        channel: ChannelType.call,
        senderHandle: '+1 (555) 019-8321',
        senderDisplayName: 'Internal Revenue Impersonator',
        content: '[Voice Transcript]: This is Agent Davis from the Federal Tax Division. A warrant has been issued for your arrest due to unpaid back taxes. Press 1 to speak with an agent immediately to settle via digital payment.',
        timestamp: now.subtract(const Duration(hours: 6)),
        riskScore: 98,
        threatCategory: 'Government Impersonation Fraud',
        aiConfidence: 0.99,
        decision: ThreatDecision.autoBlocked,
        aiReasoning: 'Known scam phone number in national blacklist. Voice transcript contains aggressive extortion phrasing.',
        riskIndicators: [
          'Number listed in 14 community scam reports',
          'False arrest threat pretense',
          'Unusual payment method demand',
        ],
        sourceMethod: 'Twilio Carrier Screening',
      ),

      // 7. AUTO-ALLOWED: WhatsApp Client Inquiry
      AiThreatRecord(
        channel: ChannelType.whatsapp,
        senderHandle: '+1 (555) 382-9901',
        senderDisplayName: 'Dr. Sarah Mitchell',
        content: 'Hi! Could we reschedule our consulting appointment tomorrow to 3:30 PM? Let me know if that works for your team.',
        timestamp: now.subtract(const Duration(hours: 7)),
        riskScore: 12,
        threatCategory: 'Safe Customer Message',
        aiConfidence: 0.95,
        decision: ThreatDecision.autoAllowed,
        aiReasoning: 'Legitimate conversational context, no malicious links, verified contact history.',
        riskIndicators: [],
        sourceMethod: 'Pipedream Webhook',
      ),

      // 8. AUTO-BLOCKED: SMS Phishing Link
      AiThreatRecord(
        channel: ChannelType.sms,
        senderHandle: '+1 (555) 777-9911',
        senderDisplayName: 'Chase Fraud Alert (Spoofed)',
        content: 'CHASE ALERT: Suspicious debit attempt of \$892.40 detected. If this was not you, lock card immediately: http://chase-security-check.top/lock',
        timestamp: now.subtract(const Duration(hours: 8)),
        riskScore: 92,
        threatCategory: 'Bank Phishing Link',
        aiConfidence: 0.96,
        decision: ThreatDecision.autoBlocked,
        aiReasoning: 'Phishing domain detected mimicking national financial institution.',
        riskIndicators: [
          'Spoofed banking identity',
          'Malicious link (.top)',
        ],
        sourceMethod: 'Twilio Carrier Screening',
      ),
    ];
  }

  /// Dispatches an action back to Pipedream (e.g. Block / Whitelist sync)
  static Future<bool> syncActionToPipedream({
    required String action,
    required ChannelType channel,
    required String senderHandle,
    required int riskScore,
    String? note,
  }) async {
    // In a real environment, this makes an HTTP POST to the Pipedream webhook endpoint
    // e.g. await http.post(Uri.parse(webhookUrl), body: jsonEncode({...}));
    // We simulate instantaneous network latency:
    await Future.delayed(const Duration(milliseconds: 350));
    return true;
  }

  /// Generates Pipedream workflow code snippet for developer reference
  static String getPipedreamNodeSnippet(ChannelType channel) {
    final channelName = channel.displayName;
    return '''
// Pipedream Component for $channelName
import { axios } from "@pipedream/platform";

export default defineComponent({
  async run({ steps, \$ }) {
    const event = steps.trigger.event;
    
    // 1. Extract message & sender
    const payload = {
      channel: "${channel.name}",
      senderHandle: event.sender?.username || event.from,
      senderDisplayName: event.sender?.name,
      content: event.message?.text || event.body,
      timestamp: new Date().toISOString(),
      source: "pipedream_webhook"
    };

    // 2. Relay to BBBlock AI Fraud Guard App
    const response = await axios(\$, {
      method: "POST",
      url: "https://api.bbblock.app/v1/screen",
      data: payload
    });

    // 3. If AI Auto-Blocks or User Blocked -> Take Countermeasure
    if (response.decision === "autoBlocked" || response.decision === "userBlocked") {
      // Mute user or flag as spam in ${channel.displayName}
      console.log(`[BBBlock] Blocked scammer \${payload.senderHandle}`);
    }

    return response;
  },
});
''';
  }
}
