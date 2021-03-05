import 'package:flutter/material.dart';
import 'package:news/src/blocs/stories_bloc.dart';
import 'package:news/src/widgets/refresh.dart';
import '../blocs/stories_provider.dart';
import '../widgets/news_list_tile.dart';
import '../widgets/refresh.dart';

class NewsList extends StatelessWidget {
  Widget build(BuildContext context) {
    final bloc = StoriesProvider.of(context);
    bloc.fetchTopIds();
    return Scaffold(
      appBar: AppBar(
        title: Text("TOP NEWS"),
      ),
      body: buildList(bloc),
    );
  }

  Widget searchQuery(bloc) {
    return StreamBuilder(
      stream: bloc.query,
      builder: (context, snapshot) {
        return TextField(
          onChanged: bloc.queryIds,
          decoration: InputDecoration(
            labelText: 'Enter query',
            errorText: snapshot.error,
          ),
        );
      },
    );
  }

  Widget buildList(StoriesBloc bloc) {
    return StreamBuilder(
      stream: bloc.topIds,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Refresh(
          child: ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, int index) {
              bloc.fetchItem(snapshot.data[index]);
              return NewsListTile(itemId: snapshot.data[index]);
            },
          ),
        );
      },
    );
  }
}
