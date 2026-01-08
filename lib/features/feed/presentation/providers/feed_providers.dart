import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/feed_repository.dart';
import '../../domain/models/feed_models.dart';

/// Provider for feed repository
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

/// Provider for all feed items
final feedItemsProvider = FutureProvider<List<FeedItem>>((ref) async {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.fetchAllFeeds();
});

/// Provider for refreshing feeds
final feedRefreshProvider = FutureProvider.family<List<FeedItem>, bool>((ref, forceRefresh) async {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.fetchAllFeeds(forceRefresh: forceRefresh);
});

/// Provider for selected feed filter
final feedFilterProvider = StateProvider<FeedSource?>((ref) => null);

/// Provider for filtered feed items
final filteredFeedItemsProvider = Provider<AsyncValue<List<FeedItem>>>((ref) {
  final feedAsync = ref.watch(feedItemsProvider);
  final filter = ref.watch(feedFilterProvider);

  return feedAsync.whenData((items) {
    if (filter == null) {
      return items;
    }
    return items.where((item) => item.source == filter).toList();
  });
});

/// Provider for feed loading state
final isFeedLoadingProvider = StateProvider<bool>((ref) => false);

/// State notifier for feed refresh
class FeedRefreshNotifier extends StateNotifier<AsyncValue<List<FeedItem>>> {
  final FeedRepository _repository;

  FeedRefreshNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.fetchAllFeeds();
      state = AsyncValue.data(items);
    } catch (e, st) {
      // Try to load from cache on error
      try {
        final cachedItems = await _repository.getCachedFeeds();
        if (cachedItems.isNotEmpty) {
          state = AsyncValue.data(cachedItems);
        } else {
          state = AsyncValue.error(e, st);
        }
      } catch (_) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.fetchAllFeeds(forceRefresh: true);
      state = AsyncValue.data(items);
    } catch (e, st) {
      // Keep old data if available
      final currentData = state.valueOrNull;
      if (currentData != null && currentData.isNotEmpty) {
        state = AsyncValue.data(currentData);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }
}

/// Provider for feed state with refresh capability
final feedStateProvider =
    StateNotifierProvider<FeedRefreshNotifier, AsyncValue<List<FeedItem>>>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return FeedRefreshNotifier(repository);
});

/// Provider for last update time
final lastFeedUpdateProvider = FutureProvider<DateTime?>((ref) async {
  final repository = ref.watch(feedRepositoryProvider);
  // Return the most recent update time
  DateTime? latestUpdate;
  for (final source in FeedSource.values) {
    final updateTime = await repository.getLastFetchTime(source);
    if (updateTime != null) {
      if (latestUpdate == null || updateTime.isAfter(latestUpdate)) {
        latestUpdate = updateTime;
      }
    }
  }
  return latestUpdate;
});
