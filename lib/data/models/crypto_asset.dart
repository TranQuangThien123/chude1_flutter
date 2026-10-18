import 'package:intl/intl.dart';

/// Represents a cryptocurrency asset with real-time dynamic pricing.
class CryptoAsset {
  final String id;
  final String symbol;
  final String name;
  final double price;
  final double previousPrice;
  final double openPrice24h;
  final double high24h;
  final double low24h;
  final double volume24h;
  final List<double> priceHistory;
  final DateTime lastUpdated;

  const CryptoAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.price,
    required this.previousPrice,
    required this.openPrice24h,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.priceHistory,
    required this.lastUpdated,
  });

  bool get isBullish => price >= openPrice24h;
  bool get isDailyBullish => price >= openPrice24h;
  bool get isTickBullish => price >= previousPrice;

  double get change24h => price - openPrice24h;
  double get changePercent24h => openPrice24h != 0 ? ((price - openPrice24h) / openPrice24h) * 100 : 0.0;

  double get tickChange => price - previousPrice;
  double get tickChangePercent => previousPrice != 0 ? ((price - previousPrice) / previousPrice) * 100 : 0.0;

  String get formattedPrice {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: price < 1 ? 4 : 2,
    );
    return formatter.format(price);
  }

  String get formatted24hChange {
    final sign = changePercent24h >= 0 ? '+' : '';
    return '$sign${changePercent24h.toStringAsFixed(2)}%';
  }

  bool get isHistoryBullish {
    if (priceHistory.length < 2) return isBullish;
    return priceHistory.last >= priceHistory.first;
  }

  String get formattedTickChange {
    final sign = tickChangePercent >= 0 ? '+' : '';
    return '$sign${tickChangePercent.toStringAsFixed(2)}%';
  }

  String get formattedVolume {
    if (volume24h >= 1e9) {
      return '\$${(volume24h / 1e9).toStringAsFixed(2)}B';
    } else if (volume24h >= 1e6) {
      return '\$${(volume24h / 1e6).toStringAsFixed(2)}M';
    } else {
      return '\$${(volume24h / 1e3).toStringAsFixed(2)}K';
    }
  }

  CryptoAsset copyWith({
    String? id,
    String? symbol,
    String? name,
    double? price,
    double? previousPrice,
    double? openPrice24h,
    double? high24h,
    double? low24h,
    double? volume24h,
    List<double>? priceHistory,
    DateTime? lastUpdated,
  }) {
    return CryptoAsset(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      previousPrice: previousPrice ?? this.previousPrice,
      openPrice24h: openPrice24h ?? this.openPrice24h,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      volume24h: volume24h ?? this.volume24h,
      priceHistory: priceHistory ?? this.priceHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() => '$symbol: $formattedPrice ($formatted24hChange)';
}
