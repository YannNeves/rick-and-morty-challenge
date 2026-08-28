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
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onRetryLoadMore,
    this.loadMoreError,
    this.errorMessage,
    super.key,
  });

  final HomeLoadStatus status;
  final List<EpisodeSummary> episodes;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onShowAll;
  final ValueChanged<EpisodeSummary> onEpisodeSelected;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final VoidCallback onRetryLoadMore;
  final String? loadMoreError;

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
          HomeLoadStatus.success => NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 320) onLoadMore();
              return false;
            },
            child: SizedBox(
              height: 116,
              child: ListView.separated(
                key: const ValueKey('home-episodes-list'),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: episodes.length + (hasMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  if (index == episodes.length) {
                    return _HorizontalLoadMore(
                      isLoading: isLoadingMore,
                      errorMessage: loadMoreError,
                      onRetry: onRetryLoadMore,
                    );
                  }
                  final episode = episodes[index];
                  return _EpisodeCard(
                    episode: episode,
                    onTap: () => onEpisodeSelected(episode),
                  );
                },
              ),
            ),
          ),
        },
      ],
    );
  }
}

class _HorizontalLoadMore extends StatelessWidget {
  const _HorizontalLoadMore({
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 180,
    child: Center(
      child:
          errorMessage != null
              ? TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              )
              : isLoading
              ? const CircularProgressIndicator()
              : const SizedBox.shrink(),
    ),
  );
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
          FilledButton.icon(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.info_outline, size: 22),
            label: const Text('Saiba mais'),
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
