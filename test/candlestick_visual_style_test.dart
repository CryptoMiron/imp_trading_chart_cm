import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imp_trading_chart/src/rendering/chart_painter.dart';

void main() {
  test('candlestick wick uses ultra-thin stroke width', () {
    final width = candlestickWickStrokeWidth(24);
    expect(width, lessThanOrEqualTo(1.0));
    expect(width, greaterThan(0));
  });

  test('candlestick wick stroke cap is not rounded', () {
    expect(candlestickWickStrokeCap(), StrokeCap.butt);
  });

  test('candlestick body fill is fully opaque', () {
    final color = candlestickBodyFillColor(const Color(0xFF26A69A));
    expect(color.a, 1.0);
  });
}
