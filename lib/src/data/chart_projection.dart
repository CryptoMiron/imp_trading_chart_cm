import 'dart:ui' show Rect, Size;

import 'package:meta/meta.dart';
import 'package:imp_trading_chart/src/engine/chart_viewport.dart'
    show ChartViewport;
import 'package:imp_trading_chart/src/math/coordinate_mapper.dart'
    show CoordinateMapper;

@immutable
class ChartProjection {
  final CoordinateMapper mapper;
  final ChartViewport viewport;
  final Size chartSize;
  final ChartResolvedPadding padding;
  final Rect contentBounds;

  const ChartProjection({
    required this.mapper,
    required this.viewport,
    required this.chartSize,
    required this.padding,
    required this.contentBounds,
  });

  factory ChartProjection.fromMapper(CoordinateMapper mapper) {
    final chartSize = Size(mapper.chartWidth, mapper.chartHeight);
    final padding = ChartResolvedPadding(
      left: mapper.paddingLeft,
      right: mapper.paddingRight,
      top: mapper.paddingTop,
      bottom: mapper.paddingBottom,
    );

    return ChartProjection(
      mapper: mapper,
      viewport: mapper.viewport,
      chartSize: chartSize,
      padding: padding,
      contentBounds: Rect.fromLTWH(
        padding.left,
        padding.top,
        mapper.contentWidth,
        mapper.contentHeight,
      ),
    );
  }
}

@immutable
class ChartResolvedPadding {
  final double left;
  final double right;
  final double top;
  final double bottom;

  const ChartResolvedPadding({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });
}
