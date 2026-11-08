import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// PDF Analiz Raporu Önizleme ve İndirme Sayfası
/// Hem Web hem Mobil platformlarda PDF'in ekranda anında görüntülenmesini,
/// yakınlaştırılmasını, yazdırılmasını ve indirilmesini sağlar.
class PdfPreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const PdfPreviewScreen({
    super.key,
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📄 Analiz Raporu Önizleme',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'PDF İndir',
            onPressed: () async {
              await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF indirme başlatıldı 📥'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        pdfFileName: fileName,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 700,
        loadingWidget: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF4F46E5)),
              SizedBox(height: 12),
              Text('Rapor yükleniyor...', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
