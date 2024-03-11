import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:contador/models/membro.dart';
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
    _carregarNomesMembros();
  }

  Future<void> _carregarNomesMembros() async {
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
              ),
            );
          });

          // Ordena os membros pelo nome
          listaMembros.sort((a, b) => a.nome.compareTo(b.nome));

          setState(() {
            membros = listaMembros;
          });

          // Agora, carregamos os dados restantes usando os IDs ordenados
          _carregarDadosCompletos();
        }
      }
    } catch (error) {
      print('Erro ao carregar membros: $error');
    }
  }

  Future<void> _carregarDadosCompletos() async {
    List<Membro> membrosCompletos = [];

    for (Membro membro in membros) {
      try {
        DatabaseEvent event =
        await _databaseReference.child(membro.id!).once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null) {
          Map<dynamic, dynamic>? data =
          snapshot.value as Map<dynamic, dynamic>?;

          if (data != null) {
            membrosCompletos.add(
              Membro(
                id: membro.id,
                nome: membro.nome,
                foto: data['foto'],
                dataAniversario: data['dataAniversario'] != null
                    ? DateTime.parse(data['dataAniversario'])
                    : null,
                tipoMembro: data['tipoMembro'],
                endereco: data['endereco'],
              ),
            );
          }
        }
      } catch (error) {
        print('Erro ao carregar dados do membro: $error');
      }
    }

    // Atualiza o estado com os membros completos
    setState(() {
      membros = membrosCompletos;
    });
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
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: 'Nome: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '${membros[index].nome}'),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: 'Data de Aniversário: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '${_formatDate(membros[index].dataAniversario)}',
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: 'Tipo de Membro: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '${membros[index].tipoMembro}'),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: 'Endereço: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '${membros[index].endereco}'),
                          ],
                        ),
                      ),
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
          : null, // Removendo a AssetImage aqui
      child: fotoPath == null
          ? Icon(Icons.person, size: 60, color: Colors.white)
          : null,
    );
  }

  void _editarMembro(Membro membro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarMembroScreen(
          membro: membro,
          databaseReference: _databaseReference,
        ),
      ),
    ).then((result) {
      if (result != null && result) {
        _carregarNomesMembros();
      }
    });
  }

  void _excluirMembro(Membro membro) async {
    DatabaseReference presencesReference =
    FirebaseDatabase.instance.reference().child('presences');

    try {
      await _databaseReference.child(membro.id!).remove();

      // Remove the associated presence records
      DataSnapshot snapshot = await _databaseReference.once().then((event) => event.snapshot);


      if (snapshot.value != null) {
        Map<dynamic, dynamic> presences =
        (snapshot.value as Map<dynamic, dynamic>);

        presences.forEach((key, value) async {
          await presencesReference.child(key).remove();
        });
      }

      // Reload the members after deletion
      _carregarNomesMembros();
    } catch (error) {
      print('Error deleting member: $error');
    }
  }





  void _openCadastroMembros() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastrarMembro()),
    ).then((result) {
      if (result != null && result) {
        _carregarNomesMembros();
      }
    });
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('yyyy-MM-ddd').format(date) : '';
  }

}

class EditarMembroScreen extends StatefulWidget {
  final Membro membro;
  final DatabaseReference databaseReference;

  EditarMembroScreen({required this.membro, required this.databaseReference});

  @override
  _EditarMembroScreenState createState() => _EditarMembroScreenState();
}

class _EditarMembroScreenState extends State<EditarMembroScreen> {

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
  }

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
            _buildDataAniversarioField(context),
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

  Widget _buildDataAniversarioField(BuildContext context) {
    return InkWell(
      onTap: () {
        _selecionarData(context);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Data de Aniversário',
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDate(widget.membro.dataAniversario),
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarData(BuildContext context) async {
    DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: widget.membro.dataAniversario ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (dataSelecionada != null && dataSelecionada != widget.membro.dataAniversario) {
      setState(() {
        widget.membro.dataAniversario = dataSelecionada;
        _dataAniversarioController.text = _formatDate(dataSelecionada);
      });
    }
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

    try {
      // Atualize apenas os campos que foram alterados
      Map<String, dynamic> updates = {
        'nome': membroAtualizado.nome,
        if (membroAtualizado.dataAniversario != null)
          'dataAniversario': membroAtualizado.dataAniversario?.toIso8601String(),
        'tipoMembro': membroAtualizado.tipoMembro,
        'endereco': membroAtualizado.endereco,
        if (membroAtualizado.foto != null) 'foto': membroAtualizado.foto,
      };

      await widget.databaseReference.child(widget.membro.id!).update(updates);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alterações salvas com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      print('Erro ao salvar alterações: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar alterações. Tente novamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
