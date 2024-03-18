import 'package:flutter/material.dart';
import 'package:contador/screens/editar_convivio.dart';
import 'package:firebase_database/firebase_database.dart';

class ListaConvivios extends StatefulWidget {
  const ListaConvivios({Key? key}) : super(key: key);

  @override
  _ListaConviviosState createState() => _ListaConviviosState();
}

class _ListaConviviosState extends State<ListaConvivios> {
  List<Map<String, dynamic>> _convivios = [];

  final DatabaseReference _conviviosReference =
  FirebaseDatabase.instance.reference().child('convivios');
  final DatabaseReference _membrosReference =
  FirebaseDatabase.instance.reference().child('membros');

  @override
  void initState() {
    super.initState();
    _carregarConvivios();
  }

  Future<void> _carregarConvivios() async {
    try {
      DatabaseEvent event = await _conviviosReference.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic>? values =
        snapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          List<Map<String, dynamic>> listaConvivios = [];

          for (var entry in values.entries) {
            var key = entry.key;
            var value = entry.value;

            // Carrega detalhes dos responsáveis
            List<String> responsaveisNomes = [];
            if (value['responsaveis'] != null) {
              for (var responsavelId in value['responsaveis']) {
                try {
                  DatabaseEvent membroEvent = await _membrosReference
                      .child(responsavelId)
                      .once();
                  DataSnapshot membroSnapshot = membroEvent.snapshot;

                  if (membroSnapshot.value != null) {
                    Map<dynamic, dynamic>? membroData =
                    membroSnapshot.value as Map<dynamic, dynamic>?;

                    if (membroData != null) {
                      responsaveisNomes.add(membroData['nome']);
                    }
                  }
                } catch (error) {
                  print('Erro ao carregar responsável: $error');
                }
              }
            }


            listaConvivios.add({
              'id': key,
              'nome': value['nome'], // Adicionando o nome do convívio
              'endereco': value['endereco'],
              'dia': value['dia'],
              'responsaveis': responsaveisNomes,
              // Adicione a URL da foto do convívio, se disponível
              'foto': value['photoURL'] ?? '', // URL da foto
            });
          }

          setState(() {
            _convivios = listaConvivios;
          });
        }
      }
    } catch (error) {
      print('Erro ao carregar convívios: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Convívios'),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildListaConvivios(),
          ),
        ],
      ),
    );
  }



  Widget _buildListaConvivios() {
    return ListView.builder(
      itemCount: _convivios.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: _buildFotoConvivio(
              _convivios[index]['foto']), // Miniatura da foto do convívio
          title: Row(
            children: [
              Text(
                'Nome: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${_convivios[index]['nome']}'),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Endereço: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${_convivios[index]['endereco']}'),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Dia: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${_convivios[index]['dia']}'),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Responsáveis: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      '${_convivios[index]['responsaveis'].join(', ')}',
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editarConvivio(_convivios[index]);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _excluirConvivio(_convivios[index]);
                },
              ),
            ],
          ),
          onTap: () {
            // Adicione a navegação ou ação ao tocar em um convívio, se necessário
          },
        );
      },
    );
  }


  Widget _buildFotoConvivio(String? fotoPath) {
    // Verifica se a URL da foto é válida
    if (fotoPath != null && fotoPath.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(fotoPath),
      );
    } else {
      // Caso contrário, exibe um ícone padrão
      return const CircleAvatar(
        radius: 30,
        child: Icon(Icons.group, size: 60, color: Colors.white), // Ícone padrão para convívio
      );
    }
  }

  void _editarConvivio(Map<String, dynamic> convivio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarConvivioScreen(convivio: convivio),
      ),
    );
  }

  void _excluirConvivio(Map<String, dynamic> convivio) async {
    String convivioId = convivio['id'];

    try {
      // Remova o convívio do banco de dados
      await _conviviosReference.child(convivioId).remove();

      // Atualize a lista de convívios
      setState(() {
        _convivios.removeWhere((element) => element['id'] == convivioId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Convívio excluído com sucesso.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Erro ao excluir convívio: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir convívio. Tente novamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
