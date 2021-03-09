import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../models/item_model.dart';
import '../resources/repository.dart';

class CommentsBloc {
  final _commentsFetcher = PublishSubject<int>();
  final _commentsOutput = BehaviorSubject<Map<int, Future<ItemModel>>>();

  //stream
  Stream<Map<int, Future<ItemModel>>> get itemWithComments =>
      _commentsOutput.stream;

  //sink
  Function(int) get fetchItemWithComments => _commentsFetcher.sink.add;

  void dispose() {
    _commentsFetcher.close();
    _commentsOutput.close();
  }
}
