import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  final _tipController = TextEditingController();
  bool _submitting = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _tipController.dispose();
    super.dispose();
  }

  Future<String> _getCurrentUserDisplayName(User user) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      final fromDb = (data?['displayName'] ?? '').toString().trim();
      if (fromDb.isNotEmpty) return fromDb;
    } catch (_) {}
    final fromAuth = (user.displayName ?? '').trim();
    if (fromAuth.isNotEmpty) return fromAuth;
    return 'Anonymous';
  }

  Future<void> _submitTip() async {
    final user = _user;
    if (user == null) {
      Fluttertoast.showToast(msg: 'Please login to submit tips.');
      return;
    }

    final text = _tipController.text.trim();
    if (text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a tip.');
      return;
    }
    if (text.length < 10) {
      Fluttertoast.showToast(msg: 'Tip is too short (min 10 characters).');
      return;
    }

    setState(() => _submitting = true);

    try {
      final displayName = await _getCurrentUserDisplayName(user);

      await FirebaseFirestore.instance.collection('tips').add({
        'text': text,
        'uid': user.uid,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _tipController.clear();
      Fluttertoast.showToast(msg: 'Tip submitted');
    } catch (_) {
      Fluttertoast.showToast(msg: 'Failed to submit tip');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tips & Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Share recycling tips to help others.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Submit a Tip', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tipController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Rinse containers before recycling.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _submitting ? null : _submitTip,
                        icon: _submitting
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.send),
                        label: Text(_submitting ? 'Submitting...' : 'Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Text('Community Tips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('tips')
                    .orderBy('createdAt', descending: true)
                    .limit(50)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load tips.'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No tips yet.\nBe the first to share one!', textAlign: TextAlign.center));
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final tip = TipItem.fromMap(docs[index].id, data);

                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(tip.text, style: const TextStyle(height: 1.35))),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    tip.displayName.isEmpty ? 'Anonymous' : tip.displayName,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TipItem {
  final String id;
  final String text;
  final String displayName;

  TipItem({required this.id, required this.text, required this.displayName});

  factory TipItem.fromMap(String id, Map<String, dynamic> map) {
    return TipItem(
      id: id,
      text: (map['text'] ?? '').toString(),
      displayName: (map['displayName'] ?? 'Anonymous').toString(),
    );
  }
}
