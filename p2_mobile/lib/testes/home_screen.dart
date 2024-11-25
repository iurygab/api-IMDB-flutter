import 'package:flutter/material.dart';
import '../../api/tmdb_api.dart'; // Para buscar dados da API
import 'movie_screen.dart'; // Para navegar até a tela de detalhes

class HomeScreen extends StatelessWidget {
  final TMDBApi api = TMDBApi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Center(
          child: Text(
            'globoplay',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Novelas
            buildSection(
              title: 'Novelas',
              future: api.fetchPopularMovies(), // Você pode trocar com um endpoint específico
            ),
            // Séries
            buildSection(
              title: 'Séries',
              future: api.fetchPopularMovies(),
            ),
            // Cinema
            buildSection(
              title: 'Cinema',
              future: api.fetchPopularMovies(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection({required String title, required Future<List<dynamic>> future}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          // Exibir lista de filmes/séries
          FutureBuilder<List<dynamic>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar dados!',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else {
                final items = snapshot.data ?? [];
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final imageUrl = 'https://image.tmdb.org/t/p/w200${item['poster_path']}';
                      final title = item['title'] ?? item['name'] ?? "Sem título";
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            // Navegar para a tela MovieScreen ao clicar no filme
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieScreen(movieId: item['id']),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imageUrl,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
