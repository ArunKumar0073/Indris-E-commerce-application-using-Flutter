import 'product_model.dart';

class CartItem {
  final ProductModel product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get total => product.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  Map<String, dynamic> toMap() => {
        'productId': product.id,
        'productName': product.name,
        'productCategory': product.category,
        'productAsset': product.asset,
        'price': product.price,
        'quantity': quantity,
        'total': total,
      };
}

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double total;
  final String status; // pending, confirmed, shipped, delivered
  final DateTime createdAt;
  final String address;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.address,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'items': items.map((i) => i.toMap()).toList(),
        'subtotal': subtotal,
        'shipping': shipping,
        'total': total,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'address': address,
      };

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: [], // items rebuilt from product catalogue when needed
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shipping: (map['shipping'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      address: map['address'] ?? '',
    );
  }
}
