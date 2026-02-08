import 'dart:io';

import 'package:seafarer_bio_data/core/pdf/profile_pdf_builder.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';


class PdfPreviewPage extends StatelessWidget {
  final Profile profile;

  const PdfPreviewPage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await ProfilePdfBuilder.generateAndSave(profile: profile);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF downloaded successfully')),
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) async {
          final File pdfFile = await ProfilePdfBuilder.generateAndSave(profile: profile);
          final Uint8List bytes = await pdfFile.readAsBytes();
          return bytes;
        },
        canChangePageFormat: false,
        canChangeOrientation: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}

