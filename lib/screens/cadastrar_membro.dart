import 'package:flutter/material.dart';
import 'package:contador/data/database_helper.dart';
import 'package:contador/models/membro.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;


class CadastrarMembro extends StatefulWidget {
  @override
  _CadastrarMembroState createState() => _CadastrarMembroState();
}

class _CadastrarMembroState extends State<CadastrarMembro> {
  final TextEditingController _nomeController = TextEditingController();
  String? _fotoPath;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

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
              _fotoPath != null
                  ? Image.file(File(_fotoPath!))
                  : ElevatedButton(
                onPressed: () {
                  _escolherFoto();
                },
                child: Text('Escolher Foto'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _cadastrarMembro();
                },
                child: Text('Cadastrar'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _exibirValores();
                },
                child: Text('Exibir Valores'),
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
      // Copiar a foto para o diretório de documentos do aplicativo
      _fotoPath = await _copiarFotoParaDocumentos(pickedFile.path);

      setState(() {
        print('Caminho da foto escolhido: $_fotoPath');
      });
    } else {
      print('Nenhuma imagem selecionada.');
    }
  }

  Future<String> _copiarFotoParaDocumentos(String caminhoOriginal) async {
    final documentosDirectory = await getApplicationDocumentsDirectory();
    final nomeArquivo = path.basename(caminhoOriginal);
    final caminhoDestino = path.join(documentosDirectory.path, nomeArquivo);

    await File(caminhoOriginal).copy(caminhoDestino);

    return caminhoDestino;
  }




  void _cadastrarMembro() async {
    String nome = _nomeController.text;

    if (nome.isNotEmpty && _fotoPath != null) {
      Membro novoMembro = Membro(nome: nome, foto: _fotoPath);
      int idInserido = await _databaseHelper.insertMember(novoMembro);
      print('Membro cadastrado com ID: $idInserido');

      _nomeController.clear();
      setState(() {
        _fotoPath = null;
        print('Caminho da foto resetado para null.');
      });

      // Adicionar mensagem de sucesso
      _showSnackBar('Membro cadastrado com sucesso!');
    } else {
      // Exibir mensagem de erro, pois o nome e a foto são obrigatórios
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
