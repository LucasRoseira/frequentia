import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contador/models/membro.dart';
import 'package:contador/models/presenca.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListarPresencas(),
    );
  }
}

class ListarPresencas extends StatefulWidget {
  @override
  _ListarPresencasState createState() => _ListarPresencasState();
}

class _ListarPresencasState extends State<ListarPresencas> {
  final DatabaseReference _presencasReference =
  FirebaseDatabase.instance.reference().child('presencas');

  List<String> datas = [];
  List<Membro> membros = [];
  List<Membro> membrosFiltrados = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDatasPresencas();
    _carregarMembros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listar Presenças'),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/acesso.jpg"),
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.02),
                      BlendMode.dstATop,
                        ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {
                    _filtrarMembros(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Filtrar por nome',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildMatrizPresencas(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatrizPresencas() {
    return DataTable(
      columnSpacing: 20.0,
      columns: [
        DataColumn(
          label: Text(
            'Nome',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          onSort: (columnIndex, ascending) {
            setState(() {
              membros.sort((a, b) => ascending
                  ? a.nome.compareTo(b.nome)
                  : b.nome.compareTo(a.nome));
            });
          },
        ),
        DataColumn(
          label: Text(
            'Presenças',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        DataColumn(
          label: Text(
            'Porcentagem',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...datas.map(
              (data) => DataColumn(
            label: Text(
              data,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
      rows: membrosFiltrados.map(
            (membro) {
          List<DataCell> cells = [
            DataCell(
              Text(
                membro.nome,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataCell(
              FutureBuilder<Map<String, dynamic>>(
                future: _contarPresencas(membro.id ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro ao contar presenças');
                  } else {
                    int presencas = snapshot.data?['presencas'] ?? 0;

                    return Text('$presencas');
                  }
                },
              ),
            ),
            DataCell(
              FutureBuilder<Map<String, dynamic>>(
                future: _contarPresencas(membro.id ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro ao contar presenças');
                  } else {
                    double porcentagem =
                        snapshot.data?['porcentagem'] ?? 0.0;

                    return Text('${porcentagem.toStringAsFixed(2)}%');
                  }
                },
              ),
            ),
          ];

          cells.addAll(
            datas.map(
                  (data) {
                return DataCell(
                  FutureBuilder<bool>(
                    future: _verificarPresenca(membro.id ?? '', data),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Erro ao verificar presença');
                      } else {
                        bool presente = snapshot.data ?? false;
                        return Text(
                          presente ? '✓' : 'X',
                          style: TextStyle(
                            fontSize: 24,
                            color: presente ? Colors.black : Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );

          return DataRow(cells: cells);
        },
      ).toList(),
    );
  }

  Future<void> _carregarDatasPresencas() async {
    try {
      DatabaseEvent event = await _presencasReference.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic>? values =
        snapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<String> datasPresencas = [];

          values.forEach((key, value) {
            datasPresencas.add(key);
          });

          datasPresencas.sort((a, b) =>
              _parseDate(b).compareTo(_parseDate(a))); // Ordena as datas em ordem decrescente

          setState(() {
            datas = datasPresencas;
          });
        }
      }
    } catch (error) {
      print('Erro ao carregar datas de presenças: $error');
    }
  }

  Future<void> _carregarMembros() async {
    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .reference()
          .child('membros')
          .once();
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

  Future<Map<String, dynamic>> _contarPresencas(String memberId) async {
    int presencasTotais = 0;

    // Cria uma lista de Futures que representam o cálculo de presença para cada data
    List<Future<bool>> futures = datas.map((data) => _verificarPresenca(memberId, data)).toList();

    // Aguarda a conclusão de todas as Futures
    List<bool> presencas = await Future.wait(futures);

    // Calcula o total de presenças
    for (bool presente in presencas) {
      if (presente) {
        presencasTotais++;
      }
    }

    double porcentagem = (presencasTotais / datas.length) * 100;

    return {
      'presencas': presencasTotais,
      'porcentagem': porcentagem,
    };
  }


  Future<bool> _verificarPresenca(String memberId, String date) async {
    try {
      DatabaseEvent event =
      await _presencasReference.child(date).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        Map<dynamic, dynamic> values =
        snapshot.value as Map<dynamic, dynamic>;

        // Verifica se a data existe nos valores
        if (values.containsKey('members')) {
          List<dynamic>? membersPresentes =
          values['members'] as List<dynamic>?;

          // Verifica se o memberId está na lista de membros presentes
          return membersPresentes?.contains(memberId) ?? false;
        }
      }
    } catch (error) {
      print('Erro ao verificar presença: $error');
    }

    return false;
  }

  DateTime _parseDate(String date) {
    // Verifica se a data é nula ou vazia
    if (date == null || date.isEmpty) {
      // Retorna uma data padrão ou lança uma exceção, dependendo do seu caso
      return DateTime.now();
    }

    // Parse a string in the format dd-MM-yyyy to DateTime
    return DateFormat("dd-MM-yyyy").parse(date);
  }

  void _filtrarMembros(String nome) {
    setState(() {
      membrosFiltrados = membros
          .where((membro) =>
          membro.nome.toLowerCase().contains(nome.toLowerCase()))
          .toList();
    });
  }
}
