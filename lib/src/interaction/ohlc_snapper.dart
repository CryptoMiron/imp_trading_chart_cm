import 'dart:ui';

import 'package:imp_trading_chart/src/data/candle.dart';

class OhlcSnapProjection {
  final int Function(double x) xToIndex;
  final double Function(double y) yToPrice;
  final double Function(double price) priceToY;

  const OhlcSnapProjection({
    required this.xToIndex,
    required this.yToPrice,
    required this.priceToY,
  });
}

class OhlcSnapper {
  const OhlcSnapper._();

  /// `candles` must be indexed by absolute candle index so `candles[index]`
  /// aligns with `projection.xToIndex` output for the current viewport.
  static Offset snap({
    required Offset point,
    required OhlcSnapProjection projection,
    required List<Candle> candles,
    required bool magnetEnabled,
  }) {
    if (!magnetEnabled) {
      return point;
    }

    final index = projection.xToIndex(point.dx);
    if (index < 0 || index >= candles.length) {
      return point;
    }

    final candle = candles[index];
    final cursorPrice = projection.yToPrice(point.dy);
    final snappedPrice = _nearestOhlc(candle, cursorPrice);

    return Offset(point.dx, projection.priceToY(snappedPrice));
  }

  static double _nearestOhlc(Candle candle, double price) {
    var nearest = candle.open;
    var smallestDistance = (price - nearest).abs();

    final candidates = <double>[candle.high, candle.low, candle.close];
    for (final candidate in candidates) {
      final distance = (price - candidate).abs();
      if (distance < smallestDistance) {
        nearest = candidate;
        smallestDistance = distance;
      }
    }

    return nearest;
  }
}
