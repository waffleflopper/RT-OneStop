import 'package:equatable/equatable.dart';

/// Feed source identifiers
enum FeedSource {
  aarc,
  nbrc,
  podcast,
}

extension FeedSourceExtension on FeedSource {
  String get displayName {
    switch (this) {
      case FeedSource.aarc:
        return 'AARC News';
      case FeedSource.nbrc:
        return 'NBRC News';
      case FeedSource.podcast:
        return 'AARC Podcast';
    }
  }

  String get value {
    switch (this) {
      case FeedSource.aarc:
        return 'aarc';
      case FeedSource.nbrc:
        return 'nbrc';
      case FeedSource.podcast:
        return 'podcast';
    }
  }
}

/// A single feed item (news article or podcast episode)
class FeedItem extends Equatable {
  final String id;
  final String title;
  final FeedSource source;
  final DateTime publishedDate;
  final String? snippet;
  final String url;
  final String? imageUrl;
  final bool isRead;

  const FeedItem({
    required this.id,
    required this.title,
    required this.source,
    required this.publishedDate,
    this.snippet,
    required this.url,
    this.imageUrl,
    this.isRead = false,
  });

  FeedItem copyWith({
    String? id,
    String? title,
    FeedSource? source,
    DateTime? publishedDate,
    String? snippet,
    String? url,
    String? imageUrl,
    bool? isRead,
  }) {
    return FeedItem(
      id: id ?? this.id,
      title: title ?? this.title,
      source: source ?? this.source,
      publishedDate: publishedDate ?? this.publishedDate,
      snippet: snippet ?? this.snippet,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'source': source.value,
        'publishedDate': publishedDate.toIso8601String(),
        'snippet': snippet,
        'url': url,
        'imageUrl': imageUrl,
        'isRead': isRead,
      };

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      source: FeedSource.values.firstWhere(
        (s) => s.value == json['source'],
        orElse: () => FeedSource.aarc,
      ),
      publishedDate: DateTime.parse(json['publishedDate'] as String),
      snippet: json['snippet'] as String?,
      url: json['url'] as String,
      imageUrl: json['imageUrl'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, source, publishedDate, snippet, url, imageUrl, isRead];
}

/// Cache for storing fetched feed data
class FeedCache extends Equatable {
  final FeedSource source;
  final DateTime lastFetched;
  final List<FeedItem> items;

  const FeedCache({
    required this.source,
    required this.lastFetched,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'source': source.value,
        'lastFetched': lastFetched.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory FeedCache.fromJson(Map<String, dynamic> json) {
    return FeedCache(
      source: FeedSource.values.firstWhere(
        (s) => s.value == json['source'],
        orElse: () => FeedSource.aarc,
      ),
      lastFetched: DateTime.parse(json['lastFetched'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [source, lastFetched, items];
}
