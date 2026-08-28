import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/features/analytics/analytics_tracker.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/data/episode_repository.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/character_sort.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/episode_models.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/presentation/episode_details_controller.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/presentation/load_status.dart';

void main() {
  test('EpisodeDetailsController does not wait for analytics', () async {
    final analytics = PendingAnalyticsTracker();
    final controller = EpisodeDetailsController(
      episodeId: 1,
      episodeRepository: FakeEpisodeRepository(),
      analyticsTracker: analytics,
    );

    await controller.load().timeout(const Duration(milliseconds: 100));

    expect(controller.status, LoadStatus.success);
    expect(controller.details?.characters.single.name, 'Rick Sanchez');
    analytics.complete();
  });
}

class FakeEpisodeRepository implements EpisodeRepository {
  @override
  Future<EpisodeListPage> getEpisodes({int page = 1}) async =>
      throw UnimplementedError();

  @override
  Future<EpisodeDetails> getEpisodeDetails(
    int episodeId, {
    CharacterSortBy sortBy = CharacterSortBy.name,
  }) async {
    return const EpisodeDetails(
      id: 1,
      name: 'Pilot',
      airDate: 'December 2, 2013',
      code: 'S01E01',
      characterCount: 1,
      characters: [
        CharacterSummary(
          id: 1,
          name: 'Rick Sanchez',
          status: 'Alive',
          species: 'Human',
          type: '',
          gender: 'Male',
          image: '',
          origin: 'Earth',
          location: 'Earth',
          episodeCount: 51,
        ),
      ],
    );
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
