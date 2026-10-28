import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:seafarer_bio_data/core/services/docx_export_service.dart';

import '../../helpers/test_profiles.dart';

/// Test plan §1.4 — Export Service: DOCX generation (subscribers only).
void main() {
  /// A `.docx` is an OOXML package: a ZIP whose entries include
  /// `[Content_Types].xml` and `word/document.xml`. Entry names live
  /// uncompressed in the local file headers, so they can be found in the raw
  /// bytes without unzipping.
  bool looksLikeZip(Uint8List bytes) =>
      bytes.length > 4 &&
      bytes[0] == 0x50 && // P
      bytes[1] == 0x4B && // K
      bytes[2] == 0x03 &&
      bytes[3] == 0x04;

  bool containsEntry(Uint8List bytes, String entryName) =>
      _indexOfBytes(bytes, utf8.encode(entryName)) >= 0;

  group('§1.4 DOCX generation', () {
    test('builds a valid OOXML package from a full profile', () async {
      final bytes = await DocxExportService.generateSeafarerDocx(
        seaExperienceProfile(),
        isSubscribed: true,
      );

      expect(bytes, isNotEmpty);
      expect(looksLikeZip(bytes), isTrue, reason: 'not a ZIP container');
      expect(containsEntry(bytes, '[Content_Types].xml'), isTrue);
      expect(containsEntry(bytes, 'word/document.xml'), isTrue);
    });

    test('builds from a profile with no documents, courses or experience',
        () async {
      final bytes = await DocxExportService.generateSeafarerDocx(
        emptyProfile(),
        isSubscribed: true,
      );

      expect(looksLikeZip(bytes), isTrue);
      expect(containsEntry(bytes, 'word/document.xml'), isTrue);
    });

    test('builds from a profile with no photo', () async {
      final bytes = await DocxExportService.generateSeafarerDocx(
        noPhotoProfile(),
        isSubscribed: true,
      );

      expect(looksLikeZip(bytes), isTrue);
    });

    test('handles very long vessel and company names', () async {
      final bytes = await DocxExportService.generateSeafarerDocx(
        longTextProfile(),
        isSubscribed: true,
      );

      expect(looksLikeZip(bytes), isTrue);
      expect(bytes, isNotEmpty);
    });

    test('a populated profile produces a larger package than an empty one',
        () async {
      final full = await DocxExportService.generateSeafarerDocx(
        seaExperienceProfile(),
        isSubscribed: true,
      );
      final empty = await DocxExportService.generateSeafarerDocx(
        emptyProfile(),
        isSubscribed: true,
      );

      expect(full.length, greaterThan(empty.length));
    });

    test('is stable across repeated generation of the same profile', () async {
      final first = await DocxExportService.generateSeafarerDocx(
        fullProfile(),
        isSubscribed: true,
      );
      final second = await DocxExportService.generateSeafarerDocx(
        fullProfile(),
        isSubscribed: true,
      );

      expect(first.length, second.length);
    });
  });

  group('§1.4 DOCX subscription guard (defense in depth)', () {
    test('throws when invoked for a profile that has not paid', () async {
      expect(
        () => DocxExportService.generateSeafarerDocx(
          fullProfile(),
          isSubscribed: false,
        ),
        throwsA(isA<PremiumRequiredException>()),
      );
    });

    test('generates when the caller is subscribed', () async {
      final bytes = await DocxExportService.generateSeafarerDocx(
        fullProfile(),
        isSubscribed: true,
      );
      expect(bytes, isNotEmpty);
      expect(looksLikeZip(bytes), isTrue);
    });
  });
}

int _indexOfBytes(List<int> haystack, List<int> needle) {
  if (needle.isEmpty || needle.length > haystack.length) return -1;
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    var matched = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        matched = false;
        break;
      }
    }
    if (matched) return i;
  }
  return -1;
}
