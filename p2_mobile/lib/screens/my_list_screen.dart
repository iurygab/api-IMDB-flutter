// Importa o pacote Flutter para construção de interfaces.
import 'package:flutter/material.dart';

// Importa uma lista global que contém os itens favoritos do usuário.
import 'shared_list.dart'; 

// Importa a tela de detalhes do filme, que será usada ao clicar em um item.
import 'movie_details_screen.dart'; 

// Define a classe da tela principal, que é um widget sem estado (StatelessWidget).
class MyListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Define o fundo da tela como preto.
      backgroundColor: Colors.black,

      // Cria uma barra de app (AppBar) na parte superior da tela.
      appBar: AppBar(
        // Define o fundo da AppBar como preto.
        backgroundColor: Colors.black,
        // Define o título da AppBar como "Minha lista".
        title: Text('Minha lista'),
      ),

      // Define o corpo da tela.
      body: userFavoriteList.isEmpty // Verifica se a lista de favoritos está vazia.
          ? Center(
              // Exibe uma mensagem centralizada se a lista estiver vazia.
              child: Text(
                'Sua lista está vazia.', // Texto da mensagem.
                style: TextStyle(
                  color: Colors.white, // Cor branca para o texto.
                  fontSize: 18, // Tamanho da fonte.
                ),
              ),
            )
          : GridView.builder(
              // Adiciona um espaçamento nas bordas do grid.
              padding: const EdgeInsets.all(8.0),
              
              // Define a estrutura do grid com um número fixo de colunas.
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Define 3 colunas no grid.
                crossAxisSpacing: 8.0, // Espaçamento horizontal entre os itens.
                mainAxisSpacing: 8.0, // Espaçamento vertical entre os itens.
              ),
              
              // Define o número de itens no grid com base na lista de favoritos.
              itemCount: userFavoriteList.length,
              
              // Define como os itens serão construídos.
              itemBuilder: (context, index) {
                final item = userFavoriteList[index]; // Obtém o item atual da lista.

                return GestureDetector(
                  // Define a ação ao tocar em um item.
                  onTap: () {
                    // Certifique-se de que o ID está presente e correto
                    if (!item.containsKey('id') || item['id'] == null) {
                      print(item.toString());
                      print('Erro: ID não encontrado para o item: $item');
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Navega para a tela de detalhes do filme.
                        builder: (context) => MovieDetailsScreen(
                          movieId: item['id'] as int, // Passa o ID correto do filme.
                          movieTitle: item['title']!, // Título do filme, obtido do item.
                          isMovie: item['media_type'] == 'movie', // Define se é um filme ou uma série.
                        ),
                      ),
                    );
                  },

                  // Adiciona bordas arredondadas ao redor da imagem do item.
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0), // Define o raio das bordas.
                    
                    // Exibe a imagem do item a partir de uma URL.
                    child: Image.network(
                      item['image']!, // URL da imagem do item.
                      fit: BoxFit.cover, // Ajusta a imagem para cobrir o espaço disponível.
                    ),
                  ),
                );
              },
            ),
    );
  }
}
