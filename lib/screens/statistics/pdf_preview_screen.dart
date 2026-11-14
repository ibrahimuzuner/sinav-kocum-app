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

  Future<void> _shareOrDownload(BuildContext context) async {
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📥 PDF indirme / paylaşma menüsü açıldı!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İşlem hatası: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _printOrSave(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: fileName,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yazdırma hatası: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

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
            icon: const Icon(Icons.print_rounded),
            tooltip: 'Yazdır / PDF Olarak Kaydet',
            onPressed: () => _printOrSave(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Paylaş / İndir',
            onPressed: () => _shareOrDownload(context),
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
        onError: (context, error) {
          debugPrint('PdfPreview raster hatası (Emülatör/Cihaz sürücüsü): $error');
          return _buildFallbackView(context, isDark);
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _printOrSave(context),
                  icon: const Icon(Icons.print_rounded, size: 20, color: Color(0xFF4F46E5)),
                  label: const Text('Yazdır / Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareOrDownload(context),
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text('PDF İndir / Aç', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackView(BuildContext context, bool isDark) {
    final sizeKb = (pdfBytes.lengthInBytes / 1024).toStringAsFixed(1);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFF4F46E5),
                  size: 56,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '📄 PDF Analiz Raporun Hazır!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Boyut: $sizeKb KB • A4 Renkli Karne',
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Raporun başarıyla üretildi. Emülatör veya cihazın dahili görselleştiricisi yerine aşağıdaki butonlarla raporu hemen cihazında açabilir, yazdırabilir veya WhatsApp ile paylaşabilirsin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _shareOrDownload(context),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('PDF Dosyasını İndir / Cihazda Aç', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _printOrSave(context),
                  icon: const Icon(Icons.print_rounded, color: Color(0xFF4F46E5)),
                  label: const Text('Yazdır veya PDF Olarak Kaydet', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _shareOrDownload(context),
                  icon: const Icon(Icons.share_rounded, color: Color(0xFF10B981)),
                  label: const Text('WhatsApp / Mail ile Paylaş', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
