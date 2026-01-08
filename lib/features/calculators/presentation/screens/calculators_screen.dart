import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/calculator_models.dart';
import '../providers/calculator_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class CalculatorsScreen extends ConsumerStatefulWidget {
  const CalculatorsScreen({super.key});

  @override
  ConsumerState<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends ConsumerState<CalculatorsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatorsByCategory = ref.watch(calculatorsByCategoryProvider);
    final favorites = ref.watch(preferencesProvider).favoriteCalculators;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculators'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search calculators...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Calculator list
          Expanded(
            child: calculatorsByCategory.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Text('Error loading calculators: $e'),
              ),
              data: (categoryMap) {
                if (_searchQuery.isNotEmpty) {
                  return _buildSearchResults(categoryMap, favorites);
                }
                return _buildCategoryList(categoryMap, favorites);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    Map<String, List<CalculatorDefinition>> categoryMap,
    Set<String> favorites,
  ) {
    final allCalculators = categoryMap.values.expand((c) => c).toList();
    final filtered = allCalculators.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query) ||
          c.category.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text('No calculators found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final calculator = filtered[index];
        return _CalculatorTile(
          calculator: calculator,
          isFavorite: favorites.contains(calculator.id),
          onTap: () => context.go('/calculators/${calculator.id}'),
          onFavoriteToggle: () {
            ref.read(preferencesProvider.notifier)
                .toggleCalculatorFavorite(calculator.id);
          },
        );
      },
    );
  }

  Widget _buildCategoryList(
    Map<String, List<CalculatorDefinition>> categoryMap,
    Set<String> favorites,
  ) {
    final categories = categoryMap.keys.toList()..sort();

    // Get favorite calculators
    final favoriteCalculators = categoryMap.values
        .expand((c) => c)
        .where((c) => favorites.contains(c.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Favorites section
        if (favoriteCalculators.isNotEmpty) ...[
          _SectionHeader(title: 'Favorites', icon: Icons.star),
          ...favoriteCalculators.map((c) => _CalculatorTile(
                calculator: c,
                isFavorite: true,
                onTap: () => context.go('/calculators/${c.id}'),
                onFavoriteToggle: () {
                  ref.read(preferencesProvider.notifier)
                      .toggleCalculatorFavorite(c.id);
                },
              )),
          const SizedBox(height: 16),
        ],

        // Category sections
        ...categories.map((category) {
          final calculators = categoryMap[category]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: category,
                icon: _getCategoryIcon(category),
              ),
              ...calculators.map((c) => _CalculatorTile(
                    calculator: c,
                    isFavorite: favorites.contains(c.id),
                    onTap: () => context.go('/calculators/${c.id}'),
                    onFavoriteToggle: () {
                      ref.read(preferencesProvider.notifier)
                          .toggleCalculatorFavorite(c.id);
                    },
                  )),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'ventilation':
        return Icons.air;
      case 'oxygenation':
        return Icons.bubble_chart;
      case 'hemodynamics':
        return Icons.favorite;
      case 'body measurements':
        return Icons.accessibility_new;
      case 'acid-base':
        return Icons.science;
      case 'oxygen equipment':
        return Icons.local_hospital;
      default:
        return Icons.calculate;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalculatorTile extends StatelessWidget {
  final CalculatorDefinition calculator;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _CalculatorTile({
    required this.calculator,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(calculator.name),
        subtitle: Text(
          calculator.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.amber : null,
          ),
          onPressed: onFavoriteToggle,
        ),
        onTap: onTap,
      ),
    );
  }
}
