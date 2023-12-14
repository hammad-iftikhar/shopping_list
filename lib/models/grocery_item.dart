import 'dart:convert';

import 'package:shopping_list/models/category.dart';

class GroceryItem {
  GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  String id;
  final String name;
  final int quantity;
  final Category category;

  String get jsonValue {
    return json.encode({
      'name': name,
      'quantity': quantity,
      'category': category.name,
    });
  }
}
