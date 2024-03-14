import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CadastroPresencaConvivio(),
    );
  }
}

class CadastroPresencaConvivio extends StatefulWidget {
  @override
  _CadastroPresencaConvivioState createState() =>
      _CadastroPresencaConvivioState();
}

class _CadastroPresencaConvivioState extends State<CadastroPresencaConvivio> {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference().child('membros');
  final DatabaseReference _presencasReference =
  FirebaseDatabase.instance.reference().child('presencas');
  List<String> membros = [];
  Map<String, bool> presencas = {};
  String selectedConvivio = ''; // Adiciona a variável para armazenar o convívio selecionado
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carregarMembros();
  }

  Future<bool> _verificarPresencaCadastro(
      String memberId, String formattedDate) async {
    try {
      DatabaseEvent event =
      await _presencasReference.child(formattedDate).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

        // Verifica se a data existe nos valores
        if (values.containsKey('members')) {
          List<dynamic>? membersPresentes =
          values['members'] as List<dynamic>?;

          // Verifica se o memberId está na lista de membros presentes
          bool hasAttendance =
              membersPresentes?.contains(memberId) ?? false;

          print(
              'Verificar Presença - Membro: $memberId, Data: $formattedDate, Presente: $hasAttendance');

          return hasAttendance;
        }
      }
    } catch (error) {
      print('Erro ao verificar presença: $error');
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Presença - Convívio'),
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
          DropdownButton<String>(
            value: selectedConvivio,
            items: membros.map((String convivio) {
              return DropdownMenuItem<String>(
                value: convivio,
                child: Text(convivio),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedConvivio = newValue!;
                _carregarPresencas(_formatDate(currentDate), selectedConvivio);
              });
            },
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  presencas.forEach((key, value) {
                    presencas[key] = !value;
                  });
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text('Marcar/Desmarcar Todas as Presenças'),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: membros.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${membros[index]}'),
                      Checkbox(
                        value: presencas[membros[index]] ?? false,
                        onChanged: (value) {
                          if (membros[index] != null) {
                            _atualizarPresenca(
                              membros[index],
                              _formatDate(currentDate),
                              value ?? false,
                            );
                          }
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
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _salvarPresencas();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text('Salvar Presenças'),
          ),
        ),
      ],
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  void _marcarTodasPresencas() {
    setState(() {
      presencas.forEach((key, value) {
        presencas[key] = true;
      });
    });
  }

  Future<void> _carregarMembros() async {
    try {
      DatabaseEvent event = await _databaseReference.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic>? values =
        snapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<String> listaMembros = [];

          values.forEach((key, value) {
            listaMembros.add(value['convivio'] as String); // Adiciona o convívio em vez do ID
          });

          // Remove os convívios duplicados
          listaMembros = listaMembros.toSet().toList();

          listaMembros.sort(); // Ordena os convívios alfabeticamente

          setState(() {
            membros = listaMembros;
          });
        }
      }
    } catch (error) {
      print('Erro ao carregar membros: $error');
    }
  }

  Future<void> _carregarPresencas(String formattedDate, String convivio) async {
    try {
      DatabaseEvent event =
      await _presencasReference.child(formattedDate).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

        Map<String, bool> loadedPresencas = {};

        membros.forEach((membro) {
          bool hasAttendance = values['members']?.contains(membro) ?? false;

          print('Membro: $membro, Tem Presença: $hasAttendance');

          loadedPresencas[membro] = hasAttendance;
        });

        print('Presenças carregadas: $loadedPresencas');

        // Atualizar presenças uma vez após o loop
        setState(() {
          presencas = loadedPresencas;
        });

        print('Presenças no estado após atualização: $presencas');
      } else {
        // Se não houver presenças para a data, definir todos os checkboxes como falso
        Map<String, bool> emptyPresencas = {};
        membros.forEach((membro) {
          emptyPresencas[membro] = false;
        });

        setState(() {
          presencas = emptyPresencas;
        });

        print(
            'Nenhuma presença para a data. Presenças definidas como falsas: $presencas');
      }
    } catch (error) {
      print('Erro ao carregar presenças: $error');
    }
  }

  Future<void> _atualizarPresenca(
      String memberId, String formattedDate, bool value) async {
    try {
      bool hasAttendance =
      await _verificarPresencaCadastro(memberId, formattedDate);

      // Se o estado atual for diferente do valor desejado, atualize
      if (hasAttendance != value) {
        setState(() {
          presencas[memberId] = value;
        });
      }
    } catch (error) {
      print('Erro ao atualizar presença: $error');
    }
  }

  Future<void> _salvarPresencas() async {
    try {
      List<String> membrosPresentes = [];

      for (var entry in presencas.entries) {
        if (entry.value) {
          membrosPresentes.add(entry.key);
        }
      }

      String formattedDate = _formatDate(currentDate);

      await _presencasReference.child(formattedDate).set({
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
      String formattedDate = _formatDate(pickedDate);

      // Carregar presenças e atualizar state
      await _carregarPresencas(formattedDate, selectedConvivio);

      setState(() {
        currentDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }
}
