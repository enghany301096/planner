import 'package:flutter_test/flutter_test.dart';
import 'package:planner/core/utils/currency_helper.dart';

void main() {
  test('normalizes legacy currency keys', () {
    expect(CurrencyHelper.normalize('L.E'), CurrencyHelper.egp);
    expect(CurrencyHelper.normalize(r'$'), CurrencyHelper.usd);
    expect(CurrencyHelper.normalize('SAR'), CurrencyHelper.sar);
  });

  test('converts through USD', () {
    final egp = CurrencyHelper.convert(
      10,
      'USD',
      'EGP',
      usdToEgp: 50,
      usdToSar: 3.75,
    );
    expect(egp, 500);

    final usd = CurrencyHelper.convert(
      50,
      'EGP',
      'USD',
      usdToEgp: 50,
      usdToSar: 3.75,
    );
    expect(usd, 1);
  });

  test('format hides amounts when requested', () {
    expect(CurrencyHelper.format(12.5, 'EGP'), 'EGP 12.50');
    expect(
      CurrencyHelper.format(12.5, 'EGP', hidden: true),
      CurrencyHelper.hiddenMask,
    );
  });
}
