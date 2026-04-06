import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/expense.dart';

class ExportService {
  Future<File> exportToCsv(List<Expense> expenses) async {
    final rows = <List<String>>[
      ['ID', 'Amount', 'Category', 'Description', 'Date', 'Payment Method', 'Recurring'],
      ...expenses.map((e) => [
            e.id,
            e.amount.toStringAsFixed(2),
            e.category.name,
            e.description,
            DateFormat('yyyy-MM-dd').format(e.date),
            e.paymentMethod.displayName,
            e.isRecurring ? 'Yes' : 'No',
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/expenses_$timestamp.csv');
    await file.writeAsString(csv);
    return file;
  }

  Future<File> exportToPdf(List<Expense> expenses) async {
    final pdf = pw.Document();
    final totalAmount = expenses.fold<double>(0, (s, e) => s + e.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Expense Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Paragraph(
            text: 'Generated on ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
          ),
          pw.Paragraph(
            text: 'Total: Rs. ${totalAmount.toStringAsFixed(2)} | ${expenses.length} transactions',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.center,
            },
            headers: ['Description', 'Amount', 'Category', 'Date', 'Payment'],
            data: expenses.map((e) => [
              e.description,
              'Rs. ${e.amount.toStringAsFixed(2)}',
              e.category.name,
              DateFormat('MMM d, yyyy').format(e.date),
              e.paymentMethod.displayName,
            ]).toList(),
          ),
          pw.SizedBox(height: 24),
          _buildCategorySummary(expenses),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/expenses_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildCategorySummary(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    for (final e in expenses) {
      categoryTotals[e.category.name] =
          (categoryTotals[e.category.name] ?? 0) + e.amount;
    }

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Category Summary',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          headers: ['Category', 'Total', 'Transactions'],
          data: sorted.map((entry) {
            final count = expenses.where((e) => e.category.name == entry.key).length;
            return [entry.key, 'Rs. ${entry.value.toStringAsFixed(2)}', '$count'];
          }).toList(),
        ),
      ],
    );
  }

  Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }
}
