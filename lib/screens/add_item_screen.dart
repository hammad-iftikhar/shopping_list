import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  var _enteredName = "",
      _enteredQuantity = "1",
      _enteredCategory = categories[Categories.vegetables]!,
      _isSaving = false;

  void _addItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSaving = true;
      });

      GroceryItem item = GroceryItem(
        id: DateTime.now().toString(),
        name: _enteredName,
        quantity: int.parse(_enteredQuantity),
        category: _enteredCategory,
      );

      final url = Uri.https(
        "flutter-prep-e1e09-default-rtdb.firebaseio.com",
        "shopping-list.json",
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: item.jsonValue,
      );

      setState(() {
        _isSaving = false;
      });

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        item.id = body['name'];

        Navigator.of(context).pop(item);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value != null) {
                    int len = value.length;
                    if (len >= 1 && len <= 50) return null;
                  }

                  return 'Must be between 1 and 50 characters';
                },
                onSaved: (newValue) {
                  _enteredName = newValue ?? "";
                },
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity,
                      validator: (value) {
                        if (value != null) {
                          double? val = double.tryParse(value);
                          if (val != null && val >= 1) {
                            return null;
                          }
                        }

                        return 'Must be a valid, positive number';
                      },
                      onSaved: (newValue) {
                        _enteredQuantity = newValue ?? "1";
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _enteredCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.name),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _enteredCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _addItem,
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
