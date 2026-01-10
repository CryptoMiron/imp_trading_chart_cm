import 'package:flutter/material.dart';

import 'chart_example.dart';

/// Entry point for the ImpChart example application.
///
/// This app serves as a **visual showcase** for all available
/// `ImpChart` factory constructors and styling presets.
///
/// ─────────────────────────────────────────────────────────────
/// WHAT THIS EXAMPLE DEMONSTRATES
/// ─────────────────────────────────────────────────────────────
///
/// • All chart factory styles:
///   - minimal
///   - simple
///   - trading
///   - dark
///   - light
///   - compact
///
/// • Multiple chart instances rendered together
/// • A clean, modern UI using cards & tabs
/// • A dark-theme optimized layout for trading visuals
/// • A realistic playground for contributors and users
///
/// This file intentionally stays **very small**:
/// - No chart logic
/// - No data generation
/// - No styling complexity
///
/// All heavy logic lives inside:
/// → `chart_example.dart`
///
/// This separation keeps:
/// - entry point clean
/// - examples easy to reason about
/// - onboarding simple for new contributors
void main() {
  runApp(const ChartExampleApp());
}

/// Root widget for the ImpChart example application.
///
/// Responsibilities:
/// - Configure global app theme
/// - Define application title
/// - Load the main example screen
///
/// ❗ This widget should stay **stateless**
/// Any state (tabs, chart data, animations) must live
/// in feature-specific widgets, NOT here.
class ChartExampleApp extends StatelessWidget {
  const ChartExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// Application title (used by OS task switchers)
      title: 'ImpChart Showcase',

      /// Global dark theme configuration.
      ///
      /// The theme is intentionally opinionated to match
      /// real trading applications:
      /// - Deep navy background
      /// - Subtle card contrast
      /// - Minimal divider noise
      ///
      /// Individual charts override colors internally
      /// using `ChartStyle`, not the app theme.
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.cyan,
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        cardColor: const Color(0xFF1A1F3A),
        dividerColor: Colors.white24,
      ),

      /// Main showcase screen.
      ///
      /// All chart examples, tabs, and demo logic
      /// are contained inside this widget.
      home: const ChartExampleScreen(),

      /// Debug banner intentionally disabled for clean visuals
      debugShowCheckedModeBanner: false,
    );
  }
}
