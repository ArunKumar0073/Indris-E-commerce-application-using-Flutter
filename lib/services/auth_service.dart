import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles Firebase Auth operations and persists the JWT (ID token)
/// in secure device storage so it survives app restarts.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'indris_jwt';

  // ── Stream ────────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ── Registration ──────────────────────────────────────────────────────────

  /// Creates the Firebase Auth account first (critical step).
  /// Then updates display name, writes Firestore profile, and persists JWT
  /// as fire-and-forget operations so they never block the UI.
  Future<UserCredential> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // Step 1 — Create the auth account (most important, must succeed)
    final credential = await _auth
        .createUserWithEmailAndPassword(
          email: email.trim().toLowerCase(),
          password: password,
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception(
              'Registration timed out. Check your internet connection.'),
        );

    final user = credential.user!;

    // Step 2 — Non-blocking: update display name + Firestore + JWT
    // We do NOT await these so the auth stream fires immediately
    // and the UI navigates to MainShell without waiting.
    _postRegisterTasks(user, fullName, email).catchError((_) {
      // Silent — profile can be written on next login if it fails now
    });

    return credential;
  }

  Future<void> _postRegisterTasks(
      User user, String fullName, String email) async {
    // Update display name
    try {
      await user.updateDisplayName(fullName.trim());
    } catch (_) {}

    // Write Firestore profile
    try {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': '',
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
    } catch (_) {}

    // Persist JWT
    try {
      await _persistToken(user);
    } catch (_) {}
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth
        .signInWithEmailAndPassword(
          email: email.trim().toLowerCase(),
          password: password,
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception(
              'Login timed out. Check your internet connection.'),
        );

    // Persist JWT in background — don't block navigation
    _persistToken(credential.user!).catchError((_) {});

    return credential;
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey).catchError((_) {});
    await _auth.signOut();
  }

  // ── Password reset ────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  // ── JWT helpers ───────────────────────────────────────────────────────────

  Future<String?> getStoredToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> refreshToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      await _persistToken(user);
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  // ── Firestore profile helpers ─────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
      return doc.exists ? doc.data() : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required String fullName,
    required String phone,
    required String bio,
  }) async {
    await _db.collection('users').doc(uid).set(
      {
        'uid': uid,
        'fullName': fullName.trim(),
        'phone': phone.trim(),
        'bio': bio.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true), // merge so we don't wipe createdAt
    ).timeout(const Duration(seconds: 10));

    await _auth.currentUser?.updateDisplayName(fullName.trim());
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _persistToken(User user) async {
    final token = await user
        .getIdToken(true)
        .timeout(const Duration(seconds: 10));
    if (token != null) {
      await _storage.write(key: _tokenKey, value: token);
    }
  }
}
