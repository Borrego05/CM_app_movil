import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerScreen extends StatelessWidget {
  final File pdfFile;
  final String titulo;

  const PdfViewerScreen({
    super.key,
    required this.pdfFile,
    required this.titulo,
  });

  Future<void> _compartir() async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      subject: titulo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: const Color(0xFFF8DD2F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir',
            onPressed: _compartir,
          ),
        ],
      ),
      body: PDFView(
        filePath: pdfFile.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
