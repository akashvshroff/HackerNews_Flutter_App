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
      body: Column(
        children: <Widget>[
          searchQuery(bloc),
          Expanded(child: buildList(bloc)),
        ],
      ),
    );
  }

  Widget searchQuery(bloc) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 5.0,
      ),
      child: StreamBuilder(
        stream: bloc.queryStream,
        builder: (context, snapshot) {
          return TextField(
            onChanged: bloc.addQuery,
            onSubmitted: bloc.queryIds,
            decoration: InputDecoration(
              hintText: 'Enter query',
              errorText: snapshot.error,
            ),
          );
        },
      ),
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
        ));
      },
    );
  }
}
