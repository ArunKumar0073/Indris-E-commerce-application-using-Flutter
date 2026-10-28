import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/nav_bar.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onCollectionsTap;
  final VoidCallback? onCartTap;

  const HomePage({
    super.key,
    this.onProfileTap,
    this.onCollectionsTap,
    this.onCartTap,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showEnquiryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EnquiryBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndrisNavBar(
        onAccountTap: widget.onProfileTap,
      ),
      endDrawer: IndrisEndDrawer(
        onLoginTap: () {
          Navigator.pop(context);
          widget.onProfileTap?.call();
        },
        onSignupTap: () {
          Navigator.pop(context);
          widget.onProfileTap?.call();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEnquiryBottomSheet(context),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.mail_outline_rounded),
        label: Text('Enquire', style: navStyle(size: 13, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero ──────────────────────────────────
            _HeroSection(
              onShopTap: widget.onCollectionsTap,
            ),
            const SizedBox(height: 48),

            // ── Featured Products ──────────────────────
            _FeaturedSection(
              onViewAllTap: widget.onCollectionsTap,
              onCartTap: widget.onCartTap,
            ),
            const SizedBox(height: 48),

            // ── Category Banners ───────────────────────
            const _CategoryBanners(),
            const SizedBox(height: 48),

            // ── Collections ────────────────────────────
            const _CollectionsSection(),
            const SizedBox(height: 48),

            // ── Why Indris ─────────────────────────────
            const _WhyIndrisSection(),
            const SizedBox(height: 48),

            // ── FAQ ────────────────────────────────────
            const _FaqSection(),
            const SizedBox(height: 48),

            // ── Footer ─────────────────────────────────
            const _FooterSection(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HERO SECTION
// ═══════════════════════════════════════════════════════════════════

class _HeroSection extends StatelessWidget {
  final VoidCallback? onShopTap;
  const _HeroSection({this.onShopTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.asset(
            'assets/images/1.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.cream,
              child: const Icon(Icons.image_not_supported_outlined,
                  size: 64, color: AppColors.border),
            ),
          ),
        ),
        // Dark gradient overlay
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Colors.transparent, Color(0xCC17181A)],
              ),
            ),
          ),
        ),
        // Text overlay
        Positioned(
          left: 24,
          bottom: 40,
          right: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FEATURED COLLECTION',
                style: navStyle(size: 11, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Executive\nSuites',
                style: headingStyle(size: 32, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Premium living room collections',
                style: bodyStyle(size: 13, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onShopTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  elevation: 0,
                ),
                child: Text('SHOP NOW',
                    style: navStyle(
                        size: 12,
                        color: AppColors.black,
                        weight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FEATURED PRODUCTS SECTION
// ═══════════════════════════════════════════════════════════════════

class _FeaturedSection extends StatelessWidget {
  final VoidCallback? onViewAllTap;
  final VoidCallback? onCartTap;

  const _FeaturedSection({this.onViewAllTap, this.onCartTap});

  @override
  Widget build(BuildContext context) {
    final featured = ProductCatalogue.featured;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HAND-PICKED FOR YOU',
                      style: navStyle(size: 11, color: AppColors.green)),
                  const SizedBox(height: 4),
                  Text('Featured Pieces',
                      style: headingStyle(size: 22)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: onViewAllTap,
                child: Text('View all →',
                    style: navStyle(size: 12, color: AppColors.green)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Horizontal scroll of featured products
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) =>
                  _FeaturedCard(product: featured[i], onCartTap: onCartTap),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onCartTap;

  const _FeaturedCard({required this.product, this.onCartTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product)),
      ),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(product.asset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                            color: AppColors.cream,
                            child: const Icon(Icons.image_outlined,
                                size: 36, color: AppColors.border),
                          )),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: StreamBuilder<bool>(
                      stream: WishlistService.instance
                          .isWishlisted(product.id),
                      builder: (_, snap) {
                        final wished = snap.data ?? false;
                        return GestureDetector(
                          onTap: () =>
                              WishlistService.instance.toggle(product),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              wished
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border,
                              size: 14,
                              color: wished
                                  ? Colors.redAccent
                                  : AppColors.textGrey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: navStyle(
                            size: 12.5, weight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 11, color: Color(0xFFFFB800)),
                        const SizedBox(width: 2),
                        Text('${product.rating}',
                            style: bodyStyle(size: 10.5)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${_fmt(product.price)}',
                          style: navStyle(
                              size: 13, weight: FontWeight.w700),
                        ),
                        _MiniCartBtn(product: product),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _MiniCartBtn extends StatefulWidget {
  final ProductModel product;
  const _MiniCartBtn({required this.product});

  @override
  State<_MiniCartBtn> createState() => _MiniCartBtnState();
}

class _MiniCartBtnState extends State<_MiniCartBtn> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              try {
                await CartService.instance.addToCart(widget.product);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${widget.product.name} added to cart'),
                    duration: const Duration(seconds: 2),
                  ));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not add to cart: $e')),
                  );
                }
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(6),
        ),
        child: _loading
            ? const SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: Colors.white))
            : const Icon(Icons.add_shopping_cart_rounded,
                size: 12, color: Colors.white),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CATEGORY BANNERS
// ═══════════════════════════════════════════════════════════════════

class _CategoryBanners extends StatelessWidget {
  const _CategoryBanners();

  static const _cats = [
    ('Living Room', 'assets/images/nivara.png', AppColors.green),
    ('Lighting', 'assets/images/qubo.png', Color(0xFF8B7355)),
    ('Assistive', 'assets/images/neuro bit.png', Color(0xFF5B7A8B)),
    ('Décor', 'assets/images/1.jpg', Color(0xFF7A5B5B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SHOP BY CATEGORY',
                      style: navStyle(size: 11, color: AppColors.green)),
                  const SizedBox(height: 4),
                  Text('Browse Collections',
                      style: headingStyle(size: 22)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final (name, asset, color) = _cats[i];
              return Container(
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(asset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.cream)),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            color.withValues(alpha: 0.85)
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Text(name,
                          style: navStyle(
                              size: 12,
                              color: Colors.white,
                              weight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SIGNATURE COLLECTIONS SECTION (existing 3 cards)
// ═══════════════════════════════════════════════════════════════════

class _CollectionsSection extends StatelessWidget {
  const _CollectionsSection();

  static const List<(String, String, String)> _collections = [
    ('NIVARA', 'Modern Living Spaces', 'assets/images/nivara.png'),
    ('Qubo', 'Study Light', 'assets/images/qubo.png'),
    ('Neuro Bite', 'Independent Eating For Paralysis Patients',
        'assets/images/neuro bit.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text('PREMIUM COLLECTION',
              style: navStyle(size: 11.5, color: AppColors.green)),
          const SizedBox(height: 8),
          Text('Signature Design Collections',
              style: headingStyle(size: 24), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'Each collection represents the pinnacle of craftsmanship '
              'and design excellence, curated for the most discerning clients.',
              style: bodyStyle(size: 13.5),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final cards = _collections.map((c) => _CollectionCard(
                  title: c.$1,
                  subtitle: c.$2,
                  imageUrl: c.$3,
                  width: isWide
                      ? (constraints.maxWidth - 48) / 3
                      : constraints.maxWidth,
                )).toList();
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: cards,
            );
          }),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double width;

  const _CollectionCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.asset(imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cream,
                        child: const Icon(Icons.image_outlined,
                            size: 40, color: AppColors.border),
                      )),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: headingStyle(size: 17)),
          const SizedBox(height: 4),
          Text(subtitle, style: bodyStyle(size: 12.5)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// WHY INDRIS SECTION
// ═══════════════════════════════════════════════════════════════════

class _WhyIndrisSection extends StatelessWidget {
  const _WhyIndrisSection();

  static const _points = [
    (Icons.handyman_outlined, 'Handcrafted Quality',
        'Every piece made by skilled artisans using sustainable materials.'),
    (Icons.local_shipping_outlined, 'Free Delivery',
        'Complimentary delivery on all orders above ₹50,000.'),
    (Icons.loop_outlined, '14-Day Returns',
        'Not happy? Return within 14 days, no questions asked.'),
    (Icons.verified_outlined, '2-Year Warranty',
        'Backed by a 2-year craftsmanship warranty on all products.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          Text('WHY INDRIS',
              style: navStyle(size: 11.5, color: AppColors.green)),
          const SizedBox(height: 8),
          Text('Crafted With Purpose',
              style: headingStyle(size: 24), textAlign: TextAlign.center),
          const SizedBox(height: 28),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _points
                  .map((p) => SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.green
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Icon(p.$1,
                                  size: 20,
                                  color: AppColors.green),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(p.$2,
                                      style: navStyle(
                                          size: 13,
                                          weight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(p.$3,
                                      style: bodyStyle(size: 12.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FAQ SECTION
// ═══════════════════════════════════════════════════════════════════

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  static const List<(String, String)> _faqs = [
    (
      'What materials do you use in your collections?',
      'We source only premium natural materials — solid hardwoods, hand-woven '
          'textiles, and ethically produced metals — to ensure lasting quality '
          'and sustainability in every piece.',
    ),
    (
      'Do you offer custom design services?',
      'Yes. Our design team works closely with clients to create bespoke pieces '
          'tailored to their space and vision. Contact us through the enquiry panel '
          'to start a consultation.',
    ),
    (
      'What are your delivery timelines?',
      'Standard pieces ship within 2–4 weeks. Custom orders typically take '
          '6–10 weeks depending on complexity and material availability.',
    ),
    (
      'Do you ship internationally?',
      'We currently ship across India and select international destinations. '
          'Reach out to us for a shipping quote to your location.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text('FREQUENTLY ASKED',
              style: navStyle(size: 11.5, color: AppColors.green)),
          const SizedBox(height: 8),
          Text('Common Questions',
              style: headingStyle(size: 24), textAlign: TextAlign.center),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              children: _faqs
                  .map((faq) =>
                      _FaqTile(question: faq.$1, answer: faq.$2))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _isOpen = !_isOpen),
          child: Container(
            color: AppColors.cream,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.question,
                      style: navStyle(
                          size: 13.5,
                          color: AppColors.black,
                          weight: FontWeight.w600)),
                ),
                Icon(
                  _isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ),
        ),
        if (_isOpen)
          Container(
            color: AppColors.cream,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(widget.answer, style: bodyStyle(size: 13)),
          ),
        const Divider(height: 1, thickness: 1, color: AppColors.border),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ENQUIRY BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════

class _EnquiryBottomSheet extends StatefulWidget {
  const _EnquiryBottomSheet();

  @override
  State<_EnquiryBottomSheet> createState() =>
      _EnquiryBottomSheetState();
}

class _EnquiryBottomSheetState extends State<_EnquiryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding:
          EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  _submitted ? 'Thank You!' : 'Send an Enquiry',
                  style: headingStyle(size: 20)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textGrey,
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_submitted) ...[
            const SizedBox(height: 24),
            const Icon(Icons.check_circle_outline_rounded,
                size: 56, color: AppColors.green),
            const SizedBox(height: 16),
            Text(
              "We've received your message and will get back to you shortly.",
              style: bodyStyle(size: 13.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ] else ...[
            Text('Our team will respond within 1–2 business days.',
                style: bodyStyle(size: 13)),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(hintText: 'Full Name'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Enter your name'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        hintText: 'Email Address'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter your email';
                      }
                      if (!v.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Tell us about your project or question…',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Enter a message'
                            : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Send Enquiry'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FOOTER
// ═══════════════════════════════════════════════════════════════════

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.black,
      padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text('Indris',
              style: logoStyle(size: 28)
                  .copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text("Let's Work Together",
              style: headingStyle(size: 18, color: Colors.white)),
          const SizedBox(height: 12),
          Text(
            'Luxury interiors crafted for the modern home.',
            style: bodyStyle(size: 13, color: Colors.white60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF2E2F31)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ['Home', 'Collections', 'Work', 'About', 'Contact']
                .map((label) => Text(label,
                    style: navStyle(
                        size: 12, color: Colors.white54)))
                .toList(),
          ),
          const SizedBox(height: 20),
          Text(
            '© 2026 Indris. All Rights Reserved.',
            style: bodyStyle(size: 11.5, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
