import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../characters/domain/character_models.dart';
import '../view_models/home_view_model.dart';

class CharactersSection extends StatelessWidget {
  const CharactersSection({
    required this.status,
    required this.characters,
    required this.onRetry,
    required this.onShowAll,
    this.errorMessage,
    super.key,
  });

  final HomeLoadStatus status;
  final List<CharacterSummary> characters;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SectionHeader(onShowAll: onShowAll),
        ),
        const SizedBox(height: 20),
        switch (status) {
          HomeLoadStatus.initial || HomeLoadStatus.loading => const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          ),
          HomeLoadStatus.empty => const _SectionMessage(
            message: 'Nenhum personagem encontrado.',
          ),
          HomeLoadStatus.failure => _SectionMessage(
            message:
                errorMessage ?? 'Não foi possível carregar os personagens.',
            onRetry: onRetry,
          ),
          HomeLoadStatus.success => ListView.separated(
            key: const ValueKey('home-characters-list'),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: characters.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _CharacterCard(character: characters[index]);
            },
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
            'Personagens',
            key: const ValueKey('characters-section-title'),
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

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character});

  final CharacterSummary character;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.darkGray;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
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
                  character.image,
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
                    character.name,
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
              label: _statusLabel(character.status),
            ),
            const SizedBox(height: 6),
            _CharacterAttribute(
              asset: 'assets/branding/character.svg',
              iconColor: foreground,
              label: _speciesLabel(character.species),
            ),
            const SizedBox(height: 6),
            _CharacterAttribute(
              asset: 'assets/branding/planet.svg',
              iconColor: foreground,
              label: character.origin,
            ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    return switch (status.toLowerCase()) {
      'alive' => 'Vivo',
      'dead' => 'Morto',
      _ => 'Desconhecido',
    };
  }

  static String _speciesLabel(String species) {
    return switch (species.toLowerCase()) {
      'human' => 'Humano',
      'alien' => 'Alienígena',
      _ => species,
    };
  }
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

class _SectionMessage extends StatelessWidget {
  const _SectionMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
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
