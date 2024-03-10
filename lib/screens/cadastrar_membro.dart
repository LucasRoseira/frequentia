import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:contador/models/membro.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:contador/services/firebase_service.dart';

class CadastrarMembro extends StatefulWidget {
  @override
  _CadastrarMembroState createState() => _CadastrarMembroState();
}

enum TipoMembro {
  Adolescentes,
  Casados,
  Noivos,
  Solteiros,
}

class _CadastrarMembroState extends State<CadastrarMembro> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataAniversarioController = TextEditingController();
  TipoMembro _tipoMembroSelecionado = TipoMembro.Adolescentes;
  final TextEditingController _enderecoController = TextEditingController();
  String? _fotoPath;
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference().child('membros');
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
            children: [
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _dataAniversarioController,
                decoration: InputDecoration(labelText: 'Data de Aniversário'),
              ),
              SizedBox(height: 16),
              // Adicionar o DropdownButton para o tipo de membro
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
                    child: Text(tipo.toString().split('.').last),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _enderecoController,
                decoration: InputDecoration(labelText: 'Endereço'),
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
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _exibirValores();
                },
                child: Text('Exibir Valores'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      print('Nenhuma imagem selecionada.');
    }
  }

  void _cadastrarMembro() async {
    String nome = _nomeController.text;
    String? dataAniversario = _dataAniversarioController.text;
    String endereco = _enderecoController.text;

    if (nome.isNotEmpty && _fotoPath != null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String fileName = path.basename(_fotoPath!);
      String absolutePath = path.join(appDocDir.path, fileName);

      await File(_fotoPath!).copy(absolutePath);

      // Upload da foto para o Firebase Storage
      UploadTask task = _storage
          .ref()
          .child('fotos/$_nomeController.jpg')
          .putFile(File(absolutePath));
      TaskSnapshot snapshot = await task;
      String photoURL = await snapshot.ref.getDownloadURL();

      Membro novoMembro = Membro(
        nome: nome,
        foto: photoURL,
        dataAniversario: dataAniversario != null ? DateTime.tryParse(dataAniversario) : null,
        tipoMembro: _tipoMembroSelecionado.toString().split('.').last,
        endereco: endereco,
      );

      await _firebaseService.cadastrarMembro(novoMembro);

      _nomeController.clear();
      _dataAniversarioController.clear();
      _enderecoController.clear();
      _fotoPath = null;

      _showSnackBar('Membro cadastrado com sucesso!');
    } else {
      print('Nome e foto do membro são obrigatórios.');
    }
  }


  void _exibirValores() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Valores dos Campos'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nome: ${_nomeController.text}'),
              Text('Data de Aniversário: ${_dataAniversarioController.text}'),
              Text('Tipo de Membro: ${_tipoMembroSelecionado.toString().split('.').last}'),
              Text('Endereço: ${_enderecoController.text}'),
              Text('Caminho da Foto: $_fotoPath'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
