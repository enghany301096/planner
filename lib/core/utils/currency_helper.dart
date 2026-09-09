class CurrencyHelper {
  static const egp = 'EGP';
  static const usd = 'USD';
  static const sar = 'SAR';
  static const codes = [egp, usd, sar];

  static String normalize(String? raw) {
    switch (raw) {
      case 'L.E':
      case 'LE':
      case 'EGP':
        return egp;
      case r'$':
      case 'USD':
        return usd;
      case 'SAR':
        return sar;
      default:
        return (raw == null || raw.isEmpty) ? egp : raw;
    }
  }

  static double toUsd(
    double amount,
    String currency, {
    required double usdToEgp,
    required double usdToSar,
  }) {
    switch (normalize(currency)) {
      case usd:
        return amount;
      case egp:
        return usdToEgp > 0 ? amount / usdToEgp : amount;
      case sar:
        return usdToSar > 0 ? amount / usdToSar : amount;
      default:
        return amount;
    }
  }

  static double fromUsd(
    double usdAmount,
    String target, {
    required double usdToEgp,
    required double usdToSar,
  }) {
    switch (normalize(target)) {
      case usd:
        return usdAmount;
      case egp:
        return usdAmount * usdToEgp;
      case sar:
        return usdAmount * usdToSar;
      default:
        return usdAmount;
    }
  }

  static double convert(
    double amount,
    String from,
    String to, {
    required double usdToEgp,
    required double usdToSar,
  }) {
    if (normalize(from) == normalize(to)) return amount;
    return fromUsd(
      toUsd(amount, from, usdToEgp: usdToEgp, usdToSar: usdToSar),
      to,
      usdToEgp: usdToEgp,
      usdToSar: usdToSar,
    );
  }

  static String symbol(String currency) {
    switch (normalize(currency)) {
      case usd:
        return r'$';
      case sar:
        return 'SAR';
      default:
        return 'EGP';
    }
  }

  static const hiddenMask = '••••';

  static String format(
    double amount,
    String currency, {
    bool hidden = false,
    int fractionDigits = 2,
  }) {
    if (hidden) return hiddenMask;
    return '${normalize(currency)} ${amount.toStringAsFixed(fractionDigits)}';
  }
}
