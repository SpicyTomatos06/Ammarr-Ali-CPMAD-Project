import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/waste_provider.dart';

class WasteGuidePage extends StatefulWidget {
  const WasteGuidePage({super.key});

  @override
  State<WasteGuidePage> createState() => _WasteGuidePageState();
}

class _WasteGuidePageState extends State<WasteGuidePage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WasteProvider>().fetchWasteItems();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wasteProvider = context.watch<WasteProvider>();

    final items = wasteProvider.search(_query);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Guide'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Builder(
              builder: (_) {
                if (wasteProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (wasteProvider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error: ${wasteProvider.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (items.isEmpty) {
                  return const Center(child: Text('No waste items found.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return _WasteItemCard(
                      item: item,
                      onTap: () => _openWasteDetails(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Search (e.g., bottle, paper, battery)...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _openWasteDetails(WasteItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        item.imageAsset,
                        height: 180,
                        width: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          width: 180,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported, size: 48),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.label, size: 18),
                      const SizedBox(width: 6),
                      Text(item.category),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  if (item.disposalGuide.trim().isNotEmpty) ...[
                    Text(
                      'How to dispose',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(item.disposalGuide),
                  ],
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WasteItemCard extends StatelessWidget {
  final WasteItem item;
  final VoidCallback onTap;

  const _WasteItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item.imageAsset,
                  height: 56,
                  width: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 56,
                    width: 56,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.category,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
