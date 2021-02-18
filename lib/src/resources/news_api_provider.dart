import 'package:http/http.dart' show Client;

class NewsApiProvider {
  Client client = Client();

  fetchTopIds() {
    client.get('http://hacker-news.firebaseio.com/v0/topstories.json');
  }

  fetchItem() {}
}
