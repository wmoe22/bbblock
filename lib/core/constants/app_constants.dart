class AppConstants {
  static const String appName = 'HangUp';
  static const String appTagline = 'Block spam. Stop scams.';
  static const String appVersion = '1.0.0';
  
  // Call categories
  static const String categoryScam = 'Scam';
  static const String categoryTelemarketing = 'Telemarketing';
  static const String categoryFinance = 'Finance';
  static const String categoryFundraising = 'Fundraising';
  static const String categoryServices = 'Services';
  static const String categoryHealthcare = 'Healthcare';
  static const String categoryGovernment = 'Government';
  static const String categoryUnknown = 'Unknown';
  static const String categorySafe = 'Safe';
  
  // Threat levels
  static const String threatHigh = 'High';
  static const String threatMedium = 'Medium';
  static const String threatLow = 'Low';
  static const String threatNone = 'None';
  
  // Time periods for stats
  static const String periodWeek = 'Week';
  static const String periodMonth = 'Month';
  static const String periodYear = 'Year';
  static const String periodAll = 'All Time';
  
  // Shared preferences keys
  static const String keyAutoBlockScam = 'auto_block_scam';
  static const String keyAutoBlockTelemarketing = 'auto_block_telemarketing';
  static const String keyCallScreening = 'call_screening';
  static const String keySmsProtection = 'sms_protection';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyBlockedCalls = 'blocked_calls';
  static const String keyCallHistory = 'call_history';
  static const String keyBlockedNumbers = 'blocked_numbers';
}
