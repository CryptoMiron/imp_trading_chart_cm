import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:imp_trading_chart/imp_trading_chart.dart';
import 'package:imp_trading_chart/src/engine/chart_viewport.dart';
import 'package:imp_trading_chart/src/engine/price_scale.dart';
import 'package:imp_trading_chart/src/math/coordinate_mapper.dart';

CoordinateMapper _mapper() {
  return CoordinateMapper(
    viewport: const ChartViewport(
      startIndex: 0,
      visibleCount: 3,
      totalCount: 3,
    ),
    priceScale: const PriceScale(min: 0, max: 100),
    chartWidth: 300,
    chartHeight: 200,
  );
}

OhlcSnapProjection _projection(CoordinateMapper mapper) {
  return OhlcSnapProjection(
    xToIndex: mapper.xToIndex,
    yToPrice: mapper.yToPrice,
    priceToY: mapper.priceToY,
  );
}

void main() {
  test('cursor X resolves candle by mapper index', () {
    final mapper = _mapper();
    final projection = _projection(mapper);
    final candles = <Candle>[
      const Candle(time: 1, open: 10, high: 12, low: 8, close: 11),
      const Candle(time: 2, open: 50, high: 52, low: 48, close: 51),
      const Candle(time: 3, open: 80, high: 82, low: 78, close: 81),
    ];

    final point = Offset(mapper.indexToX(1) + 10, mapper.priceToY(51.2));
    final snapped = OhlcSnapper.snap(
      point: point,
      projection: projection,
      candles: candles,
      magnetEnabled: true,
    );

    expect(snapped.dy, closeTo(mapper.priceToY(51), 0.0001));
  });

  test('snapped price chooses nearest from that candle OHLC', () {
    final mapper = _mapper();
    final projection = _projection(mapper);
    final candles = <Candle>[
      const Candle(time: 1, open: 10, high: 22, low: 4, close: 18),
      const Candle(time: 2, open: 50, high: 52, low: 48, close: 51),
      const Candle(time: 3, open: 80, high: 82, low: 78, close: 81),
    ];

    final point = Offset(mapper.indexToX(0) + 10, mapper.priceToY(19.1));
    final snapped = OhlcSnapper.snap(
      point: point,
      projection: projection,
      candles: candles,
      magnetEnabled: true,
    );

    expect(snapped.dx, point.dx);
    expect(snapped.dy, closeTo(mapper.priceToY(18), 0.0001));
  });

  test('when magnet disabled, point unchanged', () {
    final mapper = _mapper();
    final projection = _projection(mapper);
    final candles = <Candle>[
      const Candle(time: 1, open: 10, high: 22, low: 4, close: 18),
      const Candle(time: 2, open: 50, high: 52, low: 48, close: 51),
      const Candle(time: 3, open: 80, high: 82, low: 78, close: 81),
    ];

    final point = Offset(mapper.getCandleCenterX(2), mapper.priceToY(79.4));
    final snapped = OhlcSnapper.snap(
      point: point,
      projection: projection,
      candles: candles,
      magnetEnabled: false,
    );

    expect(snapped, point);
  });

  test('when X is outside drawable area, point unchanged', () {
    final mapper = _mapper();
    final projection = _projection(mapper);
    final candles = <Candle>[
      const Candle(time: 1, open: 10, high: 22, low: 4, close: 18),
      const Candle(time: 2, open: 50, high: 52, low: 48, close: 51),
      const Candle(time: 3, open: 80, high: 82, low: 78, close: 81),
    ];

    final point = Offset(-1, mapper.priceToY(50));
    final snapped = OhlcSnapper.snap(
      point: point,
      projection: projection,
      candles: candles,
      magnetEnabled: true,
    );

    expect(snapped, point);
  });

  test('when candles are empty, point unchanged', () {
    final mapper = _mapper();
    final projection = _projection(mapper);
    final point = Offset(mapper.indexToX(1), mapper.priceToY(50));

    final snapped = OhlcSnapper.snap(
      point: point,
      projection: projection,
      candles: const <Candle>[],
      magnetEnabled: true,
    );

    expect(snapped, point);
  });

  test('non-zero viewport start uses absolute candle index mapping', () {
    final mapper = CoordinateMapper(
      viewport: const ChartViewport(
        startIndex: 5,
        visibleCount: 3,
        totalCount: 10,
      ),
      priceScale: const PriceScale(min: 0, max: 100),
      chartWidth: 300,
      chartHeight: 200,
    );
    final projection = _projection(mapper);
    final candles = List<Candle>.generate(
      10,
      (index) => Candle(
        time: index,
        open: index.toDouble(),
        high: 100 + index.toDouble(),
        low: -100 - index.toDouble(),
        close: 10 + index.toDouble(),
      ),
    );

    final point = Offset(mapper.indexToX(6) + 1, mapper.priceToY(16.2));
    final snapped = OhlcSnapper.snap(
      point: point,
      projection: projection,
      candles: candles,
      magnetEnabled: true,
    );

    expect(snapped.dy, closeTo(mapper.priceToY(16), 0.0001));
  });

  test('tie keeps earliest OHLC candidate (open over close)', () {
    final mapper = _mapper();
    final projection = _projection(mapper);
    final candles = <Candle>[
      const Candle(time: 1, open: 10, high: 14, low: 2, close: 12),
      const Candle(time: 2, open: 50, high: 52, low: 48, close: 51),
      const Candle(time: 3, open: 80, high: 82, low: 78, close: 81),
    ];

    final point = Offset(mapper.indexToX(0) + 10, mapper.priceToY(11));
    final snapped = OhlcSnapper.snap(
      point: point,
      projection: projection,
      candles: candles,
      magnetEnabled: true,
    );

    expect(snapped.dy, closeTo(mapper.priceToY(10), 0.0001));
  });
}
