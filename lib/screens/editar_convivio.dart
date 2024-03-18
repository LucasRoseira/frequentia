import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditarConvivioScreen extends StatefulWidget {
  final Map<String, dynamic> convivio;

  const EditarConvivioScreen({Key? key, required this.convivio}) : super(key: key);

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
  final DatabaseReference _membrosReference =
  FirebaseDatabase.instance.reference().child('membros');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _novaFoto;

  List<String> _responsaveis = [];

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.convivio['nome'];
    _enderecoController.text = widget.convivio['endereco'];
    _diaController.text = widget.convivio['dia'];
    _carregarResponsaveis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Convívio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 90,
              backgroundImage: NetworkImage(widget.convivio['foto']),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _selecionarNovaFoto,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Convívio',
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _enderecoController,
              decoration: const InputDecoration(
                labelText: 'Endereço do Convívio',
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _diaController,
              decoration: const InputDecoration(
                labelText: 'Dia do Convívio (ex: Segunda-feira)',
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _responsaveisController,
              decoration: const InputDecoration(
                labelText: 'Responsáveis pelo Convívio',
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              readOnly: true,
              onTap: () {
                _mostrarDialogSelecaoResponsaveis();
              },
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _responsaveis.length,
              itemBuilder: (context, index) {
                final responsavel = _responsaveis[index];
                return ListTile(
                  title: Text(responsavel),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _responsaveis.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _salvarEdicao,
              child: const Text('Salvar Alterações'),
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
      const SnackBar(
        content: Text('Convívio atualizado com sucesso.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _carregarResponsaveis() async {
    List<String> responsaveisIds = List<String>.from(widget.convivio['responsaveis']);
    _responsaveis.clear(); // Limpa a lista antes de carregar os responsáveis
    _responsaveisController.clear(); // Limpa o controlador também

    print('Responsável adicionado à lista teste'); // Mensagem de debug
    print('Quantidade de responsáveis IDs: ${responsaveisIds.length}');
    print('IDs dos responsáveis: $responsaveisIds');



    for (String responsavelId in responsaveisIds) {
      try {
        DatabaseEvent membroEvent = await _membrosReference.child(responsavelId).once();
        DataSnapshot membroSnapshot = membroEvent.snapshot;

        if (membroSnapshot.value != null) {
          Map<dynamic, dynamic>? membroData = membroSnapshot.value as Map<dynamic, dynamic>?;

          if (membroData != null) {
            print('Responsável carregado: ${membroData['nome']}'); // Mensagem de debug
            setState(() {
              _responsaveis.add(membroData['nome']);
              _responsaveisController.text += '${membroData['nome']}, '; // Adiciona o nome ao controlador
              print('Responsável adicionado à lista: ${membroData['nome']}'); // Mensagem de debug
            });
          }
        }
      } catch (error) {
        print('Erro ao carregar responsável: $error');
      }
    }

    print('Quantidade de responsáveis carregados: ${_responsaveis.length}');

  }




  void _mostrarDialogSelecaoResponsaveis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Responsáveis'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              for (String responsavel in _responsaveis)
                CheckboxListTile(
                  title: Text(responsavel),
                  value: _responsaveisController.text.contains(responsavel),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        _responsaveisController.text += responsavel + ', ';
                      } else {
                        _responsaveisController.text =
                            _responsaveisController.text.replaceAll(responsavel + ', ', '');
                      }
                    });
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
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
        const SnackBar(
          content: Text('Nova foto do convívio atualizada com sucesso.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma nova foto selecionada.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
