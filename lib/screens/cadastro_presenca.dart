import 'package:flutter/material.dart';
import 'package:contador/data/database_helper.dart';
import 'package:contador/models/membro.dart';
import 'package:contador/models/presenca.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class CadastroPresenca extends StatefulWidget {
  @override
  _CadastroPresencaState createState() => _CadastroPresencaState();
}

class _CadastroPresencaState extends State<CadastroPresenca> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<Membro> membros = [];
  List<bool> presencas = [];
  List<DateTime> datas = [];
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Presença'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lista de Presença',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () {
                _mostrarDatePicker(context);
              },
              child: Row(
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 4),
                  Text(
                    _getCurrentDateFormatted(),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            isPortrait
                ? _buildVerticalMembros()
                : _buildHorizontalMembros(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _salvarPresencas();
        },
        tooltip: 'Salvar Presenças',
        child: Icon(Icons.save),
      ),
    );
  }

  Widget _buildVerticalMembros() {
    return Expanded(
      child: ListView.builder(
        itemCount: membros.length,
        itemBuilder: (context, index) {
          return _buildMembroTile(
            membros[index].foto,
            membros[index].nome,
            presencas[index],
                (value) {
              setState(() {
                presencas[index] = value!;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildHorizontalMembros() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: 1.0,
        children: List.generate(membros.length, (index) {
          return _buildMembroTile(
            membros[index].foto,
            membros[index].nome,
            presencas[index],
                (value) {
              setState(() {
                presencas[index] = value!;
              });
            },
          );
        }),
      ),
    );
  }

  Widget _buildMembroTile(
      String? fotoPath,
      String nome,
      bool isChecked,
      Function(bool?) onChanged,
      ) {
    return ListTile(
      leading: _buildFotoMembro(fotoPath),
      title: Text(nome),
      trailing: Checkbox(
        value: isChecked,
        onChanged: onChanged,
      ),
    );
  }

  void _carregarDados() async {
    List<Membro> listaMembros = await _databaseHelper.queryAllMembers();
    List<bool> listaPresencas = [];

    for (int i = 0; i < listaMembros.length; i++) {
      bool presencaExistente = await _databaseHelper.checkAttendanceExists(
        listaMembros[i].id!,
        currentDate,
      );

      listaPresencas.add(presencaExistente);
    }

    setState(() {
      membros = listaMembros;
      presencas = listaPresencas;
    });
  }

  void _mostrarDatePicker(BuildContext context) async {
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

      // Atualizar membros e presenças para a nova data
      _carregarDados();
    }
  }

  void _salvarPresencas() async {
    List<Attendance> presencasASalvar = [];

    for (int i = 0; i < membros.length; i++) {
      bool presencaExistente = await _databaseHelper.checkAttendanceExists(
        membros[i].id!,
        currentDate,
      );

      if (presencaExistente) {
        // A presença existe, apenas atualize a lista local
        // sem modificar a tabela
      } else {
        if (presencas[i]) {
          // A presença não existe, mas o checkbox está marcado, então adicione-a
          Attendance presenca = Attendance(
            memberId: membros[i].id!,
            date: DateTime(currentDate.year, currentDate.month, currentDate.day),
            present: true,
          );
          presencasASalvar.add(presenca);
        }
      }
    }

    for (var presenca in presencasASalvar) {
      await _databaseHelper.insertAttendance(presenca);
      print(
          'Presença inserida: ${presenca.id}, Membro ID: ${presenca.memberId}, Data: ${presenca.date}, Presente: ${presenca.present}');
    }

    _showSnackBar('Presenças salvas com sucesso!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFotoMembro(String? fotoPath) {
    return CircleAvatar(
      radius: 20,
      backgroundImage: fotoPath != null ? FileImage(File(fotoPath)) : null,
      child: fotoPath == null
          ? Icon(Icons.person, size: 40, color: Colors.white)
          : null,
    );
  }

  String _getCurrentDateFormatted() {
    return DateFormat('dd/MM/yyyy').format(currentDate);
  }
}

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