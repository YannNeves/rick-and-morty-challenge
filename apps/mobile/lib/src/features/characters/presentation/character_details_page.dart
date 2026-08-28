import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/ui/display_value.dart';
import '../../episodes/data/episode_repository.dart';
import '../../episodes/domain/episode_models.dart' hide CharacterSummary;
import '../../episodes/presentation/episode_details_page.dart';
import '../../episodes/presentation/widgets/empty_error_state.dart';
import '../../locations/data/location_repository.dart';
import '../../locations/domain/location_models.dart';
import '../../locations/presentation/location_details_page.dart';
import '../data/character_repository.dart';
import '../domain/character_models.dart';
import 'widgets/character_card.dart';

class CharacterDetailsPage extends StatefulWidget {
  const CharacterDetailsPage({
    required this.character,
    required this.characterRepository,
    required this.episodeRepository,
    required this.locationRepository,
    super.key,
  });

  final CharacterSummary character;
  final CharacterRepository characterRepository;
  final EpisodeRepository episodeRepository;
  final LocationRepository locationRepository;

  @override
  State<CharacterDetailsPage> createState() => _CharacterDetailsPageState();
}

class _CharacterDetailsPageState extends State<CharacterDetailsPage> {
  late Future<_DetailsData> _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _data = _loadData();
  }

  Future<_DetailsData> _loadData() async {
    final details = await widget.characterRepository.getCharacterDetails(
      widget.character.id,
    );
    final locationIds =
        <int>{
          if (details.origin.id != null) details.origin.id!,
          if (details.location.id != null) details.location.id!,
        }.toList();
    final results = await Future.wait([
      widget.locationRepository.getLocationsBatch(locationIds),
      widget.episodeRepository.getEpisodesBatch(details.episodeIds),
    ]);
    return _DetailsData(
      details: details,
      locations: results[0] as List<LocationSummary>,
      episodes: results[1] as List<EpisodeSummary>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.character.name.toUpperCase(),
          style: const TextStyle(color: AppColors.blue),
        ),
      ),
      body: FutureBuilder<_DetailsData>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return EmptyErrorState(
              title: 'Personagem indisponível',
              message: 'Não foi possível carregar os detalhes.',
              onRetry: () => setState(_load),
            );
          }

          final data = snapshot.data!;
          return ListView(
            key: const ValueKey('character-details-page'),
            padding: const EdgeInsets.only(top: 12, bottom: 28),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CharacterCard(
                  name: data.details.name,
                  status: data.details.status,
                  species: data.details.species,
                  image: data.details.image,
                  origin: data.details.origin.name,
                ),
              ),
              const SizedBox(height: 28),
              _SectionTitle(
                title: 'Localizações',
                count: data.locations.length,
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: data.locations.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final location = data.locations[index];
                    return _LocationCard(
                      location: location,
                      onTap: () => _openLocation(location),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              _SectionTitle(title: 'Episódios', count: data.episodes.length),
              const SizedBox(height: 14),
              SizedBox(
                height: 116,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: data.episodes.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final episode = data.episodes[index];
                    return _EpisodeCard(
                      episode: episode,
                      onTap: () => _openEpisode(episode),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
}

class _DetailsData {
  const _DetailsData({
    required this.details,
    required this.locations,
    required this.episodes,
  });
  final CharacterDetails details;
  final List<LocationSummary> locations;
  final List<EpisodeSummary> episodes;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});
  final String title;
  final int count;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Text('$count'),
      ],
    ),
  );
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location, required this.onTap});
  final LocationSummary location;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 176,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkGray : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/branding/planet.svg',
            width: 42,
            height: 42,
            colorFilter: ColorFilter.mode(
              dark ? AppColors.white : AppColors.darkGray,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 8),
          Text(location.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            displayValue(location.type),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          FilledButton(onPressed: onTap, child: const Text('Saiba mais')),
        ],
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({required this.episode, required this.onTap});
  final EpisodeSummary episode;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkGray : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${episode.name} | ${episode.code}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.info_outline),
            label: const Text('Saiba mais'),
          ),
        ],
      ),
    );
  }
}
