import 'package:flutter_test/flutter_test.dart';
import 'package:rt_onestop/features/feed/data/feed_parser.dart';
import 'package:rt_onestop/features/feed/domain/models/feed_models.dart';

void main() {
  late FeedParser parser;

  setUp(() {
    parser = FeedParser();
  });

  group('RSS Feed Parser', () {
    test('parses valid RSS feed', () {
      const rssContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>AARC Perspectives</title>
    <link>https://www.aarc.org</link>
    <item>
      <title>Episode 1: Introduction to RT</title>
      <link>https://www.aarc.org/podcast/ep1</link>
      <pubDate>Mon, 01 Jan 2024 12:00:00 +0000</pubDate>
      <description>This is the first episode description.</description>
      <guid>podcast-ep-1</guid>
    </item>
    <item>
      <title>Episode 2: Advanced Topics</title>
      <link>https://www.aarc.org/podcast/ep2</link>
      <pubDate>Mon, 08 Jan 2024 12:00:00 +0000</pubDate>
      <description>This is the second episode description.</description>
      <guid>podcast-ep-2</guid>
    </item>
  </channel>
</rss>
''';

      final items = parser.parseRssFeed(rssContent, FeedSource.podcast);

      expect(items.length, equals(2));
      expect(items[0].title, equals('Episode 1: Introduction to RT'));
      expect(items[0].source, equals(FeedSource.podcast));
      expect(items[0].url, equals('https://www.aarc.org/podcast/ep1'));
      expect(items[0].snippet, contains('first episode'));
      expect(items[1].title, equals('Episode 2: Advanced Topics'));
    });

    test('handles RSS feed with enclosures', () {
      const rssContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Test Podcast</title>
    <item>
      <title>Episode with Audio</title>
      <enclosure url="https://example.com/audio.mp3" type="audio/mpeg"/>
      <pubDate>Mon, 01 Jan 2024 12:00:00 +0000</pubDate>
    </item>
  </channel>
</rss>
''';

      final items = parser.parseRssFeed(rssContent, FeedSource.podcast);

      expect(items.length, equals(1));
      expect(items[0].url, equals('https://example.com/audio.mp3'));
    });

    test('handles empty RSS feed gracefully', () {
      const rssContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Empty Feed</title>
  </channel>
</rss>
''';

      final items = parser.parseRssFeed(rssContent, FeedSource.podcast);

      expect(items, isEmpty);
    });

    test('handles malformed RSS feed gracefully', () {
      const malformedContent = 'This is not valid XML';

      final items = parser.parseRssFeed(malformedContent, FeedSource.podcast);

      expect(items, isEmpty);
    });

    test('parses RSS date formats correctly', () {
      const rssContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <item>
      <title>Test Item</title>
      <link>https://example.com</link>
      <pubDate>Tue, 15 Dec 2024 14:30:00 +0000</pubDate>
    </item>
  </channel>
</rss>
''';

      final items = parser.parseRssFeed(rssContent, FeedSource.podcast);

      expect(items.length, equals(1));
      expect(items[0].publishedDate.year, equals(2024));
      expect(items[0].publishedDate.month, equals(12));
      expect(items[0].publishedDate.day, equals(15));
    });
  });

  group('HTML News Parser', () {
    test('parses AARC news with article elements', () {
      const htmlContent = '''
<!DOCTYPE html>
<html>
<body>
  <article>
    <h2><a href="/news/article1">First News Article</a></h2>
    <p class="excerpt">This is the first article excerpt.</p>
    <span class="date">January 15, 2024</span>
  </article>
  <article>
    <h2><a href="/news/article2">Second News Article</a></h2>
    <p class="excerpt">This is the second article excerpt.</p>
    <span class="date">January 14, 2024</span>
  </article>
</body>
</html>
''';

      final items = parser.parseAarcNews(htmlContent);

      expect(items.length, equals(2));
      expect(items[0].title, equals('First News Article'));
      expect(items[0].source, equals(FeedSource.aarc));
      expect(items[0].url, contains('aarc.org'));
    });

    test('parses AARC news with news-item class', () {
      const htmlContent = '''
<!DOCTYPE html>
<html>
<body>
  <div class="news-item">
    <h3><a href="https://www.aarc.org/news/test">Test News Item</a></h3>
    <p>Test excerpt content here.</p>
  </div>
</body>
</html>
''';

      final items = parser.parseAarcNews(htmlContent);

      expect(items.length, equals(1));
      expect(items[0].title, equals('Test News Item'));
    });

    test('handles empty HTML gracefully', () {
      const htmlContent = '''
<!DOCTYPE html>
<html>
<body>
</body>
</html>
''';

      final items = parser.parseAarcNews(htmlContent);

      expect(items, isEmpty);
    });

    test('parses NBRC news correctly', () {
      const htmlContent = '''
<!DOCTYPE html>
<html>
<body>
  <article>
    <h2><a href="/news/nbrc-update">NBRC Update</a></h2>
    <p class="summary">Important NBRC announcement.</p>
  </article>
</body>
</html>
''';

      final items = parser.parseNbrcNews(htmlContent);

      expect(items.length, equals(1));
      expect(items[0].title, equals('NBRC Update'));
      expect(items[0].source, equals(FeedSource.nbrc));
      expect(items[0].url, contains('nbrc.org'));
    });

    test('truncates long snippets', () {
      final longExcerpt = 'A' * 300;
      final htmlContent = '''
<!DOCTYPE html>
<html>
<body>
  <article>
    <h2><a href="/news/article">Article Title</a></h2>
    <p class="excerpt">$longExcerpt</p>
  </article>
</body>
</html>
''';

      final items = parser.parseAarcNews(htmlContent);

      expect(items.length, equals(1));
      expect(items[0].snippet!.length, lessThanOrEqualTo(203)); // 200 + "..."
    });

    test('makes relative URLs absolute', () {
      const htmlContent = '''
<!DOCTYPE html>
<html>
<body>
  <article>
    <h2><a href="/news/relative-url">Relative URL Article</a></h2>
  </article>
</body>
</html>
''';

      final items = parser.parseAarcNews(htmlContent);

      expect(items.length, equals(1));
      expect(items[0].url, startsWith('https://'));
    });

    test('handles absolute URLs correctly', () {
      const htmlContent = '''
<!DOCTYPE html>
<html>
<body>
  <article>
    <h2><a href="https://external.com/article">External Article</a></h2>
  </article>
</body>
</html>
''';

      final items = parser.parseAarcNews(htmlContent);

      expect(items.length, equals(1));
      expect(items[0].url, equals('https://external.com/article'));
    });
  });

  group('Date Parsing', () {
    test('parses "Month DD, YYYY" format', () {
      const htmlContent = '''
<!DOCTYPE html>
<html>
<body>
  <article>
    <h2><a href="/news/test">Test</a></h2>
    <span class="date">December 25, 2024</span>
  </article>
</body>
</html>
''';

      final items = parser.parseAarcNews(htmlContent);

      expect(items.length, equals(1));
      expect(items[0].publishedDate.month, equals(12));
      expect(items[0].publishedDate.day, equals(25));
      expect(items[0].publishedDate.year, equals(2024));
    });

    test('handles missing date gracefully', () {
      const htmlContent = '''
<!DOCTYPE html>
<html>
<body>
  <article>
    <h2><a href="/news/test">Test Without Date</a></h2>
  </article>
</body>
</html>
''';

      final items = parser.parseAarcNews(htmlContent);

      expect(items.length, equals(1));
      // Should default to current date when no date found
      expect(items[0].publishedDate.year, equals(DateTime.now().year));
    });
  });

  group('Edge Cases', () {
    test('handles null/empty content', () {
      expect(parser.parseAarcNews(''), isEmpty);
      expect(parser.parseNbrcNews(''), isEmpty);
      expect(parser.parseRssFeed('', FeedSource.podcast), isEmpty);
    });

    test('filters out items without titles', () {
      const htmlContent = '''
<!DOCTYPE html>
<html>
<body>
  <article>
    <h2><a href="/news/test"></a></h2>
  </article>
</body>
</html>
''';

      final items = parser.parseAarcNews(htmlContent);

      expect(items, isEmpty);
    });

    test('filters out items without URLs', () {
      const htmlContent = '''
<!DOCTYPE html>
<html>
<body>
  <article>
    <h2><a href="">Title Without URL</a></h2>
  </article>
</body>
</html>
''';

      final items = parser.parseAarcNews(htmlContent);

      expect(items, isEmpty);
    });

    test('limits number of items returned', () {
      // Generate HTML with 50 articles
      final buffer = StringBuffer('<!DOCTYPE html><html><body>');
      for (var i = 0; i < 50; i++) {
        buffer.write('''
<article>
  <h2><a href="/news/article$i">Article $i</a></h2>
</article>
''');
      }
      buffer.write('</body></html>');

      final items = parser.parseAarcNews(buffer.toString());

      expect(items.length, lessThanOrEqualTo(20)); // Limited to 20
    });
  });
}
