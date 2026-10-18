import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/crypto_asset.dart';
import '../../data/models/order_book.dart';
import '../../domain/repositories/market_repository.dart';
import '../../services/crypto_feed_service.dart';
import '../widgets/order_book_widget.dart';
import '../widgets/stream_lifecycle_badge.dart';

/// Screen displaying high frequency detail for a single asset.
///
/// CRITICAL REQUIREMENT SHOWCASE:
/// Demonstrates strict stream subscription management, safe cancellation,
/// and complete disposal of stream listeners when the user exits the screen.
class CoinDetailScreen extends StatefulWidget {
  final CryptoAsset initialAsset;
  final MarketRepository repository;
  final CryptoFeedService? feedService;

  const CoinDetailScreen({
    super.key,
    required this.initialAsset,
    required this.repository,
    this.feedService,
  });

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  late CryptoAsset _asset;
  OrderBookData? _orderBook;

  // Dedicated stream subscriptions for this screen
  StreamSubscription<CryptoAsset>? _assetSubscription;
  StreamSubscription<OrderBookData>? _orderBookSubscription;

  // Stream lifecycle diagnostic counters
  int _receivedTicksCount = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _asset = widget.initialAsset;
    _subscribeToStreams();
  }

  void _subscribeToStreams() {
    widget.feedService?.logLifecycle('[LISTEN] Mở chi tiết: Lắng nghe Stream coin ${widget.initialAsset.symbol} (${widget.initialAsset.name})');

    // 1. Subscribe to high frequency asset price stream
    _assetSubscription = widget.repository.getAssetStream(widget.initialAsset.symbol).listen(
      (updatedAsset) {
        if (!mounted) return;
        setState(() {
          _asset = updatedAsset;
          _receivedTicksCount++;
        });
      },
      cancelOnError: false,
    );

    // 2. Subscribe to Order Book stream
    _orderBookSubscription = widget.repository.getOrderBookStream(widget.initialAsset.symbol).listen(
      (orderBookData) {
        if (!mounted) return;
        setState(() {
          _orderBook = orderBookData;
        });
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Cancel asset tick stream
    _assetSubscription?.cancel();
    _assetSubscription = null;

    // Cancel order book depth stream
    _orderBookSubscription?.cancel();
    _orderBookSubscription = null;

    widget.feedService?.logLifecycle('[DISPOSE] Thoát màn hình: Huỷ Stream coin ${widget.initialAsset.symbol} (${widget.initialAsset.name})');

    debugPrint('[DISPOSE] Đã cancel _assetSubscription & _orderBookSubscription thành công!');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBullish = _asset.isBullish;
    final changeColor = isBullish ? AppColors.bullish : AppColors.bearish;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Text(
              '${_asset.name} (${_asset.symbol})',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            StreamLifecycleBadge(
              activeSubscriptions: _isDisposed ? 0 : 2,
              isDisposed: _isDisposed,
              statusText: 'Trực tuyến (Live)',
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Price Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GIÁ THỊ TRƯỜNG', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            _asset.formattedPrice,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: changeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: changeColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _asset.changePercent24h >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                              color: changeColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '24h: ${_asset.formatted24hChange}',
                              style: TextStyle(
                                color: changeColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn('Cao 24h', '\$${_asset.high24h.toStringAsFixed(2)}'),
                      _buildStatColumn('Thấp 24h', '\$${_asset.low24h.toStringAsFixed(2)}'),
                      _buildStatColumn(
                        'Thay đổi (Tick)',
                        _asset.formattedTickChange,
                        valueColor: _asset.isTickBullish ? AppColors.bullish : AppColors.bearish,
                      ),
                      _buildStatColumn('Khối lượng 24h', _asset.formattedVolume),
                      _buildStatColumn('Số Ticks', '$_receivedTicksCount'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live FlChart Price Curve
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Biểu đồ biến động giá',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Tick 800ms', style: TextStyle(color: AppColors.primary, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: _buildLiveChart(isBullish),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Real-time Order Book depth
            if (_orderBook != null)
              OrderBookWidget(data: _orderBook!)
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveChart(bool isBullish) {
    final spots = <FlSpot>[];
    for (int i = 0; i < _asset.priceHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), _asset.priceHistory[i]));
    }

    final chartColor = isBullish ? AppColors.bullish : AppColors.bearish;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: AppColors.border,
            strokeWidth: 0.8,
            dashArray: [4, 4],
          ),
        ),
        titlesData: const FlTitlesData(
          show: false,
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: chartColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  chartColor.withValues(alpha: 0.3),
                  chartColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
