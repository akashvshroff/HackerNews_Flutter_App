import 'package:rxdart/rxdart.dart';
import '../models/item_model.dart';
import '../resources/repository.dart';
import 'dart:async';

class StoriesBloc {
  final _repository = Repository();
  final _topIds = PublishSubject<List<int>>();
  final _itemsOutput = BehaviorSubject<Map<int, Future<ItemModel>>>();
  final _itemsFetcher = PublishSubject<int>();
  final _queryItems = PublishSubject<String>();

  // getter to Stream
  Stream<List<int>> get topIds => _topIds.stream;
  Stream<Map<int, Future<ItemModel>>> get items => _itemsOutput.stream;
  Stream<String> get query => _queryItems.stream;

  //getters to Sink
  Function(int) get fetchItem => _itemsFetcher.sink.add;

  StoriesBloc() {
    _itemsFetcher.stream.transform(_itemsTransformer()).pipe(_itemsOutput);
  }

  void queryIds(String query) async {
    final resultIds = [];
    final topIds = await _repository.fetchTopIds();
    for (int id in topIds) {
      ItemModel item = await _repository.fetchItem(id);
      if (item.text.contains(query)) {
        resultIds.add(id);
      }
      if (resultIds.isEmpty) {
        _queryItems.sink.addError('No such item exists');
      } else {
        _queryItems.sink.add(query);
        _topIds.sink.add(resultIds);
      }
    }
  }

  void fetchTopIds() async {
    final ids = await _repository.fetchTopIds();
    _topIds.sink.add(ids);
  }

  clearCache() {
    return _repository.clearCache();
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
    _queryItems.close();
    _itemsFetcher.close();
    _itemsOutput.close();
    _topIds.close();
  }
}
