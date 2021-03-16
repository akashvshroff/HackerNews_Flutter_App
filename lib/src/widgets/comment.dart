import 'package:flutter/material.dart';
import 'dart:async';
import '../models/item_model.dart';

class Comment extends StatelessWidget {
  final int itemId;
  final Map<int, Future<ItemModel>> itemMap;

  Comment({this.itemId, this.itemMap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: itemMap[itemId],
      builder: (context, AsyncSnapshot<ItemModel> snapshot) {
        if (!snapshot.hasData) {
          return Text("Still Loading");
        }

        final List<Widget> children = [
          Text(snapshot.data.text),
        ];

        snapshot.data.kids.forEach((kidId) {
          children.add(Comment(
            itemId: kidId,
            itemMap: itemMap,
          ));
        });

        return Column(
          children: children,
        );
      },
    );
  }
}
