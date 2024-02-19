import 'package:flutter/material.dart';
import 'package:contador/screens/cadastrar_membro.dart';
import 'package:contador/screens/listar_membros.dart';
import 'package:contador/screens/cadastro_presenca.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contador/widgets/menu_lateral.dart';
import 'package:contador/stores/presenca_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Presença CEDRINHO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(background: Colors.white), // Set the background color directly
      ),
      home: const MyHomePage(title: 'Controle Presença CEDRINHO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _openCadastroMembros() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastrarMembro()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: MenuLateral(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo_cedrinho.jpg',
              height: 200,
              width: 200,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCadastroMembros,
        tooltip: 'Cadastrar Membros',
        child: Icon(Icons.add),
      ),
    );
  }
}
