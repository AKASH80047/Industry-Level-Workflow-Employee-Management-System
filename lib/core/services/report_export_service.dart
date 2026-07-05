import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ReportExportService {
  /// Generates a CSV formatted string from tabular data maps
  static String generateCSV({
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) {
    final buffer = StringBuffer();
    
    // Write headers
    buffer.writeln(headers.map((h) => '"$h"').join(','));

    // Write row entries
    for (final row in rows) {
      buffer.writeln(row.map((item) {
        final clean = item.toString().replaceAll('"', '""');
        return '"$clean"';
      }).join(','));
    }

    return buffer.toString();
  }

  /// Generates a PDF document for print-ready attendance reports
  static Future<File> generatePDF({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    'Generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const pw.TextStyle(color: PdfColors.grey),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Render Table
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: rows,
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo600),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(6),
            ),
          ];
        },
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
