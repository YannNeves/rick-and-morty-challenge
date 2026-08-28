import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/ui/display_value.dart';
import '../../episodes/data/episode_repository.dart';
import '../../episodes/presentation/widgets/empty_error_state.dart';
import '../../locations/data/location_repository.dart';
import '../data/character_repository.dart';
import '../domain/character_models.dart';
import 'character_details_page.dart';
import 'characters_controller.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({
    required this.characterRepository,
    required this.episodeRepository,
    required this.locationRepository,
    required this.searchQuery,
    required this.filters,
    this.onGoHome,
    super.key,
  });

  final CharacterRepository characterRepository;
  final EpisodeRepository episodeRepository;
  final LocationRepository locationRepository;
  final String searchQuery;
  final Map<String, String> filters;
  final VoidCallback? onGoHome;

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  late final CharactersController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = CharactersController(
      characterRepository: widget.characterRepository,
    );
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) =>
          _controller.load(name: widget.searchQuery, filters: widget.filters),
    );
  }

  @override
  void didUpdateWidget(covariant CharactersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        !mapEquals(oldWidget.filters, widget.filters)) {
      _controller.load(name: widget.searchQuery, filters: widget.filters);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.status == CharactersLoadStatus.loading &&
            _controller.characters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.status == CharactersLoadStatus.failure) {
          return EmptyErrorState(
            title: 'Personagens indisponíveis',
            message: _controller.errorMessage ?? 'Tente novamente.',
            onRetry:
                () => _controller.load(
                  name: widget.searchQuery,
                  filters: widget.filters,
                ),
          );
        }

        if (_controller.status == CharactersLoadStatus.success &&
            _controller.characters.isEmpty) {
          return const _NoSearchResults();
        }

        if (MediaQuery.sizeOf(context).width >= 900) {
          final width = MediaQuery.sizeOf(context).width;
          final horizontalPadding = width > 1288 ? (width - 1240) / 2 : 24.0;
          return RefreshIndicator(
            onRefresh:
                () => _controller.load(
                  name: widget.searchQuery,
                  filters: widget.filters,
                ),
            child: CustomScrollView(
              key: const ValueKey('characters-page-grid'),
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: _CharactersHeader(),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverGrid.builder(
                    itemCount: _controller.characters.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.73,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemBuilder: (context, index) {
                      final character = _controller.characters[index];
                      return _CharacterCard(
                        character: character,
                        onTap: () => _openCharacter(character),
                      );
                    },
                  ),
                ),
                if (_controller.hasNextPage)
                  SliverToBoxAdapter(
                    child: _PaginationFooter(
                      isLoading: _controller.isLoadingMore,
                      errorMessage: _controller.loadMoreErrorMessage,
                      onRetry: _controller.retryLoadMore,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh:
              () => _controller.load(
                name: widget.searchQuery,
                filters: widget.filters,
              ),
          child: ListView.separated(
            key: const ValueKey('characters-page-list'),
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            itemCount:
                _controller.characters.length +
                1 +
                (_controller.hasNextPage ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _CharactersHeader();
              }
              if (index > _controller.characters.length) {
                return _PaginationFooter(
                  isLoading: _controller.isLoadingMore,
                  errorMessage: _controller.loadMoreErrorMessage,
                  onRetry: _controller.retryLoadMore,
                );
              }
              final character = _controller.characters[index - 1];
              return _CharacterCard(
                character: character,
                onTap: () => _openCharacter(character),
              );
            },
          ),
        );
      },
    );
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 500) {
      _controller.loadMore();
    }
  }

  void _openCharacter(CharacterSummary character) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => CharacterDetailsPage(
              character: character,
              characterRepository: widget.characterRepository,
              episodeRepository: widget.episodeRepository,
              locationRepository: widget.locationRepository,
              onGoHome: widget.onGoHome,
            ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : const SizedBox(height: 40),
      ),
    );
  }
}

class _CharactersHeader extends StatelessWidget {
  const _CharactersHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Personagens',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character, required this.onTap});

  final CharacterSummary character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.darkGray;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGray : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 1.6,
                  child: Image.network(
                    character.image,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, _, _) => ColoredBox(
                          color: isDark ? AppColors.black : AppColors.white,
                          child: const Center(
                            child: Icon(Icons.person_outline, size: 64),
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                character.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _Attribute(
                icon: Icons.monitor_heart_outlined,
                color: const Color(0xFFA8D900),
                text: _statusLabel(character.status),
              ),
              _Attribute(
                asset: 'assets/branding/character.svg',
                color: foreground,
                text: _speciesLabel(character.species),
              ),
              _Attribute(
                asset: 'assets/branding/planet.svg',
                color: foreground,
                text: displayValue(character.origin),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) => switch (status.toLowerCase()) {
    'alive' => 'Vivo',
    'dead' => 'Morto',
    _ => 'Desconhecido',
  };

  String _speciesLabel(String species) => switch (species.toLowerCase()) {
    'human' => 'Humano',
    'alien' => 'Alienígena',
    _ => displayValue(species),
  };
}

class _Attribute extends StatelessWidget {
  const _Attribute({
    required this.color,
    required this.text,
    this.icon,
    this.asset,
  });

  final IconData? icon;
  final String? asset;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child:
                icon != null
                    ? Icon(icon, size: 19, color: color)
                    : SvgPicture.asset(
                      asset!,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
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
          const Text(
            'Nenhum personagem corresponde à busca.',
            key: ValueKey('characters-no-search-results'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
