import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:seafarer_bio_data/core/pdf/profile_pdf_builder.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';

import '../../helpers/test_profiles.dart';

/// Test plan §1.4 — Export Service: PDF generation (free for every user).
///
/// Exercises `ProfilePdfBuilder.buildPdfBytes`, which builds the document
/// without touching the file system or handing the result to the OS viewer.
void main() {
  bool looksLikePdf(Uint8List bytes) =>
      bytes.length > 4 &&
      String.fromCharCodes(bytes.sublist(0, 4)) == '%PDF';

  bool hasEofMarker(Uint8List bytes) {
    final tail = String.fromCharCodes(
      bytes.sublist(bytes.length - 32 < 0 ? 0 : bytes.length - 32),
    );
    return tail.contains('%%EOF');
  }

  group('§1.4 PDF generation', () {
    test('builds from a fully populated profile', () async {
      final bytes = await ProfilePdfBuilder.buildPdfBytes(
        profile: seaExperienceProfile(),
      );

      expect(bytes, isNotEmpty);
      expect(looksLikePdf(bytes), isTrue, reason: 'missing %PDF magic header');
      expect(hasEofMarker(bytes), isTrue, reason: 'missing %%EOF trailer');
    });

    test('builds from a profile with empty Documents, Courses and Sea Experience',
        () async {
      final bytes =
          await ProfilePdfBuilder.buildPdfBytes(profile: emptyProfile());

      expect(looksLikePdf(bytes), isTrue);
      expect(bytes, isNotEmpty);
    });

    test('renders the photo placeholder when no photo is set', () async {
      final profile = noPhotoProfile();
      expect(profile.personalDetails.profilePic, isEmpty);

      final bytes = await ProfilePdfBuilder.buildPdfBytes(profile: profile);

      expect(looksLikePdf(bytes), isTrue);
    });

    test('embeds the photo when one is set', () async {
      final withPhoto =
          await ProfilePdfBuilder.buildPdfBytes(profile: fullProfile());
      final withoutPhoto =
          await ProfilePdfBuilder.buildPdfBytes(profile: noPhotoProfile());

      expect(looksLikePdf(withPhoto), isTrue);
      // The embedded image object makes the document measurably different.
      expect(withPhoto.length, isNot(equals(withoutPhoto.length)));
    });

    test('handles very long vessel and company names without throwing',
        () async {
      final bytes =
          await ProfilePdfBuilder.buildPdfBytes(profile: longTextProfile());

      expect(looksLikePdf(bytes), isTrue);
      expect(bytes, isNotEmpty);
    });

    test('handles a profile whose every text field is empty', () async {
      const blank = Profile(
        userId: 'blank',
        personalDetails: PersonalDetails(
          postAppliedFor: '',
          firstname: '',
          lastname: '',
          fatherName: '',
          dob: '',
          nationality: '',
          profilePic: '',
        ),
      );

      final bytes = await ProfilePdfBuilder.buildPdfBytes(profile: blank);

      expect(looksLikePdf(bytes), isTrue);
    });

    test('fits a long career on one page (27 sea experience rows)', () async {
      // 27 rows is the most the current layout can take — see the next test.
      final bytes = await ProfilePdfBuilder.buildPdfBytes(
        profile: fullProfile().copyWith(seaExperiences: _experienceRows(27)),
      );

      expect(looksLikePdf(bytes), isTrue);
    });

    test('handles many sea experience rows spilling onto further pages',
        () async {
      // A seafarer with 20+ years of 6-9 month contracts easily has more than
      // 28 rows. `_buildSeaExperience` wraps the table in a `pw.Column`, which
      // `MultiPage` cannot split across pages, so once the table no longer fits
      // the remaining space the whole export fails with TooManyPagesException
      // instead of continuing onto page 2. Observed threshold: 28 rows.
      //
      // Fix: return the section's children as a list / use
      // `pw.TableHelper.fromTextArray` directly at the top level of the
      // MultiPage build so the table itself becomes splittable.
      final many = List.generate(
        40,
        (i) => SeaExperience(
          vesselName: 'MV Vessel $i',
          companyName: 'Company $i Shipping Ltd',
          vesselType: 'Bulk Carrier',
          grt: '${10000 + i}',
          bhp: '${5000 + i}',
          rank: 'Third Engineer',
          from: '1.1.2020',
          to: '1.6.2020',
          period: '5',
        ),
      );

      final bytes = await ProfilePdfBuilder.buildPdfBytes(
        profile: fullProfile().copyWith(seaExperiences: many),
      );

      expect(looksLikePdf(bytes), isTrue);
      expect(bytes.length, greaterThan(2000));
    });

    test('produces deterministic-length output for the same profile', () async {
      final first =
          await ProfilePdfBuilder.buildPdfBytes(profile: fullProfile());
      final second =
          await ProfilePdfBuilder.buildPdfBytes(profile: fullProfile());

      expect(first.length, second.length);
    });

    test('a corrupt base64 photo surfaces as an error rather than a bad file',
        () async {
      // Documents current behaviour: the builder trusts `profilePic` to be
      // valid base64 (it is produced by the app's own image picker).
      final profile = fullProfile().copyWith(
        personalDetails: const PersonalDetails(
          postAppliedFor: 'Fourth Engineer',
          firstname: 'Isthiyaque',
          lastname: 'Kambathagothi',
          fatherName: 'Abdul Rauf Kambathagothi',
          dob: '17/7/1987',
          nationality: 'Indian',
          profilePic: 'not-valid-base64!!',
        ),
      );

      expect(
        () => ProfilePdfBuilder.buildPdfBytes(profile: profile),
        throwsA(isA<FormatException>()),
      );
    });

    test('the test photo fixture is decodable base64', () {
      expect(() => base64Decode(kTestPhotoBase64), returnsNormally);
      expect(base64Decode(kTestPhotoBase64), isNotEmpty);
    });
  });
}

List<SeaExperience> _experienceRows(int count) => List.generate(
      count,
      (i) => SeaExperience(
        vesselName: 'MV Vessel $i',
        companyName: 'Company $i Shipping Ltd',
        vesselType: 'Bulk Carrier',
        grt: '${10000 + i}',
        bhp: '${5000 + i}',
        rank: 'Third Engineer',
        from: '1.1.2020',
        to: '1.6.2020',
        period: '5',
      ),
    );
