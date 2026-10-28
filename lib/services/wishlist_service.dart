import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

/// Manages the current user's wishlist in Firestore.
/// Path: users/{uid}/wishlist/{productId}
class WishlistService {
  WishlistService._();
  static final WishlistService instance = WishlistService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection('users').doc(_uid).collection('wishlist');

  // ── Stream ────────────────────────────────────────────────────────────────

  Stream<List<ProductModel>> get wishlistStream {
    if (_uid == null) return const Stream.empty();
    return _ref.snapshots().map((snap) {
      return snap.docs
          .map((doc) => ProductCatalogue.byId(doc.data()['productId'] ?? ''))
          .whereType<ProductModel>()
          .toList();
    });
  }

  Stream<bool> isWishlisted(String productId) {
    if (_uid == null) return Stream.value(false);
    return _ref.doc(productId).snapshots().map((doc) => doc.exists);
  }

  // ── Toggle ────────────────────────────────────────────────────────────────

  Future<bool> toggle(ProductModel product) async {
    if (_uid == null) return false;
    final doc = _ref.doc(product.id);
    final snap = await doc.get();
    if (snap.exists) {
      await doc.delete();
      return false; // removed
    } else {
      await doc.set({
        'productId': product.id,
        'addedAt': FieldValue.serverTimestamp(),
      });
      return true; // added
    }
  }

  Future<int> getCount() async {
    if (_uid == null) return 0;
    final snap = await _ref.get();
    return snap.size;
  }

  Stream<int> get countStream {
    if (_uid == null) return Stream.value(0);
    return _ref.snapshots().map((s) => s.size);
  }
}
