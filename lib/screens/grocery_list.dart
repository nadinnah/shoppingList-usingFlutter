import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem(BuildContext context) async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => NewItem()));
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.builder(
      itemCount: _groceryItems.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(_groceryItems[index].id),
        onDismissed: (direction) {
          // setState(() {
          //   //_groceryItems.removeAt(index);
          //
          // });
          _removeItem(_groceryItems[index]);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item removed'),
              duration: Duration(seconds: 2),
                action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  setState(() {
                    _groceryItems.insert(index, _groceryItems[index]);
                  });
                },
              ),
            ),
          );

        },
        background: Container(
          color: Theme.of(context).colorScheme.error,
        ),
        child: ListTile(
          title: Text(_groceryItems[index].name),
          leading: Container(
            width: 24,
            height: 24,
            color: _groceryItems[index].category.color,
          ),
          trailing: Text(
            _groceryItems[index].quantity.toString(),
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );

    if (_groceryItems.isEmpty) {
      content = Center(
        child: Text('No items added yet'),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _addItem(context);
            },
            icon: Icon(Icons.add),
          ),
        ],
        title: Text('Your Groceries'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      // body: ListView(
      //   children: [
      //     for (final groceryItem in groceryItems)
      //       ListTile(
      //         title: Text(groceryItem.name),
      //         leading: Container(
      //           width: 24,
      //           height: 24,
      //           color: groceryItem.category.color,
      //         ),
      //         trailing: Text(groceryItem.quantity.toString(), style: TextStyle(fontSize: 16),),
      //       ),
      //   ],
      // ),
      body: content,
    );
  }
}
