import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/core/ui/pluralization.dart';

void main() {
  test('uses singular and plural episode labels', () {
    expect(episodeParticipationText(1), 'Participou de 1 episódio');
    expect(episodeParticipationText(2), 'Participou de 2 episódios');
  });
}
