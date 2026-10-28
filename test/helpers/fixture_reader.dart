import 'dart:convert';
import 'dart:io';

/// Reads a raw fixture file from `test/fixtures/`.
///
/// Only usable from `flutter test` (host VM), where the current working
/// directory is the package root. Integration tests run on a device and must
/// use the pure-Dart builders in `test_profiles.dart` instead.
String fixtureString(String fileName) =>
    File('test/fixtures/$fileName').readAsStringSync();

/// Reads a fixture file and decodes it as a JSON object.
Map<String, dynamic> fixtureMap(String fileName) =>
    jsonDecode(fixtureString(fileName)) as Map<String, dynamic>;