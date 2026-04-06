import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptScanResult {
  final double? amount;
  final String? merchant;
  final DateTime? date;
  final String rawText;

  ReceiptScanResult({
    this.amount,
    this.merchant,
    this.date,
    required this.rawText,
  });
}

class ReceiptScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<ReceiptScanResult> scanReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    final rawText = recognizedText.text;

    return ReceiptScanResult(
      amount: _extractAmount(rawText),
      merchant: _extractMerchant(recognizedText.blocks),
      date: _extractDate(rawText),
      rawText: rawText,
    );
  }

  double? _extractAmount(String text) {
    // Match common total patterns: Total, Grand Total, Amount, etc.
    final totalPatterns = [
      RegExp(r'(?:grand\s*)?total[\s:]*[\u20B9$]?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'(?:amount|amt)[\s:]*[\u20B9$]?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'[\u20B9$]\s*([\d,]+\.\d{2})'),
    ];

    for (final pattern in totalPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '');
        final amount = double.tryParse(amountStr ?? '');
        if (amount != null && amount > 0) return amount;
      }
    }

    // Fallback: find the largest currency amount
    final amounts = RegExp(r'([\d,]+\.\d{2})')
        .allMatches(text)
        .map((m) => double.tryParse(m.group(1)?.replaceAll(',', '') ?? '') ?? 0)
        .where((a) => a > 0)
        .toList();

    if (amounts.isNotEmpty) {
      amounts.sort();
      return amounts.last;
    }

    return null;
  }

  String? _extractMerchant(List<TextBlock> blocks) {
    // First non-empty text block is usually the merchant name
    for (final block in blocks) {
      final text = block.text.trim();
      if (text.isNotEmpty && text.length > 2 && !RegExp(r'^\d').hasMatch(text)) {
        return text;
      }
    }
    return null;
  }

  DateTime? _extractDate(String text) {
    final datePatterns = [
      // dd/MM/yyyy or dd-MM-yyyy
      RegExp(r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})'),
      // yyyy/MM/dd or yyyy-MM-dd
      RegExp(r'(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})'),
      // dd Mon yyyy
      RegExp(r'(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*\s+(\d{4})', caseSensitive: false),
    ];

    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          if (match.groupCount == 3) {
            final g1 = match.group(1)!;
            final g2 = match.group(2)!;
            final g3 = match.group(3)!;

            // yyyy-MM-dd format
            if (g1.length == 4) {
              return DateTime.tryParse('$g1-${g2.padLeft(2, '0')}-${g3.padLeft(2, '0')}');
            }

            // dd Mon yyyy format
            if (RegExp(r'[a-zA-Z]').hasMatch(g2)) {
              const months = {
                'jan': '01', 'feb': '02', 'mar': '03', 'apr': '04',
                'may': '05', 'jun': '06', 'jul': '07', 'aug': '08',
                'sep': '09', 'oct': '10', 'nov': '11', 'dec': '12',
              };
              final month = months[g2.toLowerCase().substring(0, 3)];
              if (month != null) {
                return DateTime.tryParse('$g3-$month-${g1.padLeft(2, '0')}');
              }
            }

            // dd/MM/yyyy format
            return DateTime.tryParse('$g3-${g2.padLeft(2, '0')}-${g1.padLeft(2, '0')}');
          }
        } catch (_) {
          continue;
        }
      }
    }
    return null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
