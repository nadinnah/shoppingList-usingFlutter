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
  late Future<List<GroceryItem>> loadedItems;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadedItems= _loadItems();
  }

  //void _loadItems() async {
  Future<List<GroceryItem>> _loadItems() async {
      var error = "";
      final url = Uri.https(
        'shopping-list-4fcdf-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
        final response = await http.get(
          url,
          headers: {'Content-type': 'application/json'},
        );
        if (response.statusCode >= 400) {
          throw Exception('Failed to fetch grocery items. Please try again later.');
          // setState(() {
          //   error = "Failed to fetch data. Please try again later.";
          // });
        }
        if (response.body == 'null') {

          return [];
        }
        final Map<String, dynamic> listData = json.decode(response.body);
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

        // setState(() {
        //   _groceryItems = loadedItems;
        //   isLoading = false;
        // });
        return loadedItems;
      //remove https from url and add .json for header(it's like saying url/shopping-list)

    }

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

    void _removeItem(GroceryItem item) async {
      final index = _groceryItems.indexOf(item);
      setState(() {
        _groceryItems.remove(item);
      });
      final url = Uri.https(
        'shopping-list-4fcdf-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json',
      );
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        setState(() {
          _groceryItems.insert(index, item);
        });
      }
    }

    @override
    Widget build(BuildContext context) {


      // if (_groceryItems.isEmpty) {
      //   content = Center(child: Text('No items added yet'));
      // }

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
          //body: content,
          body: FutureBuilder(future:loadedItems, builder: (context, snapshot){
            if(snapshot.connectionState==ConnectionState.waiting){
              return Center(child: CircularProgressIndicator());
            }
            if(snapshot.hasError){
              return Center(child: Text(snapshot.error.toString()));
            }
            if(snapshot.data!.isEmpty){
              return Center(child: Text('No items added yet'));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(snapshot.data![index].id),
                onDismissed: (direction) {
                  // setState(() {
                  //   //_groceryItems.removeAt(index);
                  //
                  // });
                  _removeItem(snapshot.data![index]);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item removed'),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          setState(() {
                            snapshot.data!.insert(index, _groceryItems[index]);
                          });
                        },
                      ),
                    ),
                  );
                },
                background: Container(color: Theme.of(context).colorScheme.error),
                child: ListTile(
                  title: Text(snapshot.data![index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: snapshot.data![index].category.color,
                  ),
                  trailing: Text(
                    snapshot.data![index].quantity.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            );

          }),
        //UI will never update due to future builder only executing once in init state
        //so if data is manipulated inside the same widget, futureBuilder will not update the widget and it isn't ideal for this project.
      );
    }
  }

