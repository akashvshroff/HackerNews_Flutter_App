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

## The Repository:
- 