import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  (ref) => AuthNotifier(),
);

final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _init() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        state = const AsyncValue.data(null);
      } else {
        try {
          final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (userDoc.exists) {
            final user = UserModel.fromFirestore(userDoc);
            state = AsyncValue.data(user);
          } else {
            // User exists in Auth but not in Firestore - this shouldn't happen after signup
            // but we'll create a basic user model to prevent sign-in issues
            debugPrint('User exists in Auth but not in Firestore. Creating basic user model.');
            final basicUser = UserModel(
              id: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              name: firebaseUser.displayName ?? 'User',
              role: UserRole.customer,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            state = AsyncValue.data(basicUser);
          }
        } catch (e, stack) {
          // If Firestore fetch fails, don't break the auth state
          // The user is still authenticated in Firebase Auth
          debugPrint('Firestore fetch failed, but user is authenticated: $e');
          // Create a basic user model from Firebase Auth data
          final basicUser = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? 'User',
            role: UserRole.customer,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          state = AsyncValue.data(basicUser);
        }
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phoneNumber,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Failed to create user');

      // Create user document in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        role: role,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());

      state = AsyncValue.data(userModel);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      debugPrint('Attempting sign in for: $email');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      debugPrint('Sign in successful for: $email');
    } catch (e, stack) {
      debugPrint('Sign in failed: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final currentUser = state.value;
      if (currentUser == null) return;

      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        phoneNumber: phoneNumber ?? currentUser.phoneNumber,
        profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(currentUser.id)
          .update(updatedUser.toFirestore());

      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
