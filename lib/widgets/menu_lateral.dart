// menu_lateral.dart
import 'package:flutter/material.dart';
import 'package:contador/screens/cadastrar_membro.dart';
import 'package:contador/screens/listar_membros.dart';
import 'package:contador/screens/cadastro_presenca.dart';
import 'package:contador/screens/listar_presencas.dart'; // Importe a tela de listar presenças

class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Container(
              height: 100,
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
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
