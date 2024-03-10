import 'package:flutter/material.dart';
import 'package:contador/data/database_helper.dart';
import 'package:contador/models/membro.dart';
import 'package:contador/models/presenca.dart';
import 'package:mobx/mobx.dart';

part 'presenca_store.g.dart';

class PresencaStore = _PresencaStoreBase with _$PresencaStore;

abstract class _PresencaStoreBase with Store {
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Use the constructor

  @observable
  List<Membro> membros = [];

  @observable
  Map<int, List<Attendance>> presencasMap = {};

  _PresencaStoreBase() {
    _carregarMembros();
  }

  @action
  Future<void> _carregarMembros() async {
    List<Membro> listaMembros = await _databaseHelper.queryAllMembers();
    membros = listaMembros;

    for (var membro in membros) {
      List<Attendance> presencas = await _databaseHelper.queryAttendances(membro.id!.toString());



      //presencasMap[membro.id!] = presencas;
    }
  }

  bool getPresenca(int memberId, DateTime date) {
    if (presencasMap.containsKey(memberId)) {
      List<Attendance> presencas = presencasMap[memberId]!;
      return true;
    }
    return false;
  }

  // presenca_store.dart
  @action
  Future<void> listarMembros() async {
    membros = await _databaseHelper.queryAllMembers();
  }

  @action
  Future<void> togglePresenca(int memberId, DateTime date) async {
    bool presencaAtual = getPresenca(memberId, date);

    if (presencasMap.containsKey(memberId)) {
      List<Attendance> presencas = presencasMap[memberId]!;
      Attendance? presencaExistente = presencas.firstWhereOrNull((presenca) => date == date);

      if (presencaExistente != null) {
        //presencaExistente.present = !presencaAtual;
        await _databaseHelper.insertAttendance(presencaExistente);
      }
    }
  }
}

extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
