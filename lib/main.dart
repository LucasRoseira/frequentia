import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:contador/widgets/menu_lateral.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:contador/models/membro.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'package:flutter/cupertino.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();

  // Inicialize o Firebase com as configurações do seu arquivo firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Presença CEDRINHO',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ListarMembros(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ], // Use DefaultMaterialLocalizations.delegate instead of GlobalMaterialLocalizations.delegate
      supportedLocales: [
        const Locale('pt'), // Specify the supported locales
      ],
    );
  }
}

class ListarMembros extends StatefulWidget {
  @override
  _ListarMembrosState createState() => _ListarMembrosState();
}

class _ListarMembrosState extends State<ListarMembros> {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference().child('membros');
  List<Membro> membros = [];
  List<Membro> membrosAniversariantes = [];
  TextEditingController _searchController = TextEditingController();
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1);
    _startAutoScroll();
    _carregarNomesMembros();

  }

  Future<void> _carregarNomesMembros() async {
    try {
      DatabaseEvent event = await _databaseReference.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic>? values =
        snapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<Membro> listaMembros = [];

          for (var entry in values.entries) {
            var key = entry.key;
            var value = entry.value;

            try {
              DatabaseEvent event =
              await _databaseReference.child(key).once();
              DataSnapshot snapshot = event.snapshot;

              if (snapshot.value != null) {
                Map<dynamic, dynamic>? data =
                snapshot.value as Map<dynamic, dynamic>?;

                if (data != null) {
                  listaMembros.add(
                    Membro(
                      id: key,
                      nome: value['nome'],
                      foto: data['foto'],
                      dataAniversario: data['dataAniversario'] != null
                          ? DateTime.parse(data['dataAniversario'])
                          : null,
                      tipoMembro: data['tipoMembro'],
                      endereco: data['endereco'],
                    ),
                  );
                }
              }
            } catch (error) {
              print('Erro ao carregar dados do membro: $error');
            }
          }

          // Ordena os membros pelo nome
          listaMembros.sort((a, b) => a.nome.compareTo(b.nome));

          setState(() {
            membros = listaMembros;
            membrosAniversariantes = _filtrarMembrosAniversariantes(listaMembros);
          });
        }
      }
    } catch (error) {
      print('Erro ao carregar membros: $error');
    }
  }

  List<Membro> _filtrarMembrosAniversariantes(List<Membro> membros) {
    DateTime now = DateTime.now();
    int currentMonth = now.month;

    return membros.where((membro) => membro.dataAniversario?.month == currentMonth).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controle Presença CEDRINHO'),
      ),
      drawer: MenuLateral(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCarrossel(),
            SizedBox(height: 10),
            _buildAniversariantesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarrossel() {
    return SizedBox(
      height: 200,
      child: PageView(
        controller: _pageController,
        children: [
          Image.asset('assets/logo_cedrinho.jpg'),
          Image.asset('assets/acesso.jpg'),
        ],
      ),
    );
  }



  void _filtrarMembros(String query) {
    setState(() {
      membrosAniversariantes = membros
          .where((membro) =>
          membro.nome.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildAniversariantesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Aniversariantes do Mês',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24, // Altere o tamanho da fonte conforme necessário
          ),
        ),
        SizedBox(height: 10),
        ...membrosAniversariantes.map((membro) {
          return _buildBirthdayCard(
            membro.nome,
            _formatDate(membro.dataAniversario),
            membro.foto, // Passa o caminho da foto do membro
          );
        }).toList(),
      ],
    );
  }




  Widget _buildBirthdayCard(String name, String birthday, String? fotoPath) {
    return Card(
      child: ListTile(
        leading: _buildFotoMembro(fotoPath), // Exibe a foto do membro
        title: Text(name),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Aniversário em $birthday'),
            Icon(Icons.cake), // Ícone de bolo
          ],
        ),
      ),
    );
  }


  Widget _buildFotoMembro(String? fotoPath) {
    return CircleAvatar(
      radius: 30,
      backgroundImage: fotoPath != null
          ? NetworkImage(fotoPath)
          : null,
      child: fotoPath == null
          ? Icon(Icons.person, size: 60, color: Colors.white)
          : null,
    );
  }



  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
  }

  void _startAutoScroll() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }
}
