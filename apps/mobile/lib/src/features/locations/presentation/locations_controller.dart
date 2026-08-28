import 'package:flutter/foundation.dart';

import '../data/location_repository.dart';
import '../domain/location_models.dart';

enum LocationsLoadStatus { idle, loading, success, failure }

class LocationsController extends ChangeNotifier {
  LocationsController({required LocationRepository locationRepository})
    : _locationRepository = locationRepository;

  final LocationRepository _locationRepository;

  LocationsLoadStatus status = LocationsLoadStatus.idle;
  List<LocationSummary> locations = const [];
  String? errorMessage;

  Future<void> load() async {
    status = LocationsLoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final firstPage = await _locationRepository.getLocations();
      final allLocations = <LocationSummary>[...firstPage.locations];

      for (var page = 2; page <= firstPage.totalPages; page++) {
        final nextPage = await _locationRepository.getLocations(page: page);
        allLocations.addAll(nextPage.locations);
      }

      allLocations.sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(second.name.toLowerCase()),
      );
      locations = List.unmodifiable(allLocations);
      status = LocationsLoadStatus.success;
      notifyListeners();
    } catch (_) {
      status = LocationsLoadStatus.failure;
      errorMessage = 'Não foi possível carregar as localizações.';
      notifyListeners();
    }
  }
}
