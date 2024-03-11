import 'package:flutter/material.dart';
import 'package:contador/models/membro.dart';

class CadastrarConvivio extends StatefulWidget {
  @override
  _CadastrarConvivioState createState() => _CadastrarConvivioState();
}

class _CadastrarConvivioState extends State<CadastrarConvivio> {
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _diaController = TextEditingController();
  final TextEditingController _pesquisaController = TextEditingController();

  List<Membro> responsaveis = [];
  List<Membro> _todosOsMembros = [];
  List<Membro> _membrosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _todosOsMembros = [
      Membro(nome: 'Membro 1'),
      Membro(nome: 'Membro 2'),
      Membro(nome: 'Membro 3'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Convívio'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResponsaveisField(),
            SizedBox(height: 16),
            _buildEnderecoField(), SizedBox(height: 16),
            _buildDiaField(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _salvarConvivio();
              },
              child: Text('Salvar Convívio'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsaveisField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Responsáveis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPesquisaMembroField(),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _adicionarResponsavel();
              },
            ),
          ],
        ),
        SizedBox(height: 8),
        _buildListaMembrosFiltrados(),
        SizedBox(height: 8),
        _buildListaResponsaveis(),
      ],
    );
  }

  Widget _buildPesquisaMembroField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _pesquisaController,
          decoration: InputDecoration(
            labelText: 'Pesquisar Membro',
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _membrosFiltrados = _filtrarMembros(value);
            });
          },
        ),
        SizedBox(height: 8),
        _buildListaMembrosFiltrados(),
      ],
    );
  }

  List<Membro> _filtrarMembros(String query) {
    return _todosOsMembros.where((membro) {
      final nomeMembro = membro.nome.toLowerCase();
      final queryLower = query.toLowerCase();

      return nomeMembro.contains(queryLower);
    }).toList();
  }

  Widget _buildListaMembrosFiltrados() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: _membrosFiltrados.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_membrosFiltrados[index].nome),
            onTap: () {
              _adicionarResponsavel(_membrosFiltrados[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEnderecoField() {
    return TextField(
      controller: _enderecoController,
      decoration: InputDecoration(labelText: 'Endereço do Convívio'),
    );
  }

  Widget _buildDiaField() {
    return TextField(
      controller: _diaController,
      decoration: InputDecoration(labelText: 'Dia do Convívio (ex: Segunda-feira)'),
    );
  }

  Widget _buildListaResponsaveis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: responsaveis.map((membro) {
        return ListTile(
          title: Text(membro.nome),
        );
      }).toList(),
    );
  }

  void _adicionarResponsavel([Membro? membro]) {
    if (membro != null) {
      setState(() {
        responsaveis.add(membro);
        _pesquisaController.clear();
        _membrosFiltrados.clear();
      });
    }
  }


  void _salvarConvivio() {
    print('Responsáveis: $responsaveis');
    print('Endereço: ${_enderecoController.text}');
    print('Dia: ${_diaController.text}');

    _enderecoController.clear();
    _diaController.clear();
    _pesquisaController.clear();
    responsaveis.clear();
  }
}
