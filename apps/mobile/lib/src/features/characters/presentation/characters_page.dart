import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
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
    super.key,
  });

  final CharacterRepository characterRepository;
  final EpisodeRepository episodeRepository;
  final LocationRepository locationRepository;
  final String searchQuery;

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  late final CharactersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CharactersController(
      characterRepository: widget.characterRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.loadAll());
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
        if (_controller.status == CharactersLoadStatus.loading &&
            _controller.characters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.status == CharactersLoadStatus.failure) {
          return EmptyErrorState(
            title: 'Personagens indisponíveis',
            message: _controller.errorMessage ?? 'Tente novamente.',
            onRetry: _controller.loadAll,
          );
        }

        if (_controller.status == CharactersLoadStatus.success &&
            _controller.characters.isEmpty) {
          return EmptyErrorState(
            title: 'Nenhum personagem encontrado',
            message: 'A API não retornou personagens.',
            onRetry: _controller.loadAll,
          );
        }

        final query = widget.searchQuery.toLowerCase();
        final filteredCharacters =
            query.isEmpty
                ? _controller.characters
                : _controller.characters
                    .where((character) {
                      return [
                        character.name,
                        character.species,
                        character.status,
                        character.origin,
                        character.location,
                      ].any((value) => value.toLowerCase().contains(query));
                    })
                    .toList(growable: false);

        return RefreshIndicator(
          onRefresh: _controller.loadAll,
          child: ListView.separated(
            key: const ValueKey('characters-page-list'),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            itemCount:
                filteredCharacters.isEmpty ? 2 : filteredCharacters.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CharactersHeader(count: filteredCharacters.length);
              }
              if (filteredCharacters.isEmpty) return const _NoSearchResults();
              final character = filteredCharacters[index - 1];
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

  void _openCharacter(CharacterSummary character) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => CharacterDetailsPage(
              character: character,
              characterRepository: widget.characterRepository,
              episodeRepository: widget.episodeRepository,
              locationRepository: widget.locationRepository,
            ),
      ),
    );
  }
}

class _CharactersHeader extends StatelessWidget {
  const _CharactersHeader({required this.count});

  final int count;

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
          Text('$count encontrados'),
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
              Row(
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
                  const Icon(Icons.favorite, color: AppColors.blue, size: 36),
                ],
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
                text: character.origin,
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
    _ => species,
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
