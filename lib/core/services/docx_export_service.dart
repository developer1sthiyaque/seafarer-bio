import 'dart:typed_data';
import 'package:docs_gee/docs_gee.dart' as docx;
import '../../features/personal_details/domain/entities/profile_entity.dart';

class DocxExportService {
  static Future<Uint8List> generateSeafarerDocx(Profile profile) async {
    final doc = docx.DocxDocument();

    // Title Section
    doc.addParagraph(
      docx.DocxParagraph.text(
        'SEAFARER BIO DATA',
        style: docx.DocxParagraphStyle.heading1,
        alignment: docx.DocxAlignment.center,
      ),
    );

    doc.addSpacer();

    // Personal Details Section
    doc.addSectionTitle('PERSONAL DETAILS');

    final details = profile.personalDetails;
    doc.addTextLine('Full Name: ${details.firstname} ${details.lastname}');
    doc.addTextLine('Post Applied For: ${details.postAppliedFor}');
    doc.addTextLine('Father\'s Name: ${details.fatherName}');
    doc.addTextLine('Date of Birth: ${details.dob}');
    doc.addTextLine('Nationality: ${details.nationality}');

    doc.addSpacer();

    // Documents Section
    if (profile.documents.isNotEmpty) {
      doc.addSectionTitle('TRAVEL DOCUMENTS');

      final docTable = docx.DocxTable(
        rows: [
          docx.DocxTableRow(
            cells: [
              docx.DocxTableCell.text('Document Name',
                  alignment: docx.DocxAlignment.center),
              docx.DocxTableCell.text('Number',
                  alignment: docx.DocxAlignment.center),
              docx.DocxTableCell.text('Issue Date',
                  alignment: docx.DocxAlignment.center),
              docx.DocxTableCell.text('Place',
                  alignment: docx.DocxAlignment.center),
              docx.DocxTableCell.text('Validity',
                  alignment: docx.DocxAlignment.center),
            ],
          ),
          ...profile.documents.map((d) => docx.DocxTableRow(
                cells: [
                  docx.DocxTableCell.text(d.name),
                  docx.DocxTableCell.text(d.number),
                  docx.DocxTableCell.text(d.issueDate),
                  docx.DocxTableCell.text(d.place),
                  docx.DocxTableCell.text(d.validity),
                ],
              )),
        ],
      );
      doc.addTable(docTable);
    }

    doc.addSpacer();

    // Sea Experience Section
    if (profile.seaExperiences.isNotEmpty) {
      doc.addSectionTitle('SEA EXPERIENCE');

      final expTable = docx.DocxTable(
        rows: [
          docx.DocxTableRow(
            cells: [
              docx.DocxTableCell.text('Vessel Name',
                  alignment: docx.DocxAlignment.center),
              docx.DocxTableCell.text('Type',
                  alignment: docx.DocxAlignment.center),
              docx.DocxTableCell.text('Rank',
                  alignment: docx.DocxAlignment.center),
              docx.DocxTableCell.text('From',
                  alignment: docx.DocxAlignment.center),
              docx.DocxTableCell.text('To',
                  alignment: docx.DocxAlignment.center),
            ],
          ),
          ...profile.seaExperiences.map((e) => docx.DocxTableRow(
                cells: [
                  docx.DocxTableCell.text(e.vesselName),
                  docx.DocxTableCell.text(e.vesselType),
                  docx.DocxTableCell.text(e.rank),
                  docx.DocxTableCell.text(e.from),
                  docx.DocxTableCell.text(e.to),
                ],
              )),
        ],
      );
      doc.addTable(expTable);
    }

    final generator = docx.DocxGenerator();
    return generator.generate(doc);
  }
}

extension DocxExtensions on docx.DocxDocument {
  void addSectionTitle(String title) {
    addParagraph(
      docx.DocxParagraph.heading(title, level: 2),
    );
  }

  void addTextLine(String text) {
    addParagraph(
      docx.DocxParagraph.text(text),
    );
  }

  void addSpacer() {
    addParagraph(
      docx.DocxParagraph.text(' '),
    );
  }
}
