import 'package:flutter/material.dart';

import '../data/episode_repository.dart';
import '../domain/episode_models.dart';
import 'episode_details_page.dart';
import 'episodes_controller.dart';
import 'load_status.dart';
import 'widgets/empty_error_state.dart';

class EpisodesPage extends StatefulWidget {
  const EpisodesPage({required this.episodeRepository, super.key});

  final EpisodeRepository episodeRepository;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.load();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rick and Morty'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed:
                () => _controller.load(pageNumber: _controller.page?.page ?? 1),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final page = _controller.page;

          if (_controller.status == LoadStatus.loading && page == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.status == LoadStatus.failure && page == null) {
            return EmptyErrorState(
              title: 'Episódios indisponíveis',
              message: _controller.errorMessage ?? 'Tente novamente.',
              onRetry: () => _controller.load(),
            );
          }

          if (page == null || page.episodes.isEmpty) {
            return EmptyErrorState(
              title: 'Nenhum episódio encontrado',
              message: 'A API não retornou episódios para esta página.',
              onRetry: () => _controller.load(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _controller.load(pageNumber: page.page),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _EpisodeSummaryHeader(page: page),
                const SizedBox(height: 12),
                for (final episode in page.episodes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EpisodeTile(
                      episode: episode,
                      onTap: () => _openEpisode(episode),
                    ),
                  ),
                _PaginationBar(
                  page: page,
                  isLoading: _controller.status == LoadStatus.loading,
                  onPrevious:
                      page.hasPreviousPage
                          ? () => _controller.load(pageNumber: page.page - 1)
                          : null,
                  onNext:
                      page.hasNextPage
                          ? () => _controller.load(pageNumber: page.page + 1)
                          : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openEpisode(EpisodeSummary episode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => EpisodeDetailsPage(
              episode: episode,
              episodeRepository: widget.episodeRepository,
            ),
      ),
    );
  }
}

class _EpisodeSummaryHeader extends StatelessWidget {
  const _EpisodeSummaryHeader({required this.page});

  final EpisodeListPage page;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.tv, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${page.totalItems} episódios • página ${page.page}/${page.totalPages}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
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

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: 68,
                  height: 56,
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

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
  });

  final EpisodeListPage page;
  final bool isLoading;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filledTonal(
            tooltip: 'Página anterior',
            onPressed: isLoading ? null : onPrevious,
            icon: const Icon(Icons.arrow_back),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('${page.page}/${page.totalPages}'),
          ),
          IconButton.filledTonal(
            tooltip: 'Próxima página',
            onPressed: isLoading ? null : onNext,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
