import '../../characters/domain/character_models.dart';

class LocationListPage {
  const LocationListPage({
    required this.page,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.locations,
  });

  final int page;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final List<LocationSummary> locations;

  factory LocationListPage.fromJson(Map<String, dynamic> json) {
    final locationsJson = json['locations'] as List<dynamic>? ?? const [];

    return LocationListPage(
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
      totalItems: json['totalItems'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
      locations: locationsJson
          .map(
            (item) => LocationSummary.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}

class LocationSummary {
  const LocationSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.dimension,
    required this.residentCount,
  });

  final int id;
  final String name;
  final String type;
  final String dimension;
  final int residentCount;

  factory LocationSummary.fromJson(Map<String, dynamic> json) {
    return LocationSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      dimension: json['dimension'] as String,
      residentCount: json['residentCount'] as int,
    );
  }
}

class LocationDetails {
  const LocationDetails({
    required this.id,
    required this.name,
    required this.type,
    required this.dimension,
    required this.residentCount,
    required this.residents,
  });

  final int id;
  final String name;
  final String type;
  final String dimension;
  final int residentCount;
  final List<CharacterSummary> residents;

  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    final residentsJson = json['residents'] as List<dynamic>? ?? const [];
    return LocationDetails(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      dimension: json['dimension'] as String,
      residentCount: json['residentCount'] as int,
      residents: residentsJson
          .map(
            (item) => CharacterSummary.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}
