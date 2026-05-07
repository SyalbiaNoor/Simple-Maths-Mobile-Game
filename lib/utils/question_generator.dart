import 'dart:math';

import '../models/question_model.dart';

class QuestionGenerator {
  static final Random random = Random();

  static QuestionModel generate(int level) {
    List<FractionItem> items = [];

    while (true) {
      items.clear();

      for (int i = 0; i < 3; i++) {
        int denominator;
        int numerator;

        if (level == 1) {
          denominator = random.nextInt(4) + 2;
        } else {
          denominator = random.nextInt(5) + 6;
        }

        numerator = random.nextInt(denominator) + 1;

        items.add(FractionItem(numerator: numerator, denominator: denominator));
      }

      double total = 0;

      for (var item in items) {
        total += item.value;
      }

      if (total >= 0.5 && total <= 1.0) {
        break;
      }
    }

    return QuestionModel(items: List.from(items));
  }
}
