enum CharacterSortBy {
  name('name'),
  status('status'),
  species('species'),
  id('id');

  const CharacterSortBy(this.apiValue);

  final String apiValue;
}
