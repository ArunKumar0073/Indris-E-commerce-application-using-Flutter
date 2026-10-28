import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/cart_model.dart';
import '../services/order_service.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: Text('My Orders', style: headingStyle(size: 20)),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: OrderService.instance.ordersStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.green));
          }

          final orders = snap.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 64, color: AppColors.border),
                  const SizedBox(height: 16),
                  Text('No orders yet', style: headingStyle(size: 20)),
                  const SizedBox(height: 8),
                  Text(
                    'Your confirmed orders will appear here.',
                    style: bodyStyle(size: 13.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.id.substring(0, 8).toUpperCase()}',
                        style:
                            navStyle(size: 13, weight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(_formatDate(order.createdAt),
                        style: bodyStyle(
                            size: 11.5, color: AppColors.textGrey)),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: navStyle(
                      size: 10,
                      color: statusColor,
                      weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),

          // Items summary
          Text('ITEMS',
              style: navStyle(size: 10, color: AppColors.textGrey)),
          const SizedBox(height: 6),
          ...(order.items.isEmpty
              ? [
                  Text('See order details',
                      style: bodyStyle(size: 13))
                ]
              : order.items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(item.product.name,
                                    style: bodyStyle(size: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                            Text('× ${item.quantity}',
                                style: bodyStyle(
                                    size: 12,
                                    color: AppColors.textGrey)),
                          ],
                        ),
                      ))
                  .toList()),

          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),

          // Delivery address
          if (order.address.isNotEmpty) ...[
            Text('DELIVERY TO',
                style:
                    navStyle(size: 10, color: AppColors.textGrey)),
            const SizedBox(height: 4),
            Text(order.address,
                style: bodyStyle(size: 12.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
          ],

          // Totals row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subtotal',
                      style: bodyStyle(
                          size: 11.5, color: AppColors.textGrey)),
                  Text(_fmt(order.subtotal),
                      style: navStyle(size: 13)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery',
                      style: bodyStyle(
                          size: 11.5, color: AppColors.textGrey)),
                  Text(
                      order.shipping == 0
                          ? 'FREE'
                          : _fmt(order.shipping),
                      style: navStyle(
                          size: 13,
                          color: order.shipping == 0
                              ? AppColors.green
                              : AppColors.black)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total',
                      style: bodyStyle(
                          size: 11.5, color: AppColors.textGrey)),
                  Text(_fmt(order.total),
                      style: navStyle(
                          size: 15, weight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.green;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return const Color(0xFF2E7D32);
      case 'cancelled':
        return Colors.redAccent;
      default:
        return AppColors.textGrey;
    }
  }

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
