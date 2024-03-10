import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contador/screens/cadastrar_membro.dart';
import 'package:contador/screens/listar_membros.dart';
import 'package:contador/screens/cadastro_presenca.dart';
import 'package:contador/widgets/menu_lateral.dart';
import 'package:contador/screens/splashscreen.dart';
import 'package:contador/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();

  // Inicialize o Firebase com as configurações do seu arquivo firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext contegtfxt) {
    return MaterialApp(
      title: 'Controle Presença CEDRINHO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen).copyWith(
          background: Colors.white,
        ),
      ),
      home: MyHomePage(title: 'Controle Presença CEDRINHO'),
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

  void _checkFirebaseConnection() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Conexão com o Firebase bem-sucedida!');
    } catch (e) {
      print('Erro na conexão com o Firebase: $e');
    }
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
              'assets/acesso.jpg',
              height: 200,
              width: 200,
            ),
            Image.asset(
              'assets/logo_cedrinho.jpg',
              height: 200,
              width: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkFirebaseConnection,
              child: Text('Verificar Conexão com Firebase'),
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
