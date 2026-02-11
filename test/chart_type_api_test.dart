import 'package:flutter_test/flutter_test.dart';
import 'package:imp_trading_chart/imp_trading_chart.dart';

void main() {
  final candles = <Candle>[
    Candle(time: 1, open: 100, high: 105, low: 95, close: 102, volume: 10),
    Candle(time: 2, open: 102, high: 106, low: 100, close: 104, volume: 12),
  ];

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
}
