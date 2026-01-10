/// Line style enum shared by:
/// - Grid lines
/// - Price line
/// - Crosshair lines
///
/// Centralizing this enum ensures:
/// - Consistent visuals
/// - Single source of truth
enum LineStyle {
  solid,
  dashed,
  dotted,
}
