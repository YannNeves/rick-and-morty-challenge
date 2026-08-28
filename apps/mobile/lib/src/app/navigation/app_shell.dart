import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_destination.dart';
import 'app_shell_view_model.dart';
import 'widgets/app_header.dart';
import 'widgets/app_search_bar.dart';
import 'widgets/app_filters_drawer.dart';
import 'widgets/animated_bottom_navigation.dart';
import 'widgets/web_home_logo.dart';
import '../../features/characters/data/character_repository.dart';
import '../../features/characters/presentation/characters_page.dart';
import '../../features/episodes/data/episode_repository.dart';
import '../../features/episodes/presentation/episodes_page.dart';
import '../../features/home/ui/views/home_view.dart';
import '../../features/locations/data/location_repository.dart';
import '../../features/locations/presentation/locations_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.viewModel,
    required this.characterRepository,
    required this.episodeRepository,
    required this.locationRepository,
    super.key,
  });

  final AppShellViewModel viewModel;
  final CharacterRepository characterRepository;
  final EpisodeRepository episodeRepository;
  final LocationRepository locationRepository;

  @override
  Widget build(BuildContext context) {
    final destination = AppDestination.values[viewModel.selectedIndex];

    return Scaffold(
      appBar: kIsWeb ? null : AppHeader(onToggleTheme: viewModel.toggleTheme),
      body: Column(
        children: [
          if (kIsWeb && destination != AppDestination.home)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1288),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 0,
                          child: IconButton.outlined(
                            key: const ValueKey('web-back-to-home-button'),
                            tooltip: 'Voltar para a Home',
                            onPressed:
                                () => viewModel.selectDestination(
                                  AppDestination.home.index,
                                ),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        WebHomeLogo(
                          onTap:
                              () => viewModel.selectDestination(
                                AppDestination.home.index,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (destination != AppDestination.home)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1288),
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchBar(
                        initialValue: viewModel.searchQuery,
                        hintText: destination.searchHint,
                        padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
                        onChanged: viewModel.updateSearchQuery,
                        hasActiveFilters:
                            viewModel.filtersFor(destination).isNotEmpty,
                        onFilterPressed:
                            () => _openFilters(context, destination),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: _buildDestination(context, destination)),
        ],
      ),
      bottomNavigationBar:
          kIsWeb
              ? null
              : AnimatedBottomNavigation(
                selectedIndex: viewModel.selectedIndex,
                onDestinationSelected: viewModel.selectDestination,
              ),
    );
  }

  Widget _buildDestination(BuildContext context, AppDestination destination) {
    return switch (destination) {
      AppDestination.home => HomeView(
        characterRepository: characterRepository,
        episodeRepository: episodeRepository,
        locationRepository: locationRepository,
        onShowAllEpisodes:
            () => viewModel.selectDestination(AppDestination.episodes.index),
        onShowAllLocations:
            () => viewModel.selectDestination(AppDestination.locations.index),
        onShowAllCharacters:
            () => viewModel.selectDestination(AppDestination.characters.index),
        onToggleTheme: viewModel.toggleTheme,
      ),
      AppDestination.locations => LocationsPage(
        locationRepository: locationRepository,
        characterRepository: characterRepository,
        episodeRepository: episodeRepository,
        searchQuery: viewModel.searchQuery,
        filters: viewModel.filtersFor(destination),
        onGoHome: () => viewModel.selectDestination(AppDestination.home.index),
      ),
      AppDestination.episodes => EpisodesPage(
        episodeRepository: episodeRepository,
        characterRepository: characterRepository,
        locationRepository: locationRepository,
        searchQuery: viewModel.searchQuery,
        filters: viewModel.filtersFor(destination),
        onGoHome: () => viewModel.selectDestination(AppDestination.home.index),
      ),
      AppDestination.characters => CharactersPage(
        characterRepository: characterRepository,
        episodeRepository: episodeRepository,
        locationRepository: locationRepository,
        searchQuery: viewModel.searchQuery,
        filters: viewModel.filtersFor(destination),
        onGoHome: () => viewModel.selectDestination(AppDestination.home.index),
      ),
    };
  }

  Future<void> _openFilters(
    BuildContext context,
    AppDestination destination,
  ) async {
    final filters = await showAppFiltersDrawer(
      context,
      destination: destination,
      initialFilters: viewModel.filtersFor(destination),
    );
    if (filters != null) viewModel.updateFilters(destination, filters);
  }
}
