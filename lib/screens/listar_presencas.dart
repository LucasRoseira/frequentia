import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:contador/data/database_helper.dart';
import 'package:contador/models/presenca.dart';
import 'package:contador/models/membro.dart';

class ListarPresencas extends StatefulWidget {
  @override
  _ListarPresencasState createState() => _ListarPresencasState();
}

class _ListarPresencasState extends State<ListarPresencas> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<Attendance> presencas = [];
  List<int> uniqueMemberIds = [];
  List<DateTime> uniqueDates = [];
  Map<int, String> memberNames = {}; // Mapa para armazenar os nomes dos membros

  @override
  void initState() {
    super.initState();
    _carregarPresencas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Presenças'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _carregarPresencas();
            },
          ),
        ],
      ),
      body: presencas.isEmpty
          ? Center(child: Text('Nenhuma presença encontrada.'))
          : _buildPresencasTable(),
    );
  }

  Widget _buildPresencasTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: _buildTableColumns(),
        rows: _buildTableRows(uniqueMemberIds),
      ),
    );
  }

  List<DataColumn> _buildTableColumns() {
    Set<DateTime> uniqueDatesSet = Set(); // Usando um conjunto para garantir datas únicas
    List<DataColumn> columns = [];

    columns.add(DataColumn(label: Text('MEMBRO')));
    columns.add(DataColumn(label: Text('PORCENTAGEM')));

    for (var date in uniqueDates) {
      if (uniqueDatesSet.add(date)) {
        // Se a data não estiver no conjunto, adicione à lista de colunas
        if (date == DateTime.now() && columns.any((column) => column.label == Text(DateFormat('dd/MM/yyyy').format(date)))) {
          // Verifique se a coluna para a data atual já existe
          continue;
        }

        columns.add(DataColumn(label: Text(DateFormat('dd/MM/yyyy').format(date))));
      }
    }

    return columns;
  }

  List<DataRow> _buildTableRows(List<int> memberIds) {
    return memberIds.map((memberId) {
      return DataRow(
        cells: [
          DataCell(Text(memberNames[memberId] ?? '')), // Usar o nome do membro
          DataCell(_buildPorcentagemPresenca(memberId)), // Adicionar porcentagem de presença
          for (var date in uniqueDates)
            if (date != DateTime.now()) // Excluir a data de hoje da exibição
              DataCell(
                FutureBuilder<bool>(
                  future: _checkAttendance(memberId, date),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Se ainda estiver carregando, você pode exibir um indicador de carregamento
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Se ocorrer um erro durante a verificação, você pode tratar aqui
                      return Text('Erro ao verificar presença');
                    } else {
                      // Verifique o resultado e exiba o marcador apropriado
                      bool isPresent = snapshot.data ?? false;
                      return Text(
                        isPresent ? '✓' : 'X',
                        style: TextStyle(fontSize: 24, color: isPresent ? Colors.black : Colors.red),
                      );
                    }
                  },
                ),
              ),
        ],
      );
    }).toList();
  }

  Widget _buildPorcentagemPresenca(int memberId) {
    int totalDias = uniqueDates.length;
    int presencasMembro = presencas.where((p) => p.memberId == memberId).length;

    double porcentagem = (presencasMembro / totalDias) * 100;

    return Text('${porcentagem.toStringAsFixed(2)}%');
  }

  Future<bool> _checkAttendance(int memberId, DateTime date) async {
    return await _databaseHelper.checkAttendanceExists(memberId, date);
  }

  void _carregarPresencas() async {
    uniqueDates = await _databaseHelper.queryAllAttendanceDates();
    List<Attendance> listaPresencas = await _databaseHelper.queryAllAttendances();

    // Obter nomes dos membros
    List<Membro> membros = await _databaseHelper.queryAllMembers();
    memberNames = Map.fromIterable(membros, key: (membro) => membro.id, value: (membro) => membro.nome);

    setState(() {
      presencas = listaPresencas;
      uniqueMemberIds = presencas.map((p) => p.memberId).toSet().toList();
    });
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListarPresencas(),
    );
  }
}