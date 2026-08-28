import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/widgets/app_search_bar.dart';
import '../../../app/navigation/widgets/web_detail_header.dart';
import '../../characters/data/character_repository.dart';
import '../../characters/domain/character_models.dart' as character_models;
import '../../characters/presentation/character_details_page.dart';
import '../../characters/presentation/widgets/character_card.dart';
import '../../characters/presentation/widgets/character_sort_drawer.dart';
import '../../locations/data/location_repository.dart';
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
    required this.characterRepository,
    required this.locationRepository,
    this.onGoHome,
    super.key,
  });

  final EpisodeSummary episode;
  final EpisodeRepository episodeRepository;
  final CharacterRepository characterRepository;
  final LocationRepository locationRepository;
  final VoidCallback? onGoHome;

  @override
  State<EpisodeDetailsPage> createState() => _EpisodeDetailsPageState();
}

class _EpisodeDetailsPageState extends State<EpisodeDetailsPage> {
  late final EpisodeDetailsController _controller;
  String _searchQuery = '';

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
      appBar:
          kIsWeb
              ? WebDetailHeader(
                title:
                    '${widget.episode.name.toUpperCase()} - ${widget.episode.code}',
                onBack: () => Navigator.of(context).maybePop(),
                onHome: _goHome,
              )
              : AppBar(
                leading: BackButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                title: Text(
                  '${widget.episode.name.toUpperCase()} - ${widget.episode.code}',
                  style: const TextStyle(color: AppColors.blue),
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

          final filteredCharacters = details.characters
              .where(
                (character) =>
                    character.name.toLowerCase().contains(_searchQuery),
              )
              .toList(growable: false);
          final isDesktop = MediaQuery.sizeOf(context).width >= 900;
          final width = MediaQuery.sizeOf(context).width;
          final horizontalPadding =
              isDesktop && width > 1288 ? (width - 1240) / 2 : 16.0;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    8,
                  ),
                  child: _EpisodeHeader(details: details),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: AppSearchBar(
                      initialValue: '',
                      hintText: 'Busque por personagem',
                      padding:
                          kIsWeb
                              ? const EdgeInsets.symmetric(vertical: 14)
                              : const EdgeInsets.fromLTRB(24, 14, 24, 8),
                      onChanged: (value) {
                        setState(
                          () => _searchQuery = value.trim().toLowerCase(),
                        );
                      },
                      hasActiveFilters:
                          _controller.sortBy != CharacterSortBy.name ||
                          _controller.sortOrder != CharacterSortOrder.ascending,
                      onFilterPressed: _openOptions,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? horizontalPadding : 24,
                    12,
                    isDesktop ? horizontalPadding : 24,
                    16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Personagens',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text('${filteredCharacters.length} encontrados'),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  24,
                ),
                sliver:
                    isDesktop
                        ? SliverGrid.builder(
                          itemCount: filteredCharacters.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 0.73,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemBuilder: (context, index) {
                            final character = filteredCharacters[index];
                            return CharacterCard(
                              name: character.name,
                              status: character.status,
                              species: character.species,
                              image: character.image,
                              origin: character.origin,
                              onTap: () => _openCharacter(character),
                            );
                          },
                        )
                        : SliverList.builder(
                          itemCount: filteredCharacters.length,
                          itemBuilder: (context, index) {
                            final character = filteredCharacters[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: CharacterCard(
                                name: character.name,
                                status: character.status,
                                species: character.species,
                                image: character.image,
                                origin: character.origin,
                                onTap: () => _openCharacter(character),
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

  Future<void> _openOptions() async {
    final result = await showCharacterSortDrawer(
      context,
      initialSort: _controller.sortBy,
      initialOrder: _controller.sortOrder,
    );
    if (result != null) {
      await _controller.changeSort(result.sortBy, result.order);
    }
  }

  void _openCharacter(CharacterSummary character) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => CharacterDetailsPage(
              character: character_models.CharacterSummary(
                id: character.id,
                name: character.name,
                status: character.status,
                species: character.species,
                type: character.type,
                gender: character.gender,
                image: character.image,
                origin: character.origin,
                location: character.location,
                episodeCount: character.episodeCount,
              ),
              characterRepository: widget.characterRepository,
              episodeRepository: widget.episodeRepository,
              locationRepository: widget.locationRepository,
              onGoHome: widget.onGoHome,
            ),
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.onGoHome?.call();
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
        Icon(icon, size: 22),
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
