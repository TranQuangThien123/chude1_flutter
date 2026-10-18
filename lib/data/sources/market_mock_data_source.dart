import 'dart:async';
import 'dart:math';
import '../models/crypto_asset.dart';
import '../models/order_book.dart';

/// Data source simulating real-time exchange WebSocket / socket feed using Dart Streams & Timers.
class MarketMockDataSource {
  static final MarketMockDataSource _instance = MarketMockDataSource._internal();
  factory MarketMockDataSource() => _instance;
  MarketMockDataSource._internal() {
    _initAssets();
  }

  final Random _random = Random();
  final Map<String, CryptoAsset> _assets = {};
  
  Timer? _generatorTimer;
  StreamController<List<CryptoAsset>>? _marketStreamController;
  
  // Track open controllers for asset-specific and order-book streams
  final Map<String, StreamController<CryptoAsset>> _assetControllers = {};
  final Map<String, StreamController<OrderBookData>> _orderBookControllers = {};

  // Diagnostics counters
  int _activeListenersCount = 0;
  int get activeListenersCount => _activeListenersCount;

  void _initAssets() {
    final now = DateTime.now();
    final initialList = [
      CryptoAsset(
        id: 'bitcoin',
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 64250.00,
        previousPrice: 64200.00,
        openPrice24h: 63100.00,
        high24h: 65120.00,
        low24h: 62890.00,
        volume24h: 28450120000.0,
        priceHistory: [63100, 63400, 63900, 63750, 64100, 64200, 64250],
        lastUpdated: now,
      ),
      CryptoAsset(
        id: 'ethereum',
        symbol: 'ETH',
        name: 'Ethereum',
        price: 3480.50,
        previousPrice: 3475.00,
        openPrice24h: 3390.00,
        high24h: 3520.00,
        low24h: 3370.00,
        volume24h: 15420300000.0,
        priceHistory: [3390, 3410, 3435, 3420, 3460, 3475, 3480.5],
        lastUpdated: now,
      ),
      CryptoAsset(
        id: 'solana',
        symbol: 'SOL',
        name: 'Solana',
        price: 142.40,
        previousPrice: 143.20,
        openPrice24h: 149.50,
        high24h: 151.20,
        low24h: 141.00,
        volume24h: 4120800000.0,
        priceHistory: [149.5, 148.0, 146.2, 145.0, 143.2, 142.4],
        lastUpdated: now,
      ),
      CryptoAsset(
        id: 'binancecoin',
        symbol: 'BNB',
        name: 'BNB',
        price: 585.20,
        previousPrice: 584.00,
        openPrice24h: 570.00,
        high24h: 592.00,
        low24h: 568.50,
        volume24h: 1250300000.0,
        priceHistory: [570, 574, 578, 582, 584, 585.2],
        lastUpdated: now,
      ),
      CryptoAsset(
        id: 'ripple',
        symbol: 'XRP',
        name: 'Ripple',
        price: 0.5420,
        previousPrice: 0.5460,
        openPrice24h: 0.5750,
        high24h: 0.5820,
        low24h: 0.5380,
        volume24h: 980400000.0,
        priceHistory: [0.575, 0.568, 0.555, 0.550, 0.546, 0.542],
        lastUpdated: now,
      ),
      CryptoAsset(
        id: 'cardano',
        symbol: 'ADA',
        name: 'Cardano',
        price: 0.4450,
        previousPrice: 0.4490,
        openPrice24h: 0.4780,
        high24h: 0.4850,
        low24h: 0.4410,
        volume24h: 540200000.0,
        priceHistory: [0.478, 0.470, 0.462, 0.455, 0.449, 0.445],
        lastUpdated: now,
      ),
      CryptoAsset(
        id: 'avalanche',
        symbol: 'AVAX',
        name: 'Avalanche',
        price: 28.65,
        previousPrice: 28.40,
        openPrice24h: 26.80,
        high24h: 29.40,
        low24h: 26.50,
        volume24h: 420800000.0,
        priceHistory: [26.8, 27.2, 27.8, 28.1, 28.4, 28.65],
        lastUpdated: now,
      ),
      CryptoAsset(
        id: 'polkadot',
        symbol: 'DOT',
        name: 'Polkadot',
        price: 6.82,
        previousPrice: 6.89,
        openPrice24h: 7.25,
        high24h: 7.35,
        low24h: 6.78,
        volume24h: 280100000.0,
        priceHistory: [7.25, 7.15, 7.02, 6.95, 6.89, 6.82],
        lastUpdated: now,
      ),
      CryptoAsset(
        id: 'chainlink',
        symbol: 'LINK',
        name: 'Chainlink',
        price: 14.85,
        previousPrice: 14.70,
        openPrice24h: 13.90,
        high24h: 15.20,
        low24h: 13.80,
        volume24h: 310500000.0,
        priceHistory: [13.9, 14.1, 14.4, 14.6, 14.7, 14.85],
        lastUpdated: now,
      ),
      CryptoAsset(
        id: 'near',
        symbol: 'NEAR',
        name: 'NEAR Protocol',
        price: 4.85,
        previousPrice: 4.92,
        openPrice24h: 5.25,
        high24h: 5.35,
        low24h: 4.80,
        volume24h: 240900000.0,
        priceHistory: [5.25, 5.15, 5.05, 4.98, 4.92, 4.85],
        lastUpdated: now,
      ),
    ];

    for (final asset in initialList) {
      _assets[asset.symbol] = asset;
    }
  }

