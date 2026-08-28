import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/features/analytics/analytics_tracker.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/data/episode_repository.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/character_sort.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/episode_models.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/presentation/episodes_controller.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/presentation/load_status.dart';

void main() {
  test('EpisodesController loads episodes and tracks page view', () async {
    final analytics = RecordingAnalyticsTracker();
    final controller = EpisodesController(
      episodeRepository: FakeEpisodeRepository(),
      analyticsTracker: analytics,
    );

    await controller.load(pageNumber: 1);

    expect(controller.status, LoadStatus.success);
    expect(controller.page?.episodes.single.name, 'Pilot');
    expect(analytics.names, contains('episode_list_viewed'));
  });

  test(
    'EpisodesController does not wait for analytics to publish data',
    () async {
      final analytics = PendingAnalyticsTracker();
      final controller = EpisodesController(
        episodeRepository: FakeEpisodeRepository(),
        analyticsTracker: analytics,
      );

      await controller.load().timeout(const Duration(milliseconds: 100));

      expect(controller.status, LoadStatus.success);
      expect(controller.page, isNotNull);
      analytics.complete();
    },
  );
}

class FakeEpisodeRepository implements EpisodeRepository {
  @override
  Future<EpisodeListPage> getEpisodes({int page = 1}) async {
    return EpisodeListPage(
      page: page,
      totalPages: 1,
      totalItems: 1,
      hasNextPage: false,
      hasPreviousPage: false,
      episodes: const [
        EpisodeSummary(
          id: 1,
          name: 'Pilot',
          airDate: 'December 2, 2013',
          code: 'S01E01',
          characterCount: 1,
        ),
      ],
    );
  }

  @override
  Future<EpisodeDetails> getEpisodeDetails(
    int episodeId, {
    CharacterSortBy sortBy = CharacterSortBy.name,
  }) async {
    throw UnimplementedError();
  }
}

class RecordingAnalyticsTracker implements AnalyticsTracker {
  final names = <String>[];

  @override
  Future<void> track(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {
    names.add(name);
  }
}

class PendingAnalyticsTracker implements AnalyticsTracker {
  final _completer = Completer<void>();

  @override
  Future<void> track(
    String name, {
    Map<String, Object?> properties = const {},
  }) => _completer.future;

  void complete() => _completer.complete();
}
