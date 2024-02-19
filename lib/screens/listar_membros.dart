import 'package:flutter/material.dart';
import 'package:contador/data/database_helper.dart';
import 'package:contador/models/membro.dart';
import 'dart:io';

class ListarMembros extends StatefulWidget {
  @override
  _ListarMembrosState createState() => _ListarMembrosState();
}

class _ListarMembrosState extends State<ListarMembros> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Membro> membros = [];

  @override
  void initState() {
    super.initState();
    _carregarMembros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Membros'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Nomes dos Membros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: membros.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    children: [
                      _buildFotoMembro(membros[index].foto),
                      SizedBox(width: 16),
                      Text(membros[index].nome),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editarMembro(membros[index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _excluirMembro(membros[index]);
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

  void _carregarMembros() async {
    List<Membro> listaMembros = await _databaseHelper.queryAllMembers();
    setState(() {
      membros = listaMembros;
    });
  }

  void _editarMembro(Membro membro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarMembroScreen(membro: membro),
      ),
    ).then((result) {
      if (result != null && result) {
        _carregarMembros();
      }
    });
  }

  void _excluirMembro(Membro membro) async {
    await _databaseHelper.deleteMember(membro.id ?? 0);
    _carregarMembros();
  }
}

class EditarMembroScreen extends StatefulWidget {
  final Membro membro;

  EditarMembroScreen({required this.membro});

  @override
  _EditarMembroScreenState createState() => _EditarMembroScreenState();
}

class _EditarMembroScreenState extends State<EditarMembroScreen> {
  late TextEditingController _nomeController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.membro.nome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Membro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFotoField(),
            _buildNomeField(),
            ElevatedButton(
              onPressed: () {
                _salvarAlteracoes();
              },
              child: Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoField() {
    return Container(); // Adicione um campo para a foto, se necessário
  }

  Widget _buildNomeField() {
    return TextFormField(
      controller: _nomeController,
      decoration: InputDecoration(labelText: 'Nome'),
    );
  }

  void _salvarAlteracoes() async {
    String novoNome = _nomeController.text;

    Membro membroAtualizado = Membro(
      id: widget.membro.id,
      nome: novoNome,
      foto: widget.membro.foto,
    );

    await DatabaseHelper.instance.updateMember(membroAtualizado);

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }
}
