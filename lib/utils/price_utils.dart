class PriceUtils {
  PriceUtils._();

  static const double usdToLkr = 320;
  static const double deliveryFee = 500;

  static double parse(String value) {
    final normalized = value.toUpperCase().trim();
    final number =
        double.tryParse(normalized.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    if (normalized.contains(r'$') || normalized.contains('USD')) {
      return number * usdToLkr;
    }

    return number;
  }

  static String format(double value) {
    final rounded = value.round();
    final text = rounded.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return 'LKR $text';
  }

  static String display(dynamic value) {
    if (value is num) return format(value.toDouble());

    final text = (value ?? '').toString().trim();
    if (text.isEmpty) return format(0);
    if (text.toUpperCase().startsWith('LKR')) return text;

    return format(parse(text));
  }
}
