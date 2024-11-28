import 'package:flutter/material.dart';
import '../api/tmdb_api.dart';
import 'shared_list.dart';

// Tela de detalhes de filmes ou séries
class MovieDetailsScreen extends StatefulWidget {
  final int movieId; // ID único do filme ou série
  final String movieTitle; // Título do filme ou série
  final bool isMovie; // Define se é um filme (true) ou uma série (false)

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
  final TMDBApi api = TMDBApi(); // Instância da API do TMDB

  Map<String, dynamic>? movieDetails; // Detalhes do filme/série
  List<dynamic> relatedMovies = []; // Lista para armazenar recomendações
  bool isLoading = true; // Indica se os dados estão carregando
  late TabController _tabController; // Controlador para alternar entre abas

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Define duas abas
    fetchDetails(); // Chama a função para buscar os detalhes
  }

  // Busca detalhes do filme/série e recomendações
  Future<void> fetchDetails() async {
    try {
      final details = widget.isMovie
          ? await api
              .fetchMovieDetails(widget.movieId) // Busca detalhes do filme
          : await api
              .fetchSeriesDetails(widget.movieId); // Busca detalhes da série

      final recommendations = widget.isMovie
          ? await api.fetchRecommendedMovies(widget.movieId)
          : await api.fetchRecommendedSeries(widget.movieId);

      setState(() {
        movieDetails = details; // Atualiza os detalhes no estado
        relatedMovies = recommendations; // Atualiza as recomendações
        isLoading = false; // Indica que os dados foram carregados
      });
    } catch (e) {
      print('Erro ao buscar detalhes: $e');
      setState(() {
        isLoading = false; // Interrompe o carregamento em caso de erro
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para estilo
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white), // Botão de voltar
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Mostra indicador de carregamento
          : movieDetails == null
              ? Center(
                  child: Text(
                    'Erro ao carregar detalhes', // Mensagem de erro
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMovieBanner(), // Exibe o banner com pôster e descrição
                      _buildActionButtons(), // Botões de ação (Assista, Minha Lista)
                      SizedBox(height: 20),
                      _buildTabBar(), // Abas para "Assista Também" e "Detalhes"
                      SizedBox(height: 10),
                      _buildTabBarView(), // Conteúdo das abas
                    ],
                  ),
                ),
    );
  }

  // Exibe o banner do filme/série com pôster, título e descrição
  Widget _buildMovieBanner() {
    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(8.0), // Bordas arredondadas no pôster
            child: Image.network(
              'https://image.tmdb.org/t/p/w500${movieDetails!['poster_path']}', // URL do pôster
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Text(
            widget.movieTitle, // Título do filme/série
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.isMovie ? 'Filme' : 'Série', // Tipo do conteúdo
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            movieDetails!['overview'] ??
                'Descrição não disponível', // Descrição
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Botões para "Assista" e "Minha Lista"
  Widget _buildActionButtons() {
    final movieData = {
      'id': widget.movieId,
      'title': widget.movieTitle, // Dados básicos do filme/série
      'image': 'https://image.tmdb.org/t/p/w500${movieDetails!['poster_path']}',
    };

    // Verifica se o item já está na lista de favoritos
    bool isInList =
        userFavoriteList.any((movie) => movie['title'] == widget.movieTitle);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botão "Assista"
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {
            if (isInList) {
              setState(() {
                userFavoriteList.removeWhere(
                    (movie) => movie['title'] == widget.movieTitle);
              });

              final snackBar = SnackBar(
                content: Text('Removido da sua lista ao assistir'), // Mensagem
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          child: Row(
            children: [
              Icon(Icons.play_arrow),
              SizedBox(width: 5),
              Text('Assista'),
            ],
          ),
        ),
        SizedBox(width: 10),
        // Botão "Minha Lista"
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
                userFavoriteList.add(movieData); // Adiciona aos favoritos
              } else {
                userFavoriteList.removeWhere((movie) =>
                    movie['title'] ==
                    widget.movieTitle); // Remove dos favoritos
              }
            });
            final snackBar = SnackBar(
              content: Text(isInList
                  ? 'Removido da sua lista' // Mensagem de remoção
                  : 'Adicionado à sua lista!'), // Mensagem de adição
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: Row(
            children: [
              Icon(
                  isInList ? Icons.check : Icons.star_border), // Ícone dinâmico
              SizedBox(width: 5),
              Text(isInList ? 'Na Lista' : 'Minha Lista'),
            ],
          ),
        ),
      ],
    );
  }

  // Abas para "Assista Também" e "Detalhes"
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(text: 'ASSISTA TAMBÉM'), // Abas dinâmicas
        Tab(text: 'DETALHES'),
      ],
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
    );
  }

  // Conteúdo das abas
  Widget _buildTabBarView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildRelatedMovies(), // Recomendações
          _buildDetails(), // Detalhes técnicos
        ],
      ),
    );
  }

  // Outras funções como _buildRelatedMovies e _buildDetails já foram comentadas acima...

  // Exibe a lista de filmes ou séries relacionadas em formato de grade
  Widget _buildRelatedMovies() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Número de colunas na grade
          childAspectRatio: 2 / 3, // Proporção do aspecto dos itens
          crossAxisSpacing: 8, // Espaço horizontal entre itens
          mainAxisSpacing: 8, // Espaço vertical entre itens
        ),
        itemCount: relatedMovies.length, // Quantidade de itens a exibir
        itemBuilder: (context, index) {
          final movie = relatedMovies[index];

          return GestureDetector(
            onTap: () {
              // Navega para a tela de detalhes do item selecionado
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsScreen(
                    movieId: movie['id'], // ID do filme/série
                    movieTitle:
                        movie['title'] ?? movie['name'], // Nome do filme/série
                    isMovie: movie['media_type'] ==
                        'movie', // Determina se é filme ou série
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(8.0), // Arredonda as bordas do item
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${movie['poster_path']}', // URL da imagem do pôster
                fit: BoxFit.cover, // Ajusta a imagem para preencher o espaço
              ),
            ),
          );
        },
      ),
    );
  }

