import 'dart:convert';
import 'dart:developer';
import 'dart:io';

class CurrencyService {
  static const String _apiUri = 'https://open.er-api.com/v6/latest/USD';

  /// Fetches the latest USD exchange rates for EGP and SAR.
  /// Returns a Map with the rates, or null if the request fails.
  static Future<Map<String, double>?> fetchLatestRates() async {
    final client = HttpClient();
    // Set connection timeout to 8 seconds
    client.connectionTimeout = const Duration(seconds: 8);

    try {
      final request = await client.getUrl(Uri.parse(_apiUri));
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(responseBody);

        if (data['result'] == 'success' && data.containsKey('rates')) {
          final rates = data['rates'] as Map<String, dynamic>;

          final double egpRate = (rates['EGP'] as num?)?.toDouble() ?? 0.0;
          final double sarRate = (rates['SAR'] as num?)?.toDouble() ?? 0.0;

          if (egpRate > 0.0 && sarRate > 0.0) {
            return {'EGP': egpRate, 'SAR': sarRate};
          }
        }
      } else {
        log('CurrencyService API error: HTTP status ${response.statusCode}');
      }
    } catch (e) {
      log('CurrencyService connection error: $e');
    } finally {
      client.close();
    }
    return null;
  }
}
