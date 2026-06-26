import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item.dart';
import 'package:http/http.dart' as http;

import '../data/categories.dart';
import '../models/category.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
   List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'shopping-list-4fcdf-default-rtdb.firebaseio.com',
      'shopping-list.json',
    ); //remove https from url and add .json for header(it's like saying url/shopping-list)
    final response = await http.get(
      url,
      headers: {'Content-type': 'application/json'},
    );
    final Map<String, dynamic> listData = json.decode(
      response.body,
    );
    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (categoryItem) =>
                categoryItem.value.title == item.value['category'],
          )
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    setState(() {
      _groceryItems = loadedItems;
    });
  }

  void _addItem(BuildContext context) async {
    await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => NewItem()));

    _loadItems();
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
        background: Container(color: Theme.of(context).colorScheme.error),
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
      content = Center(child: Text('No items added yet'));
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
