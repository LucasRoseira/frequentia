import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:contador/models/membro.dart';
import 'package:contador/models/convivio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:contador/services/firebase_service.dart';
import 'package:intl/intl.dart';

class CadastrarMembro extends StatefulWidget {
  const CadastrarMembro({Key? key}) : super(key: key);

  @override
  _CadastrarMembroState createState() => _CadastrarMembroState();
}

enum TipoMembro {
  Adolescente,
  Casado,
  Noivo,
  Solteiro,
}

class _CadastrarMembroState extends State<CadastrarMembro> {
  final TextEditingController _nomeController = TextEditingController();
  DateTime? _dataAniversario;
  TipoMembro _tipoMembroSelecionado = TipoMembro.Adolescente;
  final TextEditingController _enderecoController = TextEditingController();
  String? _fotoPath;
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference().child('membros');
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<Map<String, dynamic>> _convivios = []; // Lista de convívios
  final TextEditingController _convivioController = TextEditingController();
  String? _convivioIdSelecionado;

  // Variáveis para armazenar os convívios disponíveis
  List<String> _nomesConvivios = [];
  Map<String, String> _idConvivios = {};
  List<String> datas = [];
  List<Convivio> convivios = [];

  bool _isLoading = false; // Flag para controlar o estado de carregamento

  @override
  void initState() {
    super.initState();
    _carregarConvivios(); // Carrega os convívios ao iniciar a tela
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Membro'),
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
          _isLoading
              ? Center(
            child: CircularProgressIndicator(), // Mostrar loading
          )
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      _escolherFoto();
                    },
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: _fotoPath != null
                          ? FileImage(File(_fotoPath!))
                          : null,
                      child: _fotoPath == null
                          ? Icon(
                        Icons.camera_alt,
                        size: 60,
                        color: Colors.grey[800],
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _mostrarDatePicker(context),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: TextEditingController(
                                text: _dataAniversario != null
                                    ? _formatDate(_dataAniversario!)
                                    : '',
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Data de Aniversário',
                                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _mostrarDatePicker(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estado Civil',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButton<TipoMembro>(
                          value: _tipoMembroSelecionado,
                          onChanged: (TipoMembro? newValue) {
                            setState(() {
                              _tipoMembroSelecionado = newValue!;
                            });
                          },
                          isExpanded: true,
                          items: TipoMembro.values.map((TipoMembro tipo) {
                            return DropdownMenuItem<TipoMembro>(
                              value: tipo,
                              child: Text(
                                tipo.toString().split('.').last,
                                style: const TextStyle(fontWeight: FontWeight.normal),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Campo de convívio como um DropdownButton
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Convívio',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButton<String>(
                          value: _nomesConvivios.isNotEmpty
                              ? _nomesConvivios[0]
                              : null, // Usando o primeiro item como valor inicial padrão
                          onChanged: (String? newValue) {
                            setState(() {
                              _convivioController.text = newValue!;
                              // Recuperar o ID correspondente ao nome do convívio selecionado
                              String? convivioId =
                              _idConvivios[newValue];
                              // Armazenar o ID do convívio para uso ao cadastrar o membro
                              _convivioIdSelecionado = convivioId;
                            });
                          },
                          isExpanded: true,
                          items: _nomesConvivios.map((String nomeConvivio) {
                            return DropdownMenuItem<String>(
                              value: nomeConvivio,
                              child: Text(
                                nomeConvivio,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  TextField(
                    controller: _enderecoController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _cadastrarMembro();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text('Cadastrar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _carregarConvivios() async {
    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .reference()
          .child('convivios')
          .once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic>? values =
        snapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<String> nomesConvivios = [];
          Map<String, String> idConvivios = {}; // Mapa de ID de convívios
          values.forEach((key, value) {
            nomesConvivios.add(value['nome']);
            idConvivios[value['nome']] = key; // Mapeia o ID pelo nome
          });
          setState(() {
            _nomesConvivios = nomesConvivios;
            _idConvivios = idConvivios; // Atualiza o mapa de ID de convívios
          });
        }
      }
    } catch (error) {
      print('Erro ao recuperar nomes dos convívios: $error');
    }
  }

  Future<void> _mostrarDatePicker(BuildContext context) async {
    // Definir o ano máximo aceitável como o ano anterior ao ano atual
    final int anoMaximo = DateTime.now().year - 1;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dataAniversario ?? DateTime(DateTime.now().year - 1),
      firstDate: DateTime(1940),
      lastDate: DateTime(anoMaximo),
    );

    if (pickedDate != null && pickedDate != _dataAniversario) {
      setState(() {
        _dataAniversario = pickedDate;
      });
    }
  }


  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _escolherFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _fotoPath = pickedFile.path;
      });
    } else {
      _showSnackBar('Nenhuma imagem selecionada.');
    }
  }

  void _cadastrarMembro() async {
    setState(() {
      _isLoading = true; // Ativar loading
    });

    String nome = _nomeController.text;
    String endereco = _enderecoController.text;
    String? convivioId = _convivioIdSelecionado;

    if (nome.isNotEmpty && _fotoPath != null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String fileName = path.basename(_fotoPath!);
      String absolutePath = path.join(appDocDir.path, fileName);

      await File(_fotoPath!).copy(absolutePath);

      UploadTask task = _storage
          .ref()
          .child('fotos/$_nomeController.jpg')
          .putFile(File(absolutePath));
      TaskSnapshot snapshot = await task;
      String photoURL = await snapshot.ref.getDownloadURL();

      Membro novoMembro = Membro(
        nome: nome,
        foto: photoURL,
        dataAniversario: _dataAniversario,
        tipoMembro: _tipoMembroSelecionado.toString().split('.').last,
        endereco: endereco,
        convivio: convivioId, // Utiliza o ID do convívio
      );

      await _firebaseService.cadastrarMembro(novoMembro);

      setState(() {
        _isLoading = false; // Desativar loading após a conclusão do cadastro
      });

      _nomeController.clear();
      _dataAniversario = null;
      _enderecoController.clear();
      _convivioController.clear();
      _fotoPath = null;

      _exibirMensagem('Membro cadastrado com sucesso!', context);
    } else {
      setState(() {
        _isLoading = false; // Desativar loading
      });

      _showSnackBar('Nome e foto do membro são obrigatórios.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
}
