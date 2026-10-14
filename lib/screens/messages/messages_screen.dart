import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/sms_provider.dart';
import '../../models/sms_record.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SmsProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppTheme.onPrimary,
                unselectedLabelColor: AppTheme.textSecondary,
                dividerHeight: 0,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 18),
                        const SizedBox(width: 6),
                        const Text('Threats'),
                        if (provider.unreadThreats > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${provider.unreadThreats}',
                              style: TextStyle(
                                color: AppTheme.onError,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Safe'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Message lists
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMessageList(
                    provider.threatMessages,
                    provider,
                    isThreat: true,
                  ),
                  _buildMessageList(
                    provider.safeMessages,
                    provider,
                    isThreat: false,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageList(
    List<SmsRecord> messages,
    SmsProvider provider, {
    required bool isThreat,
  }) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isThreat ? Icons.shield_rounded : Icons.mark_email_read_rounded,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              isThreat ? 'No threats detected' : 'No safe messages',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return _buildMessageTile(context, msg, provider).animate().fadeIn(
          delay: Duration(milliseconds: index * 50),
          duration: 300.ms,
        );
      },
    );
  }

  Widget _buildMessageTile(
    BuildContext context,
    SmsRecord msg,
    SmsProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        provider.markAsRead(msg.id);
        _showMessageDetail(context, msg, provider);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: msg.isThreat
                ? AppTheme.accentRed.withValues(alpha: 0.3)
                : AppTheme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                    (msg.isThreat ? AppTheme.accentRed : AppTheme.accentGreen)
                        .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                msg.isThreat ? Icons.sms_failed_rounded : Icons.sms_rounded,
                color: msg.isThreat ? AppTheme.accentRed : AppTheme.accentGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          msg.sender,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (msg.threatType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            msg.threatType!,
                            style: TextStyle(
                              color: AppTheme.accentRed,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.preview,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.formattedTime,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            if (!msg.isRead && msg.isThreat)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMessageDetail(
    BuildContext context,
    SmsRecord msg,
    SmsProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          (msg.isThreat
                                  ? AppTheme.accentRed
                                  : AppTheme.accentGreen)
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      msg.isThreat
                          ? Icons.warning_rounded
                          : Icons.check_circle_rounded,
                      color: msg.isThreat
                          ? AppTheme.accentRed
                          : AppTheme.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.sender,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (msg.threatType != null)
                          Text(
                            'Threat: ${msg.threatType}',
                            style: TextStyle(
                              color: AppTheme.accentRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Safe view message body
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: msg.isThreat
                        ? AppTheme.accentRed.withValues(alpha: 0.3)
                        : AppTheme.dividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (msg.isThreat && provider.safeViewEnabled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_off_rounded,
                              color: AppTheme.accentOrange,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Safe View - Links are disabled',
                              style: TextStyle(
                                color: AppTheme.accentOrange,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      msg.body,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Malicious links warning
              if (msg.maliciousLinks.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accentRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.link_off_rounded,
                            color: AppTheme.accentRed,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Malicious Links Detected',
                            style: TextStyle(
                              color: AppTheme.accentRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...msg.maliciousLinks.map(
                        (link) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            link,
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
