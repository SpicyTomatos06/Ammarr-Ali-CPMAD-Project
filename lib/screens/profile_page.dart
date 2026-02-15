import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  bool _isSaving = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _user;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null && data['displayName'] is String) {
        _nameController.text = (data['displayName'] as String);
      }
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    final user = _user;
    if (user == null) {
      Fluttertoast.showToast(msg: 'Not logged in.');
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your name.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'displayName': name,
          'email': user.email,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await user.updateDisplayName(name);

      Fluttertoast.showToast(msg: 'Profile saved');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      Fluttertoast.showToast(msg: 'Failed to save profile. Try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: user == null
              ? const Center(child: Text('You are not logged in.'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Email: ${user.email ?? '-'}'),
                    const SizedBox(height: 20),
                    const Text('Display Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Ali',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
