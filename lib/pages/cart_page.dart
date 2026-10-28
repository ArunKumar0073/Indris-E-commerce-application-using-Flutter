import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('My Cart', style: headingStyle(size: 20)),
        iconTheme: const IconThemeData(color: AppColors.black),
        actions: [
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Clear Cart', style: headingStyle(size: 17)),
                  content: Text('Remove all items from your cart?',
                      style: bodyStyle(size: 14)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Clear',
                            style: navStyle(
                                size: 13, color: Colors.redAccent))),
                  ],
                ),
              );
              if (confirm == true) {
                await CartService.instance.clearCart();
              }
            },
            child: Text('Clear',
                style: navStyle(size: 13, color: Colors.redAccent)),
          ),
        ],
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: CartService.instance.cartStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.green));
          }

          final items = snap.data ?? [];

          if (items.isEmpty) {
            return _EmptyCart();
          }

          final subtotal =
              items.fold<double>(0, (s, i) => s + i.total);
          final shipping = subtotal >= 50000 ? 0.0 : 499.0;
          final total = subtotal + shipping;

          return Column(
            children: [
              // Items list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _CartItemTile(item: items[i]),
                ),
              ),

              // Order summary
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  border:
                      Border(top: BorderSide(color: AppColors.border)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _SummaryRow('Subtotal', subtotal),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      'Delivery',
                      shipping,
                      note: shipping == 0 ? 'FREE' : null,
                    ),
                    const Divider(
                        height: 20, color: AppColors.border),
                    Row(
                      children: [
                        Text('Total',
                            style: navStyle(
                                size: 15, weight: FontWeight.w700)),
                        const Spacer(),
                        Text(_fmtPrice(total),
                            style: headingStyle(size: 20)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showCheckout(context, items, total),
                        icon: const Icon(Icons.shopping_bag_outlined,
                            size: 18),
                        label: Text('PROCEED TO CHECKOUT · ${_fmtPrice(total)}'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCheckout(
      BuildContext context, List<CartItem> items, double total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CheckoutSheet(items: items, total: total),
    );
  }

  String _fmtPrice(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

// ── Cart item tile ────────────────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Image.asset(item.product.asset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cream,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.border),
                      )),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: navStyle(
                        size: 13, weight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(item.product.category,
                    style: bodyStyle(
                        size: 11.5, color: AppColors.green)),
                const SizedBox(height: 6),
                Text(_fmtPrice(item.product.price),
                    style: navStyle(
                        size: 13, weight: FontWeight.w700)),
              ],
            ),
          ),

          // Qty stepper + delete
          Column(
            children: [
              // Delete
              GestureDetector(
                onTap: () => CartService.instance
                    .removeFromCart(item.product.id),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: Colors.redAccent),
              ),
              const SizedBox(height: 8),
              // Stepper
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Btn(
                      icon: Icons.remove,
                      onTap: () => CartService.instance
                          .updateQuantity(
                              item.product.id, item.quantity - 1),
                    ),
                    SizedBox(
                      width: 28,
                      child: Center(
                          child: Text('${item.quantity}',
                              style: navStyle(
                                  size: 13,
                                  weight: FontWeight.w700))),
                    ),
                    _Btn(
                      icon: Icons.add,
                      onTap: () => CartService.instance
                          .updateQuantity(
                              item.product.id, item.quantity + 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(_fmtPrice(item.total),
                  style:
                      bodyStyle(size: 11, color: AppColors.textGrey)),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtPrice(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 14, color: AppColors.black),
        ),
      );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final String? note;
  const _SummaryRow(this.label, this.value, {this.note});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(label, style: bodyStyle(size: 13.5)),
          const Spacer(),
          if (note != null)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(note!,
                  style: navStyle(
                      size: 10,
                      color: AppColors.green,
                      weight: FontWeight.w700)),
            ),
          Text(
            value == 0 && note == 'FREE'
                ? '₹0'
                : '₹${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
            style: navStyle(size: 13.5),
          ),
        ],
      );
}

// ── Empty cart ────────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text('Your cart is empty', style: headingStyle(size: 20)),
            const SizedBox(height: 8),
            Text('Browse our collections and add items you love.',
                style: bodyStyle(size: 13.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BROWSE COLLECTIONS'),
            ),
          ],
        ),
      );
}

// ── Checkout bottom sheet ─────────────────────────────────────────────────────

class _CheckoutSheet extends StatefulWidget {
  final List<CartItem> items;
  final double total;
  const _CheckoutSheet({required this.items, required this.total});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  bool _placing = false;
  bool _placed = false;
  String _orderId = '';

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);
    try {
      final id = await OrderService.instance.placeOrder(
        items: widget.items,
        address: _addressController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _placed = true;
          _orderId = id;
          _placing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _placing = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: _placed ? _SuccessView(orderId: _orderId) : _FormView(
        formKey: _formKey,
        addressController: _addressController,
        total: widget.total,
        placing: _placing,
        onPlace: _placeOrder,
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final double total;
  final bool placing;
  final VoidCallback onPlace;

  const _FormView({
    required this.formKey,
    required this.addressController,
    required this.total,
    required this.placing,
    required this.onPlace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 16),
        Text('Checkout', style: headingStyle(size: 22)),
        const SizedBox(height: 4),
        Text('Order total: ₹${total.toStringAsFixed(0)}',
            style: bodyStyle(size: 13.5, color: AppColors.green)),
        const SizedBox(height: 20),
        Form(
          key: formKey,
          child: TextFormField(
            controller: addressController,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText: 'Delivery address (flat, street, city, pincode)'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter delivery address' : null,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: placing ? null : onPlace,
            child: placing
                ? const SizedBox(
                    height: 18, width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('PLACE ORDER'),
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String orderId;
  const _SuccessView({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const Icon(Icons.check_circle_outline_rounded,
            size: 64, color: AppColors.green),
        const SizedBox(height: 16),
        Text('Order Confirmed!', style: headingStyle(size: 22)),
        const SizedBox(height: 8),
        Text('Your order has been placed successfully.',
            style: bodyStyle(size: 14), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text('Order ID: $orderId',
            style: bodyStyle(size: 11.5, color: AppColors.textGrey)
                .copyWith(fontFamily: 'monospace'),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close sheet
              Navigator.pop(context); // go back to collections
            },
            child: const Text('CONTINUE SHOPPING'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
