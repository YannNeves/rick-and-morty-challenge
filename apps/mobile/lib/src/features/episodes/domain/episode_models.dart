class EpisodeListPage {
  const EpisodeListPage({
    required this.page,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.episodes,
  });

  final int page;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final List<EpisodeSummary> episodes;

  factory EpisodeListPage.fromJson(Map<String, dynamic> json) {
    final episodesJson = json['episodes'] as List<dynamic>? ?? const [];

    return EpisodeListPage(
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
      totalItems: json['totalItems'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
      episodes: episodesJson
          .map(
            (item) =>
                EpisodeSummary.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false),
    );
  }
}

class EpisodeSummary {
  const EpisodeSummary({
    required this.id,
    required this.name,
    required this.airDate,
    required this.code,
    required this.characterCount,
  });

  final int id;
  final String name;
  final String airDate;
  final String code;
  final int characterCount;

  factory EpisodeSummary.fromJson(Map<String, dynamic> json) {
    return EpisodeSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      airDate: json['airDate'] as String,
      code: json['code'] as String,
      characterCount: json['characterCount'] as int,
    );
  }
}

class EpisodeDetails {
  const EpisodeDetails({
    required this.id,
    required this.name,
    required this.airDate,
    required this.code,
    required this.characterCount,
    required this.characters,
  });

  final int id;
  final String name;
  final String airDate;
  final String code;
  final int characterCount;
  final List<CharacterSummary> characters;

  factory EpisodeDetails.fromJson(Map<String, dynamic> json) {
    final charactersJson = json['characters'] as List<dynamic>? ?? const [];

    return EpisodeDetails(
      id: json['id'] as int,
      name: json['name'] as String,
      airDate: json['airDate'] as String,
      code: json['code'] as String,
      characterCount: json['characterCount'] as int,
      characters: charactersJson
          .map(
            (item) => CharacterSummary.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}

class CharacterSummary {
  const CharacterSummary({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.origin,
    required this.location,
    required this.episodeCount,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final String origin;
  final String location;
  final int episodeCount;

  factory CharacterSummary.fromJson(Map<String, dynamic> json) {
    return CharacterSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      type: json['type'] as String,
      gender: json['gender'] as String,
      image: json['image'] as String,
      origin: json['origin'] as String,
      location: json['location'] as String,
      episodeCount: json['episodeCount'] as int,
    );
  }
}
