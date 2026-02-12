import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imp_trading_chart/src/rendering/chart_painter.dart';

void main() {
  test('candlestick body fill is fully opaque', () {
    final color = candlestickBodyFillColor(const Color(0xFF26A69A));
    expect(color.a, 1.0);
  });
}
