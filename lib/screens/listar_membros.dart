import 'package:flutter/material.dart';
import 'package:contador/models/membro.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:contador/screens/cadastrar_membro.dart';

class ListarMembros extends StatefulWidget {
  @override
  _ListarMembrosState createState() => _ListarMembrosState();
}

class _ListarMembrosState extends State<ListarMembros> {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference().child('membros');
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
          ),
          Expanded(
            child: ListView.builder(
              itemCount: membros.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFotoMembro(membros[index].foto),
                      SizedBox(height: 8),
                      Text('Nome: ${membros[index].nome}'),
                      Text('Data de Aniversário: ${membros[index].dataAniversario?.toLocal()}'),
                      Text('Tipo de Membro: ${membros[index].tipoMembro}'),
                      Text('Endereço: ${membros[index].endereco}'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openCadastroMembros,
        tooltip: 'Cadastrar Membros',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildFotoMembro(String? fotoPath) {
    return CircleAvatar(
      radius: 30,
      backgroundImage: fotoPath != null
          ? NetworkImage(fotoPath)
          : AssetImage('assets/placeholder_image.png') as ImageProvider<Object>,
      child: fotoPath == null
          ? Icon(Icons.person, size: 60, color: Colors.white)
          : null,
    );
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
                foto: value['foto'],
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

  void _excluirMembro(Membro membro) {
    _databaseReference.child(membro.id!).remove().then((_) {
      _carregarMembros();
    });
  }

  void _openCadastroMembros() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastrarMembro()),
    ).then((result) {
      if (result != null && result) {
        _carregarMembros();
      }
    });
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
  late TextEditingController _dataAniversarioController;
  late TextEditingController _tipoMembroController;
  late TextEditingController _enderecoController;
  late TextEditingController _fotoController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.membro.nome);
    _dataAniversarioController = TextEditingController(
        text: widget.membro.dataAniversario?.toString() ?? '');
    _tipoMembroController =
        TextEditingController(text: widget.membro.tipoMembro ?? '');
    _enderecoController =
        TextEditingController(text: widget.membro.endereco ?? '');
    _fotoController =
        TextEditingController(text: widget.membro.foto ?? '');
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
            _buildNomeField(),
            _buildDataAniversarioField(),
            _buildTipoMembroField(),
            _buildEnderecoField(),
            _buildFotoField(),
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

  Widget _buildNomeField() {
    return TextFormField(
      controller: _nomeController,
      decoration: InputDecoration(labelText: 'Nome'),
    );
  }

  Widget _buildDataAniversarioField() {
    return TextFormField(
      controller: _dataAniversarioController,
      decoration: InputDecoration(labelText: 'Data de Aniversário'),
    );
  }

  Widget _buildTipoMembroField() {
    return TextFormField(
      controller: _tipoMembroController,
      decoration: InputDecoration(labelText: 'Tipo de Membro'),
    );
  }

  Widget _buildEnderecoField() {
    return TextFormField(
      controller: _enderecoController,
      decoration: InputDecoration(labelText: 'Endereço'),
    );
  }

  Widget _buildFotoField() {
    return TextFormField(
      controller: _fotoController,
      decoration: InputDecoration(labelText: 'Caminho da Foto'),
    );
  }

  void _salvarAlteracoes() async {
    String novoNome = _nomeController.text;
    String novaDataAniversario = _dataAniversarioController.text;
    String novoTipoMembro = _tipoMembroController.text;
    String novoEndereco = _enderecoController.text;
    String novoCaminhoFoto = _fotoController.text;

    Membro membroAtualizado = Membro(
      id: widget.membro.id,
      nome: novoNome,
      dataAniversario: novaDataAniversario.isNotEmpty
          ? DateTime.tryParse(novaDataAniversario)
          : null,
      tipoMembro: novoTipoMembro,
      endereco: novoEndereco,
      foto: novoCaminhoFoto.isNotEmpty ? novoCaminhoFoto : null,
    );

    // Implemente a lógica de atualização no banco de dados (Firebase ou outro)
    // Exemplo fictício: await _databaseReference.child(widget.membro.id!).update({...});

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataAniversarioController.dispose();
    _tipoMembroController.dispose();
    _enderecoController.dispose();
    _fotoController.dispose();
    super.dispose();
  }
}
