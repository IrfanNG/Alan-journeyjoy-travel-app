class CurrencyOption {
  final String code;
  final String symbol;
  final String name;
  final String country;

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
    required this.country,
  });

  bool get hasDecimals => code != 'JPY' && code != 'KRW';

  String format(double amount) {
    final value = hasDecimals ? amount.toStringAsFixed(2) : amount.toStringAsFixed(0);
    return '$symbol$value';
  }
}

const List<CurrencyOption> supportedCurrencies = [
  CurrencyOption(code: 'USD', symbol: r'$', name: 'US Dollar', country: 'United States'),
  CurrencyOption(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit', country: 'Malaysia'),
  CurrencyOption(code: 'SGD', symbol: 'SGD', name: 'Singapore Dollar', country: 'Singapore'),
  CurrencyOption(code: 'EUR', symbol: r'€', name: 'Euro', country: 'European Union'),
  CurrencyOption(code: 'GBP', symbol: r'£', name: 'British Pound', country: 'United Kingdom'),
  CurrencyOption(code: 'JPY', symbol: r'¥', name: 'Japanese Yen', country: 'Japan'),
  CurrencyOption(code: 'THB', symbol: r'฿', name: 'Thai Baht', country: 'Thailand'),
  CurrencyOption(code: 'IDR', symbol: 'Rp', name: 'Indonesian Rupiah', country: 'Indonesia'),
  CurrencyOption(code: 'KRW', symbol: r'₩', name: 'Korean Won', country: 'South Korea'),
  CurrencyOption(code: 'AUD', symbol: r'A$', name: 'Australian Dollar', country: 'Australia'),
  CurrencyOption(code: 'CAD', symbol: r'C$', name: 'Canadian Dollar', country: 'Canada'),
];

CurrencyOption currencyFromCode(String code) {
  return supportedCurrencies.firstWhere(
    (c) => c.code == code,
    orElse: () => supportedCurrencies[0],
  );
}
