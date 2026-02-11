import 'package:flutter_test/flutter_test.dart';
import 'package:imp_trading_chart/src/rendering/chart_painter.dart';

void main() {
  test('adaptive price ticks use clean rounded steps', () {
    final ticks = buildAdaptivePriceTicks(
      minPrice: 67520,
      maxPrice: 67880,
      targetCount: 5,
    );

    expect(ticks.length, greaterThanOrEqualTo(5));
    expect(ticks, containsAllInOrder([67600, 67700, 67800]));
  });

  test('current price marker starts exactly at chart right edge', () {
    expect(resolveCurrentPriceMarkerLeft(744), 744);
  });

  test('current price marker border radius is zero', () {
    expect(currentPriceMarkerBorderRadius, 0);
  });
}
