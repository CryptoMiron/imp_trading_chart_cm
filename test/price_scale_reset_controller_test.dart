import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imp_trading_chart/imp_trading_chart.dart';

void main() {
  final candles = <Candle>[
    Candle(time: 1, open: 100, high: 102, low: 99, close: 101, volume: 10),
    Candle(time: 2, open: 101, high: 103, low: 100, close: 102, volume: 11),
    Candle(time: 3, open: 102, high: 104, low: 101, close: 103, volume: 12),
    Candle(time: 4, open: 103, high: 105, low: 102, close: 104, volume: 13),
  ];

  testWidgets(
    'controller reset triggers price-scale auto-fit without remount',
    (tester) async {
      final controller = ImpChartController();
      final chartKey = GlobalKey();
      var viewportChangeCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 240,
              child: ImpChart(
                key: chartKey,
                candles: candles,
                enableGestures: false,
                controller: controller,
                onViewportChanged: (_) {
                  viewportChangeCount += 1;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final beforeState = chartKey.currentState;

      controller.resetPriceScaleAutoFit();
      await tester.pumpAndSettle();

      final afterState = chartKey.currentState;

      expect(identical(afterState, beforeState), isTrue);
      expect(viewportChangeCount, 1);
    },
  );
}
