import 'package:flutter_test/flutter_test.dart';
import 'package:imp_trading_chart/src/rendering/chart_painter.dart';

void main() {
  test('current price marker occupies entire price scale width', () {
    final layout = resolveCurrentPriceMarkerHorizontalLayout(
      chartRight: 744,
      canvasWidth: 800,
    );

    expect(layout.left, 744);
    expect(layout.width, 56);
  });

  test('current price marker border radius is zero', () {
    expect(currentPriceMarkerBorderRadius, 0);
  });
}
