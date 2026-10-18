import 'package:flutter/material.dart';
import '../../domain/repositories/market_repository.dart';
import '../../services/crypto_feed_service.dart';
import 'market_tracker_screen.dart';

/// Main Dashboard container managing global reactive services and market view.
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  // Global domain and service instances
  late final MarketRepository _repository;
  late final CryptoFeedService _feedService;

  @override
  void initState() {
    super.initState();
    _repository = MarketRepositoryImpl();
    _feedService = CryptoFeedService(repository: _repository);
  }

  @override
  void dispose() {
    // Clean up all services and controllers
    _feedService.dispose();
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarketTrackerScreen(
      feedService: _feedService,
      repository: _repository,
    );
  }
}
