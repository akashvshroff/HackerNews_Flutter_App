import 'package:flutter/material.dart';
import '../blocs/stories_provider.dart';
import 'dart:async';
import '../screens/news_list.dart';

class Refresh extends StatelessWidget {
  final Widget child;
  final NewsListState parent;

  Refresh({this.child, this.parent});

  @override
  Widget build(BuildContext context) {
    final bloc = StoriesProvider.of(context);
    return RefreshIndicator(
      child: child,
      onRefresh: () async {
        parent.queryController.text = '';
        parent.query = '';
        await bloc.clearCache();
        await bloc.fetchTopIds();
      },
    );
  }
}
