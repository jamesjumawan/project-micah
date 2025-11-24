extension DoubleExtensions on double {
  String toCurrency({String symbol = '\$', int decimals = 2}) {
    return '$symbol${toStringAsFixed(decimals)}';
  }

  String toPercentage({int decimals = 1}) {
    return '${toStringAsFixed(decimals)}%';
  }
}

extension IntExtensions on int {
  String toCurrency({String symbol = '\$'}) {
    return '$symbol$this';
  }

  String toAbbreviated() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}
