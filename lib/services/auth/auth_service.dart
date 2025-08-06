import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class AuthService extends ChangeNotifier {
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // instance for firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // sign in user
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      //sign in with email and password
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      try {
        await _fireStore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'createdAt': Timestamp.now(),
        }, SetOptions(merge: true));
      } catch (e) {
        print("Firestore error: $e");
      }

      // Token speichern
      await _saveDeviceToken(userCredential.user!.uid);

      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw Exception(e.code); // handle error appropriately
    }
  }

  // register user
  Future<UserCredential> registerWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      // Register user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optionally set display name
      await userCredential.user?.updateDisplayName(displayName);

      // Optionally update Firestore user document
      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'displayName': displayName,
        'createdAt': Timestamp.now(),
      }, SetOptions(merge: true));

      // Token speichern
      await _saveDeviceToken(userCredential.user!.uid);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('email-already-in-use');
      }
      throw Exception(e.code);
    } catch (e) {
      throw Exception('unknown-error');
    }
  }

  // sign out user
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  // get token for push notifications
  Future<void> _saveDeviceToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _fireStore.collection('users').doc(userId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }
  }

}