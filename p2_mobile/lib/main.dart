import 'package:flutter/material.dart';
import './screens/movie_list_screen.dart';
import './screens/my_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    MovieListScreen(), // Tela inicial
    MyListScreen(),    // Tela "Minha Lista"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex], // Mostra a tela baseada no índice
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index; // Atualiza o índice ao clicar
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Minha lista'),
        ],
      ),
    );
  }
}
