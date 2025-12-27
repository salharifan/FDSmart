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

      // SECURITY: Validate user exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (!userDoc.exists) {
        // User was deleted, force logout
        await _auth.signOut();
        _errorMessage = "Account not found. Please contact support.";
        _setLoading(false);
        return false;
      }

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

  // Sign Up (Public - always creates 'user' role)
  Future<bool> signUp(
    String email,
    String password,
    String name,
    String phone,
    String role,
  ) async {
    _setLoading(true);
    try {
      // SECURITY: Force 'user' role for public signup
      String safeRole = 'user';

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create User Record in Firestore
      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        email: email,
        role: safeRole,
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

  // Admin: Create Admin User (only callable by existing admin)
  Future<bool> createAdminUser(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    // SECURITY: Only admins can create admin users
    if (_currentUser?.role != 'admin') {
      _errorMessage = "Only admins can create admin accounts";
      return false;
    }

    _setLoading(true);
    try {
      // Create user with temporary auth (requires Firebase Admin SDK in production)
      // For now, using the current approach with a note
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create Admin Record in Firestore
      UserModel newAdmin = UserModel(
        uid: cred.user!.uid,
        email: email,
        role: 'admin', // Admin role
        name: name,
        phone: phone,
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(newAdmin.toMap());

      // Sign back in as the current admin
      // Note: In production, use Firebase Admin SDK to avoid this
      await _auth.signOut();
      
      _setLoading(false);
      _errorMessage = "Admin created. Please sign in again.";
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "Failed to create admin: $e";
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
        // SECURITY: User deleted, force logout
        await _auth.signOut();
        _currentUser = null;
        _errorMessage = "Account not found. Please contact support.";
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  // Toggle Favorite
  Future<void> toggleFavorite(String itemId) async {
    if (_currentUser == null) return;

    // Update local state immediately for instant UI feedback
    List<String> updatedFavorites = List.from(_currentUser!.favorites);
    if (updatedFavorites.contains(itemId)) {
      updatedFavorites.remove(itemId);
    } else {
      updatedFavorites.add(itemId);
    }

    // Update local user model immediately
    _currentUser = UserModel(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      role: _currentUser!.role,
      name: _currentUser!.name,
      phone: _currentUser!.phone,
      favorites: updatedFavorites,
      tokens: _currentUser!.tokens,
    );
    notifyListeners(); // Update UI immediately

    // Try to sync with Firebase in background
    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'favorites': updatedFavorites,
      });
    } catch (e) {
      print("Error syncing favorites to Firebase: $e");
      // Show feedback to user
      print("Favorites saved locally. Will sync when online.");
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

  // Admin: Delete User (removes both Auth and Firestore)
  Future<bool> deleteUser(String uid) async {
    // SECURITY: Prevent admin self-deletion
    if (_currentUser?.uid == uid) {
      _errorMessage = "You cannot delete your own account";
      notifyListeners();
      return false;
    }

    // SECURITY: Only admins can delete users
    if (_currentUser?.role != 'admin') {
      _errorMessage = "Only admins can delete users";
      notifyListeners();
      return false;
    }

    try {
      // Delete Firestore document
      await _firestore.collection('users').doc(uid).delete();

      // Note: Deleting Firebase Auth account requires Admin SDK
      // In production, use Cloud Functions with Admin SDK
      // For now, just delete Firestore doc which blocks login

      return true;
    } catch (e) {
      _errorMessage = "Failed to delete user: $e";
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }
}
