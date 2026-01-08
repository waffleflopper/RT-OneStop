import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/reference_repository.dart';
import '../../domain/models/reference_models.dart';

/// Provider for reference repository
final referenceRepositoryProvider = Provider<ReferenceRepository>((ref) {
  return ReferenceRepository();
});

/// Provider for all reference categories
final referenceCategoriesProvider = FutureProvider<List<ReferenceCategory>>((ref) async {
  final repository = ref.watch(referenceRepositoryProvider);
  return repository.loadCategories();
});

/// Provider for selected population filter
final selectedPopulationProvider = StateProvider<Population>((ref) {
  return Population.adult;
});

/// Provider for categories filtered by selected population
final filteredCategoriesProvider = FutureProvider<List<ReferenceCategory>>((ref) async {
  final repository = ref.watch(referenceRepositoryProvider);
  final population = ref.watch(selectedPopulationProvider);
  return repository.getCategoriesByPopulation(population);
});

/// Provider for reference search query
final referenceSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for reference search results
final referenceSearchResultsProvider = FutureProvider<List<MapEntry<ReferenceCategory, List<ReferenceItem>>>>((ref) async {
  final repository = ref.watch(referenceRepositoryProvider);
  final query = ref.watch(referenceSearchQueryProvider);
  final population = ref.watch(selectedPopulationProvider);

  if (query.isEmpty) {
    return [];
  }

  return repository.searchReferences(query, population);
});

/// Provider for a single category by ID
final referenceCategoryProvider = FutureProvider.family<ReferenceCategory?, String>((ref, id) async {
  final repository = ref.watch(referenceRepositoryProvider);
  return repository.getCategory(id);
});

/// Provider for favorite reference IDs
final favoriteReferencesProvider = StateNotifierProvider<FavoriteReferencesNotifier, Set<String>>((ref) {
  return FavoriteReferencesNotifier();
});

class FavoriteReferencesNotifier extends StateNotifier<Set<String>> {
  FavoriteReferencesNotifier() : super({});

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  bool isFavorite(String id) => state.contains(id);
}
