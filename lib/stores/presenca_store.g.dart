// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presenca_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PresencaStore on _PresencaStoreBase, Store {
  late final _$membrosAtom =
      Atom(name: '_PresencaStoreBase.membros', context: context);

  @override
  List<Membro> get membros {
    _$membrosAtom.reportRead();
    return super.membros;
  }

  @override
  set membros(List<Membro> value) {
    _$membrosAtom.reportWrite(value, super.membros, () {
      super.membros = value;
    });
  }

  late final _$presencasMapAtom =
      Atom(name: '_PresencaStoreBase.presencasMap', context: context);

  @override
  Map<int, List<Attendance>> get presencasMap {
    _$presencasMapAtom.reportRead();
    return super.presencasMap;
  }

  @override
  set presencasMap(Map<int, List<Attendance>> value) {
    _$presencasMapAtom.reportWrite(value, super.presencasMap, () {
      super.presencasMap = value;
    });
  }

  late final _$_carregarMembrosAsyncAction =
      AsyncAction('_PresencaStoreBase._carregarMembros', context: context);

  @override
  Future<void> _carregarMembros() {
    return _$_carregarMembrosAsyncAction.run(() => super._carregarMembros());
  }

  late final _$listarMembrosAsyncAction =
      AsyncAction('_PresencaStoreBase.listarMembros', context: context);

  @override
  Future<void> listarMembros() {
    return _$listarMembrosAsyncAction.run(() => super.listarMembros());
  }

  late final _$togglePresencaAsyncAction =
      AsyncAction('_PresencaStoreBase.togglePresenca', context: context);

  @override
  Future<void> togglePresenca(int memberId, DateTime date) {
    return _$togglePresencaAsyncAction
        .run(() => super.togglePresenca(memberId, date));
  }

  @override
  String toString() {
    return '''
membros: ${membros},
presencasMap: ${presencasMap}
    ''';
  }
}
