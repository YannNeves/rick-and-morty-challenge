import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/widgets/web_detail_header.dart';
import '../../../core/ui/display_value.dart';
import '../../../core/ui/pluralization.dart';
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
    this.onGoHome,
    super.key,
  });

  final CharacterSummary character;
  final CharacterRepository characterRepository;
  final EpisodeRepository episodeRepository;
  final LocationRepository locationRepository;
  final VoidCallback? onGoHome;

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
      appBar:
          kIsWeb
              ? WebDetailHeader(
                title: widget.character.name.toUpperCase(),
                onBack: () => Navigator.of(context).maybePop(),
                onHome: _goHome,
              )
              : AppBar(
                leading: BackButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
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
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: ListView(
                key: const ValueKey('character-details-page'),
                padding: const EdgeInsets.only(top: 20, bottom: 40),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child:
                        kIsWeb
                            ? _DesktopCharacterOverview(
                              data: data,
                              onLocationSelected: _openLocation,
                            )
                            : CharacterCard(
                              name: data.details.name,
                              status: data.details.status,
                              species: data.details.species,
                              image: data.details.image,
                              origin: data.details.origin.name,
                            ),
                  ),
                  if (!kIsWeb) ...[
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        height: 180,
                        child: Row(
                          children: [
                            Expanded(
                              child: _DesktopPlaceCard(
                                label: 'Origem',
                                reference: data.details.origin,
                                location: data.locationById(
                                  data.details.origin.id,
                                ),
                                isOrigin: true,
                                width: double.infinity,
                                onTap: _openLocation,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DesktopPlaceCard(
                                label: 'Localização atual',
                                reference: data.details.location,
                                location: data.locationById(
                                  data.details.location.id,
                                ),
                                width: double.infinity,
                                onTap: _openLocation,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  _SectionTitle(
                    title: 'Episódios',
                    count: data.episodes.length,
                  ),
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
              ),
            ),
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
              onGoHome: widget.onGoHome,
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
              onGoHome: widget.onGoHome,
            ),
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.onGoHome?.call();
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

  LocationSummary? locationById(int? id) {
    if (id == null) return null;
    for (final location in locations) {
      if (location.id == id) return location;
    }
    return null;
  }
}

class _DesktopCharacterOverview extends StatelessWidget {
  const _DesktopCharacterOverview({
    required this.data,
    required this.onLocationSelected,
  });

  final _DetailsData data;
  final ValueChanged<LocationSummary> onLocationSelected;

  @override
  Widget build(BuildContext context) {
    final details = data.details;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.darkGray;
    return SizedBox(
      height: 400,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 320,
              child: Image.network(details.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 48),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/branding/episode.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          foreground,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        episodeParticipationText(details.episodeCount),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Wrap(
                    spacing: 28,
                    runSpacing: 12,
                    children: [
                      _OverviewAttribute(
                        icon: Icons.monitor_heart_outlined,
                        color: const Color(0xFFA8D900),
                        label: _translatedStatus(details.status),
                      ),
                      _OverviewAttribute(
                        asset: 'assets/branding/character.svg',
                        color: foreground,
                        label: _translatedSpecies(details.species),
                      ),
                      _OverviewAttribute(
                        icon: _genderIcon(details.gender),
                        color: foreground,
                        label: _translatedGender(details.gender),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: 180,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DesktopPlaceCard(
                            label: 'Origem',
                            reference: details.origin,
                            location: data.locationById(details.origin.id),
                            isOrigin: true,
                            onTap: onLocationSelected,
                          ),
                          const SizedBox(width: 14),
                          _DesktopPlaceCard(
                            label: 'Localização atual',
                            reference: details.location,
                            location: data.locationById(details.location.id),
                            onTap: onLocationSelected,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _translatedStatus(String value) => switch (value
      .toLowerCase()) {
    'alive' => 'Vivo',
    'dead' => 'Morto',
    _ => 'Desconhecido',
  };

  static String _translatedSpecies(String value) => switch (value
      .toLowerCase()) {
    'human' => 'Humano',
    'alien' => 'Alienígena',
    _ => displayValue(value),
  };

  static String _translatedGender(String value) => switch (value
      .toLowerCase()) {
    'male' => 'Masculino',
    'female' => 'Feminino',
    'genderless' => 'Sem gênero',
    _ => 'Desconhecido',
  };

  static IconData _genderIcon(String value) => switch (value.toLowerCase()) {
    'female' => Icons.female,
    'male' => Icons.male,
    _ => Icons.transgender,
  };
}

class _DesktopPlaceCard extends StatelessWidget {
  const _DesktopPlaceCard({
    required this.label,
    required this.reference,
    required this.location,
    required this.onTap,
    this.isOrigin = false,
    this.width = 176,
  });

  final String label;
  final CharacterReference reference;
  final LocationSummary? location;
  final ValueChanged<LocationSummary> onTap;
  final bool isOrigin;
  final double width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.darkGray;
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (isOrigin)
            SvgPicture.asset(
              'assets/branding/planet.svg',
              width: 36,
              height: 36,
              colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
            )
          else
            Icon(Icons.location_on_outlined, size: 36, color: foreground),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          Text(
            reference.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.blue),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: location == null ? null : () => onTap(location!),
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text('Saiba mais'),
            style: FilledButton.styleFrom(
              fixedSize: const Size(115, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewAttribute extends StatelessWidget {
  const _OverviewAttribute({
    required this.color,
    required this.label,
    this.icon,
    this.asset,
  });

  final Color color;
  final String label;
  final IconData? icon;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (asset != null)
          SvgPicture.asset(
            asset!,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          )
        else
          Icon(icon, size: 24, color: color),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
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
