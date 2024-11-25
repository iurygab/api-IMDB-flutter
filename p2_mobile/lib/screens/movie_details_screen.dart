import 'package:flutter/material.dart';
import '../api/tmdb_api.dart';
import 'shared_list.dart'; // Importa a lista global para a "Minha Lista"

// Tela de detalhes de filmes ou séries
class MovieDetailsScreen extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final bool isMovie;

  const MovieDetailsScreen({
    Key? key,
    required this.movieId,
    required this.movieTitle,
    required this.isMovie,
  }) : super(key: key);

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen>
    with SingleTickerProviderStateMixin {
  final TMDBApi api = TMDBApi();

  Map<String, dynamic>? movieDetails;
  List<dynamic> relatedMovies = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    try {
      final details = widget.isMovie
          ? await api.fetchMovieDetails(widget.movieId)
          : await api.fetchSeriesDetails(widget.movieId);

      final related = widget.isMovie
          ? await api.fetchPopularMovies()
          : await api.fetchPopularSeries();

      setState(() {
        movieDetails = details;
        relatedMovies = related.map((movie) {
          return {
            ...movie,
            'media_type': widget.isMovie ? 'movie' : 'tv',
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao buscar detalhes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : movieDetails == null
              ? Center(
                  child: Text(
                    'Erro ao carregar detalhes',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMovieBanner(),
                      _buildActionButtons(),
                      SizedBox(height: 20),
                      _buildTabBar(),
                      SizedBox(height: 10),
                      _buildTabBarView(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMovieBanner() {
    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              'https://image.tmdb.org/t/p/w500${movieDetails!['poster_path']}',
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Text(
            widget.movieTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.isMovie ? 'Filme' : 'Série',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            movieDetails!['overview'] ?? 'Descrição não disponível',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final movieData = {
      'title': widget.movieTitle,
      'image': 'https://image.tmdb.org/t/p/w500${movieDetails!['poster_path']}',
    };

    bool isInList = userFavoriteList.any((movie) => movie['title'] == widget.movieTitle);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {}, // Pode ser configurado para ações adicionais
          child: Row(
            children: [
              Icon(Icons.play_arrow),
              SizedBox(width: 5),
              Text('Assista'),
            ],
          ),
        ),
        SizedBox(width: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {
            setState(() {
              if (!isInList) {
                userFavoriteList.add(movieData);
              } else {
                userFavoriteList.removeWhere((movie) => movie['title'] == widget.movieTitle);
              }
            });
            final snackBar = SnackBar(
              content: Text(isInList
                  ? 'Removido da sua lista'
                  : 'Adicionado à sua lista!'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: Row(
            children: [
              Icon(isInList ? Icons.check : Icons.star_border),
              SizedBox(width: 5),
              Text(isInList ? 'Na Lista' : 'Minha Lista'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(text: 'ASSISTA TAMBÉM'),
        Tab(text: 'DETALHES'),
      ],
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
    );
  }

  Widget _buildTabBarView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildRelatedMovies(),
          _buildDetails(),
        ],
      ),
    );
  }

  Widget _buildRelatedMovies() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: relatedMovies.length,
        itemBuilder: (context, index) {
          final movie = relatedMovies[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsScreen(
                    movieId: movie['id'],
                    movieTitle: movie['title'] ?? movie['name'],
                    isMovie: movie['media_type'] == 'movie',
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildDetailRow('Título Original', movieDetails!['original_title'] ?? movieDetails!['name']),
          _buildDetailRow('Ano de Produção', movieDetails!['release_date']?.split('-').first),
          _buildDetailRow('País', _getCountries(movieDetails!['production_countries'])),
          _buildDetailRow('Duração', movieDetails!['runtime'] != null ? '${movieDetails!['runtime']} minutos' : 'N/A'),
          _buildDetailRow('Gênero', _getGenres(movieDetails!['genres'])),
          _buildDetailRow('Nota Média', '${movieDetails!['vote_average']}'),
          if (!widget.isMovie) ...[
            _buildDetailRow('Temporadas', _getSeasons(movieDetails!['seasons'])),
            _buildDetailRow('Número de Episódios', '${movieDetails!['number_of_episodes']}'),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: value ?? 'N/A',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  String _getGenres(List<dynamic>? genres) {
    if (genres == null || genres.isEmpty) return 'N/A';
    return genres.map((genre) => genre['name']).join(', ');
  }

  String _getCountries(List<dynamic>? countries) {
    if (countries == null || countries.isEmpty) return 'N/A';
    return countries.map((country) => country['name']).join(', ');
  }

  String _getSeasons(List<dynamic>? seasons) {
    if (seasons == null || seasons.isEmpty) return 'N/A';
    return '${seasons.length} temporada(s)';
  }
}
