import 'package:rxdart/rxdart.dart';
import '../models/item_model.dart';
import '../resources/repository.dart';
import 'dart:async';

class StoriesBloc {
  final _repository = Repository();
  final _topIds = PublishSubject<List<int>>();

  // getter to Stream
  Stream<List<int>> get topIds => _topIds.stream;

  void fetchTopIds() async {
    final ids = await _repository.fetchTopIds();
    _topIds.sink.add(ids);
  }

  _itemsTransformer() {
    return ScanStreamTransformer(
      (Map<int, Future<ItemModel>> cache, int id, index) {
        cache[id] = _repository.fetchItem(id);
        return cache;
      },
      <int, Future<ItemModel>>{},
    );
  }

  void dispose() {
    _topIds.close();
  }
}
