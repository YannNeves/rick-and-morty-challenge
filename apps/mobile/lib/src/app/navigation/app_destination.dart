enum AppDestination {
  home(
    label: 'Home',
    routeLabel: 'Rota Home',
    iconAsset: 'assets/branding/home.png',
    isRasterIcon: true,
  ),
  planets(
    label: 'Planetas',
    routeLabel: 'Rota Planetas',
    iconAsset: 'assets/branding/planet.svg',
  ),
  episodes(
    label: 'Episódios',
    routeLabel: 'Rota Episódios',
    iconAsset: 'assets/branding/episode.svg',
  ),
  characters(
    label: 'Personagens',
    routeLabel: 'Rota Personagens',
    iconAsset: 'assets/branding/character.svg',
  );

  const AppDestination({
    required this.label,
    required this.routeLabel,
    required this.iconAsset,
    this.isRasterIcon = false,
  });

  final String label;
  final String routeLabel;
  final String iconAsset;
  final bool isRasterIcon;

  String get searchHint => switch (this) {
    AppDestination.home => '',
    AppDestination.planets => 'Busque por planeta',
    AppDestination.episodes => 'Busque por episódio',
    AppDestination.characters => 'Busque por personagem',
  };
}
