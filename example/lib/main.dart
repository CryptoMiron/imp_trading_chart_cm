import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imp_trading_chart/imp_trading_chart.dart';

import 'main_navigation_screen.dart';

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
/// • NEW: 5 beautiful showcase charts with different themes
///
/// This file intentionally stays **very small**:
/// - No chart logic
/// - No data generation
/// - No styling complexity
///
/// All heavy logic lives inside:
/// → `chart_example.dart`
/// → `showcase_charts.dart`
/// → `showcase_screen.dart`
///
/// This separation keeps:
/// - entry point clean
/// - examples easy to reason about
/// - onboarding simple for new contributors
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ChartExampleApp());
}

/// Root widget for the ImpChart example application.
///
/// Responsibilities:
/// - Configure global app theme
/// - Define application title
/// - Provide navigation between example screens
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
        scaffoldBackgroundColor: const Color(0xFF05070F),
        cardColor: const Color(0xFF1A1F3A),
        dividerColor: Colors.white24,
      ),

      /// Main entry screen with navigation options
      home: const QuickStartScreen(),

      /// Debug banner intentionally disabled for clean visuals
      debugShowCheckedModeBanner: false,
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// ⚡ QUICK START SCREEN (Optimized for pub.dev "Example" tab)
/// ─────────────────────────────────────────────────────────────
///
/// This provides a zero-setup, copy-pasteable example of how to
/// use [ImpChart] in any Flutter application.
class QuickStartScreen extends StatelessWidget {
  const QuickStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F16),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ImpChart Quick Start',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Minimal setup, high-performance rendering.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              /// THE CHART COMPONENT
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161922),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ImpChart(
                    /// 1. Provide your data
                    candles: _generateSampleData(),

                    /// 2. Choose a pre-defined style (or customize)
                    style: ChartStyle.trading(
                      backgroundColor: Colors.transparent,
                    ).copyWith(
                      lineStyle: const LineChartStyle(
                          color: TradingColors.bullish,
                          smooth: true,
                          showGlow: true,
                          glowWidth: 1.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// NAVIGATION TO FULL SHOWCASE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavigationScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text('Explore Full Showcase Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Self-contained sample data generator for the Quick Start.
  List<Candle> _generateSampleData() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    double price = 150.0;
    return List.generate(100, (i) {
      price += (math.Random().nextDouble() - 0.5) * 5;
      return Candle(
        time: now - (100 - i) * 3600,
        open: price,
        high: price + 2,
        low: price - 2,
        close: price,
      );
    });
  }
}
