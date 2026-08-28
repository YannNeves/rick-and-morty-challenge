import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../characters/presentation/widgets/character_card.dart';
import '../../episodes/presentation/widgets/empty_error_state.dart';
import '../data/location_repository.dart';
import '../domain/location_models.dart';

class LocationDetailsPage extends StatefulWidget {
  const LocationDetailsPage({
    required this.location,
    required this.locationRepository,
    super.key,
  });

  final LocationSummary location;
  final LocationRepository locationRepository;

  @override
  State<LocationDetailsPage> createState() => _LocationDetailsPageState();
}

class _LocationDetailsPageState extends State<LocationDetailsPage> {
  late Future<LocationDetails> _details;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _details = widget.locationRepository.getLocationDetails(widget.location.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.location.name.toUpperCase())),
      body: FutureBuilder<LocationDetails>(
        future: _details,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return EmptyErrorState(
              title: 'Localização indisponível',
              message: 'Não foi possível carregar os detalhes.',
              onRetry: () => setState(_load),
            );
          }

          final details = snapshot.data!;
          return CustomScrollView(
            key: const ValueKey('location-details-page'),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: _LocationHeader(details: details),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Text(
                    'Residentes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (details.residents.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('Esta localização não possui residentes.'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.builder(
                    itemCount: details.residents.length,
                    itemBuilder: (context, index) {
                      final resident = details.residents[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CharacterCard(
                          name: resident.name,
                          status: resident.status,
                          species: resident.species,
                          image: resident.image,
                          origin: resident.origin,
                        ),
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
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.details});

  final LocationDetails details;

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
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/branding/planet.svg',
              width: 54,
              height: 54,
              colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Information(label: 'Tipo:', value: details.type),
                  const SizedBox(height: 10),
                  _Information(label: 'Dimensão:', value: details.dimension),
                  const SizedBox(height: 10),
                  _Information(
                    label: 'Número de residentes:',
                    value: '${details.residentCount}',
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

class _Information extends StatelessWidget {
  const _Information({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value),
        ],
      ),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
