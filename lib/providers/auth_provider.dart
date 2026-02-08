import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StreamSubscription<User?>? _sub;

  AuthProvider() {
    _sub = _auth.authStateChanges().listen((u) {
      _user = u;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signOut() => _auth.signOut();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