// Exibe os detalhes técnicos do filme ou série
  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Exibe uma linha para cada detalhe do filme/série
          _buildDetailRow('Título Original',
              movieDetails!['original_title'] ?? movieDetails!['name']),
          _buildDetailRow('Ano de Produção',
              movieDetails!['release_date']?.split('-').first),
          _buildDetailRow(
              'País', _getCountries(movieDetails!['production_countries'])),
          _buildDetailRow(
              'Duração',
              movieDetails!['runtime'] != null
                  ? '${movieDetails!['runtime']} minutos'
                  : 'N/A'),
          _buildDetailRow('Gênero', _getGenres(movieDetails!['genres'])),
          _buildDetailRow('Nota Média', '${movieDetails!['vote_average']}'),
          if (!widget.isMovie) ...[
            // Exibe informações adicionais apenas para séries
            _buildDetailRow(
                'Temporadas', _getSeasons(movieDetails!['seasons'])),
            _buildDetailRow('Número de Episódios',
                '${movieDetails!['number_of_episodes']}'),
          ],
        ],
      ),
    );
  }

// Cria uma linha com rótulo e valor para exibir informações de detalhes
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          text: '$label: ', // Rótulo da informação
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: value ??
                  'N/A', // Valor da informação (ou N/A caso esteja ausente)
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

// Obtém uma string formatada com os gêneros do filme/série
  String _getGenres(List<dynamic>? genres) {
    if (genres == null || genres.isEmpty)
      return 'N/A'; // Retorna N/A se não houver gêneros
    return genres
        .map((genre) => genre['name'])
        .join(', '); // Junta os nomes dos gêneros
  }

// Obtém uma string formatada com os países de produção
  String _getCountries(List<dynamic>? countries) {
    if (countries == null || countries.isEmpty)
      return 'N/A'; // Retorna N/A se não houver países
    return countries
        .map((country) => country['name'])
        .join(', '); // Junta os nomes dos países
  }

// Obtém uma string formatada com o número de temporadas
  String _getSeasons(List<dynamic>? seasons) {
    if (seasons == null || seasons.isEmpty)
      return 'N/A'; // Retorna N/A se não houver temporadas
    return '${seasons.length} temporada(s)'; // Retorna a contagem de temporadas
  }
}
