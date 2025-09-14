import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/services/base_repository.dart';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthRepository extends BaseRepository {
  Stream<firebase_auth.User?> get authStateChanges =>
      auth.authStateChanges();

  Future<UserModel> signUp({
    required String username,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final formattedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), "");
      final phoneNumberExists = await checkPhoneExists(formattedPhone);
      if (phoneNumberExists) {
        throw Exception('Phone number already in use');
      }

      final emailExists = await checkEmailExists(email);
      if (emailExists) {
        throw Exception('Email already in use');
      }
      final userCredential =
          await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw Exception('User creation failed');
      }
      final user = UserModel(
        uid: userCredential.user!.uid,
        username: username,
        fullName: fullName,
        email: email,
        phoneNumber: formattedPhone,
      );
      await saveUserData(user);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> saveUserData(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to save user data');
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  // Future<bool> checkEmailExists(String email) async {
  //   try {
  //     final methods = await auth.fetchSignInMethodsForEmail(email);
  //     return methods.isNotEmpty;
  //   } catch (e) {
  //     log(e.toString());
  //     rethrow;
  //   }
  // }

  Future<bool> checkEmailExists(String email) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking email in Firestore: $e");
      throw Exception("Email verification error");
    }
  }

  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      final formattedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), "");
      final snapshot = await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential =
          await auth.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user == null) {
        throw Exception('User not found');
      }
      final user = await getUserData(userCredential.user!.uid);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
