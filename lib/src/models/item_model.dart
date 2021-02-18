class ItemModel {
  final int id; // item's unique id.
  final bool deleted; // if the item is deleted.
  final String
      type; // type of item. One of "job", "story", "comment", "poll", or "pollopt".
  final String by; // username of the item's author.
  final int time; // date of the item, in Unix Time.
  final String text; // comment, story or poll text. HTML.
  final bool dead; // if the item is dead.
  final int
      parent; // comment's parent: either another comment or the relevant story.
  final List<dynamic>
      kids; // ids of the item's comments, in ranked display order.
  final String url; // URL of the story.
  final int score; // story's score, or the votes for a pollopt.
  final String title; // title of the story, poll or job. HTML.
  final int
      descendants; //In the case of stories or polls, the total comment count.

  ItemModel.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson["id"],
        deleted = parsedJson["deleted"],
        type = parsedJson["type"],
        by = parsedJson["by"],
        time = parsedJson["time"],
        text = parsedJson["text"],
        dead = parsedJson["dead"],
        parent = parsedJson["parent"],
        kids = parsedJson["kids"],
        url = parsedJson["url"],
        score = parsedJson["score"],
        title = parsedJson["title"],
        descendants = parsedJson["descendants"];
}
