import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:contador/models/membro.dart';

class CadastrarConvivio extends StatefulWidget {
  const CadastrarConvivio({Key? key}) : super(key: key);

  @override
  _CadastrarConvivioState createState() => _CadastrarConvivioState();
}

class _CadastrarConvivioState extends State<CadastrarConvivio> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _diaController = TextEditingController();
  final TextEditingController _pesquisaController = TextEditingController();
  final FocusNode _pesquisaFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker(); // Instância do ImagePicker
  DateTime? _selectedDate;

  List<Membro> responsaveis = [];
  List<Membro> _todosOsMembros = [];
  List<Membro> _membrosFiltrados = [];

  final DatabaseReference _conviviosReference =
  FirebaseDatabase.instance.reference().child('convivios');

  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference().child('membros');

  // Variáveis para armazenamento da foto selecionada
  XFile? _selectedImage;
  String? _photoURL;

  @override
  void initState() {
    super.initState();
    _carregarNomesMembros();
    _pesquisaFocusNode.addListener(_onPesquisaFocusChange);
  }

  void _onPesquisaFocusChange() {
    if (!_pesquisaFocusNode.hasFocus) {
      setState(() {
        _membrosFiltrados.clear(); // Limpa a lista de membros filtrados
      });
    }
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
                ),
              );
            } catch (error) {
              print('Erro ao carregar dados do membro: $error');
            }
          }

          // Ordena os membros pelo nome
          listaMembros.sort((a, b) => a.nome.compareTo(b.nome));

          setState(() {
            _todosOsMembros = listaMembros;
            _membrosFiltrados = _todosOsMembros;
          });
        }
      }
    } catch (error) {
      print('Erro ao carregar membros: $error');
    }
  }

  void _filtrarMembros(String query) {
    setState(() {
      _membrosFiltrados = _todosOsMembros
          .where((membro) =>
      membro.nome.toLowerCase().contains(query.toLowerCase()) &&
          !responsaveis.contains(membro)) // Exclui membros que já são responsáveis
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Convívio'),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
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
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAvatarSelector(), // Avatar para selecionar a foto
                const SizedBox(height: 16),
                _buildNomeConvivioField(), // Adicionando campo para nome do convívio
                const SizedBox(height: 16),
                _buildResponsaveisField(),
                const SizedBox(height: 16),
                _buildEnderecoField(),
                const SizedBox(height: 16),
                _buildDiaField(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _salvarConvivio();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: const Text(
                            'Salvar Convívio',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _visualizarDados();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            minimumSize: const Size(double.infinity, 40),
                            backgroundColor:
                            Colors.blue, // Cor de fundo
                          ),
                          child: const Text(
                            'Visualizar Dados',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ], // Faltava essa vírgula
      ), // Faltava esse fechamento
    );
  }


  // Método para construir o avatar seletor de foto
  Widget _buildAvatarSelector() {
    return GestureDetector(
      onTap: _selectPhoto, // Chama a função para selecionar a foto
      child: CircleAvatar(
        radius: 80,
        child: _selectedImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(80),
          child: Image.file(
            File(_selectedImage!.path),
            width: 160,
            height: 160,
            fit: BoxFit.cover,
          ),
        )
            : Icon(
          Icons.camera_alt,
          size: 60,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildNomeConvivioField() {
    return TextField(
      controller: _nomeController,
      decoration: const InputDecoration(
        labelText: 'Nome do Convívio',
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResponsaveisField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Responsáveis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        _buildPesquisaMembroField(),
        const SizedBox(height: 8),
        _pesquisaFocusNode.hasFocus
            ? _buildListaMembrosFiltrados()
            : const SizedBox.shrink(),
        const SizedBox(height: 8),
        _buildListaResponsaveis(),
      ],
    );
  }

  Widget _buildPesquisaMembroField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            debugPrint('Campo de pesquisa clicado');
            setState(() {
              _pesquisaFocusNode.requestFocus(); // Foca no campo de pesquisa
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.black),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextFormField(
              focusNode: _pesquisaFocusNode,
              controller: _pesquisaController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar Membro',
                suffixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                debugPrint('Texto digitado: $value');
                _filtrarMembros(value); // Chamada para filtrar membros
              },
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: (_pesquisaFocusNode.hasFocus && _membrosFiltrados.isNotEmpty)
              ? 200
              : 0,
          color: Colors.grey[
          200], // Cor de fundo da lista de membros filtrados
          child: _buildListaMembrosFiltrados(),
        ),
      ],
    );
  }

  Widget _buildListaMembrosFiltrados() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _membrosFiltrados.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            _membrosFiltrados[index].nome,
            style: const TextStyle(
              fontWeight: FontWeight.bold, // Adiciona negrito ao nome
            ),
          ),
          onTap: () {
            _adicionarResponsavel(_membrosFiltrados[index], context);
          },
        );
      },
    );
  }

  Widget _buildEnderecoField() {
    return TextField(
      controller: _enderecoController,
      decoration: const InputDecoration(
        labelText: 'Endereço do Convívio',
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  String? _selectedDay;

  Widget _buildDiaField() {
    List<String> diasDaSemana = ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Dia do Convívio',
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      value: _selectedDay,
      onChanged: (String? newValue) {
        setState(() {
          _selectedDay = newValue;
          _diaController.text = newValue ?? ''; // Atualiza o controlador do dia com o valor selecionado
        });
      },
      items: diasDaSemana.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }



  Widget _buildListaResponsaveis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: responsaveis.map((membro) {
        return ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(membro.nome),
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _removerResponsavel(membro);
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _removerResponsavel(Membro membro) {
    setState(() {
      responsaveis.remove(membro);
    });
  }


  void _adicionarResponsavel(Membro membro, BuildContext context) {
    // Verifica se o membro já está na lista de responsáveis
    if (!responsaveis.contains(membro)) {
      setState(() {
        responsaveis.add(membro);
        _pesquisaController.clear();
        _membrosFiltrados.clear();
        print('Adicionado responsável: ${membro.nome}');
      });

      // Exibe a mensagem de sucesso
      _exibirMensagem('Membro adicionado com sucesso!', context);
    } else {
      // Se o membro já estiver na lista, exiba um alerta ou mensagem informando ao usuário
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Membro já adicionado'),
            content: Text(
              'O membro ${membro.nome} já foi adicionado como responsável.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fechar o diálogo
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _exibirMensagem(String mensagem, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: Text(mensagem),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _salvarConvivio() async {
    // Verifica se algum campo está vazio
    if (_nomeController.text.isEmpty ||
        _enderecoController.text.isEmpty ||
        _diaController.text.isEmpty || // Alteração aqui
        responsaveis.isEmpty ||
        _selectedImage == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Campos obrigatórios não preenchidos'),
            content: const Text(
                'Preencha todos os campos obrigatórios e selecione uma foto.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fechar o diálogo
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Salva a foto do convívio no armazenamento do Firebase
    await _savePhotoToStorage();

    // Mostra os dados do convívio antes de salvar
    if (mounted) {
      _mostrarDadosConvivio();
    }

    // Crie um mapa com os dados do convívio
    Map<String, dynamic> convivioData = {
      'nome': _nomeController.text, // Incluindo o nome do convívio
      'endereco': _enderecoController.text,
      'dia': _diaController.text,
      'responsaveis': responsaveis.map((membro) => membro.id).toList(),
      'photoURL': _photoURL, // URL da foto do convívio
      'dataRegistro': DateTime.now().toIso8601String(),
    };

    // Salve os dados no Firebase no nó 'convivios'
    String convivioId = _conviviosReference.push().key ?? '';
    _conviviosReference.child(convivioId).set(convivioData);

    // Limpe os campos e listas
    _nomeController.clear();
    _enderecoController.clear();
    _selectedDay = null;
    _pesquisaController.clear();
    responsaveis.clear();
    _selectedImage = null;
    _photoURL = null;

    // Exibe uma mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Convívio salvo com sucesso!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _savePhotoToStorage() async {
    try {
      // Cria uma referência para o local onde a foto será armazenada
      final photoRef = FirebaseStorage.instance
          .ref()
          .child('convivios_photos')
          .child('${DateTime.now()}.jpg');

      // Carrega o arquivo da foto selecionada
      final File imageFile = File(_selectedImage!.path);

      // Envia o arquivo para o armazenamento do Firebase
      await photoRef.putFile(imageFile);

      // Obtém a URL da foto após o upload
      _photoURL = await photoRef.getDownloadURL();

    } catch (error) {
      print('Erro ao salvar foto no armazenamento do Firebase: $error');
      // Caso ocorra algum erro, defina _photoURL como null ou uma string vazia
      _photoURL = null;
    }
  }


  // Função para selecionar uma foto
  Future<void> _selectPhoto() async {
    final pickedImage =
    await _imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = pickedImage;
    });
  }

  // Widget para mostrar a foto selecionada e o botão para selecionar
  Widget _buildPhotoSelectorButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto do Convívio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        _selectedImage != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(
              File(_selectedImage!.path),
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton(
                onPressed: _selectPhoto,
                style: TextButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: const Size(double.infinity, 40),
                  backgroundColor:
                  Colors.blue, // Altere a cor de fundo conforme necessário
                ),
                child: const Text(
                  'Selecionar outra foto',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        )
            : Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton(
            onPressed: _selectPhoto,
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              minimumSize: const Size(double.infinity, 40),
              // Altere a cor de fundo conforme necessário
            ),
            child: const Text(
              'Selecionar foto',
            ),
          ),
        ),
      ],
    );
  }

  // Função para visualizar os dados antes de salvar
  void _visualizarDados() {
    // Mostra os dados do convívio antes de salvar
    _mostrarDadosConvivio();
  }

  // Função para mostrar os dados do convívio em um popup
  void _mostrarDadosConvivio() {
    String nomeConvivio = _nomeController.text;
    String enderecoConvivio = _enderecoController.text;
    String diaConvivio = _diaController.text;
    List<String> responsaveisConvivio =
    responsaveis.map((membro) => membro.nome).toList();
    String fotoConvivio = _photoURL ?? 'Nenhuma foto selecionada';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dados do Convívio'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome do Convívio: $nomeConvivio'),
                Text('Endereço do Convívio: $enderecoConvivio'),
                Text('Dia do Convívio: $diaConvivio'),
                Text(
                    'Selecionar Responsável(is): ${responsaveisConvivio.join(", ")}'),
                Text('Foto do Convívio: $fotoConvivio'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
