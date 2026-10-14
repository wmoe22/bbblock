import 'package:flutter_test/flutter_test.dart';
import 'package:hangup_clone/models/channel_type.dart';
import 'package:hangup_clone/models/ai_threat_record.dart';
import 'package:hangup_clone/services/ai_fraud_engine.dart';
import 'package:hangup_clone/providers/fraud_guard_provider.dart';

void main() {
  group('AiFraudEngine Tests', () {
    test('High confidence scam is auto-blocked (Score >= 80)', () {
      final result = AiFraudEngine.evaluate(
        channel: ChannelType.instagram,
        senderHandle: '@crypto_airdrop_giveaway_official',
        content: 'Claim 2.5 BTC right now at http://tesla-airdrop.ru/auth?wallet=connect before it expires!',
      );

      expect(result.decision, equals(ThreatDecision.autoBlocked));
      expect(result.riskScore, greaterThanOrEqualTo(80));
      expect(result.threatCategory, contains('Crypto'));
      expect(result.riskIndicators.isNotEmpty, isTrue);
    });

    test('Ambiguous interaction is escalated to the user ("if he cannot decide, pass to user")', () {
      final result = AiFraudEngine.evaluate(
        channel: ChannelType.twitter,
        senderHandle: '@tech_brand_sponsor',
        content: 'Hello! We have an exclusive paid brand promotion budget. Review our brief at http://tech-deck.xyz/brief',
      );

      // 30% <= riskScore < 80% -> Escalated to user!
      expect(result.decision, equals(ThreatDecision.escalatedToUser));
      expect(result.riskScore, greaterThanOrEqualTo(30));
      expect(result.riskScore, lessThan(80));
      expect(result.aiReasoning, contains('Escalated'));
    });

    test('Clean customer message is auto-allowed (Score < 30)', () {
      final result = AiFraudEngine.evaluate(
        channel: ChannelType.whatsapp,
        senderHandle: '+1 (555) 302-9911',
        content: 'Hello, could we please reschedule our consulting appointment to tomorrow at 2 PM?',
      );

      expect(result.decision, equals(ThreatDecision.autoAllowed));
      expect(result.riskScore, lessThan(30));
    });
  });

  group('FraudGuardProvider Tests', () {
    test('Provider tracks escalations and resolves them with Pipedream sync', () async {
      final provider = FraudGuardProvider();
      await provider.loadData();

      final initialPending = provider.pendingEscalationsCount;
      expect(initialPending, greaterThan(0));

      final firstEscalation = provider.pendingEscalations.first;

      // User decides to block it
      await provider.resolveEscalation(firstEscalation.id, true);

      expect(provider.pendingEscalationsCount, equals(initialPending - 1));
      final updated = provider.allRecords.firstWhere((r) => r.id == firstEscalation.id);
      expect(updated.decision, equals(ThreatDecision.userBlocked));
      expect(updated.resolutionNote, contains('Pipedream'));
    });

    test('Provider ingests new cross-channel interactions correctly', () {
      final provider = FraudGuardProvider();

      final record = provider.processIncomingInteraction(
        channel: ChannelType.instagram,
        senderHandle: '@scam_bot_test',
        content: 'Your account will be permanently banned within 24 hours. Verify at http://meta-login.ru',
      );

      expect(record.decision, equals(ThreatDecision.autoBlocked));
      expect(provider.allRecords.first.id, equals(record.id));
    });
  });
}
