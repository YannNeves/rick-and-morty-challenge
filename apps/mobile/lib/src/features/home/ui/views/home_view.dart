import 'package:flutter/material.dart';

import '../../../episodes/data/episode_repository.dart';
import '../../../episodes/domain/episode_models.dart';
import '../../../episodes/presentation/episode_details_page.dart';
import '../view_models/home_view_model.dart';
import '../widgets/episodes_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    required this.episodeRepository,
    required this.onShowAllEpisodes,
    super.key,
  });

  final EpisodeRepository episodeRepository;
  final VoidCallback onShowAllEpisodes;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(episodeRepository: widget.episodeRepository);
    _viewModel.loadEpisodes();
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
          child: EpisodesSection(
            status: _viewModel.status,
            episodes: _viewModel.episodes,
            errorMessage: _viewModel.errorMessage,
            onRetry: _viewModel.loadEpisodes,
            onShowAll: widget.onShowAllEpisodes,
            onEpisodeSelected: _openEpisode,
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
}
