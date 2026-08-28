import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../characters/data/character_repository.dart';
import '../../../characters/domain/character_models.dart';
import '../../../characters/presentation/character_details_page.dart';
import '../../../episodes/data/episode_repository.dart';
import '../../../episodes/domain/episode_models.dart' hide CharacterSummary;
import '../../../episodes/presentation/episode_details_page.dart';
import '../../../locations/data/location_repository.dart';
import '../../../locations/domain/location_models.dart';
import '../../../locations/presentation/location_details_page.dart';
import '../view_models/home_view_model.dart';
import '../widgets/characters_section.dart';
import '../widgets/episodes_section.dart';
import '../widgets/locations_section.dart';
import '../widgets/web_hero.dart';
import '../widgets/web_home_content.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    required this.characterRepository,
    required this.episodeRepository,
    required this.locationRepository,
    required this.onShowAllEpisodes,
    required this.onShowAllLocations,
    required this.onShowAllCharacters,
    required this.onToggleTheme,
    super.key,
  });

  final CharacterRepository characterRepository;
  final EpisodeRepository episodeRepository;
  final LocationRepository locationRepository;
  final VoidCallback onShowAllEpisodes;
  final VoidCallback onShowAllLocations;
  final VoidCallback onShowAllCharacters;
  final VoidCallback onToggleTheme;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      characterRepository: widget.characterRepository,
      episodeRepository: widget.episodeRepository,
      locationRepository: widget.locationRepository,
    );
    _viewModel.loadEpisodes();
    _viewModel.loadLocations();
    _viewModel.loadCharacters();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(top: kIsWeb ? 0 : 20, bottom: 24),
          child: Column(
            children: [
              if (kIsWeb) WebHero(onToggleTheme: widget.onToggleTheme),
              if (kIsWeb)
                WebHomeContent(
                  viewModel: _viewModel,
                  onShowAllLocations: widget.onShowAllLocations,
                  onShowAllEpisodes: widget.onShowAllEpisodes,
                  onShowAllCharacters: widget.onShowAllCharacters,
                  onLocationSelected: _openLocation,
                  onEpisodeSelected: _openEpisode,
                  onCharacterSelected: _openCharacter,
                  onBackToTop:
                      () => _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                      ),
                )
              else ...[
                EpisodesSection(
                  status: _viewModel.status,
                  episodes: _viewModel.episodes,
                  errorMessage: _viewModel.errorMessage,
                  onRetry: _viewModel.loadEpisodes,
                  onShowAll: widget.onShowAllEpisodes,
                  onEpisodeSelected: _openEpisode,
                  hasMore: _viewModel.hasMoreEpisodes,
                  isLoadingMore: _viewModel.isLoadingMoreEpisodes,
                  loadMoreError: _viewModel.moreEpisodesError,
                  onLoadMore: _viewModel.loadMoreEpisodes,
                  onRetryLoadMore: _viewModel.retryMoreEpisodes,
                ),
                const SizedBox(height: 32),
                LocationsSection(
                  status: _viewModel.locationsStatus,
                  locations: _viewModel.locations,
                  errorMessage: _viewModel.locationsErrorMessage,
                  onRetry: _viewModel.loadLocations,
                  onShowAll: widget.onShowAllLocations,
                  onLocationSelected: _openLocation,
                  hasMore: _viewModel.hasMoreLocations,
                  isLoadingMore: _viewModel.isLoadingMoreLocations,
                  loadMoreError: _viewModel.moreLocationsError,
                  onLoadMore: _viewModel.loadMoreLocations,
                  onRetryLoadMore: _viewModel.retryMoreLocations,
                ),
                const SizedBox(height: 32),
                CharactersSection(
                  status: _viewModel.charactersStatus,
                  characters: _viewModel.characters,
                  errorMessage: _viewModel.charactersErrorMessage,
                  onRetry: _viewModel.loadCharacters,
                  onShowAll: widget.onShowAllCharacters,
                  onCharacterSelected: _openCharacter,
                  hasMore: _viewModel.hasMoreCharacters,
                  isLoadingMore: _viewModel.isLoadingMoreCharacters,
                  loadMoreError: _viewModel.moreCharactersError,
                  onRetryLoadMore: _viewModel.retryMoreCharacters,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < 600) {
      _viewModel.loadMoreCharacters();
    }
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
            ),
      ),
    );
  }

  void _openLocation(LocationSummary location) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => LocationDetailsPage(
              location: location,
              locationRepository: widget.locationRepository,
              characterRepository: widget.characterRepository,
              episodeRepository: widget.episodeRepository,
            ),
      ),
    );
  }

  void _openCharacter(CharacterSummary character) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => CharacterDetailsPage(
              character: character,
              characterRepository: widget.characterRepository,
              episodeRepository: widget.episodeRepository,
              locationRepository: widget.locationRepository,
            ),
      ),
    );
  }
}
