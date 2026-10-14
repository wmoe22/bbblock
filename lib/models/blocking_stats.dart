class BlockingStats {
  final int totalBlocked;
  final int scamBlocked;
  final int telemarketingBlocked;
  final int otherBlocked;
  final int smsBlocked;
  final List<DailyStats> dailyStats;

  const BlockingStats({
    this.totalBlocked = 0,
    this.scamBlocked = 0,
    this.telemarketingBlocked = 0,
    this.otherBlocked = 0,
    this.smsBlocked = 0,
    this.dailyStats = const [],
  });

  double get blockRate {
    if (totalBlocked == 0) return 0;
    return (scamBlocked + telemarketingBlocked) / totalBlocked * 100;
  }
}

class DailyStats {
  final DateTime date;
  final int blocked;
  final int identified;

  const DailyStats({
    required this.date,
    this.blocked = 0,
    this.identified = 0,
  });
}
