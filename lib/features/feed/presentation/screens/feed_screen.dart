import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/feed_models.dart';
import '../providers/feed_providers.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedStateProvider);
    final selectedFilter = ref.watch(feedFilterProvider);
    final lastUpdate = ref.watch(lastFeedUpdateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(feedStateProvider.notifier).refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: selectedFilter == null,
                  onSelected: (_) {
                    ref.read(feedFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                ...FeedSource.values.map((source) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(source.displayName),
                      selected: selectedFilter == source,
                      onSelected: (_) {
                        ref.read(feedFilterProvider.notifier).state =
                            selectedFilter == source ? null : source;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Last updated
          lastUpdate.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (time) {
              if (time == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last updated: ${_formatTime(time)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Feed list
          Expanded(
            child: feedState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 16),
                    Text('Unable to load feed: $e'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        ref.read(feedStateProvider.notifier).refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (items) {
                // Apply filter
                final filteredItems = selectedFilter == null
                    ? items
                    : items.where((i) => i.source == selectedFilter).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 48),
                        const SizedBox(height: 16),
                        const Text('No items to display'),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            ref.read(feedStateProvider.notifier).refresh();
                          },
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(feedStateProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _FeedItemCard(item: item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat.MMMd().format(time);
    }
  }
}

class _FeedItemCard extends StatelessWidget {
  final FeedItem item;

  const _FeedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchUrl(item.url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source badge and date
              Row(
                children: [
                  _SourceBadge(source: item.source),
                  const Spacer(),
                  Text(
                    _formatDate(item.publishedDate),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                item.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Snippet
              if (item.snippet != null) ...[
                const SizedBox(height: 8),
                Text(
                  item.snippet!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Read more
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Read more',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SourceBadge extends StatelessWidget {
  final FeedSource source;

  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (source) {
      case FeedSource.aarc:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        break;
      case FeedSource.nbrc:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case FeedSource.podcast:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (source == FeedSource.podcast)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.podcasts, size: 14, color: textColor),
            ),
          Text(
            source.displayName,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
