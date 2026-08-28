enum CharacterSortBy {
  name('name'),
  status('status'),
  species('species');

  const CharacterSortBy(this.apiValue);

  final String apiValue;
}

enum CharacterSortOrder {
  ascending('asc'),
  descending('desc');

  const CharacterSortOrder(this.apiValue);
  final String apiValue;
}
