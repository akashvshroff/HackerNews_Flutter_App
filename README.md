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
- However, before I can delve into my project, I would strongly urge you to check out the [HackerNews API]([https://github.com/HackerNews/API](https://github.com/HackerNews/API)) and understand how it works, I'll cover it very briefly under the Repository section but the description will assume that you know some basics.

## The Repository:
- P.S - all files related to the repository are in the [`src/resources/`](https://github.com/akashvshroff/HackerNews_Flutter_App/tree/master/lib/src/resources) dir.
- The repository handles all the fetching and storage of data in this project and it does so by leveraging a list of sources and a list of caches - both lists are `List<Source>` and `List<Cache>` where Source and Cache are abstract classes.
- Presently, the only sources in the program is the HackerNews API and the SQLite database, while the only cache is the SQLite database. However, using such a system of sources and caches means that I can later add more sources and caches without having to refactor and disrupt my code.
- The repository has a few primary functions - fetchItem, fetchTopIds and clearCache.

### fetchItem:
- The first method accepts an integer and returns a ItemModel instance that represents the item.
- Each HackerNews component - be it a story, comment or a poll - is considered to be an item and comes with a unique id. To be able to better implement these items in the project, there is a [ItemModel class](https://github.com/akashvshroff/HackerNews_Flutter_App/blob/master/lib/src/models/item_model.dart) that can be used to create an instance of each of these components and store their respective fields.
- The program cycles through each of the sources and aims to locate the item with the particular id and returns an instance of ItemModel. Once an item is located, it is then cached to make it easier to fetch the next time.

### fetchTopIds:
- The fetchTopIds method aims to return the `List<int>` of all the top stories as per the HackerNews API - this list contains all the ids of the top stories.
- The list is then cached (the record of the current top stories is maintained for a day unless manually refreshed, more on that later).

### clearCache:
- The clearCache method is tied to a pull-to-refresh mechanism of the application and when called upon, clears all the cached data resulting in fresh data fetching the next time around.