import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imp_trading_chart/imp_trading_chart.dart';
import 'package:imp_trading_chart/src/rendering/chart_painter.dart';

List<Candle> _candles({int count = 12}) {
  return List<Candle>.generate(
    count,
    (index) => Candle(
      time: index + 1,
      open: 10 + index.toDouble(),
      high: 11 + index.toDouble(),
      low: 9 + index.toDouble(),
      close: 10.5 + index.toDouble(),
    ),
  );
}

void main() {
  testWidgets('onProjectionChanged provides usable projection snapshot',
      (tester) async {
    final projections = <ChartProjection>[];

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 320,
          height: 180,
          child: ImpChart(
            candles: const <Candle>[
              Candle(time: 1, open: 10, high: 12, low: 8, close: 11),
              Candle(time: 2, open: 11, high: 13, low: 9, close: 12),
              Candle(time: 3, open: 12, high: 14, low: 10, close: 13),
            ],
            style: ChartStyle.minimal(),
            onProjectionChanged: projections.add,
          ),
        ),
      ),
    );

    expect(projections, isNotEmpty);

    final projection = projections.last;
    expect(projection.viewport.totalCount, 3);
    expect(projection.chartSize.width, greaterThan(0));
    expect(projection.chartSize.height, greaterThan(0));
    expect(projection.chartSize.width, projection.mapper.chartWidth);
    expect(projection.chartSize.height, projection.mapper.chartHeight);

    expect(projection.contentBounds.width, greaterThan(0));
    expect(projection.contentBounds.height, greaterThan(0));
    expect(projection.contentBounds.left, projection.padding.left);
    expect(projection.contentBounds.top, projection.padding.top);

    final xAtStart = projection.mapper.indexToX(projection.viewport.startIndex);
    expect(
        projection.mapper.xToIndex(xAtStart), projection.viewport.startIndex);
  });

  testWidgets('onProjectionChanged does not emit on non-projection rebuilds',
      (tester) async {
    final projections = <ChartProjection>[];
    final rebuildTick = ValueNotifier<int>(0);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: rebuildTick,
          builder: (context, tick, child) {
            return Column(
              children: [
                Text('tick $tick'),
                SizedBox(
                  width: 320,
                  height: 180,
                  child: ImpChart(
                    candles: _candles(),
                    style: ChartStyle.minimal(),
                    onProjectionChanged: projections.add,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pump();

    expect(projections.length, 1);

    rebuildTick.value = 1;
    await tester.pump();
    await tester.pump();

    expect(projections.length, 1);
  });

  testWidgets('external crosshair mapping uses actual rendered size',
      (tester) async {
    final projections = <ChartProjection>[];
    final candles = _candles(count: 20);
    const chartWidth = 500.0;
    const chartHeight = 250.0;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: chartWidth,
          height: chartHeight,
          child: ImpChart(
            candles: candles,
            style: ChartStyle.minimal(),
            onProjectionChanged: projections.add,
          ),
        ),
      ),
    );
    await tester.pump();

    final projection = projections.single;
    final targetIndex = projection.viewport.startIndex + 8;
    final targetPosition = Offset(
      projection.mapper.getCandleCenterX(targetIndex),
      projection.mapper.paddingTop + 16,
    );
    final expectedAbsoluteIndex = projection.mapper.xToIndex(targetPosition.dx);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: chartWidth,
          height: chartHeight,
          child: ImpChart(
            candles: candles,
            style: ChartStyle.minimal(),
            onProjectionChanged: projections.add,
            externalCrosshairPosition: targetPosition,
          ),
        ),
      ),
    );

    final chartPainter = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(ImpChart),
        matching: find.byType(CustomPaint),
      ),
    );
    final painter = chartPainter.painter! as ChartPainter;

    expect(
      painter.crosshairIndex,
      expectedAbsoluteIndex - projection.viewport.startIndex,
    );
  });
}
