import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;
  final String? address;
  final String? profilePicture;
  final bool biometricEnabled;
  final int workoutsCompleted;
  final int currentStreak;
  final DateTime? lastWorkoutDate;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.address,
    this.profilePicture,
    this.biometricEnabled = false,
    this.workoutsCompleted = 0,
    this.currentStreak = 0,
    this.lastWorkoutDate,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      age: data['age'],
      weight: (data['weight'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
      gender: data['gender'],
      address: data['address'],
      profilePicture: data['profilePicture'],
      biometricEnabled: data['biometricEnabled'] ?? false,
      workoutsCompleted: data['workoutsCompleted'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      lastWorkoutDate: data['lastWorkoutDate'] != null ? (data['lastWorkoutDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'address': address,
      'profilePicture': profilePicture,
      'biometricEnabled': biometricEnabled,
      'workoutsCompleted': workoutsCompleted,
      'currentStreak': currentStreak,
      'lastWorkoutDate': lastWorkoutDate != null ? Timestamp.fromDate(lastWorkoutDate!) : null,
    };
  }
}