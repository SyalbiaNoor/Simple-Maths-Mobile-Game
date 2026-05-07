class FractionItem {
  final int numerator;
  final int denominator;

  FractionItem({
    required this.numerator,
    required this.denominator,
  });

  double get value =>
      numerator / denominator;
}

class QuestionModel {
  final List<FractionItem> items;

  QuestionModel({
    required this.items,
  });

  double get totalValue {
    double total = 0;

    for (var item in items) {
      total += item.value;
    }

    return total;
  }

  String get expression {
    return items
        .map(
          (item) =>
              "${item.numerator}/${item.denominator}",
        )
        .join(" + ");
  }
}