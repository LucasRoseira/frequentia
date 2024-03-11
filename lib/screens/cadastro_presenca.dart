import 'package:flutter/material.dart';
import 'package:contador/models/membro.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CadastroPresenca(),
    );
  }
}

class CadastroPresenca extends StatefulWidget {
  @override
  _CadastroPresencaState createState() => _CadastroPresencaState();
}

class _CadastroPresencaState extends State<CadastroPresenca> {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference().child('membros');
  List<Membro> membros = [];
  List<Membro> membrosFiltrados = [];
  Map<String, bool> presencas = {};
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carregarMembros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Presença'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
          ),
          InkWell(
            onTap: () {
              _mostrarDatePicker(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today),
                SizedBox(width: 4),
                Text(
                  _formatDate(currentDate),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: membros.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 16), // Ajusta o espaçamento
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${membros[index].nome}'),
                      Checkbox(
                        value: presencas[membros[index].id] ?? false,
                        onChanged: (value) {
                          setState(() {
                            presencas[membros[index].id!] = value!;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _mostrarDatePicker(context);
        },
        tooltip: 'Selecionar Data',
        child: Icon(Icons.calendar_today),
      ),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () {
            _salvarPresencas();
          },
          child: Text('Salvar Presenças'),
        ),
      ],
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop, // Muda a posição do FAB para o topo
    );
  }

  Future<void> _carregarMembros() async {
    try {
      DatabaseEvent event =
      await FirebaseDatabase.instance.reference().child('membros').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic>? values =
        snapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<Membro> listaMembros = [];

          values.forEach((key, value) {
            listaMembros.add(
              Membro(
                id: key,
                nome: value['nome'],
                dataAniversario: value['dataAniversario'] != null
                    ? DateTime.parse(value['dataAniversario'])
                    : null,
                tipoMembro: value['tipoMembro'],
                endereco: value['endereco'],
              ),
            );
          });

          listaMembros.sort((a, b) =>
              a.nome.compareTo(b.nome)); // Ordena os membros alfabeticamente

          setState(() {
            membros = listaMembros;
            membrosFiltrados = membros;
          });
        }
      }
    } catch (error) {
      print('Erro ao carregar membros: $error');
    }
  }

  void _filtrarMembros(String nome) {
    setState(() {
      membrosFiltrados = membros
          .where((membro) =>
          membro.nome.toLowerCase().contains(nome.toLowerCase()))
          .toList();
    });
  }

  Future<void> _salvarPresencas() async {
    try {
      List<String> membrosPresentes = [];

      for (var entry in presencas.entries) {
        if (entry.value) {
          membrosPresentes.add(entry.key);
        }
      }

      DatabaseReference presencasReference =
      FirebaseDatabase.instance.reference().child('presencas');

      // Formatando a data no formato desejado
      String formattedDate =
      DateFormat('dd-MM-yyyy').format(currentDate);

      // Salvando as presenças no Firebase
      await presencasReference.child(formattedDate).set({
        'data': formattedDate,
        'members': membrosPresentes,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Presenças salvas com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Erro ao salvar presenças: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar presenças. Tente novamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _mostrarDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
