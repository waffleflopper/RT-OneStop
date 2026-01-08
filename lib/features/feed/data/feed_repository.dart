import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../domain/models/feed_models.dart';
import 'feed_parser.dart';

/// Repository for fetching and caching feed data
class FeedRepository {
  final FeedParser _parser = FeedParser();
  final http.Client _httpClient;
  Box<String>? _cacheBox;

  FeedRepository({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<Box<String>> get _cache async {
    _cacheBox ??= await Hive.openBox<String>(AppConstants.feedCacheBox);
    return _cacheBox!;
  }

  /// Fetch all feeds (from cache or network)
  Future<List<FeedItem>> fetchAllFeeds({bool forceRefresh = false}) async {
    final allItems = <FeedItem>[];

    // Fetch from all sources
    final results = await Future.wait([
      fetchAarcNews(forceRefresh: forceRefresh),
      fetchNbrcNews(forceRefresh: forceRefresh),
      fetchPodcast(forceRefresh: forceRefresh),
    ]);

    for (final items in results) {
      allItems.addAll(items);
    }

    // Sort by date, newest first
    allItems.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));

    return allItems;
  }

  /// Fetch AARC news
  Future<List<FeedItem>> fetchAarcNews({bool forceRefresh = false}) async {
    return _fetchWithCache(
      source: FeedSource.aarc,
      url: AppConstants.aarcNewsUrl,
      parser: (content) => _parser.parseAarcNews(content),
      forceRefresh: forceRefresh,
    );
  }

  /// Fetch NBRC news
  Future<List<FeedItem>> fetchNbrcNews({bool forceRefresh = false}) async {
    return _fetchWithCache(
      source: FeedSource.nbrc,
      url: AppConstants.nbrcNewsUrl,
      parser: (content) => _parser.parseNbrcNews(content),
      forceRefresh: forceRefresh,
    );
  }

  /// Fetch AARC podcast
  Future<List<FeedItem>> fetchPodcast({bool forceRefresh = false}) async {
    return _fetchWithCache(
      source: FeedSource.podcast,
      url: AppConstants.aarcPodcastRssUrl,
      parser: (content) => _parser.parseRssFeed(content, FeedSource.podcast),
      forceRefresh: forceRefresh,
    );
  }

  /// Fetch with caching logic
  Future<List<FeedItem>> _fetchWithCache({
    required FeedSource source,
    required String url,
    required List<FeedItem> Function(String) parser,
    bool forceRefresh = false,
  }) async {
    final cache = await _cache;
    final cacheKey = 'feed_${source.value}';

    // Check cache first (unless forcing refresh)
    if (!forceRefresh) {
      final cachedData = cache.get(cacheKey);
      if (cachedData != null) {
        try {
          final feedCache = FeedCache.fromJson(
            json.decode(cachedData) as Map<String, dynamic>,
          );

          // Use cache if less than 30 minutes old
          final cacheAge = DateTime.now().difference(feedCache.lastFetched);
          if (cacheAge.inMinutes < 30) {
            return feedCache.items;
          }
        } catch (_) {
          // Invalid cache, will refetch
        }
      }
    }

    // Fetch from network
    try {
      final response = await _httpClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final items = parser(response.body);

        // Cache the results
        final feedCache = FeedCache(
          source: source,
          lastFetched: DateTime.now(),
          items: items,
        );
        await cache.put(cacheKey, json.encode(feedCache.toJson()));

        return items;
      }
    } catch (e) {
      // Network error - try to return cached data
      final cachedData = cache.get(cacheKey);
      if (cachedData != null) {
        try {
          final feedCache = FeedCache.fromJson(
            json.decode(cachedData) as Map<String, dynamic>,
          );
          return feedCache.items;
        } catch (_) {
          // Cache also failed
        }
      }
    }

    return [];
  }

  /// Get cached feed items (for offline display)
  Future<List<FeedItem>> getCachedFeeds() async {
    final cache = await _cache;
    final allItems = <FeedItem>[];

    for (final source in FeedSource.values) {
      final cacheKey = 'feed_${source.value}';
      final cachedData = cache.get(cacheKey);
      if (cachedData != null) {
        try {
          final feedCache = FeedCache.fromJson(
            json.decode(cachedData) as Map<String, dynamic>,
          );
          allItems.addAll(feedCache.items);
        } catch (_) {
          // Skip invalid cache
        }
      }
    }

    allItems.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    return allItems;
  }

  /// Get last fetch time for a source
  Future<DateTime?> getLastFetchTime(FeedSource source) async {
    final cache = await _cache;
    final cacheKey = 'feed_${source.value}';
    final cachedData = cache.get(cacheKey);

    if (cachedData != null) {
      try {
        final feedCache = FeedCache.fromJson(
          json.decode(cachedData) as Map<String, dynamic>,
        );
        return feedCache.lastFetched;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Clear all cached feeds
  Future<void> clearCache() async {
    final cache = await _cache;
    await cache.clear();
  }

  /// Mark item as read
  Future<void> markAsRead(String itemId) async {
    final cache = await _cache;
    final readItemsKey = 'read_items';
    final readItemsData = cache.get(readItemsKey);

    Set<String> readItems = {};
    if (readItemsData != null) {
      try {
        readItems = (json.decode(readItemsData) as List<dynamic>)
            .map((e) => e as String)
            .toSet();
      } catch (_) {}
    }

    readItems.add(itemId);
    await cache.put(readItemsKey, json.encode(readItems.toList()));
  }

  /// Check if item is read
  Future<bool> isRead(String itemId) async {
    final cache = await _cache;
    final readItemsData = cache.get('read_items');

    if (readItemsData != null) {
      try {
        final readItems = (json.decode(readItemsData) as List<dynamic>)
            .map((e) => e as String)
            .toSet();
        return readItems.contains(itemId);
      } catch (_) {}
    }
    return false;
  }
}
