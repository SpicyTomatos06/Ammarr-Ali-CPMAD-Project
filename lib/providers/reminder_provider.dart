import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ReminderItem {
  final String id;
  final String dayOfWeek;
  final String time;
  final String note;

  ReminderItem({
    required this.id,
    required this.dayOfWeek,
    required this.time,
    required this.note,
  });

  factory ReminderItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ReminderItem(
      id: doc.id,
      dayOfWeek: (data['dayOfWeek'] ?? '').toString(),
      time: (data['time'] ?? '').toString(),
      note: (data['note'] ?? '').toString(),
    );
  }
}

class ReminderProvider extends ChangeNotifier {
  List<ReminderItem> _reminders = [];
  List<ReminderItem> get reminders => _reminders;

  bool _loading = true;
  bool get loading => _loading;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  void bindToUser(String? uid) {
    _sub?.cancel();
    _reminders = [];
    _loading = true;
    notifyListeners();

    if (uid == null) {
      _loading = false;
      notifyListeners();
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .orderBy('createdAt', descending: true);

    _sub = ref.snapshots().listen((snap) {
      _reminders = snap.docs.map((d) => ReminderItem.fromDoc(d)).toList();
      _loading = false;
      notifyListeners();
    }, onError: (_) {
      _loading = false;
      notifyListeners();
    });
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  Future<void> addReminder({
    required String uid,
    required String dayOfWeek,
    required String time,
    required String note,
  }) async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reminders');

    await ref.add({
      'dayOfWeek': dayOfWeek,
      'time': time,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });

  }

  Future<void> deleteReminder({
    required String uid,
    required String reminderId,
  }) async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc(reminderId);

    await ref.delete();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
