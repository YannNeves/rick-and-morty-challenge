import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

import '../../characters/data/character_repository.dart';
import '../../locations/data/location_repository.dart';
import '../data/episode_repository.dart';
import '../domain/episode_models.dart';
import 'episode_details_page.dart';
import 'episodes_controller.dart';
import 'load_status.dart';
import 'widgets/empty_error_state.dart';

class EpisodesPage extends StatefulWidget {
  const EpisodesPage({
    required this.episodeRepository,
    required this.characterRepository,
    required this.locationRepository,
    required this.searchQuery,
    required this.filters,
    this.onGoHome,
    super.key,
  });

  final EpisodeRepository episodeRepository;
  final CharacterRepository characterRepository;
  final LocationRepository locationRepository;
  final String searchQuery;
  final Map<String, String> filters;
  final VoidCallback? onGoHome;

  @override
  State<EpisodesPage> createState() => _EpisodesPageState();
}

class _EpisodesPageState extends State<EpisodesPage> {
  late final EpisodesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EpisodesController(
      episodeRepository: widget.episodeRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.loadAll());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.status == LoadStatus.loading &&
            _controller.episodes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.status == LoadStatus.failure) {
          return EmptyErrorState(
            title: 'Episódios indisponíveis',
            message: _controller.errorMessage ?? 'Tente novamente.',
            onRetry: _controller.loadAll,
          );
        }

        if (_controller.status == LoadStatus.success &&
            _controller.episodes.isEmpty) {
          return EmptyErrorState(
            title: 'Nenhum episódio encontrado',
            message: 'A API não retornou episódios.',
            onRetry: _controller.loadAll,
          );
        }

        final query = widget.searchQuery.toLowerCase();
        final filteredEpisodes = (query.isEmpty
                ? _controller.episodes
                : _controller.episodes
                    .where((episode) {
                      return episode.name.toLowerCase().contains(query) ||
                          episode.code.toLowerCase().contains(query);
                    })
                    .toList(growable: false))
            .toList(growable: true);
        final sortBy = widget.filters['sortBy'] ?? 'episode';
        final descending = widget.filters['order'] == 'desc';
        filteredEpisodes.sort((left, right) {
          final result = switch (sortBy) {
            'name' => left.name.toLowerCase().compareTo(
              right.name.toLowerCase(),
            ),
            'airDate' => left.airDate.compareTo(right.airDate),
            _ => left.code.compareTo(right.code),
          };
          return descending ? -result : result;
        });

        if (MediaQuery.sizeOf(context).width >= 900) {
          final width = MediaQuery.sizeOf(context).width;
          final horizontalPadding = width > 1288 ? (width - 1240) / 2 : 24.0;
          return RefreshIndicator(
            onRefresh: _controller.loadAll,
            child: CustomScrollView(
              key: const ValueKey('episodes-page-grid'),
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: _EpisodesHeader(count: filteredEpisodes.length),
                      ),
                    ),
                  ),
                ),
                if (filteredEpisodes.isEmpty)
                  const SliverToBoxAdapter(child: _NoSearchResults())
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    sliver: SliverGrid.builder(
                      itemCount: filteredEpisodes.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            mainAxisExtent: 112,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemBuilder: (context, index) {
                        final episode = filteredEpisodes[index];
                        return _EpisodeTile(
                          episode: episode,
                          onTap: () => _openEpisode(episode),
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.loadAll,
          child: ListView.separated(
            key: const ValueKey('episodes-page-list'),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            itemCount:
                filteredEpisodes.isEmpty ? 2 : filteredEpisodes.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _EpisodesHeader(count: filteredEpisodes.length);
              }
              if (filteredEpisodes.isEmpty) return const _NoSearchResults();

              final episode = filteredEpisodes[index - 1];
              return _EpisodeTile(
                episode: episode,
                onTap: () => _openEpisode(episode),
              );
            },
          ),
        );
      },
    );
  }

  void _openEpisode(EpisodeSummary episode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => EpisodeDetailsPage(
              episode: episode,
              episodeRepository: widget.episodeRepository,
              characterRepository: widget.characterRepository,
              locationRepository: widget.locationRepository,
              onGoHome: widget.onGoHome,
            ),
      ),
    );
  }
}

class _EpisodesHeader extends StatelessWidget {
  const _EpisodesHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Episódios',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text('$count encontrados'),
        ],
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({required this.episode, required this.onTap});

  final EpisodeSummary episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkGray : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SizedBox(
                  width: 72,
                  height: 58,
                  child: Center(
                    child: Text(
                      episode.code,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${episode.airDate} • ${episode.characterCount} personagens',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
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

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nenhum episódio corresponde à busca.',
            key: ValueKey('episodes-no-search-results'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
