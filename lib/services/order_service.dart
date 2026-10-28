import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';
import 'cart_service.dart';

/// Manages orders in Firestore.
/// Path: users/{uid}/orders/{orderId}
class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _db.collection('users').doc(_uid).collection('orders');

  // ── Place order ───────────────────────────────────────────────────────────

  Future<String> placeOrder({
    required List<CartItem> items,
    required String address,
  }) async {
    if (_uid == null) throw Exception('Not logged in');
    if (items.isEmpty) throw Exception('Cart is empty');

    final subtotal = items.fold<double>(0, (s, i) => s + i.total);
    final shipping = subtotal >= 50000 ? 0.0 : 499.0;
    final total = subtotal + shipping;

    final ref = _ordersRef.doc();
    final order = OrderModel(
      id: ref.id,
      userId: _uid!,
      items: items,
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      status: 'confirmed',
      createdAt: DateTime.now(),
      address: address,
    );

    await ref.set(order.toMap());

    // Clear cart after placing order
    await CartService.instance.clearCart();

    return ref.id;
  }

  // ── Stream ────────────────────────────────────────────────────────────────

  Stream<List<OrderModel>> get ordersStream {
    if (_uid == null) return const Stream.empty();
    return _ordersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => OrderModel.fromMap(d.data())).toList());
  }

  Future<List<OrderModel>> getOrders() async {
    if (_uid == null) return [];
    final snap =
        await _ordersRef.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => OrderModel.fromMap(d.data())).toList();
  }
}
