import 'dart:io';

void main(List<String> arguments) {
  final coveragePath = arguments.isEmpty ? 'coverage/lcov.info' : arguments[0];
  final minimum = arguments.length < 2 ? 65.0 : double.parse(arguments[1]);
  final file = File(coveragePath);

  if (!file.existsSync()) {
    stderr.writeln('Coverage file not found: $coveragePath');
    exitCode = 1;
    return;
  }

  var foundLines = 0;
  var hitLines = 0;

  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('LF:')) {
      foundLines += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hitLines += int.parse(line.substring(3));
    }
  }

  final percentage = foundLines == 0 ? 0 : hitLines * 100 / foundLines;
  stdout.writeln(
    'Flutter coverage: ${percentage.toStringAsFixed(2)}% '
    '($hitLines/$foundLines lines; minimum ${minimum.toStringAsFixed(0)}%)',
  );

  if (percentage < minimum) exitCode = 1;
}
