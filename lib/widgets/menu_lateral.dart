import 'package:flutter/material.dart';
import 'package:contador/screens/listar_presencas.dart';
import 'package:contador/screens/cadastro_presenca.dart';
import 'package:contador/screens/listar_membros.dart';
import 'package:contador/screens/cadastrar_membro.dart';

class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: ImageIcon(AssetImage('assets/icons/comparecimento.png')),
            title: Text(
              'Visualizar Presença',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListarPresencas()),
              );
            },
          ),
          ListTile(
            leading: ImageIcon(AssetImage('assets/icons/adicionar-simbolo-do-usuario.png')),
            title: Text(
              'Cadastrar Presença',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroPresenca()),
              );
            },
          ),
          ListTile(
            leading: ImageIcon(AssetImage('assets/icons/visualizar.png')),
            title: Text(
              'Visualizar Membros',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListarMembros()),
              );
            },
          ),
          ListTile(
            leading: ImageIcon(AssetImage('assets/icons/membro-da-equipe.png')),
            title: Text(
              'Cadastrar Membros',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastrarMembro()),
              );
            },
          ),
          // Adicione mais opções de menu conforme necessário
        ],
      ),
    );
  }
}
