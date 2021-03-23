import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../blocs/comments_provider.dart';
import '../models/item_model.dart';
import 'dart:async';
import '../widgets/comment.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetail extends StatelessWidget {
  final int itemId;

  NewsDetail({this.itemId});

  @override
  Widget build(BuildContext context) {
    final bloc = CommentsProvider.of(context);
    return Scaffold(
      appBar: AppBar(title: Text("STORY")),
      body: buildBody(bloc),
    );
  }

  Widget buildBody(CommentsBloc bloc) {
    return StreamBuilder(
      stream: bloc.itemWithComments,
      builder: (context, AsyncSnapshot<Map<int, Future<ItemModel>>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final itemFuture = snapshot.data[itemId];
        return FutureBuilder(
          future: itemFuture,
          builder: (context, AsyncSnapshot<ItemModel> itemSnapshot) {
            if (!itemSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return buildList(itemSnapshot.data, snapshot.data);
          },
        );
      },
    );
  }

  Widget buildList(ItemModel item, Map<int, Future<ItemModel>> itemMap) {
    final children = <Widget>[];
    children.add(buildTitle(item));
    children.add(buildLink(item));
    children.add(Divider(thickness: 5.0));
    final commentsList = item.kids.map((kidId) {
      return Comment(
        itemId: kidId,
        itemMap: itemMap,
        depth: 0,
      );
    }).toList();
    children.addAll(commentsList);

    return ListView(
      children: children,
    );
  }

  Widget buildTitle(ItemModel item) {
    return Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
        child: Text(
          item.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  Widget buildLink(ItemModel item) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        title: Text("read story."),
        leading: Icon(Icons.link),
        onTap: () {
          launchUrl(item.url);
        },
      ),
    );
  }

  launchUrl(String url) async {
    if (await canLaunch(url)) {
      print('can launch');
      await launch(url);
    }
  }

  // Widget buildWebIcon(ItemModel item) {

  // }
}
