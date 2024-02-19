  import 'dart:io';
  import 'package:path/path.dart';
  import 'package:sqflite/sqflite.dart';
  import 'package:path_provider/path_provider.dart';
  import 'package:contador/models/membro.dart';
  import 'package:contador/models/presenca.dart';
  import 'package:intl/intl.dart';


  class DatabaseHelper {
    static final _databaseName = "attendance_database.db";
    static final _databaseVersion = 3;

    static final tableMembers = 'membros';
    static final tablePresencas = 'presencas';

    static final columnId = 'id';
    static final columnName = 'nome';
    static final columnMemberId = 'memberId';
    static final columnDate = 'data';
    static final columnPresent = 'presente';
    static final columnFotoPath = 'fotoPath';

    DatabaseHelper._privateConstructor();
    static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

    static Database? _database;
    Future<Database> get database async {
      if (_database != null) return _database!;

      _database = await _initDatabase();
      return _database!;
    }

    Future<Database> _initDatabase() async {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, _databaseName);

      print('Criando o banco de dados em: $path');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
      );
    }

    Future<void> _onCreate(Database db, int version) async {
      print('Criando a tabela $tableMembers');
      await db.execute('''
      CREATE TABLE $tableMembers (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnFotoPath TEXT NOT NULL
      )
    ''');

      print('Criando a tabela $tablePresencas');
      await db.execute('''
      CREATE TABLE $tablePresencas ( 
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnMemberId INTEGER NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnPresent INTEGER NOT NULL,
        FOREIGN KEY ($columnMemberId) REFERENCES $tableMembers($columnId)
      )
    ''');
    }

    Future<int> insertMember(Membro membro) async {
      Database db = await database;
      int id = await db.insert(tableMembers, {
        columnName: membro.nome,
        columnFotoPath: membro.foto,
      });

      print('Inserido um membro com ID: $id');
      return id;
    }

    Future<List<Membro>> queryAllMembers() async {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(tableMembers);
      return List.generate(maps.length, (i) {
        return Membro.fromMap(maps[i]);
      });
    }

    Future<List<Attendance>> queryAllAttendances() async {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(tablePresencas);
      return List.generate(maps.length, (i) {
        return Attendance.fromMap(maps[i]);
      });
    }

    Future<int> insertAttendance(Attendance attendance) async {
      Database db = await database;
      int id = await db.insert(tablePresencas, {
        columnMemberId: attendance.memberId,
        // Ajuste para salvar apenas a data no formato dd/mm/aaaa
        columnDate: _formatDate(attendance.date),
        columnPresent: attendance.present ? 1 : 0,
      });

      print('Inserida uma presença com ID: $id');
      return id;
    }

    String _formatDate(DateTime date) {
      // Formata a data para o formato dd/mm/aaaa
      return DateFormat('dd/MM/yyyy').format(date);
    }

    Future<List<Attendance>> queryAttendances(int memberId) async {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        tablePresencas,
        where: '$columnMemberId = ?',
        whereArgs: [memberId],
      );
      return List.generate(maps.length, (i) {
        return Attendance.fromMap(maps[i]);
      });
    }

    Future<List<DateTime>> queryAllAttendanceDates() async {
      Database db = await database;
      List<Map<String, dynamic>> result =
      await db.rawQuery('SELECT DISTINCT $columnDate FROM $tablePresencas');

      List<DateTime> dates = [];
      for (Map<String, dynamic> dateMap in result) {
        String dateString = dateMap[columnDate];
        try {
          DateTime date = DateFormat('dd/MM/yyyy').parse(dateString);
          dates.add(date);
        } catch (e) {
          print('Error parsing date: $dateString');
        }
      }

      return dates;
    }


    Future<bool> checkAttendanceExists(int memberId, DateTime date) async {
      final Database db = await instance.database;

      final List<Map<String, dynamic>> result = await db.query(
        tablePresencas,
        columns: [columnPresent],
        where: '$columnMemberId = ? AND $columnDate = ?',
        whereArgs: [memberId, DateFormat('dd/MM/yyyy').format(date)],
      );

      // Se houver um registro correspondente, retorne o valor de 'presente'
      if (result.isNotEmpty) {
        return result[0][columnPresent] == 1;
      }

      // Se não houver registro, retorne false (não presente)
      return false;
    }



    Future<int> deleteMember(int id) async {
      Database db = await instance.database;
      return await db.delete(tableMembers, where: '$columnId = ?', whereArgs: [id]);
    }

    Future<int> updateMember(Membro membro) async {
      final db = await instance.database;
      return await db.update(
        tableMembers,
        membro.toMap(),
        where: '$columnId = ?',
        whereArgs: [membro.id],
      );
    }

    // Print the list of tables after creation
    Future<List<Membro>> searchMembersByName(String searchTerm) async {
      final Database db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableMembers,
        where: '$columnName LIKE ?',
        whereArgs: ['%$searchTerm%'],
        orderBy: '$columnDate DESC', // Adiciona esta linha para ordenar por data decrescente
      );

      return List.generate(maps.length, (i) {
        return Membro.fromMap(maps[i]);
      });
    }

    Future<List<DateTime>> queryAllAttendanceDatesOrdered() async {
      final Database db = await instance.database;

      final List<Map<String, dynamic>> result = await db.query(
        tablePresencas,
        columns: [columnDate],
        groupBy: columnDate,
        orderBy: '$columnDate DESC', // Ordenar por data em ordem decrescente
      );

      List<DateTime> dates = result
          .map((map) => DateFormat('yyyy-MM-dd').parse(map[columnDate]))
          .toList();

      return dates;
    }

  }
