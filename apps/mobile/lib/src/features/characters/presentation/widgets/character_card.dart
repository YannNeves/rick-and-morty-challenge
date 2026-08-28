import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    required this.name,
    required this.status,
    required this.species,
    required this.image,
    required this.origin,
    this.onTap,
    super.key,
  });

  final String name;
  final String status;
  final String species;
  final String image;
  final String origin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.darkGray;

    return Material(
      color: isDark ? AppColors.darkGray : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1.35,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, _, _) => ColoredBox(
                          color: isDark ? AppColors.black : AppColors.white,
                          child: const Center(
                            child: Icon(Icons.person_outline, size: 72),
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.favorite, color: AppColors.blue, size: 42),
                ],
              ),
              const SizedBox(height: 8),
              _CharacterAttribute(
                icon: Icons.monitor_heart_outlined,
                iconColor: const Color(0xFFA8D900),
                label: _statusLabel(status),
              ),
              const SizedBox(height: 6),
              _CharacterAttribute(
                asset: 'assets/branding/character.svg',
                iconColor: foreground,
                label: _speciesLabel(species),
              ),
              const SizedBox(height: 6),
              _CharacterAttribute(
                asset: 'assets/branding/planet.svg',
                iconColor: foreground,
                label: origin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusLabel(String status) => switch (status.toLowerCase()) {
    'alive' => 'Vivo',
    'dead' => 'Morto',
    _ => 'Desconhecido',
  };

  static String _speciesLabel(String species) => switch (species
      .toLowerCase()) {
    'human' => 'Humano',
    'alien' => 'Alienígena',
    _ => species,
  };
}

class _CharacterAttribute extends StatelessWidget {
  const _CharacterAttribute({
    required this.iconColor,
    required this.label,
    this.icon,
    this.asset,
  });

  final IconData? icon;
  final String? asset;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child:
              icon != null
                  ? Icon(icon, size: 20, color: iconColor)
                  : SvgPicture.asset(
                    asset!,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
