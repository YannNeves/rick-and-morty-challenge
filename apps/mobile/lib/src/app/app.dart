import 'package:flutter/material.dart';

import '../features/analytics/analytics_tracker.dart';
import '../features/episodes/data/episode_repository.dart';
import '../features/episodes/presentation/episodes_page.dart';

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({
    required this.episodeRepository,
    required this.analyticsTracker,
    super.key,
  });

  final EpisodeRepository episodeRepository;
  final AnalyticsTracker analyticsTracker;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF00796B);

    return MaterialApp(
      title: 'Rick and Morty Episodes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: EpisodesPage(
        episodeRepository: episodeRepository,
        analyticsTracker: analyticsTracker,
      ),
    );
  }
}
