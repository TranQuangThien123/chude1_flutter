import '../../data/models/crypto_asset.dart';
import '../../data/models/order_book.dart';
import '../../data/sources/market_mock_data_source.dart';

abstract class MarketRepository {
  Stream<List<CryptoAsset>> getMarketStream();
  Stream<CryptoAsset> getAssetStream(String symbol);
  Stream<OrderBookData> getOrderBookStream(String symbol);
  Future<List<CryptoAsset>> getInitialAssets();
  int get activeListenersCount;
  void dispose();
}

class MarketRepositoryImpl implements MarketRepository {
  final MarketMockDataSource _dataSource;

  MarketRepositoryImpl({MarketMockDataSource? dataSource})
      : _dataSource = dataSource ?? MarketMockDataSource();

  @override
  Stream<List<CryptoAsset>> getMarketStream() => _dataSource.getMarketStream();

  @override
  Stream<CryptoAsset> getAssetStream(String symbol) => _dataSource.getAssetStream(symbol);

  @override
  Stream<OrderBookData> getOrderBookStream(String symbol) => _dataSource.getOrderBookStream(symbol);

  @override
  Future<List<CryptoAsset>> getInitialAssets() => _dataSource.fetchAssetsOnce();

  @override
  int get activeListenersCount => _dataSource.activeListenersCount;

  @override
  void dispose() => _dataSource.dispose();
}
