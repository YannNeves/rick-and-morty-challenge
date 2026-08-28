import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../characters/presentation/widgets/character_card.dart';
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
      appBar: AppBar(
        title: Text(
          '${widget.episode.name.toUpperCase()} - ${widget.episode.code}',
        ),
      ),
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
                sliver: SliverList.builder(
                  itemCount: details.characters.length,
                  itemBuilder: (context, index) {
                    final character = details.characters[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CharacterCard(
                        name: character.name,
                        status: character.status,
                        species: character.species,
                        image: character.image,
                        origin: character.origin,
                      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EpisodeInformation(
              icon: Icons.calendar_month_outlined,
              label: 'Data que foi ao ar:',
              value: details.airDate,
            ),
            const SizedBox(height: 12),
            _EpisodeInformation(
              icon: Icons.people_outline,
              label: 'Número de personagens:',
              value: '${details.characterCount}',
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeInformation extends StatelessWidget {
  const _EpisodeInformation({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 2),
        Icon(icon, size: 22, color: AppColors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
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
