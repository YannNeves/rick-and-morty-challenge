import 'package:flutter/material.dart';

import 'navigation/app_shell.dart';
import 'navigation/app_shell_view_model.dart';
import 'theme/app_theme.dart';
import '../features/episodes/data/episode_repository.dart';

class RickAndMortyApp extends StatefulWidget {
  const RickAndMortyApp({required this.episodeRepository, super.key});

  final EpisodeRepository episodeRepository;

  @override
  State<RickAndMortyApp> createState() => _RickAndMortyAppState();
}

class _RickAndMortyAppState extends State<RickAndMortyApp> {
  late final AppShellViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AppShellViewModel();
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
        return MaterialApp(
          title: 'Rick and Morty',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _viewModel.themeMode,
          home: AppShell(
            viewModel: _viewModel,
            episodeRepository: widget.episodeRepository,
          ),
        );
      },
    );
  }
}
