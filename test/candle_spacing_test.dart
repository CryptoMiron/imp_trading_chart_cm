import 'package:flutter_test/flutter_test.dart';
import 'package:imp_trading_chart/src/rendering/chart_painter.dart';

void main() {
  test('candle gap stays within near-constant 2..4 pixels', () {
    expect(candleGapPxForSlot(6), closeTo(2, 0.001));
    expect(candleGapPxForSlot(18), inInclusiveRange(2, 4));
    expect(candleGapPxForSlot(30), closeTo(4, 0.001));
    expect(candleGapPxForSlot(120), closeTo(4, 0.001));
  });
}
