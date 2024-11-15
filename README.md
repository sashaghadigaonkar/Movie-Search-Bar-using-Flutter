packages:
flutter/material.dart: Provides Flutter's material design widgets and themes.
provider/provider.dart: Provides state management using the Provider package.
http/http.dart: Allows making HTTP requests (used here to call the OMDB API).
dart:convert: Used for converting data (like JSON) to and from Dart objects.

Movie CLASS : 
Movie Class: Defines the data structure for each movie.
Constructor: Takes required parameters (title, genre, rating, poster).
fromJson factory method: Converts JSON data to a Movie object. The json parameter represents a movie's details in JSON format, which we receive from the OMDB API.


MovieProvider CLASS :
MovieProvider Class: Manages the state of movie search results.

_movies: Private list that stores the fetched movies.
_isLoading: Boolean flag to track if data is loading.

movies: Provides the list of movies to other widgets.
isLoading: Provides the loading state to other widgets.
searchMovies Method: Fetches movies based on a query.
Sets _isLoading to true: Indicates the data is being loaded.
Makes HTTP Request: Calls the OMDB API with the search query.
Checks Response: If the API call succeeds:
   If there are search results, it uses Future.wait to fetch detailed info for each movie using the movie ID (imdbID).
   If there are no results, it clears the movie list.
Error Handling: If the API call fails, it prints an error and clears the movie list.
Notifies Listeners: Updates the UI by calling notifyListeners() after each change.



SearchScreen : 
SearchScreen is the main UI for the app where the user can search for movies and view the results.
TextField: Lets the user input their search query. The TextEditingController listens for changes in the input.
CircularProgressIndicator: Displays a loading spinner while the app is fetching movie data.
ListView.builder: Dynamically creates a scrollable list of movie cards. Each card shows the movie title, genre, rating, and poster.
Card: The movie card is styled with rounded corners, and a small margin for spacing.
ClipRRect: Used to display the movie poster with rounded corners.
ListTile: Displays the movie information (title, genre, rating) in a structured format.
Ratings: Ratings below 7 are displayed in blue color while those above 7 are displayed in green.



overall workflow : 
The user enters a search term in the TextField.
Upon clicking the search icon, the searchMovies method is called via the MovieProvider.
The app sends a request to the OMDb API to fetch movie details based on the search query.
The response is parsed, and a list of Movie objects is created.
The UI rebuilds with the updated movie list using notifyListeners().
The results are displayed in a scrollable list, with a loading spinner shown while fetching the data.
