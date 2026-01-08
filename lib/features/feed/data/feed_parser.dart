import 'package:html/parser.dart' as html_parser;
import 'package:xml/xml.dart';
import '../domain/models/feed_models.dart';

/// Parser for extracting feed items from various sources
class FeedParser {
  /// Parse AARC news HTML page
  List<FeedItem> parseAarcNews(String htmlContent) {
    final items = <FeedItem>[];

    try {
      final document = html_parser.parse(htmlContent);

      // AARC news typically uses article elements or specific CSS classes
      // Try multiple selectors for robustness
      final articles = document.querySelectorAll('article, .news-item, .post, .entry');

      for (final article in articles) {
        try {
          // Find title - try various common patterns
          final titleElement = article.querySelector('h2 a, h3 a, .title a, .entry-title a, a.title');
          if (titleElement == null) continue;

          final title = titleElement.text.trim();
          if (title.isEmpty) continue;

          final url = titleElement.attributes['href'] ?? '';
          if (url.isEmpty) continue;

          // Make URL absolute if needed
          final absoluteUrl = url.startsWith('http')
              ? url
              : 'https://www.aarc.org$url';

          // Find date
          DateTime publishedDate = DateTime.now();
          final dateElement = article.querySelector('.date, .post-date, time, .entry-date');
          if (dateElement != null) {
            final dateText = dateElement.text.trim();
            publishedDate = _parseDate(dateText) ?? DateTime.now();
          }

          // Find snippet/excerpt
          String? snippet;
          final excerptElement = article.querySelector('.excerpt, .summary, .entry-summary, p');
          if (excerptElement != null) {
            snippet = excerptElement.text.trim();
            if (snippet.length > 200) {
              snippet = '${snippet.substring(0, 197)}...';
            }
          }

          // Find image
          String? imageUrl;
          final imgElement = article.querySelector('img');
          if (imgElement != null) {
            imageUrl = imgElement.attributes['src'];
          }

          items.add(FeedItem(
            id: 'aarc_${url.hashCode}',
            title: title,
            source: FeedSource.aarc,
            publishedDate: publishedDate,
            snippet: snippet,
            url: absoluteUrl,
            imageUrl: imageUrl,
          ));
        } catch (e) {
          // Skip malformed articles
          continue;
        }
      }

      // If no articles found with structured selectors, try simpler approach
      if (items.isEmpty) {
        final links = document.querySelectorAll('a');
        for (final link in links) {
          final href = link.attributes['href'] ?? '';
          if (href.contains('/news/') || href.contains('/article/')) {
            final title = link.text.trim();
            if (title.length > 10 && title.length < 200) {
              final absoluteUrl = href.startsWith('http')
                  ? href
                  : 'https://www.aarc.org$href';

              items.add(FeedItem(
                id: 'aarc_${href.hashCode}',
                title: title,
                source: FeedSource.aarc,
                publishedDate: DateTime.now(),
                url: absoluteUrl,
              ));
            }
          }
        }
      }
    } catch (e) {
      // Return empty list on parse failure
    }

    return items.take(20).toList(); // Limit to 20 items
  }

  /// Parse NBRC news HTML page
  List<FeedItem> parseNbrcNews(String htmlContent) {
    final items = <FeedItem>[];

    try {
      final document = html_parser.parse(htmlContent);

      // NBRC news structure
      final articles = document.querySelectorAll('article, .news-item, .post, .news-post, .entry');

      for (final article in articles) {
        try {
          final titleElement = article.querySelector('h2 a, h3 a, .title a, a.title, .entry-title a');
          if (titleElement == null) continue;

          final title = titleElement.text.trim();
          if (title.isEmpty) continue;

          final url = titleElement.attributes['href'] ?? '';
          if (url.isEmpty) continue;

          final absoluteUrl = url.startsWith('http')
              ? url
              : 'https://www.nbrc.org$url';

          DateTime publishedDate = DateTime.now();
          final dateElement = article.querySelector('.date, .post-date, time');
          if (dateElement != null) {
            final dateText = dateElement.text.trim();
            publishedDate = _parseDate(dateText) ?? DateTime.now();
          }

          String? snippet;
          final excerptElement = article.querySelector('.excerpt, .summary, p');
          if (excerptElement != null) {
            snippet = excerptElement.text.trim();
            if (snippet.length > 200) {
              snippet = '${snippet.substring(0, 197)}...';
            }
          }

          items.add(FeedItem(
            id: 'nbrc_${url.hashCode}',
            title: title,
            source: FeedSource.nbrc,
            publishedDate: publishedDate,
            snippet: snippet,
            url: absoluteUrl,
          ));
        } catch (e) {
          continue;
        }
      }

      // Fallback approach
      if (items.isEmpty) {
        final links = document.querySelectorAll('a');
        for (final link in links) {
          final href = link.attributes['href'] ?? '';
          if (href.contains('/news') || href.contains('/article')) {
            final title = link.text.trim();
            if (title.length > 10 && title.length < 200) {
              final absoluteUrl = href.startsWith('http')
                  ? href
                  : 'https://www.nbrc.org$href';

              items.add(FeedItem(
                id: 'nbrc_${href.hashCode}',
                title: title,
                source: FeedSource.nbrc,
                publishedDate: DateTime.now(),
                url: absoluteUrl,
              ));
            }
          }
        }
      }
    } catch (e) {
      // Return empty list on parse failure
    }

    return items.take(20).toList();
  }

