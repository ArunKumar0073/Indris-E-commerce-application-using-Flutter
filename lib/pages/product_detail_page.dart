import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _qty = 1;
  bool _addingToCart = false;

  ProductModel get p => widget.product;

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},');

  Future<void> _addToCart() async {
    setState(() => _addingToCart = true);
    await CartService.instance.addToCart(p, quantity: _qty);
    if (!mounted) return;
    setState(() => _addingToCart = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${p.name} × $_qty added to cart'),
      backgroundColor: AppColors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar with image ───────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.background,
            iconTheme: const IconThemeData(color: AppColors.black),
            actions: [
              StreamBuilder<bool>(
                stream: WishlistService.instance.isWishlisted(p.id),
                builder: (context, snap) {
                  final isWished = snap.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isWished
                          ? Icons.favorite_rounded
                          : Icons.favorite_border,
                      color: isWished ? Colors.redAccent : AppColors.black,
                    ),
                    onPressed: () async {
                      await WishlistService.instance.toggle(p);
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    p.asset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.cream,
                      child: const Icon(Icons.image_outlined,
                          size: 64, color: AppColors.border),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black26],
                      ),
                    ),
                  ),
                  // Badges
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Row(
                      children: [
                        if (p.isNew) _badge('NEW', AppColors.green),
                        if (p.discountPercent > 0) ...[
                          const SizedBox(width: 6),
                          _badge(
                              '-${p.discountPercent.toInt()}% OFF',
                              Colors.redAccent),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(p.category.toUpperCase(),
                      style: navStyle(size: 11, color: AppColors.green)),
                  const SizedBox(height: 6),

                  // Name
                  Text(p.name, style: headingStyle(size: 24)),
                  const SizedBox(height: 4),
                  Text(p.subtitle, style: bodyStyle(size: 13.5)),
                  const SizedBox(height: 12),

                  // Rating row
                  Row(
                    children: [
                      ...List.generate(
                          5,
                          (i) => Icon(
                                i < p.rating.floor()
                                    ? Icons.star_rounded
                                    : (i < p.rating
                                        ? Icons.star_half_rounded
                                        : Icons.star_border_rounded),
                                size: 16,
                                color: const Color(0xFFFFB800),
                              )),
                      const SizedBox(width: 6),
                      Text('${p.rating}',
                          style: navStyle(
                              size: 13, weight: FontWeight.w600)),
                      Text(' · ${p.reviewCount} reviews',
                          style: bodyStyle(size: 12.5)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${_fmt(p.price)}',
                          style: headingStyle(
                              size: 26, color: AppColors.black)),
                      if (p.originalPrice != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          '₹${_fmt(p.originalPrice!)}',
                          style: bodyStyle(size: 14).copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${p.discountPercent.toInt()}% OFF',
                            style: navStyle(
                                size: 10,
                                color: Colors.redAccent,
                                weight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.price >= 50000
                        ? 'Free delivery included'
                        : '+ ₹499 delivery',
                    style: bodyStyle(size: 12, color: AppColors.green),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  // Description
                  Text('ABOUT THIS PIECE',
                      style: navStyle(size: 11, color: AppColors.green)),
                  const SizedBox(height: 8),
                  Text(p.description,
                      style: bodyStyle(size: 14), maxLines: 20),
                  const SizedBox(height: 20),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: AppColors.border),
                              ),
                              child: Text(tag,
                                  style: navStyle(
                                      size: 11,
                                      color: AppColors.textGrey)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  // Delivery info
                  const _InfoRow(Icons.local_shipping_outlined,
                      'Free delivery on orders above ₹50,000'),
                  const SizedBox(height: 10),
                  const _InfoRow(Icons.verified_outlined,
                      '2-year craftsmanship warranty'),
                  const SizedBox(height: 10),
                  const _InfoRow(Icons.loop_outlined,
                      '14-day hassle-free returns'),
                  const SizedBox(height: 32),

                  // Qty + Add to cart
                  Row(
                    children: [
                      // Qty stepper
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _QtyBtn(
                              icon: Icons.remove,
                              onTap: _qty > 1
                                  ? () => setState(() => _qty--)
                                  : null,
                            ),
                            SizedBox(
                              width: 36,
                              child: Center(
                                child: Text('$_qty',
                                    style: navStyle(
                                        size: 14,
                                        weight: FontWeight.w700)),
                              ),
                            ),
                            _QtyBtn(
                              icon: Icons.add,
                              onTap: () => setState(() => _qty++),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addingToCart ? null : _addToCart,
                          icon: _addingToCart
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                              : const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 18),
                          label: Text(_addingToCart
                              ? 'Adding…'
                              : 'ADD TO CART'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: navStyle(
                size: 9.5,
                color: Colors.white,
                weight: FontWeight.w700)),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.green),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text, style: bodyStyle(size: 13))),
        ],
      );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon,
              size: 16,
              color: onTap != null
                  ? AppColors.black
                  : AppColors.border),
        ),
      );
}
