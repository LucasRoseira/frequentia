  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:firebase_database/firebase_database.dart';
  import 'package:contador/models/membro.dart';

  class ListarMembros extends StatefulWidget {
  const ListarMembros({Key? key}) : super(key: key);

    @override
    _ListarMembrosState createState() => _ListarMembrosState();
  }

  class _ListarMembrosState extends State<ListarMembros> {
    final DatabaseReference _databaseReference =
    FirebaseDatabase.instance.reference().child('membros');
    final DatabaseReference _conviviosReference =
    FirebaseDatabase.instance.reference().child('convivios');
    List<Membro> membros = [];
    List<Membro> membrosFiltrados = [];
    List<String> convivios = [];
    final TextEditingController _searchController = TextEditingController();
    String? _selectedConvivio;

    // Adicionar campos para armazenar o ID e o nome do membro selecionado
    String? _selectedMemberId;
    String? _selectedMemberName;

    @override
    void initState() {
      super.initState();
      _carregarNomesMembros();
      _carregarConvivios();
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

            for (var entry in values.entries) {
              var key = entry.key;
              var value = entry.value;

              try {
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
                    convivio: value['convivio'], // Adicione apenas o ID do convívio
                  ),
                );
              } catch (error) {
                print('Erro ao carregar dados do membro: $error');
              }
            }

            listaMembros.sort((a, b) => a.nome.compareTo(b.nome));

            setState(() {
              membros = listaMembros;
              membrosFiltrados = membros;
            });
          }
        }
      } catch (error) {
        print('Erro ao carregar membros: $error');
      }
    }



    Future<void> _carregarConvivios() async {
      try {
        DatabaseEvent event = await _conviviosReference.once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null) {
          Map<dynamic, dynamic>? values =
          snapshot.value as Map<dynamic, dynamic>?;

          if (values != null) {
            List<String> listaConvivios = [];

            values.forEach((key, value) {
              String convivioId = key;
              listaConvivios.add(convivioId);
            });
            if (mounted) {
              setState(() {
                convivios = listaConvivios;
              });
            }
          }
        }
      } catch (error) {
        print('Erro ao carregar convívios: $error');
      }
    }

    void _filtrarMembros(String query) {
      if (mounted) {
        setState(() {
          membrosFiltrados = membros
              .where((membro) =>
              membro.nome.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Listagem de Membros'),
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage("assets/acesso.jpg"),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.03),
                    BlendMode.dstATop,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPesquisaMembroField(),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedConvivio,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todos os Convívios'),
                      ),
                      ...convivios.map((String convivioId) {
                        return DropdownMenuItem<String>(
                          value: convivioId,
                          child: FutureBuilder<String?>(
                            future: _getConvivioName(convivioId), // Chama a função para obter o nome do convívio
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Carregando...'); // Exibe mensagem de carregamento enquanto espera pelo nome do convívio
                              } else {
                                String convivioNome = snapshot.data ?? 'Nenhum convívio';
                                return Text(convivioNome);
                              }
                            },
                          ),
                        );
                      }),
                    ],
                    onChanged: (String? newValue) {
                      if (mounted) {
                        setState(() {
                          _selectedConvivio = newValue;
                          _filtrarMembrosPorConvivio(newValue);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Filtrar por Convívio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: membrosFiltrados.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFotoMembro(membrosFiltrados[index].foto),
                              const SizedBox(height: 8),
                              Text('Nome: ${membrosFiltrados[index].nome}'),
                              Text(
                                  'Data de Aniversário: ${_formatDate(membrosFiltrados[index].dataAniversario)}'),
                              Text(
                                  'Tipo de Membro: ${membrosFiltrados[index].tipoMembro}'),
                              Text(
                                  'Endereço: ${membrosFiltrados[index].endereco}'),
                              FutureBuilder<String?>(
                                future: _getConvivioName(membrosFiltrados[index].convivio ?? ''),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Text('Convívio: Carregando...'); // Exibe mensagem de carregamento enquanto espera pelo nome do convívio
                                  } else {
                                    String convivioNome = snapshot.data ?? 'Nenhum convívio';
                                    return Text('Convívio: $convivioNome');
                                  }
                                },
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 150,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Configurar o membro selecionado antes de editar
                                    _selectedMemberId = membrosFiltrados[index].id;
                                    _selectedMemberName = membrosFiltrados[index].nome;
                                    _editarMembro(membrosFiltrados[index]);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _excluirMembro(membrosFiltrados[index]);
                                  },
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            // Faça algo ao tocar no membro
                          },
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      );
    }



    Future<String?> _getConvivioName(String convivioId) async {
      try {
        DatabaseEvent event =
        await _conviviosReference.child(convivioId).once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null) {
          Map<dynamic, dynamic>? data =
          snapshot.value as Map<dynamic, dynamic>?;

          if (data != null) {
            return data['nome'];
          }
        }
      } catch (error) {
        print('Erro ao obter nome do convívio: $error');
      }

      return null;
    }
    Widget _buildPesquisaMembroField() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _searchController,
          onChanged: _filtrarMembros,
          decoration: InputDecoration(
            labelText: 'Pesquisar Membro',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    Widget _buildFotoMembro(String? fotoPath) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: fotoPath != null ? NetworkImage(fotoPath) : null,
        child: fotoPath == null
            ? const Icon(Icons.person, size: 60, color: Colors.white)
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
            convivios: convivios,
            selectedMemberId: _selectedMemberId, // Passando o ID do membro selecionado
            selectedMemberName: _selectedMemberName, // Passando o nome do membro selecionado
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

        // Remove os registros de presença associados
        DataSnapshot snapshot = await _databaseReference
            .once()
            .then((event) => event.snapshot);

        if (snapshot.value != null) {
          Map<dynamic, dynamic> presences =
          (snapshot.value as Map<dynamic, dynamic>);

          presences.forEach((key, value) async {
            await presencesReference.child(key).remove();
          });
        }

        // Recarrega os membros após a exclusão
        _carregarNomesMembros();
      } catch (error) {
        print('Erro ao excluir membro: $error');
      }
    }

    void _filtrarMembrosPorConvivio(String? convivio) {
      if (mounted) {
        setState(() {
          if (convivio == null) {
            membrosFiltrados = membros;
          } else {
            membrosFiltrados = membros
                .where((membro) => membro.convivio == convivio)
                .toList();
          }
        });
      }
    }

    String _formatDate(DateTime? date) {
      return date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
    }
  }

  class EditarMembroScreen extends StatefulWidget {
    final Membro membro;
    final DatabaseReference databaseReference;
    final List<String> convivios;
    final String? selectedMemberId;
    final String? selectedMemberName;



    const EditarMembroScreen({Key? key, 
      required this.membro,
      required this.databaseReference,
      required this.convivios,
      this.selectedMemberId,
      this.selectedMemberName,
    }) : super(key: key);

    @override
    _EditarMembroScreenState createState() => _EditarMembroScreenState();
  }

  class _EditarMembroScreenState extends State<EditarMembroScreen> {
    String _formatDate(DateTime? date) {
      return date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
    }
    String? _selectedConvivioId;
    late TextEditingController _nomeController;
    late TextEditingController _dataAniversarioController;
    late TextEditingController _tipoMembroController;
    late TextEditingController _enderecoController;
    late TextEditingController _fotoController;
    late TextEditingController _convivioController;

    @override
    void initState() {
      _carregarNomesConvivios();
      super.initState();

      _nomeController = TextEditingController(text: widget.membro.nome);
      _dataAniversarioController = TextEditingController(
          text: widget.membro.dataAniversario?.toString() ?? '');
      _tipoMembroController =
          TextEditingController(text: widget.membro.tipoMembro ?? '');
      _enderecoController =
          TextEditingController(text: widget.membro.endereco ?? '');
      _fotoController = TextEditingController(text: widget.membro.foto ?? '');
      _convivioController =
          TextEditingController(text: widget.membro.convivio ?? '');
    }

    Widget _buildConvivioField() {
      return FutureBuilder<String?>(
        future: _getConvivioName(widget.membro.convivio ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            String? convivioNome = snapshot.data;

            print('--Convívio do membro: ${widget.membro.convivio}');
            print('--Nome do convívio: $convivioNome');

            return DropdownButtonFormField<String>(
              value: widget.membro.convivio,
              items: widget.convivios.map((String convivioId) {
                print('ID do convívio 6: $convivioId');
                return DropdownMenuItem<String>(
                  value: convivioId,
                  child: Text(
                    convivioId == widget.membro.convivio
                        ? convivioNome ?? 'Nome do Convívio'
                        : _convivioNames[convivioId] ?? 'Selecione um Convívio',
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (mounted) {
                  setState(() {
                    widget.membro.convivio = newValue;
                    _selectedConvivioId = newValue; // Atualiza a variável _selectedConvivioId
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Convívio',
              ),
            );
          }
        },
      );
    }



    final Map<String, String> _convivioNames = {};

    Future<void> _carregarNomesConvivios() async {
      try {
        DatabaseEvent event = await _conviviosReference.once();
        DataSnapshot snapshot = event.snapshot;


        if (snapshot.value != null) {
          Map<dynamic, dynamic>? values =
          snapshot.value as Map<dynamic, dynamic>?;

          if (values != null) {
            values.forEach((key, value) {
              _convivioNames[key] = value['nome'];
            });
          }
        }
      } catch (error) {
        print('Erro ao carregar nomes dos convívios: $error');
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Membro'),
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
              _buildConvivioField(),
              _buildFotoField(),
              SizedBox(
                width: double.infinity, // Define a largura igual à largura do pai
                child: ElevatedButton(
                  onPressed: () {
                    _salvarAlteracoes(_convivioController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Define a borda retangular
                    ),
                  ),
                  child: const Text('Salvar Alterações'),
                ),
              ),
            ],
          ),
        ),
      );
    }


    Widget _buildNomeField() {
      return TextFormField(
        controller: _nomeController,
        decoration: const InputDecoration(labelText: 'Nome'),
      );
    }

    Widget _buildDataAniversarioField(BuildContext context) {
      return InkWell(
        onTap: () {
          _selecionarData(context);
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Data de Nascimento',
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDate(widget.membro.dataAniversario),
              ),
              const Icon(Icons.calendar_today),
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

      if (dataSelecionada != null &&
          dataSelecionada != widget.membro.dataAniversario) {
        if (mounted) {
          setState(() {
            widget.membro.dataAniversario = dataSelecionada;
            _dataAniversarioController.text = _formatDate(dataSelecionada);
          });
        }
      }
    }

    Widget _buildTipoMembroField() {
      return TextFormField(
        controller: _tipoMembroController,
        decoration: const InputDecoration(labelText: 'Tipo de Membro'),
      );
    }

    Widget _buildEnderecoField() {
      return TextFormField(
        controller: _enderecoController,
        decoration: const InputDecoration(labelText: 'Endereço'),
      );
    }

    Widget _buildFotoField() {
      return TextFormField(
        controller: _fotoController,
        decoration: const InputDecoration(labelText: 'Caminho da Foto'),
      );
    }

    final DatabaseReference _conviviosReference =
    FirebaseDatabase.instance.reference().child('convivios');

    Future<String?> _getConvivioName(String convivioId) async {
      try {
        DatabaseEvent event =
        await _conviviosReference.child(convivioId).once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null) {
          Map<dynamic, dynamic>? data =
          snapshot.value as Map<dynamic, dynamic>?;

          if (data != null) {
            return data['nome'];
          }
        }
      } catch (error) {
        print('Erro ao obter nome do convívio: $error');
      }

      return null;
    }

    void _salvarAlteracoes(String novoConvivio) async {
      // Obter os valores atualizados dos campos
      String novoNome = _nomeController.text;
      DateTime? novaDataAniversario = widget.membro.dataAniversario; // Corrigir aqui
      String novoTipoMembro = _tipoMembroController.text;
      String novoEndereco = _enderecoController.text;
      String novoCaminhoFoto = _fotoController.text;
      String? novoConvivio = _selectedConvivioId;

      // Formatar a data de aniversário adequadamente
      String novaDataAniversarioFormatted = _formatDate(novaDataAniversario);

      // Debug: Mostrar os valores antes de atualizar
      print('Valores antes da atualização:');
      print('Nome: $novoNome');
      print('Data de Aniversário (string): $novaDataAniversarioFormatted'); // Corrigir aqui
      print('Tipo de Membro: $novoTipoMembro');
      print('Endereço: $novoEndereco');
      print('Caminho da Foto: $novoCaminhoFoto');
      print('Convívio: $novoConvivio');

      Membro membroAtualizado = Membro(
        id: widget.membro.id,
        nome: novoNome,
        dataAniversario: novaDataAniversario, // Corrigir aqui
        tipoMembro: novoTipoMembro,
        endereco: novoEndereco,
        foto: novoCaminhoFoto.isNotEmpty ? novoCaminhoFoto : null,
        convivio: novoConvivio,
      );

      // Atualizar os dados do membro no banco de dados
      try {
        Map<String, dynamic> updates = {
          'nome': membroAtualizado.nome,
          if (membroAtualizado.dataAniversario != null)
            'dataAniversario': membroAtualizado.dataAniversario?.toIso8601String(),
          'tipoMembro': membroAtualizado.tipoMembro,
          'convivio': membroAtualizado.convivio,
          'endereco': membroAtualizado.endereco,
          if (membroAtualizado.foto != null) 'foto': membroAtualizado.foto,
        };
        await widget.databaseReference
            .child(widget.membro.id!)
            .update(updates);

        // Mostrar uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alterações salvas com sucesso!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Fechar a tela de edição
        Navigator.pop(context, true);
      } catch (error) {
        // Mostrar uma mensagem de erro
        print('Erro ao salvar alterações: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
      _convivioController.dispose();
      super.dispose();
    }
  }
