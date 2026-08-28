enum AppDestination {
  home(
    label: 'Home',
    iconAsset: 'assets/branding/home.png',
    isRasterIcon: true,
  ),
  episodes(label: 'Episódios', iconAsset: 'assets/branding/episode.svg'),
  locations(label: 'Localização', iconAsset: 'assets/branding/planet.svg'),
  characters(label: 'Personagens', iconAsset: 'assets/branding/character.svg');

  const AppDestination({
    required this.label,
    required this.iconAsset,
    this.isRasterIcon = false,
  });

  final String label;
  final String iconAsset;
  final bool isRasterIcon;

  String get searchHint => switch (this) {
    AppDestination.home => '',
    AppDestination.locations => 'Busque por localização',
    AppDestination.episodes => 'Busque por episódio',
    AppDestination.characters => 'Busque por personagem',
  };
}
