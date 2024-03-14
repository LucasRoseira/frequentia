import 'dart:async';
import 'package:flutter/material.dart';
import 'package:contador/main.dart'; // Importe o arquivo onde MyHomePage está definido

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Aguarda 3 segundos e navega para a próxima tela
    Timer(
      Duration(seconds: 4),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()), // Use MyApp para acessar MyHomePage
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ou a cor desejada
      body: Center(
        child: Image.asset(
          'assets/logo_cedrinho.jpg',
          height: 200,
          width: 200,
        ),
      ),
    );
  }
}
