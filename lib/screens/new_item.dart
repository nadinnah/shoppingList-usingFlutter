import 'package:flutter/material.dart';

import '../data/categories.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          child: Column(children: [
            TextFormField(
              maxLength: 50,
              decoration: InputDecoration(
                label: Text('Name'),

              ),
              validator: (value){
                return 'hello';
              },
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.end  //CrossAxisAlignment.end is used to align the children to the end of the row vertically
                ,children: [
              Expanded(
                child: TextFormField( //wrap TextFormField with expanded as it's unconstrained horizontally like row
                  decoration: InputDecoration(
                    label: Text('Quantity'),
                  ),
                  initialValue: '1',
                  keyboardType: TextInputType.number,
                  validator: (value){
                    return 'hello';
                  },
                ),
              ),
              SizedBox(width: 8,),
              Expanded(
                child: DropdownButtonFormField(items: [for(final category in categories.entries) //entries converts the map into a list of entries
                  DropdownMenuItem(value: category.value, child: Row(children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: category.value.color,
                    ),
                    SizedBox(width: 6,),
                    Text(category.value.title),
                  ],))], onChanged:
                (value){

                }),
              )
            ],)

          ])
        ),
      )

    );
  }
}