  /// Single or Broadcast stream: we use Broadcast stream so multiple screens,
  /// widgets, and alert listeners can subscribe simultaneously.
  Stream<List<CryptoAsset>> getMarketStream() {
    if (_marketStreamController == null || _marketStreamController!.isClosed) {
      _marketStreamController = StreamController<List<CryptoAsset>>.broadcast(
        onListen: () {
          _activeListenersCount++;
          _startPriceGeneratorIfNeeded();
        },
        onCancel: () {
          _activeListenersCount = max(0, _activeListenersCount - 1);
          if (_activeListenersCount == 0) {
            _stopPriceGenerator();
          }
        },
      );
    }
    return _marketStreamController!.stream;
  }

  /// High frequency individual asset stream (emits every 300ms for active detail screen)
  Stream<CryptoAsset> getAssetStream(String symbol) {
    if (!_assetControllers.containsKey(symbol) || _assetControllers[symbol]!.isClosed) {
      final controller = StreamController<CryptoAsset>.broadcast();
      _assetControllers[symbol] = controller;
    }
    return _assetControllers[symbol]!.stream;
  }

  /// Real-time live order book stream for depth chart
  Stream<OrderBookData> getOrderBookStream(String symbol) {
    if (!_orderBookControllers.containsKey(symbol) || _orderBookControllers[symbol]!.isClosed) {
      final controller = StreamController<OrderBookData>.broadcast();
      _orderBookControllers[symbol] = controller;
    }
    return _orderBookControllers[symbol]!.stream;
  }

  /// Async Future demonstration: simulates network delay and returns snapshot
  Future<List<CryptoAsset>> fetchAssetsOnce({Duration delay = const Duration(milliseconds: 600)}) async {
    await Future.delayed(delay);
    return _assets.values.toList();
  }

  void _startPriceGeneratorIfNeeded() {
    if (_generatorTimer != null && _generatorTimer!.isActive) return;

    _generatorTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      _tickMarket();
    });
  }

  void _stopPriceGenerator() {
    _generatorTimer?.cancel();
    _generatorTimer = null;
  }

  void _tickMarket() {
    // Pick 2-4 assets to randomly fluctuate
    final symbols = _assets.keys.toList();
    final countToUpdate = 2 + _random.nextInt(3);

    for (int i = 0; i < countToUpdate; i++) {
      final symbol = symbols[_random.nextInt(symbols.length)];
      final current = _assets[symbol]!;

      // Price delta between -1.8% and +1.8%
      final deltaPercent = (_random.nextDouble() * 3.6 - 1.8) / 100.0;
      final newPrice = current.price * (1.0 + deltaPercent);

      // Keep up to 15 history points for sparkline
      final updatedHistory = List<double>.from(current.priceHistory)..add(newPrice);
      if (updatedHistory.length > 20) {
        updatedHistory.removeAt(0);
      }

      final updatedAsset = current.copyWith(
        previousPrice: current.price,
        price: double.parse(newPrice.toStringAsFixed(current.price < 1 ? 4 : 2)),
        high24h: max(current.high24h, newPrice),
        low24h: min(current.low24h, newPrice),
        priceHistory: updatedHistory,
        lastUpdated: DateTime.now(),
      );

      _assets[symbol] = updatedAsset;

      // Notify asset specific stream if active
      if (_assetControllers.containsKey(symbol) && !_assetControllers[symbol]!.isClosed) {
        _assetControllers[symbol]!.add(updatedAsset);
      }

      // Generate order book update
      if (_orderBookControllers.containsKey(symbol) && !_orderBookControllers[symbol]!.isClosed) {
        _orderBookControllers[symbol]!.add(_generateOrderBook(updatedAsset));
      }
    }

    // Broadcast updated market list
    if (_marketStreamController != null && !_marketStreamController!.isClosed) {
      _marketStreamController!.add(_assets.values.toList());
    }
  }

  OrderBookData _generateOrderBook(CryptoAsset asset) {
    final List<OrderBookEntry> bids = [];
    final List<OrderBookEntry> asks = [];

    double bidPrice = asset.price * 0.9995;
    double askPrice = asset.price * 1.0005;

    for (int i = 0; i < 6; i++) {
      final bidAmount = (_random.nextDouble() * 2.5 + 0.1);
      final askAmount = (_random.nextDouble() * 2.5 + 0.1);
      bidPrice -= asset.price * 0.0008 * (i + 1);
      askPrice += asset.price * 0.0008 * (i + 1);

      bids.add(OrderBookEntry(
        price: double.parse(bidPrice.toStringAsFixed(asset.price < 1 ? 4 : 2)),
        amount: double.parse(bidAmount.toStringAsFixed(3)),
        total: double.parse((bidPrice * bidAmount).toStringAsFixed(2)),
        isBuy: true,
      ));

      asks.add(OrderBookEntry(
        price: double.parse(askPrice.toStringAsFixed(asset.price < 1 ? 4 : 2)),
        amount: double.parse(askAmount.toStringAsFixed(3)),
        total: double.parse((askPrice * askAmount).toStringAsFixed(2)),
        isBuy: false,
      ));
    }

    return OrderBookData(
      symbol: asset.symbol,
      bids: bids,
      asks: asks,
      currentPrice: asset.price,
      timestamp: DateTime.now(),
    );
  }

  /// Clean shutdown of all data source resources
  void dispose() {
    _stopPriceGenerator();
    _marketStreamController?.close();
    _marketStreamController = null;
    for (final c in _assetControllers.values) {
      c.close();
    }
    _assetControllers.clear();
    for (final c in _orderBookControllers.values) {
      c.close();
    }
    _orderBookControllers.clear();
  }
}
