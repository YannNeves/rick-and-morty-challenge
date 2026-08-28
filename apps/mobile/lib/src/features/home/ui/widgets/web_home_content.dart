import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/ui/display_value.dart';
import '../../../characters/domain/character_models.dart';
import '../../../characters/presentation/widgets/character_card.dart';
import '../../../episodes/domain/episode_models.dart' hide CharacterSummary;
import '../../../locations/domain/location_models.dart';
import '../view_models/home_view_model.dart';

class WebHomeContent extends StatelessWidget {
  const WebHomeContent({
    required this.viewModel,
    required this.onShowAllLocations,
    required this.onShowAllEpisodes,
    required this.onShowAllCharacters,
    required this.onLocationSelected,
    required this.onEpisodeSelected,
    required this.onCharacterSelected,
    required this.onBackToTop,
    super.key,
  });

  final HomeViewModel viewModel;
  final VoidCallback onShowAllLocations;
  final VoidCallback onShowAllEpisodes;
  final VoidCallback onShowAllCharacters;
  final ValueChanged<LocationSummary> onLocationSelected;
  final ValueChanged<EpisodeSummary> onEpisodeSelected;
  final ValueChanged<CharacterSummary> onCharacterSelected;
  final VoidCallback onBackToTop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Localizações',
                onShowAll: onShowAllLocations,
              ),
              const SizedBox(height: 20),
              _LocationsRow(
                status: viewModel.locationsStatus,
                locations: viewModel.locations,
                onRetry: viewModel.loadLocations,
                onSelected: onLocationSelected,
                hasMore: viewModel.hasMoreLocations,
                isLoadingMore: viewModel.isLoadingMoreLocations,
                loadMoreError: viewModel.moreLocationsError,
                onLoadMore: viewModel.loadMoreLocations,
                onRetryLoadMore: viewModel.retryMoreLocations,
              ),
              const SizedBox(height: 52),
              _SectionHeader(title: 'Episódios', onShowAll: onShowAllEpisodes),
              const SizedBox(height: 20),
              _EpisodesRow(
                status: viewModel.status,
                episodes: viewModel.episodes,
                onRetry: viewModel.loadEpisodes,
                onSelected: onEpisodeSelected,
                hasMore: viewModel.hasMoreEpisodes,
                isLoadingMore: viewModel.isLoadingMoreEpisodes,
                loadMoreError: viewModel.moreEpisodesError,
                onLoadMore: viewModel.loadMoreEpisodes,
                onRetryLoadMore: viewModel.retryMoreEpisodes,
              ),
              const SizedBox(height: 52),
              _SectionHeader(
                title: 'Personagens',
                onShowAll: onShowAllCharacters,
              ),
              const SizedBox(height: 20),
              _CharactersGrid(
                status: viewModel.charactersStatus,
                characters: viewModel.characters,
                onRetry: viewModel.loadCharacters,
                onSelected: onCharacterSelected,
                hasMore: viewModel.hasMoreCharacters,
                isLoadingMore: viewModel.isLoadingMoreCharacters,
                loadMoreError: viewModel.moreCharactersError,
                onRetryLoadMore: viewModel.retryMoreCharacters,
              ),
              const SizedBox(height: 72),
              _WebFooter(onBackToTop: onBackToTop),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onShowAll});

  final String title;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: onShowAll,
          icon: const Icon(Icons.grid_view_rounded, size: 20),
          label: const Text('Ver todos'),
          style: FilledButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkGray : AppColors.blue,
            foregroundColor: AppColors.white,
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }
}

class _LocationsRow extends StatelessWidget {
  const _LocationsRow({
    required this.status,
    required this.locations,
    required this.onRetry,
    required this.onSelected,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onRetryLoadMore,
    required this.loadMoreError,
  });
  final HomeLoadStatus status;
  final List<LocationSummary> locations;
  final VoidCallback onRetry;
  final ValueChanged<LocationSummary> onSelected;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final VoidCallback onRetryLoadMore;
  final String? loadMoreError;

  @override
  Widget build(BuildContext context) {
    if (status != HomeLoadStatus.success) {
      return _LoadState(status: status, onRetry: onRetry, height: 210);
    }
    if (locations.isEmpty) {
      return const _EmptyState('Nenhuma localização encontrada.');
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 320) onLoadMore();
        return false;
      },
      child: SizedBox(
        height: 210,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: locations.length + (hasMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            if (index == locations.length) {
              return _WebLoadMore(
                isLoading: isLoadingMore,
                errorMessage: loadMoreError,
                onRetry: onRetryLoadMore,
              );
            }
            final location = locations[index];
            return _WebLocationCard(
              location: location,
              onTap: () => onSelected(location),
            );
          },
        ),
      ),
    );
  }
}

