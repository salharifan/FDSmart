import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fdsmart/features/auth/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUserDetails(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Sign In
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);

    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _fetchUserDetails(cred.user!.uid);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      if (e.code == 'unknown') {
        _errorMessage =
            "Firebase not configured. Use demo@fdsmart.com to test.";
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage =
          "Connection failed. Please configure Firebase or use Demo account.";
      _setLoading(false);
      return false;
    }
  }

  // Sign Up
  Future<bool> signUp(
    String email,
    String password,
    String name,
    String phone,
    String role,
  ) async {
    _setLoading(true);
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create User Record in Firestore
      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        email: email,
        role: role,
        name: name,
        phone: phone,
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(newUser.toMap());
      _currentUser = newUser;

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage =
          "An unexpected error occurred: $e. (Did you configure Firebase?)";
      _setLoading(false);
      return false;
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);

    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .update(updates);
        await _fetchUserDetails(_currentUser!.uid);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Change Password
  Future<bool> changePassword(String newPassword) async {
    _setLoading(true);
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Password Reset
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Fetch User Details
  Future<void> _fetchUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(
          doc.data() as Map<String, dynamic>,
          uid,
        );
      } else {
        // Fallback for users without a profile doc (e.g. legacy or demo users)
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          _currentUser = UserModel(
            uid: uid,
            email: firebaseUser.email ?? 'user@fdsmart.com',
            role: 'user',
            name:
                firebaseUser.displayName ??
                firebaseUser.email?.split('@')[0] ??
                'User',
            phone: firebaseUser.phoneNumber ?? '',
          );
        }
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  // Toggle Favorite
  Future<void> toggleFavorite(String itemId) async {
    if (_currentUser == null) return;

    List<String> updatedFavorites = List.from(_currentUser!.favorites);
    if (updatedFavorites.contains(itemId)) {
      updatedFavorites.remove(itemId);
    } else {
      updatedFavorites.add(itemId);
    }

    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'favorites': updatedFavorites,
      });
      _currentUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        role: _currentUser!.role,
        name: _currentUser!.name,
        favorites: updatedFavorites,
        tokens: _currentUser!.tokens,
      );
      notifyListeners();
    } catch (e) {
      print("Error updating favorites: $e");
    }
  }

  // Deduct Tokens
  Future<bool> deductTokens(double amount) async {
    if (_currentUser == null || _currentUser!.tokens < amount) return false;

    try {
      double newBalance = _currentUser!.tokens - amount;
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'tokens': newBalance,
      });
      _currentUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        role: _currentUser!.role,
        name: _currentUser!.name,
        favorites: _currentUser!.favorites,
        tokens: newBalance,
      );
      notifyListeners();
      return true;
    } catch (e) {
      print("Error deducting tokens: $e");
      return false;
    }
  }

  // Admin: Fetch all users
  Stream<List<UserModel>> getAllUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Admin: Delete User
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }
}
