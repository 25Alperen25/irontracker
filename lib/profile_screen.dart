import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

final logger = Logger();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      String userId = _auth.currentUser!.uid;
      User? user = _auth.currentUser;
      if (user != null) {
        _email = user.email!;
      }
      DocumentSnapshot userDoc = await _firebaseService.getUser(userId);
      if (userDoc.exists) {
        setState(() {
          
          _weightController.text = userDoc['weight'].toString();
          _heightController.text = userDoc['height'].toString();
        });
      }
    } catch (e) {
      logger.e("Failed to load user profile: $e");
    }
  }

  Future<void> _addProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        logger.e('No image selected.');
      }
    });
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
  }

  void _saveProfile() async {
    try {
      String userId = _auth.currentUser!.uid;
      double height = double.tryParse(_heightController.text) ?? 0;
      double weight = double.tryParse(_weightController.text) ?? 0;

      logger.i('Saving profile data: height=$height, weight=$weight');
      
      await _firebaseService.setUser(userId, {
        'height': height,
        'weight': weight,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
      logger.e("Failed to update profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _image != null ? FileImage(_image!) : const AssetImage('assets/Profil.jpg') as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(_email, style: const TextStyle(fontSize: 16)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Column(
                children: [
                  TextField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _addProfilePicture,
              child: const Text('Add Profile Picture'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
