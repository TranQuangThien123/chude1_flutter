import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Diagnostic status badge displaying active Stream subscriptions & leak protection status.
class StreamLifecycleBadge extends StatelessWidget {
  final int activeSubscriptions;
  final bool isDisposed;
  final String statusText;

  const StreamLifecycleBadge({
    super.key,
    required this.activeSubscriptions,
    this.isDisposed = false,
    this.statusText = 'Trực tuyến (Live)',
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = isDisposed
        ? AppColors.textSecondary
        : (activeSubscriptions > 0 ? AppColors.bullish : AppColors.warning);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isDisposed ? 'Đã ngắt kết nối' : statusText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
