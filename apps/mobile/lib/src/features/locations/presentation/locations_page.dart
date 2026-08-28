import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/ui/display_value.dart';
import '../../characters/data/character_repository.dart';
import '../../episodes/data/episode_repository.dart';
import '../../episodes/presentation/widgets/empty_error_state.dart';
import '../data/location_repository.dart';
import '../domain/location_models.dart';
import 'location_details_page.dart';
import 'locations_controller.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({
    required this.locationRepository,
    required this.characterRepository,
    required this.episodeRepository,
    required this.searchQuery,
    required this.filters,
    super.key,
  });

  final LocationRepository locationRepository;
  final CharacterRepository characterRepository;
  final EpisodeRepository episodeRepository;
  final String searchQuery;
  final Map<String, String> filters;

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  late final LocationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LocationsController(
      locationRepository: widget.locationRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.status == LocationsLoadStatus.loading &&
            _controller.locations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.status == LocationsLoadStatus.failure) {
          return EmptyErrorState(
            title: 'Localizações indisponíveis',
            message: _controller.errorMessage ?? 'Tente novamente.',
            onRetry: _controller.load,
          );
        }

        if (_controller.status == LocationsLoadStatus.success &&
            _controller.locations.isEmpty) {
          return EmptyErrorState(
            title: 'Nenhuma localização encontrada',
            message: 'A API não retornou localizações.',
            onRetry: _controller.load,
          );
        }

        final normalizedQuery = widget.searchQuery.toLowerCase();
        final typeFilter = widget.filters['type'] ?? '';
        final dimensionFilter = widget.filters['dimension'] ?? '';
        final filteredLocations = (normalizedQuery.isEmpty
                ? _controller.locations
                : _controller.locations
                    .where((location) {
                      final matchesName = location.name.toLowerCase().contains(
                        normalizedQuery,
                      );
                      final matchesType = location.type.toLowerCase().contains(
                        typeFilter,
                      );
                      final matchesDimension = location.dimension
                          .toLowerCase()
                          .contains(dimensionFilter);
                      return matchesName && matchesType && matchesDimension;
                    })
                    .toList(growable: false))
            .toList(growable: true);
        final sortBy = widget.filters['sortBy'] ?? 'name';
        final descending = widget.filters['order'] == 'desc';
        filteredLocations.sort((left, right) {
          final result = switch (sortBy) {
            'type' => left.type.toLowerCase().compareTo(
              right.type.toLowerCase(),
            ),
            'dimension' => left.dimension.toLowerCase().compareTo(
              right.dimension.toLowerCase(),
            ),
            'residents' => left.residentCount.compareTo(right.residentCount),
            _ => left.name.toLowerCase().compareTo(right.name.toLowerCase()),
          };
          return descending ? -result : result;
        });

        return RefreshIndicator(
          onRefresh: _controller.load,
          child: ListView.separated(
            key: const ValueKey('locations-page-list'),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            itemCount:
                filteredLocations.isEmpty ? 2 : filteredLocations.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _LocationsHeader(count: filteredLocations.length);
              }

              if (filteredLocations.isEmpty) {
                return const _NoSearchResults();
              }

              final location = filteredLocations[index - 1];
              return _LocationListCard(
                location: location,
                onTap: () => _openLocation(location),
              );
            },
          ),
        );
      },
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
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma localização corresponde à busca.',
            key: const ValueKey('locations-no-search-results'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LocationsHeader extends StatelessWidget {
  const _LocationsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Localizações',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text('$count encontradas'),
        ],
      ),
    );
  }
}

class _LocationListCard extends StatelessWidget {
  const _LocationListCard({required this.location, required this.onTap});

  final LocationSummary location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.darkGray;

    return Material(
      color: isDark ? AppColors.darkGray : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/branding/planet.svg',
                  width: 52,
                  height: 52,
                  colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayValue(location.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${displayValue(location.dimension)} • ${location.residentCount} residentes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
