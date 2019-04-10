import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Just a convenient wrapper class for the current signed in user
class CurrentUser {
  static FirebaseUser auth;
  static DocumentReference ref;
  static String id = '';
  static String token = '';

  static Future<void> setUser(FirebaseUser value) async {
    if (value != null) {
      id = value.uid;
      ref = Firestore.instance.collection('users').document(id);
      auth = value;
      token = await value.getIdToken();
      return;
    }
    print('SET USER ERROR: The given FirebaseUser was null');
  }

  static Future<void> setNewUser(FirebaseUser value, String name) async {
    if (value != null) {
      id = value.uid;
      Firestore.instance.collection('users').document(id).setData({
        'name': name == null || name == '' ? value.email : name
      }).then((x) {
        ref = Firestore.instance.collection('users').document(id);
      });      
      auth = value;
      token = await value.getIdToken();
      return;
    }
    print('SET USER ERROR: The given FirebaseUser was null');
  }

  static void signOut() {
    auth = null;
    ref = null;
    id = '';
    token = '';
    FirebaseAuth.instance.signOut();
  }
}