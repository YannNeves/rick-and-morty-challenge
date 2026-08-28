import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../locations/domain/location_models.dart';
import '../view_models/home_view_model.dart';

class LocationsSection extends StatelessWidget {
  const LocationsSection({
    required this.status,
    required this.locations,
    required this.onRetry,
    required this.onShowAll,
    required this.onLocationSelected,
    this.errorMessage,
    super.key,
  });

  final HomeLoadStatus status;
  final List<LocationSummary> locations;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onShowAll;
  final ValueChanged<LocationSummary> onLocationSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SectionHeader(onShowAll: onShowAll),
        ),
        const SizedBox(height: 18),
        switch (status) {
          HomeLoadStatus.initial || HomeLoadStatus.loading => const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          ),
          HomeLoadStatus.empty => const _SectionMessage(
            message: 'Nenhuma localização encontrada.',
          ),
          HomeLoadStatus.failure => _SectionMessage(
            message:
                errorMessage ?? 'Não foi possível carregar as localizações.',
            onRetry: onRetry,
          ),
          HomeLoadStatus.success => SizedBox(
            height: 240,
            child: ListView.separated(
              key: const ValueKey('home-locations-list'),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: locations.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final location = locations[index];
                return _LocationCard(
                  location: location,
                  onTap: () => onLocationSelected(location),
                );
              },
            ),
          ),
        },
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            'Localizações',
            key: const ValueKey('locations-section-title'),
            maxLines: 1,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: onShowAll,
          style: FilledButton.styleFrom(
            backgroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkGray
                    : AppColors.blue,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          icon: const Icon(Icons.grid_view_rounded, size: 22),
          label: const Text('Ver todos'),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location, required this.onTap});

  final LocationSummary location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.darkGray;

    return SizedBox(
      width: 176,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkGray : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 42, 12, 14),
                child: Column(
                  children: [
                    Text(
                      location.type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: AppColors.blue),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.info_outline, size: 22),
                      label: const Text('Saiba mais'),
                    ),
                    const Spacer(),
                    const Icon(Icons.favorite, color: AppColors.blue, size: 32),
                  ],
                ),
              ),
            ),
          ),
          SvgPicture.asset(
            'assets/branding/planet.svg',
            width: 62,
            height: 62,
            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: const Text('Tentar novamente'),
              ),
          ],
        ),
      ),
    );
  }
}
