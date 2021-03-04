import 'dart:io';
import 'package:http/http.dart' show Client;
import 'dart:convert';
import '../models/item_model.dart';
import 'dart:async';
import 'repository.dart';

final root = 'https://hacker-news.firebaseio.com/v0';

class NewsApiProvider implements Source {
  Client client = Client();

  Future<List<int>> fetchTopIds() async {
    final response = await client.get('$root/topstories.json');
    final ids = jsonDecode(response.body);
    return ids.cast<int>();
  }

  Future<ItemModel> fetchItem(int id) async {
    final response = await client.get('$root/item/$id.json');
    final parsedJson = json.decode(response.body);
    return ItemModel.fromJson(parsedJson);
  }
}
