# HangUp Clone - Spam Call Blocker & Caller ID 🛡️

A faithful, modern cross-platform Flutter clone of **HangUp** (the spam and scam call blocker app developed by **Nord Security**).

---

## 📱 App Highlights & Features

### 1. 🛡️ Real-Time Caller Identification & Screening
- Identifies unknown callers before you answer.
- Categorizes incoming calls: **Scam**, **Telemarketing**, **Finance**, **Healthcare**, **Services**, **Government**, and **Safe**.
- Dynamic threat level analysis (**High**, **Medium**, **Low**, **None**).
- Prominent Caller ID dialog with risk badges and action buttons: **Block**, **Decline**, or **Answer**.

### 2. 🚫 Intelligent Auto-Blocking ("Set and Forget")
- Toggleable **Auto-Block Scams**: automatically silences/drops calls flagged as scams.
- Toggleable **Auto-Block Telemarketing**: prevents unwanted promotional calls from ringing.
- Manual blocklist management: easily block or unblock specific phone numbers directly from history or settings.

### 3. 💬 SMS Threat Protection & Safe View
- Automatically scans incoming text messages for malicious links, suspicious domains, and phishing attempts.
- **Safe View Mode**: disables links inside suspicious SMS to protect users from accidental clicks.
- Filter messages into **Threats** and **Safe** tabs with threat classification (e.g., Phishing, Prize Scam, Delivery Scam, Tax Scam).

### 4. 📊 Detailed Blocking Statistics & Visual Analytics
- Visualized breakdowns using interactive **FL Chart** charts.
- Bar charts tracking blocked vs. identified calls over time.
- Donut/pie distribution by call category.
- Filter statistics across **Week**, **Month**, and **Year** timeframes.

### 5. ⚡ Live Threat Simulator (Interactive Testing)
- Built-in simulation tool directly accessible via the top bar (`⚡`) or floating action button.
- Test in real-time:
  - 🚨 **Scam Call** (e.g. IRS Impersonator) -> triggers immediate auto-block or screening alert.
  - 📣 **Telemarketing Call** (e.g. Solar Panels / Warranty Promotion).
  - 🩺 **Verified Safe Call** (e.g. Clinic Appointment).
  - 💬 **Phishing SMS** -> triggers interception and Safe View warning banner.

### 6. 🎨 Apple-Grade Design System (Navy + White / Midnight + Black)
- **Light mode:** crisp white surfaces with deep navy ink and accents. **Dark mode:** true black canvas with midnight-navy surfaces and a luminous blue.
- Continuous-corner ("squircle") surfaces, hairline borders, soft depth and large collapsing titles.
- Floating glass tab bar, iOS-style grouped lists, segmented controls, bottom sheets and haptics.
- **Typography:** Inter is the main font (titles, labels, numbers, buttons) and Geist is the sub font (body copy, subtitles, captions). Build text styles with `AppFont.main(...)` / `AppFont.sub(...)` in `lib/core/theme/app_fonts.dart`.
- Design tokens live in `lib/core/theme/app_theme.dart`; reusable components in `lib/widgets/ui_kit.dart`.
- Smooth, restrained motion powered by `flutter_animate`.
- Intuitive onboarding carousel explaining core capabilities and privacy-first architecture.

---

## 🏗️ Architecture & Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # Category names, keys, app metadata
│   │   └── app_icons.dart          # Category & threat icon/color helpers
│   └── theme/
│       └── app_theme.dart          # Material 3 dark theme & typography
├── models/
│   ├── blocking_stats.dart         # Statistics & timeline models
│   ├── call_record.dart            # Call logs & caller ID metadata
│   └── sms_record.dart             # SMS logs & phishing link metadata
├── providers/
│   ├── call_provider.dart          # Call management, auto-blocking rules, stats state
│   └── sms_provider.dart           # SMS monitoring, safe view, read states
├── screens/
│   ├── calls/
│   │   └── call_history_screen.dart # Filterable call history
│   ├── home/
│   │   └── home_screen.dart        # Protection shield, quick stats, auto-block toggles
│   ├── messages/
│   │   └── messages_screen.dart    # SMS threats, safe view inspector modal
│   ├── onboarding/
│   │   └── onboarding_screen.dart  # 4-stage onboarding slider
│   ├── settings/
│   │   └── settings_screen.dart    # Protection toggles & manual blocklist
│   ├── stats/
│   │   └── stats_screen.dart       # FL Chart bar and pie analytics
│   └── main_shell.dart             # Bottom navigation shell & simulation controller
├── widgets/
│   ├── category_chip.dart          # Category breakdown chip
│   ├── incoming_call_dialog.dart   # Real-time caller ID overlay dialog
│   ├── protection_shield.dart      # Animated status shield widget
│   ├── recent_call_tile.dart       # Individual call history tile with quick block
│   └── stat_card.dart              # Metric cards
└── main.dart                       # Entry point, providers, status bar configuration
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or later)
- Dart SDK (3.0.0 or later)

### Run the App

1. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run on Chrome (Web):**
   ```bash
   flutter run -d chrome
   ```

3. **Run on Linux Desktop:**
   ```bash
   flutter run -d linux
   ```

4. **Run on Android / iOS Simulator:**
   ```bash
   flutter run
   ```

5. **Run Tests & Linter:**
   ```bash
   flutter analyze
   flutter test
   ```
# bbblock
