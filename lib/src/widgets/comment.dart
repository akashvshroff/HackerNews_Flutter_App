import 'package:flutter/material.dart';
import 'dart:async';
import '../models/item_model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/loading_container.dart';

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
          return LoadingContainer();
        }

        final item = snapshot.data;

        final List<Widget> children = [
          ListTile(
            contentPadding: EdgeInsets.only(
              right: 16.0,
              left: (depth + 1) * 16.0,
            ),
            title: buildHtml(item),
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

  Widget buildHtml(ItemModel item) {
    return Html(
      data: item.text,
      onLinkTap: (String url) {
        launchUrl(url);
      },
    );
  }

  launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
