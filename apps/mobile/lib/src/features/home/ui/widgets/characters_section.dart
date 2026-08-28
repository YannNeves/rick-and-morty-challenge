import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../characters/domain/character_models.dart';
import '../../../characters/presentation/widgets/character_card.dart';
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
              final character = characters[index];
              return CharacterCard(
                name: character.name,
                status: character.status,
                species: character.species,
                image: character.image,
                origin: character.origin,
              );
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
