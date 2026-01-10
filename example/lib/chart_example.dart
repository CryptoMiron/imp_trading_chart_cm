import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:imp_trading_chart/imp_trading_chart.dart' show Candle, ImpChart;

/// Simulation modes used to stress-test the chart engine.
///
/// Each mode targets a different numerical domain:
/// - [low]    → extreme precision (very small floating-point values)
/// - [medium] → standard trading ranges
/// - [high]   → very large values (millions to billions)
/// - [mixed]  → worst-case scenario with range switching
enum SimulationMode {
  /// 0.00000000000000000000001 → 0.1
  low,

  /// $0 → $100,000
  medium,

  /// $0 → $1,000,000,000
  high,

  /// Mixed ranges (low + medium + high)
  mixed,
}

/// Main example screen showcasing ImpChart factory constructors.
///
/// This widget demonstrates:
/// - Live OHLC candle generation
/// - Real-time updates
/// - Multiple chart styles via factory methods
/// - Handling of extreme numeric ranges
class ChartExampleScreen extends StatefulWidget {
  const ChartExampleScreen({super.key});

  @override
  State<ChartExampleScreen> createState() => _ChartExampleScreenState();
}

class _ChartExampleScreenState extends State<ChartExampleScreen>
    with SingleTickerProviderStateMixin {
  // ===========================================================================
  // STATE & CONTROLLERS
  // ===========================================================================

  /// Current candle data rendered by the charts
  List<Candle> _candles = [];

  /// Random generator used for deterministic price simulation
  final Random _random = Random();

  /// Currently active simulation mode
  SimulationMode? _simulationMode;

  /// Live update flags (mutually exclusive)
  bool _isLiveLow = false;
  bool _isLiveMedium = false;
  bool _isLiveHigh = false;
  bool _isLiveMixed = false;

  /// Controls the chart-style tabs
  late TabController _tabController;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    /// Four tabs:
    /// Trading | Simple | Compact | Minimal
    _tabController = TabController(length: 4, vsync: this);

    /// Rebuild UI when switching chart style
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    /// ❗ No candles are generated initially
    /// User must explicitly select a simulation mode
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // INITIAL CANDLE GENERATION
  // ===========================================================================

  /// Generates an initial candle set for the selected simulation mode.
  ///
  /// Characteristics:
  /// - Generates exactly **500 candles**
  /// - Uses **percentage-based volatility**
  /// - Produces realistic OHLC relationships
  /// - Uses **integer timestamps only (seconds)**
  void _generateCandlesForMode(SimulationMode mode) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final candles = <Candle>[];

    double minPrice;
    double maxPrice;
    double startPrice;
    double volatilityPercent;

    switch (mode) {
      case SimulationMode.low:
        minPrice = 0.00000000000000000000001;
        maxPrice = 0.1;
        startPrice = 0.01;
        volatilityPercent = 0.05;
        break;

      case SimulationMode.medium:
        minPrice = 0.01;
        maxPrice = 100000.0;
        startPrice = 1000.0;
        volatilityPercent = 0.02;
        break;

      case SimulationMode.high:
        minPrice = 0.01;
        maxPrice = 1000000000.0;
        startPrice = 10000000.0;
        volatilityPercent = 0.015;
        break;

      case SimulationMode.mixed:
        minPrice = 0.00000000000000000000001;
        maxPrice = 1000000000.0;
        startPrice = 100.0;
        volatilityPercent = 0.03;
        break;
    }

    double price = startPrice;
    final bool isMixedMode = mode == SimulationMode.mixed;

    for (int i = 0; i < 500; i++) {
      final time = now - (500 - i) * 60; // 1-minute candles

      /// Mixed mode periodically jumps between ranges
      if (isMixedMode && i > 0 && i % 100 == 0) {
        switch (_random.nextInt(3)) {
          case 0:
            price = _random.nextDouble() * 0.1 + 0.0001;
            break;
          case 1:
            price = _random.nextDouble() * 100000 + 100;
            break;
          case 2:
            price = _random.nextDouble() * 1000000000 + 1000000;
            break;
        }
        price = price.clamp(minPrice, maxPrice * 1.1);
      }

      /// Percentage-based random walk
      final changePercent =
          (_random.nextDouble() - 0.5) * 2 * volatilityPercent;

      final open = price;
      final close =
          (price + price * changePercent).clamp(minPrice, maxPrice * 1.1);

      /// Ensure realistic wick sizes
      final candleRange =
          math.max((close - open).abs(), price * volatilityPercent * 0.5);

      final high =
          math.max(open, close) + _random.nextDouble() * candleRange * 0.5;
      final low =
          math.min(open, close) - _random.nextDouble() * candleRange * 0.5;

      candles.add(Candle(
        time: time,
        open: open,
        high: high,
        low: low,
        close: close,
      ));

      price = close;
    }

    setState(() {
      _candles = candles;
      _simulationMode = mode;
    });
  }

  // ===========================================================================
  // LIVE SIMULATION CONTROL
  // ===========================================================================

  /// Resets chart state and stops all simulations.
  void _resetChart() {
    setState(() {
      _candles = [];
      _simulationMode = null;
      _isLiveLow = false;
      _isLiveMedium = false;
      _isLiveHigh = false;
      _isLiveMixed = false;
    });
  }

  /// Latest candle close price (used by charts & stats bar)
  double? get _currentPrice => _candles.isNotEmpty ? _candles.last.close : null;

  /// Toggles live updates for the selected simulation mode.
  ///
  /// - Ensures only ONE live mode is active
  /// - Generates candles if switching modes
  void _toggleLive(SimulationMode mode) {
    setState(() {
      _isLiveLow = false;
      _isLiveMedium = false;
      _isLiveHigh = false;
      _isLiveMixed = false;

      switch (mode) {
        case SimulationMode.low:
          _isLiveLow = !_isLiveLow;
          break;
        case SimulationMode.medium:
          _isLiveMedium = !_isLiveMedium;
          break;
        case SimulationMode.high:
          _isLiveHigh = !_isLiveHigh;
          break;
        case SimulationMode.mixed:
          _isLiveMixed = !_isLiveMixed;
          break;
      }

      if (_candles.isEmpty || _simulationMode != mode) {
        _generateCandlesForMode(mode);
      }
    });

    final isLive = (mode == SimulationMode.low && _isLiveLow) ||
        (mode == SimulationMode.medium && _isLiveMedium) ||
        (mode == SimulationMode.high && _isLiveHigh);

    if (isLive) {
      _startLiveUpdates(mode);
    }
  }

  /// Performs recursive live price updates.
  ///
  /// Behavior:
  /// - Runs every 500ms
  /// - Updates current candle if timestamp matches
  /// - Creates a new candle otherwise
  /// - Preserves OHLC integrity
  void _startLiveUpdates(SimulationMode mode) {
    Future.delayed(const Duration(milliseconds: 500), () {
      final isLive = (mode == SimulationMode.low && _isLiveLow) ||
          (mode == SimulationMode.medium && _isLiveMedium) ||
          (mode == SimulationMode.high && _isLiveHigh) ||
          (mode == SimulationMode.mixed && _isLiveMixed);

      if (!mounted || !isLive || _candles.isEmpty) return;

      final lastCandle = _candles.last;
      final newTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      setState(() {
        final currentPrice = lastCandle.close;
        double volatilityPercent;
        double maxPrice;

        switch (mode) {
          case SimulationMode.low:
            volatilityPercent = 0.05;
            maxPrice = 0.1;
            break;
          case SimulationMode.medium:
            volatilityPercent = 0.02;
            maxPrice = 100000.0;
            break;
          case SimulationMode.high:
            volatilityPercent = 0.015;
            maxPrice = 1000000000.0;
            break;
          case SimulationMode.mixed:
            if (currentPrice < 1) {
              volatilityPercent = 0.05;
              maxPrice = 0.1;
            } else if (currentPrice < 10000) {
              volatilityPercent = 0.03;
              maxPrice = 100000;
            } else {
              volatilityPercent = 0.02;
              maxPrice = 1000000000;
            }
            break;
        }

        final changePercent =
            (_random.nextDouble() - 0.5) * 2 * volatilityPercent;
        final newPrice = (currentPrice + currentPrice * changePercent).clamp(
          mode == SimulationMode.low || mode == SimulationMode.mixed
              ? 0.00000000000000000000001
              : 0.01,
          maxPrice * 1.1,
        );

        if (lastCandle.time == newTime) {
          _candles[_candles.length - 1] = Candle(
            time: lastCandle.time,
            open: lastCandle.open,
            high: math.max(lastCandle.high, newPrice),
            low: math.min(lastCandle.low, newPrice),
            close: newPrice,
          );
        } else {
          _candles.add(Candle(
            time: newTime,
            open: lastCandle.close,
            high: math.max(lastCandle.close, newPrice),
            low: math.min(lastCandle.close, newPrice),
            close: newPrice,
          ));
        }
      });

      _startLiveUpdates(mode);
    });
  }

  /// Formats a price value for display in the stats bar.
  ///
  /// Uses compact, human-readable notation for large numbers:
  /// - ≥ 1B → Billion (B)
  /// - ≥ 1M → Million (M)
  /// - ≥ 1K → Thousand (K)
  /// - Otherwise → fixed decimal currency
  ///
  /// Examples:
  /// - 1250        → $1.25K
  /// - 2500000     → $2.50M
  /// - 9876543210  → $9.88B
  String _formatPriceForDisplay(double price) {
    final absPrice = price.abs();
    final sign = price < 0 ? '-' : '';

    if (absPrice >= 1e9) {
      return '$sign\$${(absPrice / 1e9).toStringAsFixed(2)}B';
    } else if (absPrice >= 1e6) {
      return '$sign\$${(absPrice / 1e6).toStringAsFixed(2)}M';
    } else if (absPrice >= 1e3) {
      return '$sign\$${(absPrice / 1e3).toStringAsFixed(2)}K';
    } else {
      return '$sign\$${absPrice.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),

      // =========================================================================
      // APP BAR + CHART STYLE TABS
      // =========================================================================
      appBar: AppBar(
        title: const Text(
          'Chart Showcase',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1F3A),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.cyan,
          labelColor: Colors.cyan,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: '🎯 Trading'),
            Tab(text: '📊 Simple'),
            Tab(text: '📦 Compact'),
            Tab(text: '⚡ Minimal'),
          ],
        ),
      ),

      // =========================================================================
      // MAIN CONTENT
      // =========================================================================
      body: Column(
        children: [
          // ---------------------------------------------------------------------
          // SIMULATION CONTROLS PANEL
          // ---------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F3A),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Simulation Controls',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                /// Simulation mode buttons (mutually exclusive)
                Row(
                  children: [
                    Expanded(
                      child: _buildSimulationButton(
                        'Low Range\n0.000...01 - 0.1',
                        SimulationMode.low,
                        Colors.blue,
                        _isLiveLow,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSimulationButton(
                        'Medium\n\$0 - \$100K',
                        SimulationMode.medium,
                        Colors.green,
                        _isLiveMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSimulationButton(
                        'High Range\n\$0 - \$1B',
                        SimulationMode.high,
                        Colors.orange,
                        _isLiveHigh,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSimulationButton(
                        'Mixed\nAny Type',
                        SimulationMode.mixed,
                        Colors.purple,
                        _isLiveMixed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildResetButton(),
                  ],
                ),
              ],
            ),
          ),

          // ---------------------------------------------------------------------
          // STATS BAR (LIVE METRICS)
          // ---------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F3A),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                /// Scrollable stats to handle small screens
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatItem(
                          icon: Icons.candlestick_chart,
                          label: 'Candles',
                          value: '${_candles.length}',
                          color: Colors.cyan,
                        ),
                        const SizedBox(width: 20),
                        _buildStatItem(
                          icon: Icons.trending_up,
                          label: 'Price',
                          value: _currentPrice != null
                              ? _formatPriceForDisplay(_currentPrice!)
                              : 'N/A',
                          color: Colors.green,
                        ),
                        if (_candles.isNotEmpty) ...[
                          const SizedBox(width: 20),
                          _buildStatItem(
                            icon: Icons.arrow_upward,
                            label: 'High',
                            value: _formatPriceForDisplay(_candles.last.high),
                            color: Colors.green,
                          ),
                          const SizedBox(width: 20),
                          _buildStatItem(
                            icon: Icons.arrow_downward,
                            label: 'Low',
                            value: _formatPriceForDisplay(_candles.last.low),
                            color: Colors.red,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                /// LIVE indicator badge
                if (_isLiveLow || _isLiveMedium || _isLiveHigh || _isLiveMixed)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE ${_getModeLabel()}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ---------------------------------------------------------------------
          // CHART CONTENT AREA
          // ---------------------------------------------------------------------
          Expanded(
            child: _candles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a simulation mode to start',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose Low, Medium, or High range simulation',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTradingChart(),
                      _buildSimpleChart(),
                      _buildCompactChart(),
                      _buildMinimalChart(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Returns the active simulation mode label for the LIVE indicator.
  String _getModeLabel() {
    if (_isLiveLow) return 'LOW';
    if (_isLiveMedium) return 'MEDIUM';
    if (_isLiveHigh) return 'HIGH';
    if (_isLiveMixed) return 'MIXED';
    return '';
  }

  /// Builds a simulation control button.
  ///
  /// Behavior:
  /// - Starts or pauses live simulation
  /// - Highlights active and selected states
  /// - Enforces single active simulation mode
  Widget _buildSimulationButton(
    String label,
    SimulationMode mode,
    Color color,
    bool isActive,
  ) {
    final isLive = (mode == SimulationMode.low && _isLiveLow) ||
        (mode == SimulationMode.medium && _isLiveMedium) ||
        (mode == SimulationMode.high && _isLiveHigh);

    return InkWell(
      onTap: () => _toggleLive(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isLive
              ? color.withValues(alpha: 0.3)
              : (_simulationMode == mode
                  ? color.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLive ? color : color.withValues(alpha: 0.3),
            width: isLive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLive ? Icons.pause_circle : Icons.play_circle,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isLive ? color : Colors.white70,
                fontSize: 11,
                fontWeight: isLive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the reset button used to clear the chart state.
  ///
  /// Resets:
  /// - Candle data
  /// - Active simulation mode
  /// - Live update flags
  ///
  /// Visually styled as a destructive action (red) to indicate reset behavior.
  Widget _buildResetButton() {
    return InkWell(
      onTap: _resetChart,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.refresh,
          color: Colors.red,
          size: 24,
        ),
      ),
    );
  }

  /// Builds a single statistic item used in the stats bar.
  ///
  /// Displays:
  /// - An icon
  /// - A short label
  /// - A highlighted value
  ///
  /// Designed to be compact and horizontally scrollable for small screens.
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 9,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the full-featured trading chart example.
  ///
  /// Features:
  /// - Crosshair interaction
  /// - Current price indicator
  /// - Rich layout styling
  /// - Higher visible candle count
  ///
  /// Intended to showcase the most powerful ImpChart configuration.
  Widget _buildTradingChart() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_graph, color: Colors.cyan, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Trading Chart',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'Full-featured with all bells & whistles',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),

          /// Chart
          Expanded(
            child: ImpChart.trading(
              candles: _candles,
              currentPrice: _currentPrice,
              showCrosshair: true,
              defaultVisibleCount: 200,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a simple chart configuration.
  ///
  /// Features:
  /// - Clean line rendering
  /// - Price & time labels
  /// - No advanced interactions
  ///
  /// Ideal for lightweight analytics views.
  Widget _buildSimpleChart() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.show_chart, color: Colors.green, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Simple Chart',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'Basic chart with labels',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),

          /// Chart
          Expanded(
            child: ImpChart.simple(
              candles: _candles,
              currentPrice: _currentPrice,
              lineColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a compact chart optimized for dense layouts.
  ///
  /// Features:
  /// - Reduced spacing
  /// - Smaller visible range
  /// - Lightweight visuals
  ///
  /// Ideal for dashboards and summary views.
  Widget _buildCompactChart() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.compress, color: Colors.orange, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Compact Chart',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'Perfect for dashboards',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),

          /// Chart
          Expanded(
            child: ImpChart.compact(
              candles: _candles,
              currentPrice: _currentPrice,
              lineColor: Colors.orange,
              defaultVisibleCount: 75,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an ultra-minimal chart configuration.
  ///
  /// Features:
  /// - No labels
  /// - No grid
  /// - No animations
  ///
  /// Designed for sparkline-style visualizations.
  Widget _buildMinimalChart() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.pink.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.pink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.minimize, color: Colors.pink, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Minimal Chart',
                        style: TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'Ultra-minimal, just the line',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),

          /// Chart
          Expanded(
            child: ImpChart.minimal(
              candles: _candles,
              defaultVisibleCount: 50,
            ),
          ),
        ],
      ),
    );
  }
}
