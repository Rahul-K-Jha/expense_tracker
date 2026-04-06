import '../../domain/entities/category.dart';
import '../../domain/entities/payment_method.dart';
import 'auto_categorizer.dart';

class ParsedVoiceExpense {
  final double? amount;
  final String? description;
  final Category? category;
  final PaymentMethod? paymentMethod;

  ParsedVoiceExpense({
    this.amount,
    this.description,
    this.category,
    this.paymentMethod,
  });
}

class VoiceExpenseParser {
  /// Parse a spoken expense like "50 rupees for lunch at cafe by UPI"
  static ParsedVoiceExpense parse(String text) {
    final lower = text.toLowerCase().trim();

    return ParsedVoiceExpense(
      amount: _extractAmount(lower),
      description: _extractDescription(lower),
      category: _extractCategory(lower),
      paymentMethod: _extractPaymentMethod(lower),
    );
  }

  static double? _extractAmount(String text) {
    // Match patterns: "50 rupees", "Rs 200", "500", "1.5k", "2000 rs"
    final patterns = [
      RegExp(r'(\d+(?:\.\d+)?)\s*(?:k)\b'),
      RegExp(r'(?:rs\.?|rupees?|\u20B9)\s*(\d+(?:\.\d+)?)'),
      RegExp(r'(\d+(?:\.\d+)?)\s*(?:rs\.?|rupees?)'),
      RegExp(r'(?:^|\s)(\d+(?:\.\d+)?)(?:\s|$)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        var amount = double.tryParse(match.group(1) ?? '');
        if (amount != null) {
          // Handle "k" suffix (e.g., "1.5k" = 1500)
          if (text.contains(RegExp(r'\d+(?:\.\d+)?\s*k\b'))) {
            amount *= 1000;
          }
          return amount;
        }
      }
    }
    return null;
  }

  static String? _extractDescription(String text) {
    // Remove amount and payment method parts, keep the descriptive part
    var desc = text;

    // Remove amount patterns
    desc = desc.replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*(?:k|rs\.?|rupees?)\b'), '');
    desc = desc.replaceAll(RegExp(r'(?:rs\.?|rupees?|\u20B9)\s*(\d+(?:\.\d+)?)'), '');

    // Remove payment method keywords
    desc = desc.replaceAll(RegExp(r'\b(?:by|via|using|with)\s+(?:upi|card|cash|bank\s*transfer)\b'), '');

    // Remove filler words
    desc = desc.replaceAll(RegExp(r'\b(?:spent|paid|for|on|at)\b'), ' ');

    // Clean up
    desc = desc.replaceAll(RegExp(r'\s+'), ' ').trim();

    return desc.isEmpty ? null : desc;
  }

  static Category? _extractCategory(String text) {
    return AutoCategorizer.suggestCategory(text);
  }

  static PaymentMethod? _extractPaymentMethod(String text) {
    if (RegExp(r'\bupi\b').hasMatch(text)) return PaymentMethod.upi;
    if (RegExp(r'\bcard\b').hasMatch(text)) return PaymentMethod.card;
    if (RegExp(r'\bcash\b').hasMatch(text)) return PaymentMethod.cash;
    if (RegExp(r'\bbank\s*transfer\b').hasMatch(text)) return PaymentMethod.bankTransfer;
    return null;
  }
}
