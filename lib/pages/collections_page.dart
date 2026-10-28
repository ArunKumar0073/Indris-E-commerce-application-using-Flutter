import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../theme/app_theme.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import 'product_detail_page.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  String _selectedCategory = 'All';
  String _sortBy = 'Featured';

  static const List<String> _sortOptions = [
    'Featured',
    'Price: Low to High',
    'Price: High to Low',
    'Top Rated',
    'Newest',
  ];

  List<ProductModel> get _filtered {
    var list = ProductCatalogue.byCategory(_selectedCategory);
    switch (_sortBy) {
      case 'Price: Low to High':
        list = [...list]..sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        list = [...list]..sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Top Rated':
        list = [...list]..sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Newest':
        list = [...list]
          ..sort((a, b) => (b.isNew ? 1 : 0) - (a.isNew ? 1 : 0));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ProductCatalogue.categories;
    final products = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────
            Container(
              color: AppColors.cream,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PREMIUM COLLECTION',
                      style: navStyle(size: 11, color: AppColors.green)),
                  const SizedBox(height: 4),
                  Text('Signature Collections',
                      style: headingStyle(size: 22)),
                ],
              ),
            ),

            // ── Category chips ────────────────────────
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final selected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.black
                            : AppColors.cream,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selected
                              ? AppColors.black
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: navStyle(
                          size: 11.5,
                          color: selected
                              ? Colors.white
                              : AppColors.textGrey,
                          weight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Count + Sort row ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text('${products.length} products',
                      style: bodyStyle(
                          size: 12.5, color: AppColors.textGrey)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showSortSheet(context),
                    child: Row(
                      children: [
                        const Icon(Icons.sort_rounded,
                            size: 16, color: AppColors.green),
                        const SizedBox(width: 4),
                        Text(_sortBy,
                            style: navStyle(
                                size: 12, color: AppColors.green)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Product list (2-column wrap) ──────────
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text('No products found',
                          style: bodyStyle(size: 14)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                      itemCount: (products.length / 2).ceil(),
                      itemBuilder: (context, rowIndex) {
                        final leftIndex = rowIndex * 2;
                        final rightIndex = leftIndex + 1;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _ProductCard(
                                    product: products[leftIndex]),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: rightIndex < products.length
                                    ? _ProductCard(
                                        product: products[rightIndex])
                                    : const SizedBox(),
                              ),
                            ],
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

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text('Sort By', style: headingStyle(size: 18)),
            ),
            ..._sortOptions.map((opt) => ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  title: Text(opt,
                      style: bodyStyle(
                          size: 14,
                          color: opt == _sortBy
                              ? AppColors.green
                              : AppColors.black)),
                  trailing: opt == _sortBy
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.green, size: 18)
                      : null,
                  onTap: () {
                    setState(() => _sortBy = opt);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      // NO Clip.hardEdge — it was cutting off the button
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Image ──────────────────────────────────
          GestureDetector(
            onTap: () => _goToDetail(context),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10)),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      product.asset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cream,
                        child: const Icon(Icons.image_outlined,
                            size: 36, color: AppColors.border),
                      ),
                    ),
                    // Badges
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.isNew)
                            _badge('NEW', AppColors.green),
                          if (product.discountPercent > 0)
                            _badge(
                                '-${product.discountPercent.toInt()}%',
                                Colors.redAccent),
                        ],
                      ),
                    ),
                    // Wishlist
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _WishlistButton(product: product),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Info ───────────────────────────────────
          GestureDetector(
            onTap: () => _goToDetail(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.category,
                      style:
                          navStyle(size: 9.5, color: AppColors.green)),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: headingStyle(size: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: Color(0xFFFFB800)),
                      const SizedBox(width: 2),
                      Text('${product.rating}',
                          style: bodyStyle(size: 10.5)),
                      Text(' (${product.reviewCount})',
                          style: bodyStyle(
                              size: 10, color: AppColors.textGrey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (product.originalPrice != null)
                    Text(
                      '₹${_fmt(product.originalPrice!)}',
                      style: bodyStyle(size: 10).copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textGrey,
                      ),
                    ),
                  Text(
                    '₹${_fmt(product.price)}',
                    style: navStyle(
                        size: 13,
                        color: AppColors.black,
                        weight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),

          // ── Add to Cart button ─────────────────────
          // Completely outside any navigation GestureDetector
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: _QuickAddButton(product: product),
          ),
        ],
      ),
    );
  }

  void _goToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product)),
    );
  }

  Widget _badge(String label, Color color) => Container(
        margin: const EdgeInsets.only(bottom: 3),
        padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: navStyle(
                size: 8.5,
                color: Colors.white,
                weight: FontWeight.w700)),
      );

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ── Wishlist button ───────────────────────────────────────────────────────────

class _WishlistButton extends StatelessWidget {
  final ProductModel product;
  const _WishlistButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: WishlistService.instance.isWishlisted(product.id),
      builder: (context, snap) {
        final isWished = snap.data ?? false;
        return GestureDetector(
          onTap: () async {
            final added = await WishlistService.instance.toggle(product);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(added
                    ? '${product.name} added to wishlist'
                    : 'Removed from wishlist'),
                duration: const Duration(seconds: 2),
              ));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWished ? Icons.favorite_rounded : Icons.favorite_border,
              size: 16,
              color: isWished ? Colors.redAccent : AppColors.textGrey,
            ),
          ),
        );
      },
    );
  }
}

// ── Quick Add to Cart button ──────────────────────────────────────────────────

class _QuickAddButton extends StatefulWidget {
  final ProductModel product;
  const _QuickAddButton({required this.product});

  @override
  State<_QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<_QuickAddButton> {
  bool _loading = false;
  bool _added = false;

  Future<void> _addToCart() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      await CartService.instance.addToCart(widget.product);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _added = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.product.name} added to cart ✓'),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 2),
      ));

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _added = false);

    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      // Show exact Firebase error — most common is PERMISSION_DENIED
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.code == 'permission-denied'
              ? 'Permission denied — please update Firestore rules in Firebase Console'
              : 'Firebase error: ${e.message}',
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: ElevatedButton(
        onPressed: _addToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _added ? AppColors.green.withValues(alpha: 0.8) : AppColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6)),
        ),
        child: _loading
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : _added
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('Added!',
                          style: navStyle(
                              size: 11.5,
                              color: Colors.white,
                              weight: FontWeight.w700)),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_shopping_cart_rounded,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('Add to Cart',
                          style: navStyle(
                              size: 11.5,
                              color: Colors.white,
                              weight: FontWeight.w600)),
                    ],
                  ),
      ),
    );
  }
}
