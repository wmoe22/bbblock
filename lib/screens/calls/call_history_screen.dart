import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/call_provider.dart';
import '../../widgets/recent_call_tile.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  String _filter = 'All';
  final List<String> _filters = ['All', 'Blocked', 'Scam', 'Telemarketing', 'Safe'];

  @override
  Widget build(BuildContext context) {
    return Consumer<CallProvider>(
      builder: (context, provider, _) {
        final filteredCalls = _getFilteredCalls(provider);

        return Column(
          children: [
            // Filter chips
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _filter == filter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filter = filter),
                    backgroundColor: AppTheme.cardDark,
                    selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.dividerColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Call list
            Expanded(
              child: filteredCalls.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_missed_rounded,
                              size: 48, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No calls found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredCalls.length,
                      itemBuilder: (context, index) {
                        return RecentCallTile(call: filteredCalls[index])
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: index * 30),
                              duration: 300.ms,
                            );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  List<dynamic> _getFilteredCalls(CallProvider provider) {
    switch (_filter) {
      case 'Blocked':
        return provider.callHistory.where((c) => c.wasBlocked).toList();
      case 'Scam':
        return provider.callHistory.where((c) => c.category == 'Scam').toList();
      case 'Telemarketing':
        return provider.callHistory.where((c) => c.category == 'Telemarketing').toList();
      case 'Safe':
        return provider.callHistory.where((c) => c.category == 'Safe' || c.threatLevel == 'None').toList();
      default:
        return provider.callHistory;
    }
  }
}
