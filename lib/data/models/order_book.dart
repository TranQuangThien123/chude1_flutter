/// A single entry in the cryptocurrency order book.
class OrderBookEntry {
  final double price;
  final double amount;
  final double total;
  final bool isBuy;

  const OrderBookEntry({
    required this.price,
    required this.amount,
    required this.total,
    required this.isBuy,
  });
}

/// Snapshot of the live order book with bids, asks, and current spread.
class OrderBookData {
  final String symbol;
  final List<OrderBookEntry> bids; // Buy orders (green)
  final List<OrderBookEntry> asks; // Sell orders (red)
  final double currentPrice;
  final DateTime timestamp;

  const OrderBookData({
    required this.symbol,
    required this.bids,
    required this.asks,
    required this.currentPrice,
    required this.timestamp,
  });

  double get highestBid => bids.isNotEmpty ? bids.first.price : currentPrice;
  double get lowestAsk => asks.isNotEmpty ? asks.first.price : currentPrice;
  double get spread => (lowestAsk - highestBid).abs();
  double get spreadPercentage => currentPrice > 0 ? (spread / currentPrice) * 100 : 0.0;
}
