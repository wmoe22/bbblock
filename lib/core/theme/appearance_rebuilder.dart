import 'package:flutter/widgets.dart';

import 'app_appearance.dart';

/// Rebuilds everything below it whenever the appearance (light/dark) changes.
///
/// Colors come from static [AppTheme] getters rather than `Theme.of(context)`,
/// so Flutter has no way to know a widget depends on them. `const` widgets in
/// particular are skipped on normal rebuilds and would keep their old colors
/// until recreated. Marking every element dirty once per toggle fixes that
/// without resetting navigation, tab selection or scroll positions.
class AppearanceRebuilder extends StatefulWidget {
  final Widget child;

  const AppearanceRebuilder({super.key, required this.child});

  @override
  State<AppearanceRebuilder> createState() => _AppearanceRebuilderState();
}

class _AppearanceRebuilderState extends State<AppearanceRebuilder> {
  @override
  void initState() {
    super.initState();
    AppAppearance.instance.addListener(_onAppearanceChanged);
  }

  @override
  void dispose() {
    AppAppearance.instance.removeListener(_onAppearanceChanged);
    super.dispose();
  }

  void _onAppearanceChanged() {
    if (!mounted) return;

    void markDirty(Element element) {
      element.markNeedsBuild();
      element.visitChildren(markDirty);
    }

    (context as Element).visitChildren(markDirty);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
