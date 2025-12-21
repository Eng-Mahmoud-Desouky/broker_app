import 'package:flutter/material.dart';

import '../../domain/entities/order_status.dart';

/// Badge widget for displaying order status
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool showIcon;
  final double fontSize;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.getStatusColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.getStatusColor(), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              status.getStatusIcon(),
              size: fontSize + 4,
              color: status.getStatusColor(),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status.arabicLabel,
            style: TextStyle(
              color: status.getStatusColor(),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
