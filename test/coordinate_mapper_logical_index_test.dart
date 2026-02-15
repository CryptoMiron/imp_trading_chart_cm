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
  test('logical index roundtrip keeps anchor stable', () {
    final mapper = _mapper(
      startIndex: 80,
      visibleCount: 20,
      totalCount: 100,
      rightOffsetBars: 12,
    );

    final logicalIndex = mapper.xToLogicalIndex(400);
    final x = mapper.logicalIndexToX(logicalIndex);

    expect((x - 400).abs(), lessThan(0.0001));
  });

  test('right offset bars affect logical index mapping', () {
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

    expect(
      withOffset.logicalIndexToX(99),
      lessThan(noOffset.logicalIndexToX(99)),
    );
    expect(withOffset.xToLogicalIndex(980), 99);
  });

  test('logical mapping clamps at chart boundaries', () {
    final mapper = _mapper(
      startIndex: 80,
      visibleCount: 20,
      totalCount: 100,
      rightOffsetBars: 0,
    );

    expect(mapper.xToLogicalIndex(-10), 80);
    expect(mapper.xToLogicalIndex(1200), 99);
    expect(mapper.logicalIndexToX(mapper.xToLogicalIndex(-10)), 0);
    expect(mapper.logicalIndexToX(mapper.xToLogicalIndex(1200)), 950);
  });
}
