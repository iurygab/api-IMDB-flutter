import 'package:flutter/material.dart';
import '../api/tmdb_api.dart';
import 'movie_details_screen.dart';

// Tela inicial com lista de filmes e séries
class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  // Instância da API para buscar dados
  final TMDBApi api = TMDBApi();

  // Listas para armazenar filmes populares, séries e filmes de cinema
  List<dynamic> popularMovies = [];
  List<dynamic> series = [];
  List<dynamic> cinemaMovies = [];

  // Variável para controlar o estado de carregamento
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento dos dados ao abrir a tela
    fetchMovies();
  }

  // Função para buscar dados de filmes e séries da API
  Future<void> fetchMovies() async {
    try {
      // Faz as requisições para filmes populares, séries e filmes de cinema
      final popular = await api.fetchPopularMovies();
      final seriesData = await api.fetchPopularSeries();
      final cinemaData = await api.fetchPopularMovies(); // Pode ajustar para outro endpoint

      // Atualiza o estado com os dados recebidos
      setState(() {
        popularMovies = popular;
        series = seriesData;
        cinemaMovies = cinemaData;
        isLoading = false; // Finaliza o estado de carregamento
      });
    } catch (e) {
      // Trata possíveis erros na requisição
      print('Erro ao buscar filmes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo escuro para a tela
      appBar: AppBar(
        backgroundColor: Colors.black, // Fundo do AppBar
        elevation: 0, // Remove a sombra
        title: Center(
          child: Text(
            'globoplay', // Título no centro do AppBar
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carregamento
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seção: Filmes Populares
                  buildSection(
                    title: "Filmes Populares",
                    items: popularMovies,
                    mediaType: 'movie',
                  ),
                  // Seção: Séries
                  buildSection(
                    title: "Séries",
                    items: series,
                    mediaType: 'tv',
                  ),
                  // Seção: Cinema
                  buildSection(
                    title: "Cinema",
                    items: cinemaMovies,
                    mediaType: 'movie',
                  ),
                ],
              ),
            ),
      
    );
  }

  // Função para criar uma seção (ex.: Filmes Populares, Séries, Cinema)
  Widget buildSection({required String title, required List<dynamic> items, required String mediaType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
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
          // Lista horizontal com os itens (filmes/séries)
          SizedBox(
            height: 200, // Altura do item
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Lista rolável na horizontal
              itemCount: items.length,
              itemBuilder: (context, index) {
                final movie = items[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navegação para a tela de detalhes
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailsScreen(
                            movieId: movie['id'],
                            movieTitle: movie['title'] ?? movie['name'],
                            isMovie: mediaType == 'movie',
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0), // Bordas arredondadas
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w200${movie['poster_path']}', // Pôster do filme/série
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
