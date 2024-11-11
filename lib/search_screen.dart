
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Movie model
class Movie {
  final String title;
  final String genre;
  final String rating;
  final String poster;

  Movie({
    required this.title,
    required this.genre,
    required this.rating,
    required this.poster,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? 'No Title',
      genre: json['Genre'] ?? 'No Genre',
      rating: json['imdbRating'] ?? 'N/A',
      poster: json['Poster'] ?? '',
    );
  }
}

// MovieProvider for state management
class MovieProvider with ChangeNotifier {
  List<Movie> _movies = [];
  bool _isLoading = false;

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;

  Future<void> searchMovies(String query) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('http://www.omdbapi.com/?s=$query&apikey=12ea731f');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Data: $data'); // Debugging print statement

      if (data['Search'] != null) {
        _movies = await Future.wait(
          (data['Search'] as List).map((movieData) async {
            final movieDetailUrl = Uri.parse(
                'http://www.omdbapi.com/?i=${movieData['imdbID']}&apikey=12ea731f');
            final detailResponse = await http.get(movieDetailUrl);

            if (detailResponse.statusCode == 200) {
              final detailData = json.decode(detailResponse.body);
              return Movie.fromJson(detailData);
            } else {
              return Movie.fromJson(movieData);
            }
          }).toList(),
        );
      } else {
        print('No movies found for query: $query');
        _movies = [];
      }
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
      _movies = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchScreen(),
    );
  }
}

// UI screen with search functionality
class SearchScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(
              vertical:
                  30.0), 
          child: Text(
            'Home',
            style: TextStyle(
              color: Color(0xFF212121),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 20,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 0),
              child: TextField(
                controller: _controller,
                style: TextStyle(
                  color: Color(0xFF212121),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                ),
                decoration: InputDecoration(
                  labelText: 'Search',
                  labelStyle: TextStyle(
                    color: Color(0xFF212121),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF212121)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF212121)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Color(0xFF212121),
                      size: 24,
                    ),
                    onPressed: () {
                      movieProvider.searchMovies(_controller.text);
                    },
                  ),
                ),
                cursorColor: Color(0xFF212121),
              ),
            ),

            SizedBox(height: 20),
            movieProvider.isLoading
                ? CircularProgressIndicator(color: Color(0xFF212121))
                : Expanded(
                    child: ListView.builder(
                      itemCount: movieProvider.movies.length,
                      itemBuilder: (context, index) {
                        final movie = movieProvider.movies[index];
                        final String ratingText =
                            movie.rating.isNotEmpty ? movie.rating : 'N/A';
                        final double ratingValue =
                            double.tryParse(ratingText) ?? 0.0;
                        final Color ratingColor = ratingValue > 7
                            ? Color(0xFF5EC570)
                            : Color(0xFF1C7EEB);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal:
                                  16.0), // Reduced vertical space between movies
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top:
                                        90), // Reduced top margin to bring cards closer
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8.0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      200.0,
                                      16.0,
                                      16.0,
                                      20.0), // Adjusted for right alignment
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF212121),
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              4), 
                                      Text(
                                        movie.genre.replaceAll(',', ' |'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 8), 
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: ratingColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '$ratingText IMDB',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16, 
                                left: 16,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 150,
                                    height: 200, // Reduced height of the poster
                                    child: movie.poster.isNotEmpty
                                        ? Image.network(
                                            movie.poster,
                                            fit: BoxFit.cover,
                                          )
                                        : Center(
                                            child: Text('No Image'),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
