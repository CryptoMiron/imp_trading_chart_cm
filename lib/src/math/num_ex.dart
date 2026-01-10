/// Numeric formatting helpers for human-readable display.
///
/// This extension adds **presentation-only utilities** to `num`.
/// It is intentionally:
/// - Stateless
/// - UI-focused
/// - Independent from business logic
///
/// Common use cases:
/// - Axis labels
/// - Volume / market cap formatting
/// - Compact numeric displays
/// - Ordinal rankings (1st, 2nd, 3rd)
///
/// ⚠️ IMPORTANT:
/// These helpers should NEVER be used for calculations.
/// They are strictly for **display purposes**.
extension DoubleFormatting on num {
  /// Formats a number into a compact human-readable string.
  ///
  /// Examples:
  /// - 950        → "950"
  /// - 1200       → "1.2K"
  /// - 1500000    → "1.5M"
  /// - 2000000000 → "2.0B"
  ///
  /// Formatting rules:
  /// - Uses fixed 1 decimal for K/M/B
  /// - Drops decimals for small round numbers
  /// - Keeps UI clean and readable
  String get formatNumber {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)}B';
    } else if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    } else {
      // If number is a clean multiple of 10, avoid decimals
      if (this % 10 == 0) {
        return toStringAsFixed(0);
      } else {
        return toStringAsFixed(1);
      }
    }
  }

  /// Formats a number into a compact string with configurable precision.
  ///
  /// Parameters:
  /// - [pos] → number of decimal places (default: 2)
  ///
  /// Examples (pos = 2):
  /// - 1500        → "1.50K"
  /// - 2500000    → "2.50M"
  /// - 3000000000 → "3.00B"
  ///
  /// Useful when:
  /// - Precision matters (financial UI)
  /// - Different widgets require different decimal control
  String formatNumWithPos({int pos = 2}) {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(pos)}B';
    } else if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(pos)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(pos)}K';
    } else {
      // Avoid unnecessary decimals for clean numbers
      if (this % 10 == 0) {
        return toStringAsFixed(0);
      } else {
        return toStringAsFixed(pos);
      }
    }
  }

  /// Converts a number into its ordinal representation.
  ///
  /// Examples:
  /// - 1  → "1st"
  /// - 2  → "2nd"
  /// - 3  → "3rd"
  /// - 4  → "4th"
  /// - 11 → "11th"
  /// - 13 → "13th"
  ///
  /// Special handling:
  /// - 11, 12, 13 always use "th"
  ///
  /// Common use cases:
  /// - Rankings
  /// - Positions
  /// - Leaderboards
  String get ordinal {
    // Handle special cases: 11th, 12th, 13th
    if (this % 100 >= 11 && this % 100 <= 13) return "${this}th";

    switch (this % 10) {
      case 1:
        return "${this}st";
      case 2:
        return "${this}nd";
      case 3:
        return "${this}rd";
      default:
        return "${this}th";
    }
  }
}
