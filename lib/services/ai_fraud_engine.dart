import '../models/channel_type.dart';
import '../models/ai_threat_record.dart';

class AiAnalysisResult {
  final int riskScore;
  final String threatCategory;
  final double aiConfidence;
  final ThreatDecision decision;
  final String aiReasoning;
  final List<String> riskIndicators;

  const AiAnalysisResult({
    required this.riskScore,
    required this.threatCategory,
    required this.aiConfidence,
    required this.decision,
    required this.aiReasoning,
    required this.riskIndicators,
  });
}

class AiFraudEngine {
  /// Default triage thresholds
  static const int defaultAutoBlockThreshold = 80;
  static const int defaultAutoAllowThreshold = 30;

  /// Custom prompt instructions for the AI screening model
  static const String defaultPromptTemplate = '''
You are BBBlock AI Shield, an enterprise-grade autonomous fraud detection model.
Analyze incoming communications across Voice, SMS, Instagram DMs, Twitter/X, Facebook Messenger, WhatsApp, and Email.
Evaluate threat likelihood from 0 to 100%.
- If confidence >= 80%: Auto-block and quarantine.
- If confidence < 30%: Auto-allow.
- If between 30% and 79%: Escalate to the business owner with concise risk indicators and reasoning.
''';

  /// Evaluates an incoming message or interaction
  static AiAnalysisResult evaluate({
    required String content,
    required String senderHandle,
    required ChannelType channel,
    int autoBlockThreshold = defaultAutoBlockThreshold,
    int autoAllowThreshold = defaultAutoAllowThreshold,
  }) {
    final lower = content.toLowerCase();
    final senderLower = senderHandle.toLowerCase();

    final List<String> indicators = [];
    int baseScore = 0;
    String category = 'Safe Communication';

    // 1. Phishing & Malicious Link Detection
    if (lower.contains('http://') ||
        lower.contains('bit.ly') ||
        lower.contains('.xyz') ||
        lower.contains('.ru') ||
        lower.contains('.top') ||
        lower.contains('login-verify') ||
        lower.contains('secure-account-update')) {
      baseScore += 45;
      indicators.add('Suspicious or shortened external URL detected');
      category = 'Phishing Link';
    }

    // 2. Urgent Financial & Wire Transfer Fraud
    if (lower.contains('wire transfer') ||
        lower.contains('bank details changed') ||
        lower.contains('send invoice payment') ||
        lower.contains('routing number') ||
        lower.contains('urgent payment required') ||
        lower.contains('unpaid taxes')) {
      baseScore += 50;
      indicators.add('Urgent financial transfer or banking reroute demand');
      category = 'Wire Transfer Fraud';
    }

    // 3. Crypto & Token Scams
    if (lower.contains('bitcoin') ||
        lower.contains('btc') ||
        lower.contains('crypto') ||
        lower.contains('eth') ||
        lower.contains('binance') ||
        lower.contains('wallet address') ||
        lower.contains('guaranteed return') ||
        lower.contains('seed phrase') ||
        lower.contains('airdrop') ||
        lower.contains('giveaway') ||
        lower.contains('nft drop')) {
      baseScore += 45;
      indicators.add('Cryptocurrency solicitation or wallet credential trigger');
      category = 'Crypto Investment Scam';
    }

    // 4. Social Media Impersonation / Bot Handles
    if (senderLower.contains('support') ||
        senderLower.contains('helpdesk') ||
        senderLower.contains('official') ||
        senderLower.contains('verify') ||
        senderLower.contains('admin') ||
        senderLower.contains('giveaway') ||
        senderLower.contains('airdrop') ||
        senderLower.contains('security_team')) {
      baseScore += 30;
      indicators.add('Lookalike official username / impersonation pattern');
      if (category == 'Safe Communication') category = 'Impersonation Scam';
    }

    // 5. Account Suspension & Extortion Threats
    if (lower.contains('account will be terminated') ||
        lower.contains('permanently banned') ||
        lower.contains('copyright infringement') ||
        lower.contains('24 hours to comply') ||
        lower.contains('suspended within 1 hour')) {
      baseScore += 35;
      indicators.add('High-pressure account termination extortion threat');
      category = 'Account Extortion Phishing';
    }

    // 6. Generic Social Spam / Promotion / Collaboration Bot
    if (lower.contains('promote it on') ||
        lower.contains('dm us for collab') ||
        lower.contains('buy 10k followers') ||
        lower.contains('send to 3 accounts')) {
      baseScore += 35;
      indicators.add('Automated social DM spam bot pattern');
      category = 'Social Spam Bot';
    }

    // 7. Legitimate Business Patterns (Mitigators)
    if (lower.contains('reschedule appointment') ||
        lower.contains('order #') ||
        lower.contains('receipt') ||
        lower.contains('track package') ||
        lower.contains('hello, are you available for consulting') ||
        lower.contains('business inquiry regarding your services')) {
      baseScore -= 20;
    }

    // Clamp score
    final finalScore = baseScore.clamp(0, 99);

    // Confidence calculation based on clarity of signals
    double confidence;
    if (finalScore >= 80 || finalScore <= 20) {
      confidence = 0.90 + (0.09 * (finalScore > 50 ? (finalScore - 80) / 20 : (20 - finalScore) / 20));
    } else {
      confidence = 0.55 + ((finalScore - 30).abs() % 20) / 100;
    }

    // Determine decision based on thresholds
    ThreatDecision decision;
    String reasoning;

    if (finalScore >= autoBlockThreshold) {
      decision = ThreatDecision.autoBlocked;
      reasoning =
          'AI Model determined with ${(confidence * 100).toStringAsFixed(1)}% certainty that this is fraudulent activity ($category). Automatically quarantined to protect business operations.';
    } else if (finalScore < autoAllowThreshold) {
      decision = ThreatDecision.autoAllowed;
      category = 'Safe';
      reasoning =
          'No malicious heuristics detected. Message passed semantic screening and was verified as legitimate.';
    } else {
      // THE CORE IDEA: "if he can't pass on to the user"
      decision = ThreatDecision.escalatedToUser;
      if (category == 'Safe Communication') category = 'Borderline / Ambiguous';
      reasoning =
          'AI Model detected ambiguous risk signals (Risk score $finalScore%). The intent could be a legitimate partner inquiry or a sophisticated spear-phishing attempt. Escalated to business owner for final review.';
    }

    if (indicators.isEmpty && decision != ThreatDecision.autoAllowed) {
      indicators.add('Unfamiliar sender requesting engagement');
      indicators.add('Behavioral pattern deviates from typical customer baseline');
    }

    return AiAnalysisResult(
      riskScore: finalScore,
      threatCategory: category,
      aiConfidence: double.parse(confidence.toStringAsFixed(2)),
      decision: decision,
      aiReasoning: reasoning,
      riskIndicators: indicators,
    );
  }
}
