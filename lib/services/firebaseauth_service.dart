import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:fluttertoast/fluttertoast.dart'; 

class FirebaseAuthService { 
  // FirebaseAuth instance 
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;
  
  Future<User?> signIn({String? email, String? password}) async { 
    try { 
      UserCredential ucred = await _fbAuth.signInWithEmailAndPassword( 
        email: email!, password: password!); 
      User? user = ucred.user; 
      debugPrint("Signed In successful! userid: $ucred.user.uid, user: $user."); 
      return user!; 
    } on FirebaseAuthException catch (e) { 
      Fluttertoast.showToast(msg: e.message!, gravity: ToastGravity.TOP);
      return null; 
    } catch (e) { 
      return null; 
    } 
  }
  
  Future<User?> signUp({String? email, String? password}) async { 
    try { 
      UserCredential ucred = await _fbAuth.createUserWithEmailAndPassword( 
        email: email!, password: password!); 
      User? user = ucred.user; 
      debugPrint('Signed Up successful! user: $user'); 
      return user; 
    } on FirebaseAuthException catch (e) { 
      Fluttertoast.showToast(msg: e.message!, gravity: ToastGravity.TOP); 
      return null; 
    } catch (e) { 
      return null; 
    } 
  }
  Future<void> signOut() async { 
    await _fbAuth.signOut(); 
  }
}