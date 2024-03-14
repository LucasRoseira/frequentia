import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:contador/models/membro.dart';
import 'package:contador/models/convivio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:contador/services/firebase_service.dart';
import 'package:intl/intl.dart';

class CadastrarMembro extends StatefulWidget {
  @override
  _CadastrarMembroState createState() => _CadastrarMembroState();
}

enum TipoMembro {
  Adolescente,
  Casado,
  Noivo,
  Solteiro,
}

class _CadastrarMembroState extends State<CadastrarMembro> {
  final TextEditingController _nomeController = TextEditingController();
  DateTime? _dataAniversario;
  TipoMembro _tipoMembroSelecionado = TipoMembro.Adolescente;
  final TextEditingController _enderecoController = TextEditingController();
  String? _fotoPath;
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference().child('membros');
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> _convivios = []; // Lista de convívios
  final TextEditingController _convivioController = TextEditingController();
  String? _convivioIdSelecionado;

  // Variáveis para armazenar os convívios disponíveis
  List<String> _nomesConvivios = [];
  Map<String, String> _idConvivios = {};
  List<String> datas = [];
  List<Convivio> convivios = [];

  @override
  void initState() {
    super.initState();
    _carregarConvivios(); // Carrega os convívios ao iniciar a tela
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Membro'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => _mostrarDatePicker(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: _dataAniversario != null
                          ? _formatDate(_dataAniversario!)
                          : '',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Data de Aniversário',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado Civil',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButton<TipoMembro>(
                    value: _tipoMembroSelecionado,
                    onChanged: (TipoMembro? newValue) {
                      setState(() {
                        _tipoMembroSelecionado = newValue!;
                      });
                    },
                    items: TipoMembro.values.map((TipoMembro tipo) {
                      return DropdownMenuItem<TipoMembro>(
                        value: tipo,
                        child: Text(
                          tipo.toString().split('.').last,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Campo de convívio como um DropdownButton
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Convívio',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    child: DropdownButton<String>(
                      value: _nomesConvivios.isNotEmpty ? _nomesConvivios[0] : null, // Usando o primeiro item como valor inicial padrão
                      onChanged: (String? newValue) {
                        setState(() {
                          _convivioController.text = newValue!;
                          // Recuperar o ID correspondente ao nome do convívio selecionado
                          String? convivioId = _idConvivios[newValue];
                          // Armazenar o ID do convívio para uso ao cadastrar o membro
                          _convivioIdSelecionado = convivioId;
                        });
                      },
                      isExpanded: true,
                      items: _nomesConvivios.map((String nomeConvivio) {
                        return DropdownMenuItem<String>(
                          value: nomeConvivio,
                          child: Text(
                            nomeConvivio,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),
              TextField(
                controller: _enderecoController,
                decoration: InputDecoration(
                  labelText: 'Endereço',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              _fotoPath != null
                  ? Image.file(File(_fotoPath!))
                  : ElevatedButton(
                onPressed: () {
                  _escolherFoto();
                },
                child: Text('Escolher Foto'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _cadastrarMembro();
                },
                child: Text('Cadastrar'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _carregarConvivios() async {
    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .reference()
          .child('convivios')
          .once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic>? values =
        snapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<String> nomesConvivios = [];
          Map<String, String> idConvivios = {}; // Mapa de ID de convívios
          values.forEach((key, value) {
            nomesConvivios.add(value['nome']);
            idConvivios[value['nome']] = key; // Mapeia o ID pelo nome
          });
          setState(() {
            _nomesConvivios = nomesConvivios;
            _idConvivios = idConvivios; // Atualiza o mapa de ID de convívios
          });
        }
      }
    } catch (error) {
      print('Erro ao recuperar nomes dos convívios: $error');
    }
  }

  Future<void> _mostrarDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dataAniversario ?? DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _dataAniversario) {
      setState(() {
        _dataAniversario = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _escolherFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _fotoPath = pickedFile.path;
        print('Caminho da foto escolhido: $_fotoPath');
      });
    } else {
      _showSnackBar('Nenhuma imagem selecionada.');
    }
  }

  void _cadastrarMembro() async {
    String nome = _nomeController.text;
    String endereco = _enderecoController.text;
    String? convivioId = _convivioIdSelecionado;

    if (nome.isNotEmpty && _fotoPath != null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String fileName = path.basename(_fotoPath!);
      String absolutePath = path.join(appDocDir.path, fileName);

      await File(_fotoPath!).copy(absolutePath);

      UploadTask task = _storage
          .ref()
          .child('fotos/$_nomeController.jpg')
          .putFile(File(absolutePath));
      TaskSnapshot snapshot = await task;
      String photoURL = await snapshot.ref.getDownloadURL();

      Membro novoMembro = Membro(
        nome: nome,
        foto: photoURL,
        dataAniversario: _dataAniversario,
        tipoMembro: _tipoMembroSelecionado.toString().split('.').last,
        endereco: endereco,
        convivio: convivioId, // Utiliza o ID do convívio
      );

      await _firebaseService.cadastrarMembro(novoMembro);

      _nomeController.clear();
      _dataAniversario = null;
      _enderecoController.clear();
      _convivioController.clear();
      _fotoPath = null;

      _showSnackBar('Membro cadastrado com sucesso!');
    } else {
      _showSnackBar('Nome e foto do membro são obrigatórios.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
