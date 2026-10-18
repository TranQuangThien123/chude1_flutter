import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/crypto_asset.dart';
import '../../data/models/price_alert.dart';
import '../../domain/repositories/market_repository.dart';
import '../../services/crypto_feed_service.dart';
import '../widgets/crypto_card.dart';
import 'coin_detail_screen.dart';

/// Screen 1: Real-time Crypto Market Ticker with Debounced Search & Broadcast Alerts.
class MarketTrackerScreen extends StatefulWidget {
  final CryptoFeedService feedService;
  final MarketRepository repository;

  const MarketTrackerScreen({
    super.key,
    required this.feedService,
    required this.repository,
  });

  @override
  State<MarketTrackerScreen> createState() => _MarketTrackerScreenState();
}

class _MarketTrackerScreenState extends State<MarketTrackerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<PriceAlert> _recentAlerts = [];
  StreamSubscription<PriceAlert>? _alertSubscription;

  late Stream<List<CryptoAsset>> _filteredStream;

  @override
  void initState() {
    super.initState();
    _filteredStream = widget.feedService.getFilteredMarketStream();
    _listenToBroadcastAlerts();
  }

  void _listenToBroadcastAlerts() {
    _alertSubscription = widget.feedService.alertStream.listen((alert) {
      if (!mounted) return;
      setState(() {
        _recentAlerts.insert(0, alert);
        if (_recentAlerts.length > 3) {
          _recentAlerts.removeLast();
        }
      });
    });
  }

  @override
  void dispose() {
    // Cancel alert subscription to prevent leak
    _alertSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Header
            _buildHeader(),

            // Search Bar with Debounce
            _buildSearchBar(),

            // Broadcast Alert Banner
            if (_recentAlerts.isNotEmpty) _buildAlertBanner(),

            // Realtime Market Stream List
            Expanded(
              child: StreamBuilder<List<CryptoAsset>>(
                stream: _filteredStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.bearish, size: 48),
                          const SizedBox(height: 12),
                          Text('Lỗi luồng: ${snapshot.error}', style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  final assets = snapshot.data!;
                  if (assets.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không tìm thấy mã phù hợp với từ khóa',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onRefresh: () async {
                      // Simulates pulling fresh data with Future
                      await widget.repository.getInitialAssets();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        final asset = assets[index];
                        return CryptoCard(
                          asset: asset,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CoinDetailScreen(
                                  initialAsset: asset,
                                  repository: widget.repository,
                                  feedService: widget.feedService,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Thị trường Crypto',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm coin...',
            hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      widget.feedService.searchInputSink.add('');
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (text) {
            // Push keystroke into stream sink
            widget.feedService.searchInputSink.add(text);
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildAlertBanner() {
    final latestAlert = _recentAlerts.first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: latestAlert.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: latestAlert.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(latestAlert.icon, color: latestAlert.color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              latestAlert.message,
              style: TextStyle(color: latestAlert.color, fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
