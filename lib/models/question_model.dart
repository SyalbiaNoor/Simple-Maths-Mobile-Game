import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FractionItem {
  final int numerator;
  final int denominator;
  final Color color;

  // selectedCells will be initialized by the controller when grid size is known
  // It is stored as an RxList so the UI can react to changes.
  RxList<bool> selectedCells = <bool>[].obs;

  FractionItem({
    required this.numerator,
    required this.denominator,
    required this.color,
  });

  double get value => numerator / denominator;
}

class QuestionModel {
  final List<FractionItem> items;

  QuestionModel({required this.items});

  double get totalValue {
    double total = 0;

    for (var item in items) {
      total += item.value;
    }

    return total;
  }

  String get expression {
    return items
        .map((item) => "${item.numerator}/${item.denominator}")
        .join(" + ");
  }
}
