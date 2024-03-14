import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditarConvivioScreen extends StatefulWidget {
  final Map<String, dynamic> convivio;

  EditarConvivioScreen({required this.convivio});

  @override
  _EditarConvivioScreenState createState() => _EditarConvivioScreenState();
}

class _EditarConvivioScreenState extends State<EditarConvivioScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _diaController = TextEditingController();
  final TextEditingController _responsaveisController =
  TextEditingController(); // Novo campo para os responsáveis

  final DatabaseReference _conviviosReference =
  FirebaseDatabase.instance.reference().child('convivios');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _novaFoto;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.convivio['nome'];
    _enderecoController.text = widget.convivio['endereco'];
    _diaController.text = widget.convivio['dia'];
    _carregarResponsaveis(); // Carregar os responsáveis ao iniciar a tela
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Convívio'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 90,
              backgroundImage: NetworkImage(widget.convivio['foto']),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _selecionarNovaFoto,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Convívio',
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _enderecoController,
              decoration: InputDecoration(
                labelText: 'Endereço do Convívio',
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _diaController,
              decoration: InputDecoration(
                labelText: 'Dia do Convívio (ex: Segunda-feira)',
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              // Campo para exibir os responsáveis
              controller: _responsaveisController,
              decoration: InputDecoration(
                labelText: 'Responsáveis pelo Convívio',
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _salvarEdicao,
              child: Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }

  void _salvarEdicao() async {
    String convivioId = widget.convivio['id'];

    Map<String, dynamic> convivioData = {
      'nome': _nomeController.text,
      'endereco': _enderecoController.text,
      'dia': _diaController.text,
      // Não estamos atualizando os responsáveis aqui, pois essa funcionalidade não foi implementada
    };

    _conviviosReference.child(convivioId).update(convivioData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Convívio atualizado com sucesso.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _carregarResponsaveis() {
    // Aqui você pode adicionar lógica para carregar os responsáveis do convívio e preencher o campo correspondente
    // Por exemplo, você pode consultar o banco de dados para obter os responsáveis associados a este convívio e exibi-los no campo de texto
    // Como essa funcionalidade não foi implementada neste código, este método está vazio
  }

  void _selecionarNovaFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _novaFoto = File(pickedFile.path);
      });
    }
  }



  void _uploadNovaFoto() async {
    if (_novaFoto != null) {
      String convivioId = widget.convivio['id'];
      String fotoAntigaURL = widget.convivio['foto'];

      // Excluir a foto antiga do armazenamento
      if (fotoAntigaURL.isNotEmpty) {
        await _storage.refFromURL(fotoAntigaURL).delete();
      }

      // Upload da nova foto para o armazenamento
      String fileName = 'convivio_$convivioId.jpg';
      Reference storageRef =
      _storage.ref().child('convivios').child(fileName);
      UploadTask uploadTask = storageRef.putFile(_novaFoto!);
      await uploadTask.whenComplete(() {});

      // Atualizar a URL da foto no banco de dados
      String novaFotoURL = await storageRef.getDownloadURL();
      await _conviviosReference
          .child(convivioId)
          .child('foto')
          .set(novaFotoURL);

      // Atualizar o estado do widget para exibir a nova foto
      setState(() {
        widget.convivio['foto'] = novaFotoURL;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nova foto do convívio atualizada com sucesso.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nenhuma nova foto selecionada.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
