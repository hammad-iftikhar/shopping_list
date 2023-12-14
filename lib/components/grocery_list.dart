import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList(
      {super.key, required this.groceryItems, required this.onRemoveItem});

  final List<GroceryItem> groceryItems;
  final Function(GroceryItem) onRemoveItem;

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.groceryItems.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(widget.groceryItems[index].id),
        child: ListTile(
          leading: Container(
            width: 20,
            height: 20,
            color: widget.groceryItems[index].category.color,
          ),
          title: Text(widget.groceryItems[index].name),
          trailing: Text(widget.groceryItems[index].quantity.toString()),
        ),
        onDismissed: (direction) {
          widget.onRemoveItem(widget.groceryItems[index]);
        },
      ),
    );
  }
}
