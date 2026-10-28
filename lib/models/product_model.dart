class ProductModel {
  final String id;
  final String name;
  final String category;
  final String subtitle;
  final String description;
  final double price;
  final double? originalPrice; // for showing discount
  final String asset; // local asset path
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final bool isFeatured;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subtitle,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.asset,
    this.tags = const [],
    this.rating = 4.5,
    this.reviewCount = 0,
    this.isNew = false,
    this.isFeatured = false,
  });

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'subtitle': subtitle,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'asset': asset,
        'tags': tags,
        'rating': rating,
        'reviewCount': reviewCount,
        'isNew': isNew,
        'isFeatured': isFeatured,
      };
}

// ── Product Catalogue ─────────────────────────────────────────────────────────

class ProductCatalogue {
  static const List<ProductModel> all = [
    // ── NIVARA collection ─────────────────────────────
    ProductModel(
      id: 'nivara-sofa-01',
      name: 'Nivara Lounge Sofa',
      category: 'Living Room',
      subtitle: 'Modern Living Spaces',
      description:
          'The Nivara Lounge Sofa redefines contemporary comfort with its '
          'low-profile silhouette and premium fabric upholstery. Crafted from '
          'solid teak with hand-stitched cushions, it anchors any living space '
          'with understated luxury.',
      price: 84999,
      originalPrice: 99999,
      asset: 'assets/images/nivara.png',
      tags: ['Sofa', 'Teak', 'Premium'],
      rating: 4.8,
      reviewCount: 124,
      isFeatured: true,
    ),
    ProductModel(
      id: 'nivara-coffee-01',
      name: 'Nivara Coffee Table',
      category: 'Living Room',
      subtitle: 'Artisan Crafted',
      description:
          'Hand-finished in a warm walnut tone, the Nivara Coffee Table pairs '
          'clean geometric lines with a tempered glass top. Pairs perfectly '
          'with the Nivara Lounge Sofa.',
      price: 32999,
      originalPrice: 38000,
      asset: 'assets/images/nivara.png',
      tags: ['Table', 'Walnut', 'Glass'],
      rating: 4.6,
      reviewCount: 88,
    ),
    ProductModel(
      id: 'nivara-shelf-01',
      name: 'Nivara Wall Shelf',
      category: 'Living Room',
      subtitle: 'Minimal Storage',
      description:
          'Floating wall shelf in solid mango wood with a hand-rubbed oil '
          'finish. Minimal yet functional — holds décor, books, or plants '
          'with effortless elegance.',
      price: 14999,
      asset: 'assets/images/nivara.png',
      tags: ['Shelf', 'Mango Wood', 'Wall'],
      rating: 4.4,
      reviewCount: 56,
      isNew: true,
    ),

    // ── QUBO collection ───────────────────────────────
    ProductModel(
      id: 'qubo-lamp-01',
      name: 'Qubo Task Lamp',
      category: 'Lighting',
      subtitle: 'Study Light',
      description:
          'Precision-engineered for focus, the Qubo Task Lamp delivers '
          'adaptive illumination with a 3-step colour temperature and '
          '5-level dimmer. Its minimal cubic form sits beautifully on any desk.',
      price: 8999,
      originalPrice: 11999,
      asset: 'assets/images/qubo.png',
      tags: ['Lamp', 'LED', 'Dimmable'],
      rating: 4.7,
      reviewCount: 210,
      isFeatured: true,
    ),
    ProductModel(
      id: 'qubo-floor-01',
      name: 'Qubo Floor Lamp',
      category: 'Lighting',
      subtitle: 'Ambient Lighting',
      description:
          'Standing 165 cm tall, the Qubo Floor Lamp casts a warm ambient '
          'glow through a frosted glass diffuser. Powder-coated matte black '
          'steel frame with adjustable head.',
      price: 18500,
      asset: 'assets/images/qubo.png',
      tags: ['Floor Lamp', 'Steel', 'Glass'],
      rating: 4.5,
      reviewCount: 74,
      isNew: true,
    ),
    ProductModel(
      id: 'qubo-pendant-01',
      name: 'Qubo Pendant Light',
      category: 'Lighting',
      subtitle: 'Dining & Living',
      description:
          'A clean geometric pendant with a spun aluminium shade and '
          'braided textile cord. Available in matt white and charcoal. '
          'Easy ceiling rose installation included.',
      price: 12500,
      originalPrice: 15000,
      asset: 'assets/images/qubo.png',
      tags: ['Pendant', 'Aluminium', 'Ceiling'],
      rating: 4.6,
      reviewCount: 95,
    ),

    // ── NEURO BITE collection ─────────────────────────
    ProductModel(
      id: 'neurobite-01',
      name: 'Neuro Bite Device',
      category: 'Assistive',
      subtitle: 'Independent Eating',
      description:
          'The Neuro Bite is an assistive eating device engineered for '
          'individuals with upper-limb paralysis. Its ergonomic clamp-mount '
          'system and motorised scoop mechanism restore dining dignity '
          'with grace and precision.',
      price: 24999,
      originalPrice: 29999,
      asset: 'assets/images/neuro bit.png',
      tags: ['Assistive', 'Healthcare', 'Motorised'],
      rating: 4.9,
      reviewCount: 43,
      isFeatured: true,
    ),

    // ── GENERAL / DECOR ───────────────────────────────
    ProductModel(
      id: 'decor-vase-01',
      name: 'Terracotta Vase Set',
      category: 'Décor',
      subtitle: 'Hand-Thrown Pottery',
      description:
          'A set of three hand-thrown terracotta vases in graduating heights. '
          'Each piece bears the maker\'s mark and subtle variations that '
          'celebrate handcraft over machine perfection.',
      price: 4999,
      asset: 'assets/images/1.jpg',
      tags: ['Vase', 'Terracotta', 'Set of 3'],
      rating: 4.3,
      reviewCount: 38,
      isNew: true,
    ),
    ProductModel(
      id: 'decor-cushion-01',
      name: 'Block-Print Cushion Cover',
      category: 'Décor',
      subtitle: 'Hand Block-Printed',
      description:
          'Ajrakh hand block-printed cotton cushion covers in a '
          'deep indigo and ochre palette. Set of two, 45×45 cm, '
          'with concealed zip. Machine washable.',
      price: 2499,
      originalPrice: 3200,
      asset: 'assets/images/1.jpg',
      tags: ['Cushion', 'Cotton', 'Block Print'],
      rating: 4.5,
      reviewCount: 117,
    ),
  ];

  static List<String> get categories {
    final cats = all.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  static List<ProductModel> byCategory(String category) {
    if (category == 'All') return all;
    return all.where((p) => p.category == category).toList();
  }

  static List<ProductModel> get featured =>
      all.where((p) => p.isFeatured).toList();

  static ProductModel? byId(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
