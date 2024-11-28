import 'package:flutter/material.dart';
import 'dart:async'; 
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
      home: SplashScreenWrapper(),
    );
  }
}

// Wrapper para gerenciar a navegação da SplashScreen
class SplashScreenWrapper extends StatefulWidget {
  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    // Temporizador para trocar para a tela principal após 3 segundos
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(_createFadeRoute());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Exibe a tela de splash
  }

  // Função para criar a animação de transição com fade
  PageRouteBuilder _createFadeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MainScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0); 
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        animation.drive(tween);

        // Retorna uma animação de fade
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

// SplashScreen: Tela de carregamento inicial
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/splash.png',  
          width: double.infinity,  
          height: double.infinity, 
          fit: BoxFit.cover, 
        ),
      ),
    );
  }
}

// MainScreen: Tela principal com navegação
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
