import 'package:flutter/material.dart';
import 'dart:async';
import '../models/item_model.dart';

class Comment extends StatelessWidget {
  final int depth;
  final int itemId;
  final Map<int, Future<ItemModel>> itemMap;

  Comment({this.itemId, this.itemMap, this.depth});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: itemMap[itemId],
      builder: (context, AsyncSnapshot<ItemModel> snapshot) {
        if (!snapshot.hasData) {
          return Text("Still Loading");
        }

        final item = snapshot.data;

        final List<Widget> children = [
          ListTile(
            contentPadding: EdgeInsets.only(
              right: 16.0,
              left: (depth + 1) * 16.0,
            ),
            title: Text(item.text),
            subtitle: item.by != '' ? Text(item.by) : Text("Deleted"),
          ),
          Divider(),
        ];

        item.kids.forEach((kidId) {
          children.add(Comment(
            itemId: kidId,
            itemMap: itemMap,
            depth: depth + 1,
          ));
        });

        return Column(
          children: children,
        );
      },
    );
  }
}
