import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';

class CartService {
  CartService._();
  static final CartService instance = CartService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _cartRef(String uid) =>
      _db.collection('users').doc(uid).collection('cart');

  // ── Stream ────────────────────────────────────────────────────────────────

  Stream<List<CartItem>> get cartStream {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _cartRef(uid).snapshots().map((snap) {
      final result = <CartItem>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final product = ProductCatalogue.byId(data['productId'] ?? '');
        if (product != null) {
          result.add(CartItem(
            product: product,
            quantity: (data['quantity'] ?? 1) as int,
          ));
        }
      }
      return result;
    });
  }

  Stream<int> get cartCountStream {
    final uid = _uid;
    if (uid == null) return Stream.value(0);
    return _cartRef(uid).snapshots().map((snap) {
      int count = 0;
      for (final doc in snap.docs) {
        count += (doc.data()['quantity'] ?? 1) as int;
      }
      return count;
    });
  }

  // ── Add to cart — simple direct write, no transaction ─────────────────────

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final uid = _uid;
    if (uid == null) throw Exception('Please log in first.');

    final docRef = _cartRef(uid).doc(product.id);

    // Simple get + set/update — no transaction (transactions hang on web)
    final snap = await docRef.get();

    if (snap.exists) {
      final current = (snap.data()?['quantity'] ?? 1) as int;
      await docRef.update({'quantity': current + quantity});
    } else {
      await docRef.set({
        'productId': product.id,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Update quantity ───────────────────────────────────────────────────────

  Future<void> updateQuantity(String productId, int quantity) async {
    final uid = _uid;
    if (uid == null) return;
    final doc = _cartRef(uid).doc(productId);
    if (quantity <= 0) {
      await doc.delete();
    } else {
      await doc.update({'quantity': quantity});
    }
  }

  // ── Remove ────────────────────────────────────────────────────────────────

  Future<void> removeFromCart(String productId) async {
    final uid = _uid;
    if (uid == null) return;
    await _cartRef(uid).doc(productId).delete();
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  Future<void> clearCart() async {
    final uid = _uid;
    if (uid == null) return;
    final snap = await _cartRef(uid).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}