  /// Parse RSS feed (for AARC podcast)
  List<FeedItem> parseRssFeed(String xmlContent, FeedSource source) {
    final items = <FeedItem>[];

    try {
      final document = XmlDocument.parse(xmlContent);
      final channel = document.findAllElements('channel').firstOrNull;
      if (channel == null) return items;

      final itemElements = channel.findAllElements('item');

      for (final item in itemElements) {
        try {
          final title = item.findElements('title').firstOrNull?.innerText.trim() ?? '';
          if (title.isEmpty) continue;

          final link = item.findElements('link').firstOrNull?.innerText.trim() ?? '';
          final guid = item.findElements('guid').firstOrNull?.innerText.trim() ?? link;

          DateTime publishedDate = DateTime.now();
          final pubDateElement = item.findElements('pubDate').firstOrNull;
          if (pubDateElement != null) {
            publishedDate = _parseRssDate(pubDateElement.innerText) ?? DateTime.now();
          }

          String? snippet = item.findElements('description').firstOrNull?.innerText.trim();
          if (snippet != null && snippet.length > 200) {
            // Strip HTML tags from description
            snippet = snippet.replaceAll(RegExp(r'<[^>]*>'), '');
            if (snippet.length > 200) {
              snippet = '${snippet.substring(0, 197)}...';
            }
          }

          // Look for enclosure (audio file for podcasts)
          String? mediaUrl;
          final enclosure = item.findElements('enclosure').firstOrNull;
          if (enclosure != null) {
            mediaUrl = enclosure.getAttribute('url');
          }

          // Look for image
          String? imageUrl;
          final itunesImage = item.findElements('itunes:image').firstOrNull;
          if (itunesImage != null) {
            imageUrl = itunesImage.getAttribute('href');
          }

          items.add(FeedItem(
            id: '${source.value}_${guid.hashCode}',
            title: title,
            source: source,
            publishedDate: publishedDate,
            snippet: snippet,
            url: link.isNotEmpty ? link : (mediaUrl ?? ''),
            imageUrl: imageUrl,
          ));
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // Return empty list on parse failure
    }

    return items.take(50).toList(); // Podcasts may have more episodes
  }

  /// Parse various date formats
  DateTime? _parseDate(String dateText) {
    // Try ISO format first
    final isoResult = DateTime.tryParse(dateText);
    if (isoResult != null) {
      return isoResult;
    }

    // Try Month DD, YYYY format
    final monthMatch = RegExp(r'(\w+)\s+(\d{1,2}),?\s+(\d{4})').firstMatch(dateText);
    if (monthMatch != null) {
      final month = _parseMonth(monthMatch.group(1)!);
      if (month != null) {
        final day = int.tryParse(monthMatch.group(2)!) ?? 1;
        final year = int.tryParse(monthMatch.group(3)!) ?? DateTime.now().year;
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  /// Parse RSS date format (RFC 822)
  DateTime? _parseRssDate(String dateText) {
    try {
      // RFC 822 format: "Tue, 10 Dec 2024 12:00:00 +0000"
      final match = RegExp(
        r'\w+,?\s+(\d{1,2})\s+(\w+)\s+(\d{4})\s+(\d{2}):(\d{2}):(\d{2})',
      ).firstMatch(dateText);

      if (match != null) {
        final day = int.parse(match.group(1)!);
        final month = _parseMonth(match.group(2)!);
        final year = int.parse(match.group(3)!);
        final hour = int.parse(match.group(4)!);
        final minute = int.parse(match.group(5)!);
        final second = int.parse(match.group(6)!);

        if (month != null) {
          return DateTime.utc(year, month, day, hour, minute, second);
        }
      }
    } catch (_) {}

    return null;
  }

  /// Parse month name to number
  int? _parseMonth(String monthName) {
    const months = {
      'jan': 1, 'january': 1,
      'feb': 2, 'february': 2,
      'mar': 3, 'march': 3,
      'apr': 4, 'april': 4,
      'may': 5,
      'jun': 6, 'june': 6,
      'jul': 7, 'july': 7,
      'aug': 8, 'august': 8,
      'sep': 9, 'september': 9,
      'oct': 10, 'october': 10,
      'nov': 11, 'november': 11,
      'dec': 12, 'december': 12,
    };
    return months[monthName.toLowerCase()];
  }
}
