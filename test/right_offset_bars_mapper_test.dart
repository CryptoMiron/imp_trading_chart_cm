import 'package:flutter_test/flutter_test.dart';
import 'package:imp_trading_chart/src/engine/chart_viewport.dart';
import 'package:imp_trading_chart/src/engine/price_scale.dart';
import 'package:imp_trading_chart/src/math/coordinate_mapper.dart';

CoordinateMapper _mapper({
  required int startIndex,
  required int visibleCount,
  required int totalCount,
  required double rightOffsetBars,
}) {
  return CoordinateMapper(
    viewport: ChartViewport(
      startIndex: startIndex,
      visibleCount: visibleCount,
      totalCount: totalCount,
    ),
    priceScale: const PriceScale(min: 0, max: 100),
    chartWidth: 1000,
    chartHeight: 600,
    paddingLeft: 0,
    paddingRight: 0,
    paddingTop: 0,
    paddingBottom: 0,
    rightOffsetBars: rightOffsetBars,
  );
}

void main() {
  test('right offset bars reserve future space at latest candle', () {
    final noOffset = _mapper(
      startIndex: 80,
      visibleCount: 20,
      totalCount: 100,
      rightOffsetBars: 0,
    );
    final withOffset = _mapper(
      startIndex: 80,
      visibleCount: 20,
      totalCount: 100,
      rightOffsetBars: 12,
    );

    final noOffsetX = noOffset.getCandleCenterX(99);
    final withOffsetX = withOffset.getCandleCenterX(99);

    expect(withOffsetX, lessThan(noOffsetX));
    expect(withOffset.candleWidth, lessThan(noOffset.candleWidth));
  });

  test('panning allows candles to move into right offset area', () {
    final latest = _mapper(
      startIndex: 80,
      visibleCount: 20,
      totalCount: 100,
      rightOffsetBars: 12,
    );
    final panned = _mapper(
      startIndex: 70,
      visibleCount: 20,
      totalCount: 100,
      rightOffsetBars: 12,
    );

    expect(
        panned.getCandleCenterX(99), greaterThan(latest.getCandleCenterX(99)));
  });

  test('xToIndex in future space snaps to last visible candle', () {
    final mapper = _mapper(
      startIndex: 80,
      visibleCount: 20,
      totalCount: 100,
      rightOffsetBars: 12,
    );

    expect(mapper.xToIndex(980), 99);
  });
}
