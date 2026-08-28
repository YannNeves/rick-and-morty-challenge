import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_destination.dart';
import 'app_shell_view_model.dart';
import 'widgets/app_header.dart';
import 'widgets/app_search_bar.dart';
import 'widgets/animated_bottom_navigation.dart';
import '../../features/episodes/data/episode_repository.dart';
import '../../features/home/ui/views/home_view.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.viewModel,
    required this.episodeRepository,
    super.key,
  });

  final AppShellViewModel viewModel;
  final EpisodeRepository episodeRepository;

  @override
  Widget build(BuildContext context) {
    final destination = AppDestination.values[viewModel.selectedIndex];

    return Scaffold(
      appBar: kIsWeb ? null : AppHeader(onToggleTheme: viewModel.toggleTheme),
      body: Column(
        children: [
          if (!kIsWeb)
            AppSearchBar(
              initialValue: viewModel.searchQuery,
              onChanged: viewModel.updateSearchQuery,
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
    if (destination == AppDestination.home) {
      return HomeView(
        episodeRepository: episodeRepository,
        onShowAllEpisodes:
            () => viewModel.selectDestination(AppDestination.episodes.index),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Center(
        key: ValueKey(destination),
        child: Text(
          destination.routeLabel,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
