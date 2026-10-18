import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/order_book.dart';

/// Real-time animated Order Book showing live market depth (Bids & Asks).
class OrderBookWidget extends StatelessWidget {
  final OrderBookData data;

  const OrderBookWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Find max total for proportional depth visualization
    double maxTotal = 1.0;
    for (final bid in data.bids) {
      if (bid.total > maxTotal) maxTotal = bid.total;
    }
    for (final ask in data.asks) {
      if (ask.total > maxTotal) maxTotal = ask.total;
    }

    return Container(
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
                'Sổ lệnh trực tiếp',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Spread: ${data.spread.toStringAsFixed(2)} (${data.spreadPercentage.toStringAsFixed(3)}%)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Column Headers
          const Row(
            children: [
              Expanded(
                child: Text('Giá Bán (Ask)', style: TextStyle(color: AppColors.bearish, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Text('Khối lượng', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text('Giá Mua (Bid)', style: TextStyle(color: AppColors.bullish, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Text('Khối lượng', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 16),
          // Order Rows
          for (int i = 0; i < 5; i++)
            _buildOrderRow(
              ask: i < data.asks.length ? data.asks[i] : null,
              bid: i < data.bids.length ? data.bids[i] : null,
              maxTotal: maxTotal,
            ),
        ],
      ),
    );
  }

  Widget _buildOrderRow({
    required OrderBookEntry? ask,
    required OrderBookEntry? bid,
    required double maxTotal,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Ask side (Red)
          Expanded(
            child: Stack(
              children: [
                if (ask != null)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: (ask.total / maxTotal).clamp(0.05, 1.0),
                        child: Container(
                          color: AppColors.bearish.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ask?.price.toStringAsFixed(2) ?? '-',
                        style: const TextStyle(color: AppColors.bearish, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ask?.amount.toStringAsFixed(3) ?? '-',
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Bid side (Green)
          Expanded(
            child: Stack(
              children: [
                if (bid != null)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: (bid.total / maxTotal).clamp(0.05, 1.0),
                        child: Container(
                          color: AppColors.bullish.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bid?.price.toStringAsFixed(2) ?? '-',
                        style: const TextStyle(color: AppColors.bullish, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bid?.amount.toStringAsFixed(3) ?? '-',
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
