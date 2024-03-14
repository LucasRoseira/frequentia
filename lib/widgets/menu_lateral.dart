import 'package:contador/screens/cadastrar_presencas_convivio.dart';
import 'package:flutter/material.dart';
import 'package:contador/screens/cadastrar_convivio.dart';
import 'package:contador/screens/cadastrar_membro.dart';
import 'package:contador/screens/cadastro_presenca.dart';
import 'package:contador/screens/listar_membros.dart';
import 'package:contador/screens/listar_presencas.dart';
import 'package:contador/screens/listar_convivios.dart'; // Importe a tela de lista de convívios
import 'package:contador/screens/cadastrar_convivio.dart'; // Importe a tela de cadastro de presença de convívio

class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.add_box,
              size: 32,
            ),
            title: Text(
              'Cadastrar Convívio',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastrarConvivio()),
              );
            },
          ),
          ListTile(
            leading: ImageIcon(
              AssetImage('assets/icons/comparecimento.png'),
              size: 32,
            ),
            title: Text(
              'Visualizar Presença',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListarPresencas()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.add,
              size: 32,
            ),
            title: Text(
              'Cadastrar Membros',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastrarMembro()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.group,
              size: 32,
            ),
            title: Text(
              'Visualizar Membros',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListarMembros()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.person_add,
              size: 32,
            ),
            title: Text(
              'Cadastrar Presença',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroPresenca()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.event,
              size: 32,
            ),
            title: Text(
              'Cadastrar Presença Convívio',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroPresencaConvivio()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.list,
              size: 32,
            ),
            title: Text(
              'Lista de Convívios',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListaConvivios()),
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
