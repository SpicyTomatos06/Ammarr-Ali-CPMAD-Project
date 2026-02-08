import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'map_page.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  final _searchController = TextEditingController();
  String _queryText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Query<Map<String, dynamic>> _buildQuery() {
    final base = FirebaseFirestore.instance.collection('recycling_points');

    if (_queryText.trim().isEmpty) {
      return base.orderBy('nameLower').limit(50);
    }

    final q = _queryText.trim().toLowerCase();
    final end = q + '\uf8ff';

    return base.orderBy('nameLower').startAt([q]).endAt([end]).limit(50);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recycling Locations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by location name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _queryText = '');
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _queryText = val),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _buildQuery().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load locations.'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No locations found.\n(Add documents to Firestore: recycling_points)',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final point = RecyclingPoint.fromMap(docs[index].id, data);

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
                                  const Icon(Icons.location_on, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      point.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(point.address),
                              const SizedBox(height: 10),

                              if (point.acceptedTypes.isNotEmpty) ...[
                                const Text(
                                  'Accepted Types',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: point.acceptedTypes
                                      .map(
                                        (t) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: Colors.green),
                                          ),
                                          child: Text(
                                            t,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 10),
                              ],

                              if (point.lat != null && point.lng != null)
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.map),
                                    label: const Text('View on Map'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MapPage(
                                            title: point.name,
                                            lat: point.lat!,
                                            lng: point.lng!,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              else
                                const Text(
                                  'Map coordinates not available for this location.',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
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

class RecyclingPoint {
  final String id;
  final String name;
  final String address;
  final List<String> acceptedTypes;
  final double? lat;
  final double? lng;

  RecyclingPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.acceptedTypes,
    required this.lat,
    required this.lng,
  });

  factory RecyclingPoint.fromMap(String id, Map<String, dynamic> map) {
    final rawTypes = map['acceptedTypes'];

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return RecyclingPoint(
      id: id,
      name: (map['name'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      acceptedTypes: rawTypes is List ? rawTypes.map((e) => e.toString()).toList() : <String>[],
      lat: toDouble(map['lat']),
      lng: toDouble(map['lng']),
    );
  }
}
