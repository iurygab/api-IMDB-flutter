import 'package:flutter/material.dart';
import '../../api/tmdb_api.dart';

class MovieScreen extends StatefulWidget {
  final int movieId;

  MovieScreen({required this.movieId});

  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  late Future<Map<String, dynamic>> movieDetails;
  final TMDBApi api = TMDBApi();

  @override
  void initState() {
    super.initState();
    movieDetails = api.fetchMovieDetails(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Detalhes do Filme'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar detalhes!', style: TextStyle(color: Colors.white)));
          } else {
            final movie = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    'https://image.tmdb.org/t/p/w500${movie?['poster_path']}',
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      movie?['title'] ?? 'Sem título',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      movie?['overview'] ?? 'Sem descrição disponível',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
