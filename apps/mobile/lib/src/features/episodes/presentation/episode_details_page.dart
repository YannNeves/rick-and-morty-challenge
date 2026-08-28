import 'package:flutter/material.dart';

import '../data/episode_repository.dart';
import '../domain/character_sort.dart';
import '../domain/episode_models.dart';
import 'episode_details_controller.dart';
import 'load_status.dart';
import 'widgets/empty_error_state.dart';

class EpisodeDetailsPage extends StatefulWidget {
  const EpisodeDetailsPage({
    required this.episode,
    required this.episodeRepository,
    super.key,
  });

  final EpisodeSummary episode;
  final EpisodeRepository episodeRepository;

  @override
  State<EpisodeDetailsPage> createState() => _EpisodeDetailsPageState();
}

class _EpisodeDetailsPageState extends State<EpisodeDetailsPage> {
  late final EpisodeDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EpisodeDetailsController(
      episodeId: widget.episode.id,
      episodeRepository: widget.episodeRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.episode.code)),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final details = _controller.details;

          if (_controller.status == LoadStatus.loading && details == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.status == LoadStatus.failure && details == null) {
            return EmptyErrorState(
              title: 'Personagens indisponíveis',
              message: _controller.errorMessage ?? 'Tente novamente.',
              onRetry: _controller.load,
            );
          }

          if (details == null) {
            return const SizedBox.shrink();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _EpisodeHeader(details: details),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _SortControl(
                    selected: _controller.sortBy,
                    onChanged: _controller.changeSort,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final count =
                        width >= 900
                            ? 3
                            : width >= 560
                            ? 2
                            : 1;

                    return SliverGrid.builder(
                      itemCount: details.characters.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: count,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 168,
                      ),
                      itemBuilder: (context, index) {
                        return _CharacterTile(
                          character: details.characters[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EpisodeHeader extends StatelessWidget {
  const _EpisodeHeader({required this.details});

  final EpisodeDetails details;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              details.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(details.code)),
                Chip(label: Text(details.airDate)),
                Chip(label: Text('${details.characterCount} personagens')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SortControl extends StatelessWidget {
  const _SortControl({required this.selected, required this.onChanged});

  final CharacterSortBy selected;
  final ValueChanged<CharacterSortBy> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<CharacterSortBy>(
        segments: const [
          ButtonSegment(
            value: CharacterSortBy.name,
            icon: Icon(Icons.sort_by_alpha),
            label: Text('Nome'),
          ),
          ButtonSegment(
            value: CharacterSortBy.status,
            icon: Icon(Icons.monitor_heart_outlined),
            label: Text('Status'),
          ),
          ButtonSegment(
            value: CharacterSortBy.species,
            icon: Icon(Icons.category_outlined),
            label: Text('Espécie'),
          ),
          ButtonSegment(
            value: CharacterSortBy.id,
            icon: Icon(Icons.tag),
            label: Text('ID'),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (values) => onChanged(values.first),
      ),
    );
  }
}

class _CharacterTile extends StatelessWidget {
  const _CharacterTile({required this.character});

  final CharacterSummary character;

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
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                character.image,
                width: 92,
                height: 92,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: const SizedBox(
                      width: 92,
                      height: 92,
                      child: Icon(Icons.person),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    character.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _StatusChip(status: character.status),
                      _InfoChip(label: character.species),
                      _InfoChip(label: character.gender),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    character.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'alive' => const Color(0xFF2E7D32),
      'dead' => const Color(0xFFC62828),
      _ => const Color(0xFF6D4C41),
    };

    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(Icons.circle, size: 10, color: color),
      label: Text(status),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(visualDensity: VisualDensity.compact, label: Text(label));
  }
}
