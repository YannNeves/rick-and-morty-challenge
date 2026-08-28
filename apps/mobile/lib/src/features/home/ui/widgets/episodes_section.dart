import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../episodes/domain/episode_models.dart';
import '../view_models/home_view_model.dart';

class EpisodesSection extends StatelessWidget {
  const EpisodesSection({
    required this.status,
    required this.episodes,
    required this.onRetry,
    required this.onShowAll,
    required this.onEpisodeSelected,
    this.errorMessage,
    super.key,
  });

  final HomeLoadStatus status;
  final List<EpisodeSummary> episodes;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onShowAll;
  final ValueChanged<EpisodeSummary> onEpisodeSelected;

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
            height: 116,
            child: Center(child: CircularProgressIndicator()),
          ),
          HomeLoadStatus.empty => const _SectionMessage(
            message: 'Nenhum episódio encontrado.',
          ),
          HomeLoadStatus.failure => _SectionMessage(
            message: errorMessage ?? 'Não foi possível carregar os episódios.',
            actionLabel: 'Tentar novamente',
            onAction: onRetry,
          ),
          HomeLoadStatus.success => SizedBox(
            height: 116,
            child: ListView.separated(
              key: const ValueKey('home-episodes-list'),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: episodes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final episode = episodes[index];
                return _EpisodeCard(
                  episode: episode,
                  onTap: () => onEpisodeSelected(episode),
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
        Text(
          'Episódios',
          key: const ValueKey('episodes-section-title'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
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

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({required this.episode, required this.onTap});

  final EpisodeSummary episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.darkGray;

    return Container(
      width: 260,
      padding: const EdgeInsets.fromLTRB(18, 15, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/branding/episode.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${episode.name} | ${episode.code}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.info_outline, size: 22),
                label: const Text('Saiba mais'),
              ),
              const Spacer(),
              const Icon(Icons.favorite, color: AppColors.blue, size: 30),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
