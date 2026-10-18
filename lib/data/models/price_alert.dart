import 'package:flutter/material.dart';

enum AlertType { pump, dump, thresholdReached }

/// Broadcast notification triggered by real-time stream processing
class PriceAlert {
  final String id;
  final String symbol;
  final String message;
  final double price;
  final double deltaPercent;
  final AlertType type;
  final DateTime timestamp;

  const PriceAlert({
    required this.id,
    required this.symbol,
    required this.message,
    required this.price,
    required this.deltaPercent,
    required this.type,
    required this.timestamp,
  });

  Color get color {
    switch (type) {
      case AlertType.pump:
        return const Color(0xFF3FB950);
      case AlertType.dump:
        return const Color(0xFFF85149);
      case AlertType.thresholdReached:
        return const Color(0xFFD29922);
    }
  }

  IconData get icon {
    switch (type) {
      case AlertType.pump:
        return Icons.trending_up;
      case AlertType.dump:
        return Icons.trending_down;
      case AlertType.thresholdReached:
        return Icons.notifications_active;
    }
  }
}
