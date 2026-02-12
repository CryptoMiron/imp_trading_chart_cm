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

  test('current price marker background starts at separator without gap', () {
    final left = resolveCurrentPriceMarkerBackgroundLeft(
      chartRight: 744,
      canvasWidth: 800,
    );
    expect(left, 744);
  });

  test('current price marker width fills full price scale column', () {
    final width = resolveCurrentPriceMarkerBackgroundWidth(
      availableWidth: 56,
      textWidth: 40,
      horizontalPadding: 4,
    );
    expect(width, 56);
  });

  test('current price marker never protrudes beyond price scale bounds', () {
    final left = resolveCurrentPriceMarkerBackgroundLeft(
      chartRight: 744,
      canvasWidth: 800,
    );
    final width = resolveCurrentPriceMarkerBackgroundWidth(
      availableWidth: 56,
      textWidth: 200,
      horizontalPadding: 4,
    );

    expect(left, 744);
    expect(left + width, 800);
  });

  test('current price marker text is centered within full scale width', () {
    final textX = resolveCurrentPriceMarkerTextX(
      markerLeft: 744,
      markerWidth: 56,
      textWidth: 40,
      horizontalPadding: 4,
    );
    expect(textX, 752);
  });

  test('current price marker border radius is zero', () {
    expect(currentPriceMarkerBorderRadius, 0);
  });

  test('pulse marker hides when latest candle is outside viewport', () {
    expect(
      shouldDrawCurrentPricePulse(
        hasVisibleCandles: true,
        rippleEnabled: true,
        viewportEndIndex: 120,
        totalCount: 150,
      ),
      isFalse,
    );
  });

  test('pulse marker shows when viewport includes latest candle', () {
    expect(
      shouldDrawCurrentPricePulse(
        hasVisibleCandles: true,
        rippleEnabled: true,
        viewportEndIndex: 150,
        totalCount: 150,
      ),
      isTrue,
    );
  });

  test('remaining candle close time is computed from open time and timeframe',
      () {
    final remaining = resolveRemainingCandleTime(
      candleOpenTime: DateTime.utc(2026, 1, 1, 12, 0, 0),
      candleTimeframe: const Duration(minutes: 1),
      now: DateTime.utc(2026, 1, 1, 12, 0, 35),
    );

    expect(remaining, const Duration(seconds: 25));
  });

  test('remaining candle time format uses mm:ss for intraday frames', () {
    final text = formatRemainingCandleTime(const Duration(seconds: 25));
    expect(text, '00:25');
  });
}
