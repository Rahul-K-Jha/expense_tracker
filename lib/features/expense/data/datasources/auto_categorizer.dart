import '../../domain/entities/category.dart';

class AutoCategorizer {
  static const _keywordMap = <String, List<String>>{
    'food': [
      'restaurant', 'cafe', 'coffee', 'pizza', 'burger', 'lunch', 'dinner',
      'breakfast', 'food', 'meal', 'snack', 'bakery', 'swiggy', 'zomato',
      'dominos', 'mcdonalds', 'starbucks', 'tea', 'biryani', 'dosa',
    ],
    'transport': [
      'uber', 'ola', 'cab', 'taxi', 'auto', 'metro', 'bus', 'train',
      'fuel', 'petrol', 'diesel', 'parking', 'toll', 'flight', 'airline',
      'rapido', 'namma',
    ],
    'shopping': [
      'amazon', 'flipkart', 'myntra', 'mall', 'shop', 'store', 'clothing',
      'shoes', 'electronics', 'gadget', 'meesho', 'ajio',
    ],
    'bills': [
      'electricity', 'water', 'gas', 'internet', 'wifi', 'mobile', 'recharge',
      'rent', 'emi', 'insurance', 'loan', 'bill', 'utility', 'airtel',
      'jio', 'broadband',
    ],
    'entertainment': [
      'movie', 'netflix', 'spotify', 'hotstar', 'prime', 'game', 'concert',
      'ticket', 'theatre', 'cinema', 'youtube', 'subscription',
    ],
    'health': [
      'hospital', 'doctor', 'medicine', 'pharmacy', 'medical', 'clinic',
      'dental', 'gym', 'fitness', 'yoga', 'apollo', 'lab', 'test',
    ],
    'education': [
      'course', 'book', 'tuition', 'school', 'college', 'udemy', 'coursera',
      'exam', 'study', 'library', 'tutorial', 'class',
    ],
    'groceries': [
      'grocery', 'vegetable', 'fruit', 'milk', 'bread', 'rice', 'oil',
      'supermarket', 'bigbasket', 'blinkit', 'zepto', 'instamart', 'dmart',
    ],
  };

  /// Suggest a category based on the description text.
  /// Returns the best matching category or null if no match.
  static Category? suggestCategory(String description) {
    final lower = description.toLowerCase();

    String? bestCategoryId;
    int bestScore = 0;

    for (final entry in _keywordMap.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          score += keyword.length; // longer matches score higher
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestCategoryId = entry.key;
      }
    }

    if (bestCategoryId == null) return null;

    return Category.defaults.firstWhere(
      (c) => c.id == bestCategoryId,
      orElse: () => Category.defaults.last,
    );
  }
}
