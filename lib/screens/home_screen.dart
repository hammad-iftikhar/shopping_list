import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/components/grocery_list.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryItem> _grocceryItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final List<GroceryItem> items = [];

    final url = Uri.https(
      "flutter-prep-e1e09-default-rtdb.firebaseio.com",
      "shopping-list.json",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      for (var item in data.entries) {
        final category = categories.entries
            .firstWhere((e) => e.value.name == item.value['category']);
        items.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category.value,
          ),
        );
      }
    } else {
      _error = "Something went wrong. Please try again later.";
    }

    setState(() {
      _grocceryItems = items;
      _isLoading = false;
    });
  }

  void _removeItem(GroceryItem item) {
    int index = _grocceryItems.indexOf(item);

    final url = Uri.https(
      "flutter-prep-e1e09-default-rtdb.firebaseio.com",
      "shopping-list/${item.id}.json",
    );

    http.delete(url);

    setState(() {
      _grocceryItems.remove(item);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _grocceryItems.insert(index, item);
            });
          },
        ),
        content: const Text('Item removed'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_grocceryItems.isEmpty) {
      content = const Center(
        child: Text('No item Found.'),
      );
    } else {
      content = GroceryList(
        groceryItems: _grocceryItems,
        onRemoveItem: _removeItem,
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: () async {
              final item = await Navigator.of(context).push<GroceryItem>(
                MaterialPageRoute(
                  builder: (ctx) => const AddItemScreen(),
                ),
              );

              if (item != null) {
                setState(() {
                  _grocceryItems.add(item);
                });
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
