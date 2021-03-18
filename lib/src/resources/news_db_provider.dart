import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import '../models/item_model.dart';
import 'repository.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class NewsDbProvider implements Source, Cache {
  Database db;
  var readyCompleter = Completer();
  Future get ready => readyCompleter.future;

  NewsDbProvider() {
    init().then((_) {
      readyCompleter.complete();
    });
  }

  Future init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'news_items.db');
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database newDb, int version) {
        newDb.execute('''
          CREATE TABLE Items
            (
              id INTEGER PRIMARY KEY,
              type TEXT,
              by TEXT,
              time INTEGER,
              text TEXT,
              parent INTEGER,
              kids BLOB,
              dead INTEGER,
              deleted INTEGER,
              url TEXT,
              score INTEGER,
              title TEXT,
              descendants INTEGER
            )
          ''');
        newDb.execute('''
        CREATE TABLE Ids
        (
          id INTEGER,
          date TEXT,
          ids BLOB
        )
        ''');
        newDb.execute('INSERT INTO Ids (id, date, ids) VALUES (1, NULL, NULL)');
      },
    );
  }

  String _getDate() {
    var now = DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  Future<ItemModel> fetchItem(int id) async {
    await ready;
    final maps = await db.query(
      "Items",
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.length > 0) {
      //will only receive one map or no map.
      return ItemModel.fromDb(maps.first);
    } else {
      return null;
    }
  }

  Future<List<int>> fetchTopIds() async {
    await ready;
    final maps = await db.query(
      "Ids",
      columns: null,
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps[0]['date'] != null && maps[0]['date'] == _getDate()) {
      //if there is data and data is of today.
      return json.decode(maps[0]['ids']).cast<int>();
    }
  }

  Future<int> addItem(ItemModel item) {
    return db.insert(
      'Items',
      item.toMapForDb(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> addTopIds(List<int> topIds) {
    Map<String, dynamic> idMap = {
      "id": 1,
      "date": _getDate(),
      "ids": json.encode(topIds),
    };
    return db.update(
      'Ids',
      idMap,
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> clear() {
    db.delete("Items");
    return db.update('Ids', {'id': 1, 'date': null, 'ids': null});
  }
}

final newsDbProvider = NewsDbProvider();
