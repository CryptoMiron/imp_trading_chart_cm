import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imp_trading_chart/imp_trading_chart.dart';
import 'package:imp_trading_chart/src/engine/chart_engine.dart';

void main() {
  final candles = <Candle>[
    Candle(time: 1, open: 100, high: 105, low: 95, close: 102, volume: 10),
    Candle(time: 2, open: 102, high: 106, low: 100, close: 104, volume: 12),
  ];

  final wideWickCandles = <Candle>[
    Candle(time: 1, open: 100, high: 320, low: 1, close: 100, volume: 10),
    Candle(time: 2, open: 101, high: 310, low: 5, close: 101, volume: 12),
    Candle(time: 3, open: 102, high: 300, low: 10, close: 102, volume: 14),
  ];

  Future<ChartEngine> captureEngineAfterDoubleTap(
    WidgetTester tester,
    ChartType chartType,
  ) async {
    ChartEngine? captured;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 240,
            child: ImpChart.simple(
              candles: wideWickCandles,
              chartType: chartType,
              onViewportChanged: (engine) {
                captured = engine;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chart = find.byType(ImpChart);
    await tester.tap(chart);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(chart);
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    return captured!;
  }

  test('ImpChart.trading defaults to candle chart type', () {
    final widget = ImpChart.trading(candles: candles);

    expect(widget.chartType, ChartType.candle);
  });

  test('ImpChart.simple defaults to line chart type', () {
    final widget = ImpChart.simple(candles: candles);

    expect(widget.chartType, ChartType.line);
  });

  test('ImpChart accepts explicit bar chart type', () {
    final widget = ImpChart(candles: candles, chartType: ChartType.bar);

    expect(widget.chartType, ChartType.bar);
  });

  testWidgets('line uses close range while candle and bar include wick range', (
    tester,
  ) async {
    final lineEngine =
        await captureEngineAfterDoubleTap(tester, ChartType.line);
    final candleEngine = await captureEngineAfterDoubleTap(
      tester,
      ChartType.candle,
    );
    final barEngine = await captureEngineAfterDoubleTap(tester, ChartType.bar);

    final lineScale = lineEngine.getPriceScale();
    final candleScale = candleEngine.getPriceScale();
    final barScale = barEngine.getPriceScale();

    expect(lineScale.max, lessThan(150));
    expect(candleScale.max, greaterThan(250));
    expect(barScale.max, greaterThan(250));
  });
}
