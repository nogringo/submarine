import 'dart:io';

import 'package:submarine_cli/src/version.dart';
import 'package:test/test.dart';

void main() {
  test('packageVersion follows pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version: (\S+)$',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);

    expect(packageVersion, version);
  });
}
