import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../episodes/presentation/widgets/empty_error_state.dart';
import '../data/location_repository.dart';
import '../domain/location_models.dart';
import 'locations_controller.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({
    required this.locationRepository,
    required this.searchQuery,
    super.key,
  });

  final LocationRepository locationRepository;
  final String searchQuery;

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
        final filteredLocations =
            normalizedQuery.isEmpty
                ? _controller.locations
                : _controller.locations
                    .where((location) {
                      return location.name.toLowerCase().contains(
                            normalizedQuery,
                          ) ||
                          location.type.toLowerCase().contains(
                            normalizedQuery,
                          ) ||
                          location.dimension.toLowerCase().contains(
                            normalizedQuery,
                          );
                    })
                    .toList(growable: false);

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

              return _LocationListCard(location: filteredLocations[index - 1]);
            },
          ),
        );
      },
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
  const _LocationListCard({required this.location});

  final LocationSummary location;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.darkGray;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
      ),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${location.dimension} • ${location.residentCount} residentes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
