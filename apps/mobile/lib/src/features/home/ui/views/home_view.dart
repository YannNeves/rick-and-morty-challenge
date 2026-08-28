import 'package:flutter/material.dart';

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

class HomeView extends StatefulWidget {
  const HomeView({
    required this.characterRepository,
    required this.episodeRepository,
    required this.locationRepository,
    required this.onShowAllEpisodes,
    required this.onShowAllLocations,
    required this.onShowAllCharacters,
    super.key,
  });

  final CharacterRepository characterRepository;
  final EpisodeRepository episodeRepository;
  final LocationRepository locationRepository;
  final VoidCallback onShowAllEpisodes;
  final VoidCallback onShowAllLocations;
  final VoidCallback onShowAllCharacters;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;

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
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20, bottom: 24),
          child: Column(
            children: [
              EpisodesSection(
                status: _viewModel.status,
                episodes: _viewModel.episodes,
                errorMessage: _viewModel.errorMessage,
                onRetry: _viewModel.loadEpisodes,
                onShowAll: widget.onShowAllEpisodes,
                onEpisodeSelected: _openEpisode,
              ),
              const SizedBox(height: 32),
              LocationsSection(
                status: _viewModel.locationsStatus,
                locations: _viewModel.locations,
                errorMessage: _viewModel.locationsErrorMessage,
                onRetry: _viewModel.loadLocations,
                onShowAll: widget.onShowAllLocations,
                onLocationSelected: _openLocation,
              ),
              const SizedBox(height: 32),
              CharactersSection(
                status: _viewModel.charactersStatus,
                characters: _viewModel.characters,
                errorMessage: _viewModel.charactersErrorMessage,
                onRetry: _viewModel.loadCharacters,
                onShowAll: widget.onShowAllCharacters,
                onCharacterSelected: _openCharacter,
              ),
            ],
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
