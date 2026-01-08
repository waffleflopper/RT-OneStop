import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/reference_models.dart';
import '../providers/reference_providers.dart';

class ReferenceScreen extends ConsumerStatefulWidget {
  const ReferenceScreen({super.key});

  @override
  ConsumerState<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends ConsumerState<ReferenceScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPopulation = ref.watch(selectedPopulationProvider);
    final categoriesAsync = ref.watch(filteredCategoriesProvider);
    final searchQuery = ref.watch(referenceSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reference'),
      ),
      body: Column(
        children: [
          // Population selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<Population>(
              segments: Population.values.map((p) {
                return ButtonSegment(
                  value: p,
                  label: Text(p.displayName),
                );
              }).toList(),
              selected: {selectedPopulation},
              onSelectionChanged: (selection) {
                ref.read(selectedPopulationProvider.notifier).state =
                    selection.first;
              },
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search reference values...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(referenceSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(referenceSearchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // Content
          Expanded(
            child: searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildCategoryList(categoriesAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchResults = ref.watch(referenceSearchResultsProvider);

    return searchResults.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (results) {
        if (results.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final entry = results[index];
            return _ReferenceCategoryCard(
              category: entry.key,
              items: entry.value,
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryList(AsyncValue<List<ReferenceCategory>> categoriesAsync) {
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('No reference data available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _ReferenceCategoryCard(
              category: category,
              items: category.items,
            );
          },
        );
      },
    );
  }
}

class _ReferenceCategoryCard extends StatefulWidget {
  final ReferenceCategory category;
  final List<ReferenceItem> items;

  const _ReferenceCategoryCard({
    required this.category,
    required this.items,
  });

  @override
  State<_ReferenceCategoryCard> createState() => _ReferenceCategoryCardState();
}

class _ReferenceCategoryCardState extends State<_ReferenceCategoryCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.category.lastReviewed != null)
                          Text(
                            'Last reviewed: ${widget.category.lastReviewed}',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),

          // Items
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  ...widget.items.map((item) => _ReferenceItemRow(item: item)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReferenceItemRow extends StatelessWidget {
  final ReferenceItem item;

  const _ReferenceItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.parameter,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.ageRange != null)
                  Text(
                    item.ageRange!,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.normalRange} ${item.unit}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
                if (item.notes != null)
                  Text(
                    item.notes!,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.end,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
