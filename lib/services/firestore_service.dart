import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile(UserModel user) async {
    try {
      debugPrint("Creating user profile in Firestore for UID: ${user.uid}");
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
      debugPrint("Firestore profile created successfully for ${user.uid}");
    } catch (e) {
      debugPrint("Error creating user profile: $e");
      // We don't rethrow here so the user can still proceed to email verification
      // even if the profile document creation failed temporarily.
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      debugPrint("Fetching user profile for UID: $uid");
      final doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 10));
      debugPrint("Firestore response received for $uid. exists: ${doc.exists}");
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      return null;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<String?> uploadProfilePicture(String uid, File imageFile) async {
    final ref = FirebaseStorage.instance.ref().child('profile_pictures').child('$uid.jpg');
    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();
    await updateUserProfile(uid, {'profilePicture': url});
    return url;
  }

  Future<void> setBiometricStatus(String uid, bool isEnabled) async {
    await _firestore.collection('users').doc(uid).update({'biometricEnabled': isEnabled});
  }

  Future<void> logWorkoutCompletion(String uid) async {
    final docRef = _firestore.collection('users').doc(uid);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      int currentStreak = data['currentStreak'] ?? 0;
      int workoutsCompleted = data['workoutsCompleted'] ?? 0;
      DateTime? lastWorkoutDate = data['lastWorkoutDate'] != null ? (data['lastWorkoutDate'] as Timestamp).toDate() : null;

      final now = DateTime.now();
      
      if (lastWorkoutDate != null) {
        final difference = now.difference(lastWorkoutDate).inDays;
        
        // If it's been exactly 1 day, increment streak.
        if (difference == 1) {
          currentStreak += 1;
        } 
        // If it's been more than 1 day, reset streak.
        else if (difference > 1) {
          currentStreak = 1; 
        }
        // If difference == 0, it means they already worked out today. Streak stays the same.
      } else {
        // First workout ever
        currentStreak = 1;
      }

      transaction.update(docRef, {
        'workoutsCompleted': workoutsCompleted + 1,
        'currentStreak': currentStreak,
        'lastWorkoutDate': Timestamp.fromDate(now),
      });
    });
  }
}
