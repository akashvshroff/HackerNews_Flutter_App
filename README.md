# Outline:

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/XmBgl5EB7tY/0.jpg)](https://www.youtube.com/watch?v=XmBgl5EB7tY)

- A minimal, performant news application built using the HackerNews API. The application fetches data and caches them using SQLite to increase efficiency and data transfer within the application is facilitated using the BLOC pattern where the Streams are created using the rxdart package. 
- The video above outlines the features and UI of the application, while a detailed description of how the application has been built lies below. 

# Purpose:
- The core portion of this application was built as a part of a [Flutter and Dart course](https://www.udemy.com/course/dart-and-flutter-the-complete-developers-guide/) that I completed on Udemy. I thoroughly enjoyed the build as it was quite challenging at times, especially when trying to construct a clean and efficient data fetching architecture and trying to present the data in a friendly manner. 
- I prefer learning by following a tutorial and then adding my own features and tinkering with the project and this idea can be viewed in the search bar I added, as well as rendering HTML, linking the story and a number of other features that helped me truly understand how the application worked and by extension, how to work with the BLOC pattern in Flutter. 
- Moreover, this project helped solidify my understanding of Dart and its core nuances such as futures, streams, and type annotation. It also allowed me to work (and get extremely comfortable) with a myriad of external packages and libraries such as sqflite, rxdart and http which are extremely useful and will certainly help me going forward.

# Description:
- Trying to explain the entire application and the purpose of each and every facet would render this document far too long and boring, therefore I'll just cover the application in a very barebones, structural sense. 
- There are 3 main parts to the application: the Repository, the BLOCs and the UI. I will cover each individually as well as talk about how they combine to make the application. 
- However, before I can delve into my project, I would strongly urge you to check out the [HackerNews API]([https://github.com/HackerNews/API](https://github.com/HackerNews/API)) and understand how it works, I'll cover it very briefly under the Repository section but the description will assume that you know some basics.

## The Repository:
- P.S - all files related to the repository are in the [`src/resources/`](https://github.com/akashvshroff/HackerNews_Flutter_App/tree/master/lib/src/resources) dir.
- The repository handles all the fetching and storage of data in this project and it does so by leveraging a list of sources and a list of caches - both lists are `List<Source>` and `List<Cache>` where Source and Cache are abstract classes.
- Presently, the only sources in the program is the HackerNews API and the SQLite database, while the only cache is the SQLite database. However, using such a system of sources and caches means that I can later add more sources and caches without having to refactor and disrupt my code.
- The repository has a few primary functions - fetchItem, fetchTopIds and clearCache.

### fetchItem:
- The first method accepts an integer and returns a ItemModel instance that represents the item.
- Each HackerNews component - be it a story, comment or a poll - is considered to be an item and comes with a unique id. To be able to better implement these items in the project, there is an [ItemModel class](https://github.com/akashvshroff/HackerNews_Flutter_App/blob/master/lib/src/models/item_model.dart) that can be used to create an instance of each of these components and store their respective fields.
- The program cycles through each of the sources and aims to locate the item with the particular id and returns an instance of ItemModel. Once an item is located, it is then cached to make it easier to fetch the next time.

### fetchTopIds:
- The fetchTopIds method aims to return the `List<int>` of all the top stories as per the HackerNews API - this list contains all the ids of the top stories.
- The list is then cached (the record of the current top stories is maintained for a day unless manually refreshed, more on that later).

### clearCache:
- The clearCache method is tied to a pull-to-refresh mechanism of the application and when called upon, clears all the cached data resulting in fresh data fetching the next time around.

## The BLOCs:
- The two BLOCs in this project - the StoriesBloc and the CommentsBloc as well as their respective Providers can be found in the [`src/blocs/`](https://github.com/akashvshroff/HackerNews_Flutter_App/tree/master/lib/src/blocs) dir.
- These house the StreamControllers and methods that are responsible for the presentation of data in the project and both interface with the Repository class.
- The two Provider classes are used to wrap the MaterialApp so that any child can access the respective BLOC by using the `static of` method of the Provider and passing it a `BuildContext`.

### StoriesBloc:
- The StoriesBloc contains a few StreamControllers, getters and associated methods. The _topIds StreamController is used to pass events that correspond to the `List<int>` of topIds that is used to build the the list of top stories displayed to the user.
- The `_itemsFetcher` and `_itemsOutput` StreamControllers are used to fetch and return an ItemModel for each item. There is an input and output stream set-up as the id to be fetched is passed to the _itemsFetcher sink (via a getter) and this stream is then transformed using the `ScanStreamTransformer` and its results are piped to the output stream.
- This slightly complex set-up is used to ensure that subscriptions are only made to the output stream and not to the stream that is being transformed as that leads to a number of errant transformer calls.
- The ScanStreamTransformer outputs a cache map to the _itemsOutput stream where each item id corresponds to its respective `Future<ItemModel>` (the reason for using Futures is covered in the UI section).
- Each of the methods in this BLOC rely on an instance of the Repository class to fetch, store and clear data.

### CommentsBloc:
- The CommentsBloc is responsible for fetching and presenting all the child comments for a particular parent story that is being presented in detail.
- The BLOC follows the same input - transformer - output stream setup that the StoriesBloc did, with a few changes.
- This process is a little more complex as there is a recursive call must occur owing to the nature of the HackerNews API. Each item can have a number of `kids` and therefore to fetch the entire comment thread, one has to fetch all the child comments for all the child comments of the top-level story and so on until there are no child comments. The process by which the BLOC accomplishes this, could be thought of as a queue as well.
- First, there is a getter to the sink of the input StreamController and this getter is used only once outside the BLOC to trigger the recursive process and into the sink is added the id of the top-level parent story. The transformer then fetches (and caches) the item corresponding to each id passed into the stream and then it adds all the kid ids of that item to the sink using the getter, thereby creating a queue where the kids are added and fetched until none remain.

    ```dart
    //sink - called once outside the BLOC
    Function(int) get fetchItemWithComments => _commentsFetcher.sink.add;

    //transformer
    _commentsTransformer() {
        return ScanStreamTransformer<int, Map<int, Future<ItemModel>>>(
          (cache, int id, index) {
            cache[id] = _repository.fetchItem(id);
            cache[id].then((ItemModel item) {
              item.kids.forEach((kidId) => fetchItemWithComments(kidId)); //added to queue
            });
            return cache;
          },
          <int, Future<ItemModel>>{},
        );
      }
    ```

- Therefore, through this process, the BLOC has fetched the ItemModels for each of the comments associated with a story and stored it in the map which is piped to the output stream.

## The UI:
- The UI leverages the two BLOCs in order to present information in a clean and effective manner - since it is largely composed of StatelessWidgets (with the exception of the search bar - more on that later), it uses StreamBuilders in order to subscribe to the streams housed in the BLOCs and display changing information through the events of the streams.
- Moreover, FutureBuilders are used in many scenarios to resolve Futures as and when required and display them when necessary in order to be more performant.
- There are a few key components of the UI and I will explain them as aptly as I can.

### Navigation:
- Navigation is made extremely easy in Flutter applications owing to the Navigator object provided by the MaterialApp. Here, the Navigation is handled using the `onGenerateRoute` callback.
- This choice is made, instead of the more common map-based routing, to allow for easy information sharing during navigation. More specifically, to share the id of the top-level parent item while going from the list of top-stories to the story page for each comment.
- The home page i.e the list of top-stories is given a route name of `/` while the detail page is simply `/:id` where :id refers to the item id. This information is passed to the onGenerateRoute callback in the RouteSettings object via the pushNamed method.
- In the callback, the route name is parsed and the respective MaterialPageRoute is returned with either an instance of NewsList or NewsDetail (with the item id as the instance variable).
- Moreover, before the page is returned, there is some initial data fetching done - if the top stories are to be displayed then they are fetched and if some particular story is to be displayed, the recursive fetching process via the transformer is triggered.

    ```dart
    //onGenerateCallback: routes,
    Route routes(RouteSettings settings) {
        if (settings.name == '/') { //check route 
          return MaterialPageRoute(
            builder: (context) {
              final storiesBloc = StoriesProvider.of(context);
              storiesBloc.fetchTopIds(); //top stories fetching
              return NewsList();
            },
          );
        } else {
          return MaterialPageRoute(builder: (context) {
            final itemId = int.parse(settings.name.replaceFirst('/', '')); //parse id
            final commentsBloc = CommentsProvider.of(context);

            commentsBloc.fetchItemWithComments(itemId); //trigger recursive fetching
     
            return NewsDetail(
              itemId: itemId, //itemId as an instance variable
            );
          });
        }
      }
    ```

### NewsList:
- The [NewsList](https://github.com/akashvshroff/HackerNews_Flutter_App/blob/master/lib/src/screens/news_list.dart) is another key feature of the UI and is the list of top stories as well a search filter to query the list of top stories. On clicking any of the stories, the user is then taken to a detail page for the story where users can see all the comments and access the original source of the story.
- A `StreamBuilder` is used that subscribes to the topIds stream and calls upon a `ListView.builder` in order to display the items onto the screen, this way only those items that are visible to the user are rendered. Each individual story is rendered using a custom widget, [NewsListTile](https://github.com/akashvshroff/HackerNews_Flutter_App/blob/master/lib/src/widgets/news_list_tile.dart) and the ListView.builder returns an instance of `NewsListTile` for each id in the topIds.
- The ListView.builder also calls upon the input stream and tries to fetch the ItemModel for the particular id it is rendering and therefore the NewsListTile is also composed of a StreamBuilder and FutureBuilder that returns a custom [LoadingContainer](https://github.com/akashvshroff/HackerNews_Flutter_App/blob/master/lib/src/widgets/loading_container.dart) if there is no data, else it returns a ListTile with the story information and an `onTap` callback.
- The process is as follows:

    ```
    StreamBuilder (topIds)
    -ListView.builder (renders each id in topIds)
     -NewsListTile (for each itemId)
      -StreamBuilder (itemsOutput - gets cache map output)
       -FutureBuilder (since each cache[id] is Future<ItemModel>)
    	-ListTile or LoadingContainer or empty Container
    ```

- Here, our query is also involved. The query is saved in a variable and if the FutureBuilder has data and the `ItemModel.title` contains the query, then the ListTile is displayed, else an empty container is used.
- This sort of system is used since it means that the performant features of the ListView.builder can still be used as titles are displayed as and when you scroll through the search results and as more titles are being fetched, you can still access the ones that have already been fetched.
- The NewsList page can also be refreshed using the [Refresh](https://github.com/akashvshroff/HackerNews_Flutter_App/blob/master/lib/src/widgets/refresh.dart) widget that clears all data and fetches the top ids again so that the data is refreshed in real time. Refresh also clears the editingController associated with the search TextField.

### NewsDetail:
- The [NewsDetail](https://github.com/akashvshroff/HackerNews_Flutter_App/blob/master/lib/src/screens/news_detail.dart) page is responsible for displaying the title of the story, the associated link and all of the comments in a visually demarcated manner highlighting the relationship between each comment.
- To display each comment and indent it as per the relationship with the other comments, we use a custom widget, [Comment](https://github.com/akashvshroff/HackerNews_Flutter_App/blob/master/lib/src/widgets/comment.dart).

    ```dart
    class Comment extends StatelessWidget {
      final int depth;
      final int itemId;
      final Map<int, Future<ItemModel>> itemMap;

      Comment({this.itemId, this.itemMap, this.depth});
    }
    ```

- The itemId refers to the id of the comment being displayed, the itemMap is the cache map that contains the `Future<ItemModel>` values of each of the comments and the depth is used for indendation and refers to the distance from the parent comment.
- A ListView is used to display all the UI elements; the title, link and comments. This is done by creating a list of widgets that is passed to the ListView.
- In the NewsDetail buildList, we add all the top-level comments to our list of widgets in the form of Comment instances and this triggers the build method of each Comment widget which returns a Column of its representation (as a ListTile) and Comment instances of all of its children (with depth incremented) and thereby creating a recursive process.
- Therefore, the ListView contains a list composed of the title, link and all the comments. Each comment is a Comment widget which returns a Column composed of the ListTile for that comment and Comment instances of all its children.
- The build method of the Comment widget contains a FutureBuilder that simply returns the LoadingContainer if the Future has not resolved.
- Since the text passed by the HackerNews API is raw html, the [flutter_html](https://pub.dev/packages/flutter_html) package is used to render the content to the screen and the [url_launcher](https://pub.dev/packages/url_launcher) package is used to launch all links, including that of the top-level story and any present in a comment.