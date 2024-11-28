import 'package:http/http.dart' as http;
import 'dart:convert';

class TMDBApi {
  final String apiKey = 'cfb23f8a0328f93a763163ba28b486f0';
  final String baseUrl = 'https://api.themoviedb.org/3';

  // Método para buscar filmes populares
  Future<List<dynamic>> fetchPopularMovies({String language = 'pt-BR', int page = 1}) async {
    final url = Uri.parse('$baseUrl/movie/popular?api_key=cfb23f8a0328f93a763163ba28b486f0&language=$language&page=$page');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['results'];
      } else {
        throw Exception('Erro ao buscar filmes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  
  Future<Map<String, dynamic>> fetchMovieDetails(int movieId, {String language = 'pt-BR'}) async {
  final url = Uri.parse('$baseUrl/movie/$movieId?api_key=cfb23f8a0328f93a763163ba28b486f0&language=$language');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar detalhes do filme: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erro de conexão: $e');
  }
}


  // Método para buscar filmes por pesquisa
  Future<List<dynamic>> searchMovies(String query, {String language = 'pt-BR'}) async {
    final url = Uri.parse('$baseUrl/search/movie?api_key=cfb23f8a0328f93a763163ba28b486f0&language=$language&query=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['results'];
      } else {
        throw Exception('Erro ao buscar filmes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

 Future<Map<String, dynamic>> fetchSeriesDetails(int seriesId) async {
  final response = await http.get(
    Uri.parse('https://api.themoviedb.org/3/tv/$seriesId?api_key=cfb23f8a0328f93a763163ba28b486f0&language=pt-BR'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    print('Erro ao buscar série: ${response.statusCode}');
    throw Exception('Falha ao carregar os detalhes da série');
  }
}


  // Método para buscar séries populares
    Future<List<dynamic>> fetchPopularSeries() async {
      final response = await http.get(
        Uri.parse('$baseUrl/tv/popular?api_key=cfb23f8a0328f93a763163ba28b486f0&language=pt-BR&page=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'];
      } else {
        throw Exception('Erro ao buscar séries populares');
      }
    }
   // Método para buscar filmes recomendados
  Future<List<dynamic>> fetchRecommendedMovies(int movieId) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/movie/$movieId/recommendations?api_key=$apiKey&language=pt-BR'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'] ?? []; // Retorna a lista de recomendações
    } else {
      throw Exception('Erro ao buscar filmes recomendados');
    }
  }

  // Método para buscar séries recomendadas
  Future<List<dynamic>> fetchRecommendedSeries(int seriesId) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/tv/$seriesId/recommendations?api_key=$apiKey&language=pt-BR'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'] ?? []; // Retorna a lista de recomendações
    } else {
      throw Exception('Erro ao buscar séries recomendadas');
    }
  }
}


