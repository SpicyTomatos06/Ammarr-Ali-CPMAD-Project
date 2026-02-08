import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class WasteItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final String disposalGuide;
  final List<String> keywords;
  final String imageAsset;

  WasteItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.disposalGuide,
    required this.keywords,
    required this.imageAsset,
  });

  factory WasteItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final List<dynamic> rawKeywords = (data['keywords'] ?? []) as List<dynamic>;

    return WasteItem(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      category: (data['category'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      disposalGuide: (data['disposalGuide'] ?? '') as String,
      keywords: rawKeywords.map((e) => e.toString()).toList(),
      imageAsset: (data['imageAsset'] ?? 'images/waste_default.png') as String, // fallback
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'disposalGuide': disposalGuide,
      'keywords': keywords,
      'imageAsset': imageAsset,
    };
  }
}

class WasteProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _error;

  List<WasteItem> _items = [];
  List<WasteItem> get items => _items;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWasteItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await _db.collection('waste_items').orderBy('name').get();
      _items = snap.docs.map((d) => WasteItem.fromDoc(d)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<WasteItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _items;

    return _items.where((item) {
      final inName = item.name.toLowerCase().contains(q);
      final inKeywords = item.keywords.any((k) => k.toLowerCase().contains(q));
      return inName || inKeywords;
    }).toList();
  }

  Future<void> updateWasteItemImage({
    required String itemId,
    required String imageAsset,
  }) async {
    await _db.collection('waste_items').doc(itemId).update({
      'imageAsset': imageAsset,
    });

    final idx = _items.indexWhere((x) => x.id == itemId);
    if (idx != -1) {
      final old = _items[idx];
      _items[idx] = WasteItem(
        id: old.id,
        name: old.name,
        category: old.category,
        description: old.description,
        disposalGuide: old.disposalGuide,
        keywords: old.keywords,
        imageAsset: imageAsset,
      );
      notifyListeners();
    }
  }
}
