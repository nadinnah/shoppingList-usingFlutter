import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/screens/new_item.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {

  void _addItem(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>NewItem()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: (){
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
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (ctx, index) => ListTile(
          title: Text(groceryItems[index].name),
          leading: Container(
            width: 24,
            height: 24,
            color: groceryItems[index].category.color,
          ),
          trailing: Text(
            groceryItems[index].quantity.toString(),
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
