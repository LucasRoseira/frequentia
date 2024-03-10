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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildMatrizPresencas(),
        ),
      ),
    );
  }

  Widget _buildMatrizPresencas() {
    return DataTable(
      columns: [
        DataColumn(label: Text('Nome')),
        DataColumn(label: Text('Porcentagem')),
        ...datas.map((data) => DataColumn(label: Text(data))),
      ],
      rows: membros.map((membro) {
        return DataRow(
          cells: [
            DataCell(Text(membro.nome)),
            DataCell(
              FutureBuilder<double>(
                future: _calcularPorcentagemPresenca(membro.id ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro ao calcular porcentagem');
                  } else {
                    double porcentagem = snapshot.data ?? 0.0;
                    return Text('${porcentagem.toStringAsFixed(2)}%');
                  }
                },
              ),
            ),
            ...datas.map((data) {
              return DataCell(
                FutureBuilder<bool>(
                  future: _verificarPresenca(membro.id ?? '', data ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
            }),
          ],
        );
      }).toList(),
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

          setState(() {
            membros = listaMembros;
          });
        }
      }
    } catch (error) {
      print('Erro ao carregar membros: $error');
    }
  }

  Future<double> _calcularPorcentagemPresenca(String memberId) async {
    int presencasTotais = 0;

    for (String data in datas) {
      bool presente = await _verificarPresenca(memberId, data);
      if (presente) {
        presencasTotais++;
      }
    }

    double porcentagem = (presencasTotais / datas.length) * 100;
    return porcentagem;
  }

  Future<bool> _verificarPresenca(String memberId, String? date) async {
    try {
      DatabaseEvent event =
      await _presencasReference.child(date ?? '').once();
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
}