class _WebLocationCard extends StatelessWidget {
  const _WebLocationCard({required this.location, required this.onTap});
  final LocationSummary location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.darkGray;
    return SizedBox(
      width: 147,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              color: isDark ? AppColors.darkGray : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 38, 10, 12),
                  child: Column(
                    children: [
                      Text(
                        displayValue(location.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        location.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.blue),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Saiba mais'),
                        style: FilledButton.styleFrom(
                          fixedSize: const Size(115, 32),
                          minimumSize: const Size(115, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SvgPicture.asset(
            'assets/branding/planet.svg',
            width: 60,
            height: 60,
            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}

class _EpisodesRow extends StatelessWidget {
  const _EpisodesRow({
    required this.status,
    required this.episodes,
    required this.onRetry,
    required this.onSelected,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onRetryLoadMore,
    required this.loadMoreError,
  });
  final HomeLoadStatus status;
  final List<EpisodeSummary> episodes;
  final VoidCallback onRetry;
  final ValueChanged<EpisodeSummary> onSelected;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final VoidCallback onRetryLoadMore;
  final String? loadMoreError;

  @override
  Widget build(BuildContext context) {
    if (status != HomeLoadStatus.success) {
      return _LoadState(status: status, onRetry: onRetry, height: 96);
    }
    if (episodes.isEmpty) {
      return const _EmptyState('Nenhum episódio encontrado.');
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 320) onLoadMore();
        return false;
      },
      child: SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: episodes.length + (hasMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            if (index == episodes.length) {
              return _WebLoadMore(
                isLoading: isLoadingMore,
                errorMessage: loadMoreError,
                onRetry: onRetryLoadMore,
              );
            }
            final episode = episodes[index];
            return _WebEpisodeCard(
              episode: episode,
              onTap: () => onSelected(episode),
            );
          },
        ),
      ),
    );
  }
}

class _WebEpisodeCard extends StatelessWidget {
  const _WebEpisodeCard({required this.episode, required this.onTap});
  final EpisodeSummary episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkGray : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 190,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/branding/episode.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${episode.name} | ${episode.code}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Saiba mais'),
                    style: FilledButton.styleFrom(
                      fixedSize: const Size(115, 32),
                      minimumSize: const Size(115, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CharactersGrid extends StatelessWidget {
  const _CharactersGrid({
    required this.status,
    required this.characters,
    required this.onRetry,
    required this.onSelected,
    required this.hasMore,
    required this.isLoadingMore,
    required this.loadMoreError,
    required this.onRetryLoadMore,
  });
  final HomeLoadStatus status;
  final List<CharacterSummary> characters;
  final VoidCallback onRetry;
  final ValueChanged<CharacterSummary> onSelected;
  final bool hasMore;
  final bool isLoadingMore;
  final String? loadMoreError;
  final VoidCallback onRetryLoadMore;

  @override
  Widget build(BuildContext context) {
    if (status != HomeLoadStatus.success) {
      return _LoadState(status: status, onRetry: onRetry, height: 400);
    }
    if (characters.isEmpty) {
      return const _EmptyState('Nenhum personagem encontrado.');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 1100
                ? 4
                : (constraints.maxWidth >= 700 ? 3 : 2);
        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: characters.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.735,
              ),
              itemBuilder: (context, index) {
                final character = characters[index];
                return CharacterCard(
                  name: character.name,
                  status: character.status,
                  species: character.species,
                  image: character.image,
                  origin: character.origin,
                  onTap: () => onSelected(character),
                );
              },
            ),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.all(24),
                child:
                    loadMoreError != null
                        ? OutlinedButton.icon(
                          onPressed: onRetryLoadMore,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Tentar novamente'),
                        )
                        : isLoadingMore
                        ? const CircularProgressIndicator()
                        : const SizedBox(height: 40),
              ),
          ],
        );
      },
    );
  }
}

class _WebLoadMore extends StatelessWidget {
  const _WebLoadMore({
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 170,
    child: Center(
      child:
          errorMessage != null
              ? TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              )
              : isLoading
              ? const CircularProgressIndicator()
              : const SizedBox.shrink(),
    ),
  );
}

class _LoadState extends StatelessWidget {
  const _LoadState({
    required this.status,
    required this.onRetry,
    required this.height,
  });
  final HomeLoadStatus status;
  final VoidCallback onRetry;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child:
            status == HomeLoadStatus.failure
                ? TextButton(
                  onPressed: onRetry,
                  child: const Text('Tentar novamente'),
                )
                : const CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(child: Text(message)),
    );
  }
}

class _WebFooter extends StatelessWidget {
  const _WebFooter({required this.onBackToTop});
  final VoidCallback onBackToTop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/branding/logo_a.svg',
          width: 165,
          semanticsLabel: 'Rick and Morty',
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onBackToTop,
          label: const Text('Voltar ao topo'),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_circle_up_outlined),
        ),
      ],
    );
  }
}
