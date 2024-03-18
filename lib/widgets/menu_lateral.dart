import 'package:contador/screens/cadastrar_presencas_convivio.dart';
import 'package:flutter/material.dart';
import 'package:contador/screens/cadastrar_convivio.dart';
import 'package:contador/screens/cadastrar_membro.dart';
import 'package:contador/screens/cadastro_presenca.dart';
import 'package:contador/screens/listar_membros.dart';
import 'package:contador/screens/listar_presencas.dart';
import 'package:contador/screens/listar_convivios.dart'; // Importe a tela de lista de convívios
// Importe a tela de cadastro de presença de convívio

class MenuLateral extends StatelessWidget {
  const MenuLateral({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.add_box,
              size: 32,
            ),
            title: const Text(
              'Cadastrar Convívio',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CadastrarConvivio()),
              );
            },
          ),
          ListTile(
            leading: const ImageIcon(
              AssetImage('assets/icons/comparecimento.png'),
              size: 32,
            ),
            title: const Text(
              'Visualizar Presença',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListarPresencas()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.add,
              size: 32,
            ),
            title: const Text(
              'Cadastrar Membros',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CadastrarMembro()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.group,
              size: 32,
            ),
            title: const Text(
              'Visualizar Membros',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListarMembros()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.person_add,
              size: 32,
            ),
            title: const Text(
              'Cadastrar Presença',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CadastroPresenca()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.event,
              size: 32,
            ),
            title: const Text(
              'Cadastrar Presença Convívio',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CadastroPresencaConvivio()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.list,
              size: 32,
            ),
            title: const Text(
              'Lista de Convívios',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListaConvivios()),
              );
            },
          ),
          // Adicione mais opções de menu conforme necessário
        ].toList()
          ..sort((a, b) => a.title.toString().compareTo(b.title.toString())),
      ),
    );
  }
}
