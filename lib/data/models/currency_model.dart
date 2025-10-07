/// Model representing a currency
class CurrencyModel {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  const CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Common currencies used in the app
class Currencies {
  Currencies._();

  static const CurrencyModel rwf = CurrencyModel(
    code: 'RWF',
    name: 'Rwandan Franc',
    symbol: 'FRw',
    flag: '🇷🇼',
  );

  static const CurrencyModel usd = CurrencyModel(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    flag: '🇺🇸',
  );

  static const CurrencyModel eur = CurrencyModel(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    flag: '🇪🇺',
  );

  static const CurrencyModel gbp = CurrencyModel(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    flag: '🇬🇧',
  );

  static const CurrencyModel kes = CurrencyModel(
    code: 'KES',
    name: 'Kenyan Shilling',
    symbol: 'KSh',
    flag: '🇰🇪',
  );

  static const CurrencyModel ugx = CurrencyModel(
    code: 'UGX',
    name: 'Ugandan Shilling',
    symbol: 'USh',
    flag: '🇺🇬',
  );

  static const CurrencyModel tzs = CurrencyModel(
    code: 'TZS',
    name: 'Tanzanian Shilling',
    symbol: 'TSh',
    flag: '🇹🇿',
  );

  static const List<CurrencyModel> all = [
    rwf,
    usd,
    eur,
    gbp,
    kes,
    ugx,
    tzs,
  ];

  static CurrencyModel? findByCode(String code) {
    try {
      return all.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }
}
