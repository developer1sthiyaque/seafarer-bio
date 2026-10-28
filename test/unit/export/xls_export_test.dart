import 'package:flutter_test/flutter_test.dart';

/// Test plan §1.4 / §5 — XLS export is a planned feature. Nothing in `lib/`
/// implements it yet, so these are placeholders kept in the suite so the
/// requirement is not lost.
///
/// Expected interface, mirroring the existing exporters:
///
/// ```dart
///   class XlsExportService {
///     static Future<Uint8List> generateSeafarerXls(Profile profile);
///   }
/// ```
///
/// with the same coverage the other exporters have: full profile, empty
/// tables, no photo, long text, and a valid container header (`PK` — XLSX is an
/// OOXML ZIP, like DOCX).
void main() {
  group('§1.4 XLS generation', () {
    test(
      'xls export - not yet implemented',
      () {
        fail('XlsExportService does not exist yet');
      },
      skip: 'Planned feature, not yet implemented',
    );

    test(
      'xls export from an empty profile - not yet implemented',
      () {
        fail('XlsExportService does not exist yet');
      },
      skip: 'Planned feature, not yet implemented',
    );

    test(
      'xls export is subscriber gated - not yet implemented',
      () {
        fail('XlsExportService does not exist yet');
      },
      skip: 'Planned feature, not yet implemented',
    );
  });
}
