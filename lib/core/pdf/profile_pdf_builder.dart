import 'dart:io';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ProfilePdfBuilder {
  static Future<File> generateAndSave({
    required Profile profile,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _buildHeader(profile),
          pw.SizedBox(height: 12),

          _buildPersonalInfo(profile),
          pw.SizedBox(height: 16),

          _buildDocumentsTable(profile),
          pw.SizedBox(height: 16),

          _buildCoursesTable(profile),
          pw.SizedBox(height: 16),

          _buildSeaExperience(profile),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/seafarer_bio_data_${profile.personalDetails.firstname}.pdf');

    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);

    return file;
  }

  // ---------------- SECTIONS ----------------

  static pw.Widget _buildHeader(Profile profile) {
    return pw.Text(
      'Seafarer Profile',
      style: pw.TextStyle(
        fontSize: 22,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    );
  }

  static pw.Widget _buildPersonalInfo(Profile profile) {
    final p = profile.personalDetails;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _labelValue('Post Applied For', p.postAppliedFor),
              _labelValue('First Name', p.firstname),
              _labelValue('Last Name', p.lastname),
              _labelValue("Father's Name", p.fatherName),
              _labelValue('Date of Birth', p.dob),
              _labelValue('Nationality', p.nationality),
              _labelValue('Languages', p.languages.join(', ')),
            ],
          ),
        ),

        // Profile Image (Optional)
        pw.Container(
          width: 90,
          height: 110,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
          ),
          child: pw.Center(
            child: pw.Text('Photo'),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDocumentsTable(Profile profile) {
    return _buildTableSection(
      title: 'Documents',
      headers: ['Document', 'Number','Date of Issue' ,'Place of issue','Validity'],
      rows: profile.documents.map((e) => [
        e.name,
        e.number,
        e.issueDate,
        e.place,
        e.validity,
      ]).toList(),
    );
  }

  static pw.Widget _buildCoursesTable(Profile profile) {
    return _buildTableSection(
      title: 'Courses',
      headers: ['Course', 'Number','Date of Issue', 'Place of Issue','Validity'],
      rows: profile.courses.map((e) => [
        e.title,
        e.number,
        e.issueDate,
        e.place,
        e.validity,
      ]).toList(),
    );
  }

  // static pw.Widget _buildSeaExperience(Profile profile) {
  //   return pw.Column(
  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //     children: [
  //       _sectionTitle('Sea Experience'),
  //
  //       ...profile.seaExperiences.map(
  //             (e) => pw.Container(
  //           margin: const pw.EdgeInsets.symmetric(vertical: 6),
  //           padding: const pw.EdgeInsets.all(8),
  //           decoration: pw.BoxDecoration(
  //             color: PdfColors.blue50,
  //             borderRadius: pw.BorderRadius.circular(6),
  //           ),
  //           child: pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //             children: [
  //               pw.Text('Ship Name: ${e.vesselName}',
  //                   style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //               pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   pw.Text('Type: ${e.vesselType}'),
  //                   pw.Text('Rank: ${e.rank}'),
  //                 ],
  //               ),
  //               pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   pw.Text('From: ${e.from}'),
  //                   pw.Text('To: ${e.to}'),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  static pw.Widget _buildSeaExperience(Profile profile) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Sea Experience'),

        pw.Table.fromTextArray(
          headers: [
            'Name of vessel',
            'Company name',
            'Type of vessel',
            'G.R.T',
            'B.H.P',
            'Rank',
            'From',
            'To',
            'Period'
          ],
          data: profile.seaExperiences.map((e) => [
            e.vesselName,
            e.companyName,
            e.vesselType,
            e.grt,
            e.bhp,
            e.rank,
            e.from,
            e.to,
            e.period,
          ]).toList(),
          // Table Decoration & Styling
          border: pw.TableBorder.all(color: PdfColors.grey400),
          headerStyle: pw.TextStyle(
            fontSize: 8, // Smaller font to fit 9 columns
            fontWeight: pw.FontWeight.bold,
          ),
          cellStyle: const pw.TextStyle(
            fontSize: 8, // Smaller font to fit 9 columns
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.centerLeft,

          // Optional: Adjust specific column widths if needed
          columnWidths: {
            0: const pw.FlexColumnWidth(2), // Vessel Name usually longer
            1: const pw.FlexColumnWidth(2), // Company Name usually longer
            2: const pw.FlexColumnWidth(1.5), // Type
            3: const pw.FlexColumnWidth(1), // GRT
            4: const pw.FlexColumnWidth(1), // BHP
            5: const pw.FlexColumnWidth(1.2), // Rank
            6: const pw.FlexColumnWidth(1.2), // From
            7: const pw.FlexColumnWidth(1.2), // To
            8: const pw.FlexColumnWidth(1), // Period
          },
        ),
      ],
    );
  }
  // ---------------- HELPERS ----------------

  static pw.Widget _labelValue(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  static pw.Widget _buildTableSection({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),

        pw.Table.fromTextArray(
          headers: headers,
          data: rows,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration:
          const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.centerLeft,
          border: pw.TableBorder.all(color: PdfColors.grey400),
        ),
      ],
    );
  }
}
