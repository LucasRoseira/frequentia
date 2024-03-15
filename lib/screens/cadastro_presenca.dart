import 'package:flutter/material.dart';
import 'package:contador/models/membro.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importe este pacote

void main() {
  initializeDateFormatting('pt_BR', null).then((_) { // Inicialize os dados de localização antes de rodar o app
    runApp(MyApp());
  });
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ], // Use DefaultMaterialLocalizations.delegate instead of GlobalMaterialLocalizations.delegate
      supportedLocales: [
        const Locale('pt'), // Specify the supported locales
      ],
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
  final DatabaseReference _presencasReference =
  FirebaseDatabase.instance.reference().child('presencas');
  List<Membro> membros = [];
  Map<String, bool> presencas = {};
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carregarMembros();
    _carregarPresencas(_formatDate(currentDate));
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
        title: Text('Cadastro de Presença'),
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
                          Text('${membros[index].nome}'),
                          Checkbox(
                            value: presencas[membros[index].id] ?? false,
                            onChanged: (value) {
                              if (membros[index].id != null) {
                                _atualizarPresenca(
                                  membros[index].id!,
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

          listaMembros.sort((a, b) => a.nome.compareTo(b.nome));

          setState(() {
            membros = listaMembros;

            // Carregar presenças para cada membro
            membros.forEach((membro) {
              _carregarPresencasMembro(membro.id!);
            });
          });
        }
      }
    } catch (error) {
      print('Erro ao carregar membros: $error');
    }
  }

  Future<void> _carregarPresencas(String formattedDate) async {
    try {
      DatabaseEvent event =
      await _presencasReference.child(formattedDate).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

        Map<String, bool> loadedPresencas = {};

        membros.forEach((membro) {
          String memberId = membro.id ?? '';
          bool hasAttendance = values['members']?.contains(memberId) ?? false;

          print('Membro: $memberId, Tem Presença: $hasAttendance');

          loadedPresencas[memberId] = hasAttendance;
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
          emptyPresencas[membro.id ?? ''] = false;
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

  Future<void> _carregarPresencasMembro(String memberId) async {
    try {
      String formattedDate = _formatDate(currentDate);

      DatabaseEvent event =
      await _presencasReference.child(formattedDate).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is Map) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

        bool hasAttendance = values['members']?.contains(memberId) ?? false;

        // Atualizar presença do membro específico
        setState(() {
          presencas[memberId] = hasAttendance;
        });
      }
    } catch (error) {
      print('Erro ao carregar presenças do membro: $error');
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
      locale: const Locale("pt", "BR"), // Definindo o idioma como português do Brasil
    );

    if (pickedDate != null && pickedDate != currentDate) {
      String formattedDate = _formatDate(pickedDate);

      // Carregar presenças e atualizar state
      await _carregarPresencas(formattedDate);

      setState(() {
        currentDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }


}
