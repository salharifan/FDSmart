import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fdsmart/features/auth/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Sign In
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);

    // Demo mode removed

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
  Future<bool> signUp(String email, String password, String name) async {
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
        role: 'user', // Default role
        name: name,
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

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Fetch User Details
  Future<void> _fetchUserDetails(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }
}
