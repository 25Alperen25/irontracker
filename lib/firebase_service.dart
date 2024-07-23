import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(String userId, String email, String username, double height, double weight) {
    return _firestore.collection('users').doc(userId).set({
      'email': email,
      'username': username,
      'height': height,
      'weight': weight,
    });
  }

  Future<void> addDailyProgress(String userId, String day, List<String> exercises) {
    return _firestore.collection('users').doc(userId).collection('daily_progress').doc(day).set({
      'exercises': exercises,
    });
  }

  Future<DocumentSnapshot> getDailyProgress(String userId, String day) {
    return _firestore.collection('users').doc(userId).collection('daily_progress').doc(day).get();
  }

  Future<void> setDailyProgress(String userId, String day, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(userId).collection('daily_progress').doc(day).set(data, SetOptions(merge: true));
  }

  Future<void> deleteUser(String userId) {
    return _firestore.collection('users').doc(userId).delete();
  }

  Future<void> deleteDailyProgress(String userId, String day) {
    return _firestore.collection('users').doc(userId).collection('daily_progress').doc(day).delete();
  }

  Future<void> setUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
      print("User data updated successfully");
    } catch (e) {
      print("Failed to update user data: $e");
    }
  }

  Future<DocumentSnapshot> getUser(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      print("Failed to get user data: $e");
      rethrow;
    }
  }
}
