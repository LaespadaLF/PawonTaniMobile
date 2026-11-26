import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';

/// Layanan untuk mencetak dan menghasilkan dokumen PDF Bukti Hasil Panen PawonTani.
class PanenPdfService {
  PanenPdfService._();

  static String _formatCurrency(double amount) {
    final intVal = amount.toInt();
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  /// Membuat berkas PDF resmi bukti hasil panen.
  static Future<Uint8List> generatePanenPdf(
    HarvestItem item, {
    String? printedBy,
  }) async {
    final pdf = pw.Document(
      title: 'Bukti Panen - ${item.harvestCode}',
      author: 'PawonTani Mobile',
    );

    final primaryGreen = PdfColor.fromHex('2E7D32');
    final darkGreen = PdfColor.fromHex('1B5E20');
    final lightGreenBg = PdfColor.fromHex('E8F5E9');
    final grayBorder = PdfColor.fromHex('E0E0E0');
    final textDark = PdfColor.fromHex('212121');
    final textMuted = PdfColor.fromHex('616161');

    // Status styling
    PdfColor statusColor;
    PdfColor statusBg;
    String statusText;
    switch (item.status) {
      case HarvestStatus.disetujui:
        statusColor = PdfColor.fromHex('2E7D32');
        statusBg = PdfColor.fromHex('E8F5E9');
        statusText = 'DISETUJUI';
        break;
      case HarvestStatus.ditolak:
        statusColor = PdfColor.fromHex('C62828');
        statusBg = PdfColor.fromHex('FFEBEE');
        statusText = 'DITOLAK';
        break;
      case HarvestStatus.menunggu:
        statusColor = PdfColor.fromHex('E65100');
        statusBg = PdfColor.fromHex('FFF3E0');
        statusText = 'MENUNGGU VERIFIKASI';
        break;
    }

    final printDate = DateTime.now();
    final printDateStr =
        '${printDate.day.toString().padLeft(2, '0')}/${printDate.month.toString().padLeft(2, '0')}/${printDate.year} ${printDate.hour.toString().padLeft(2, '0')}:${printDate.minute.toString().padLeft(2, '0')} WIB';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header Surat / Bukti
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 12),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: primaryGreen, width: 2),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PAWON TANI',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Sistem Informasi & Manajemen Kelompok Tani',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: textMuted,
                          ),
                        ),
                        pw.Text(
                          'Kelompok Tani: ${item.poktan}',
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: statusBg,
                            borderRadius: pw.BorderRadius.circular(6),
                            border: pw.Border.all(color: statusColor, width: 0.8),
                          ),
                          child: pw.Text(
                            statusText,
                            style: pw.TextStyle(
                              fontSize: 9.5,
                              fontWeight: pw.FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Kode: ${item.harvestCode}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        pw.Text(
                          'Cetak: $printDateStr',
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // 2. Judul Dokumen
              pw.Center(
                child: pw.Text(
                  'BUKTI CATATAN HASIL PANEN RESMI',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              pw.SizedBox(height: 14),

              // 3. Highlight Kartu Tonase (Total Bobot)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: lightGreenBg,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: primaryGreen, width: 0.8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'KOMODITAS & VARIETAS',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          item.title.isNotEmpty ? item.title : item.cropType.displayName,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        pw.Text(
                          item.subtitle,
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'TOTAL HASIL TIMBANGAN',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '${item.weightKg.toStringAsFixed(0)} Kg',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        pw.Text(
                          '(${item.weightTon.toStringAsFixed(2)} Ton)',
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            fontWeight: pw.FontWeight.bold,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // 4. Informasi Lokasi & Pelaksanaan Panen
              _buildSectionHeader('I. INFORMASI LAHAN & PEMANENAN', primaryGreen),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: grayBorder, width: 0.5),
                children: [
                  _buildTableRow('Lokasi Lahan', item.location, 'Musim Tanam', item.season),
                  _buildTableRow('Blok & Luas Panen', item.blockArea.isNotEmpty ? item.blockArea : '-', 'Tanggal Panen', item.date),
                  _buildTableRow('Metode Panen', item.harvestMethod, 'Waktu Panen', item.harvestTime),
                ],
              ),

              pw.SizedBox(height: 12),

              // 5. Parameter Kualitas Hasil Panen
              _buildSectionHeader('II. PARAMETER & MUTU KUALITAS', primaryGreen),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: grayBorder, width: 0.5),
                children: [
                  _buildTableRow('Kualitas / Grade', item.qualityGrade, 'Kadar Air', '${item.moisturePercent.toStringAsFixed(1)} %'),
                  _buildTableRow('Persentase Butir Utuh', '${item.wholeGrainPercent.toStringAsFixed(1)} %', 'Hampa & Kotoran', '${item.wastePercent.toStringAsFixed(1)} %'),
                ],
              ),

              pw.SizedBox(height: 12),

              // 6. Estimasi Finansial & Biaya
              _buildSectionHeader('III. ESTIMASI NILAI & BIAYA PANEN', primaryGreen),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: grayBorder, width: 0.5),
                children: [
                  _buildTableRow(
                    'Estimasi Harga / Kg',
                    'Rp ${_formatCurrency(item.pricePerKg)}',
                    'Biaya Pemanenan',
                    'Rp ${_formatCurrency(item.harvestCost)}',
                  ),
                  _buildTableRow(
                    'Total Estimasi Nilai Panen',
                    'Rp ${_formatCurrency(item.estimatedValue)}',
                    'Keterangan Tenaga Kerja',
                    item.costWorkers.isNotEmpty ? item.costWorkers : '-',
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // 7. Catatan Lapangan & Riwayat Verifikasi
              _buildSectionHeader('IV. CATATAN & VERIFIKASI', primaryGreen),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: grayBorder, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(
                          width: 110,
                          child: pw.Text('Catatan Lapangan:', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            item.fieldNotes.isNotEmpty ? item.fieldNotes : '-',
                            style: pw.TextStyle(fontSize: 8.5, color: textDark),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 110,
                          child: pw.Text('Verifikator:', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            item.validatedBy.isNotEmpty ? item.validatedBy : 'Pengurus Kelompok Tani',
                            style: pw.TextStyle(fontSize: 8.5, color: textDark),
                          ),
                        ),
                        pw.SizedBox(
                          width: 90,
                          child: pw.Text('Tanggal Verifikasi:', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                        ),
                        pw.Text(
                          item.validatedAt.isNotEmpty ? item.validatedAt : (item.status == HarvestStatus.disetujui ? item.date : '-'),
                          style: pw.TextStyle(fontSize: 8.5, color: textDark),
                        ),
                      ],
                    ),
                    if (item.validatedNotes != null && item.validatedNotes!.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 110,
                            child: pw.Text('Catatan Verifikasi:', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              item.validatedNotes!,
                              style: pw.TextStyle(fontSize: 8.5, color: textDark),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              pw.Spacer(),

              // 8. Tanda Tangan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Petani Pelapor,', style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 38),
                      pw.Container(width: 120, height: 0.8, color: textDark),
                      pw.SizedBox(height: 2),
                      pw.Text('( Anggota Kelompok Tani )', style: pw.TextStyle(fontSize: 8, color: textMuted)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Mengetahui / Memverifikasi,', style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 38),
                      pw.Container(width: 140, height: 0.8, color: textDark),
                      pw.SizedBox(height: 2),
                      pw.Text('( Pengurus ${item.poktan} )', style: pw.TextStyle(fontSize: 8, color: textMuted)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 14),

              // 9. Footer
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 6),
                decoration: pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: grayBorder, width: 0.5)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Dokumen ini dicetak otomatis dari Aplikasi Mobile PawonTani.',
                      style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                    ),
                    pw.Text(
                      'Halaman 1 dari 1',
                      style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSectionHeader(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('F5F5F5'),
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  static pw.TableRow _buildTableRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            label1,
            style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('616161')),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            value1,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('212121')),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            label2,
            style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('616161')),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            value2,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('212121')),
          ),
        ),
      ],
    );
  }

  /// Membuka dialog pratinjau dan pencetakan PDF.
  static Future<void> printPanenPdf(HarvestItem item) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => generatePanenPdf(item),
      name: 'Bukti-Panen-${item.harvestCode}',
    );
  }

  /// Mengunduh atau membagikan berkas PDF bukti panen (kompatibel Web, Android, iOS).
  static Future<void> sharePanenPdf(HarvestItem item) async {
    final bytes = await generatePanenPdf(item);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Bukti-Panen-${item.harvestCode}.pdf',
    );
  }

  /// Unduh langsung berkas PDF bukti panen ke perangkat lokal.
  static Future<void> downloadPanenPdf(HarvestItem item) async {
    final bytes = await generatePanenPdf(item);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Bukti-Panen-${item.harvestCode}.pdf',
    );
  }
}
