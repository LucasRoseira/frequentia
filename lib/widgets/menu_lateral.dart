import 'package:flutter/material.dart';
import 'package:contador/screens/cadastrar_convivio.dart';
import 'package:contador/screens/cadastrar_membro.dart';
import 'package:contador/screens/cadastro_presenca.dart';
import 'package:contador/screens/listar_membros.dart';
import 'package:contador/screens/listar_presencas.dart';

class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: ImageIcon(
              AssetImage('assets/icons/grupo-de-tres-homens-de-pe-lado-a-lado-abracando-se.png'),
              size: 32, // Defina o tamanho desejado
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
              size: 32, // Defina o tamanho desejado
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
            leading: ImageIcon(
              AssetImage('assets/icons/membro-da-equipe.png'),
              size: 32, // Defina o tamanho desejado
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
            leading: ImageIcon(
              AssetImage('assets/icons/visualizar.png'),
              size: 32, // Defina o tamanho desejado
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
            leading: ImageIcon(
              AssetImage('assets/icons/adicionar-simbolo-do-usuario.png'),
              size: 32, // Defina o tamanho desejado
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
          // Adicione mais opções de menu conforme necessário
        ].toList()
          ..sort((a, b) => a.title.toString().compareTo(b.title.toString())),
      ),
    );
  }
}
