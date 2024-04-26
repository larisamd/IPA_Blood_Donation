import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../models/donor.dart';

class AuthenticationService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Donor?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Reload user to get the latest email verification status
        await userCredential.user!.reload();

        if (userCredential.user!.emailVerified) {
          // continue with login if email is verified
          return Donor(
            id: userCredential.user!.uid,
            // add additional user details
            name: '',
            lastName: '',
            email: '',
            password: '',
            bloodType: '',
            city: '',
          );
        } else {
          // log out user if email is not verified
          await _firebaseAuth.signOut();
          throw firebase_auth.FirebaseAuthException(
            code: 'email_not_verified',
            message: 'Please verify your email before logging in.',
          );
        }
      } else {
        return null;
      }
    } catch (e) {
      //print('Error signing in: $e');
      return null;
    }
  }

  Future<bool> emailExistsInFirestore(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('donor')
          .where('email', isEqualTo: email)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      //print('Error checking email existence in Firestore: $e');
      return true; // return true in case of error to prevent registration
    }
  }

  Future<Donor?> registerWithEmailAndPassword(String email, String password,
      String name, String lastName, String bloodType, String city) async {
    try {
      firebase_auth.UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // make a new user document in Firestore with additional details
      await _firestore.collection('donor').doc(userCredential.user!.uid).set({
        'name': name,
        'lastName': lastName,
        'email': email,
        'bloodType': bloodType,
        'city': city,
      });

      // return created user
      return Donor(
        id: userCredential.user!.uid,
        name: name,
        lastName: lastName,
        email: email,
        password: password,
        bloodType: bloodType,
        city: city,
      );
    } catch (e) {
      //print(e);
      return null;
    }
  }

  Future<Donor?> getUserFromFirestore(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('donor').doc(userId).get();
      if (snapshot.exists) {
        return Donor(
          id: snapshot.id,
          name: snapshot['name'],
          lastName: snapshot['lastName'],
          email: snapshot['email'],
          password: '',
          bloodType: snapshot['bloodType'],
          city: snapshot['city'],
        );
      } else {
        return null;
      }
    } catch (e) {
      //print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      //print('Error signing out: $e');
    }
  }
}
