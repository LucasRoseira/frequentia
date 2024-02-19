// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membro_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MembroStore on _MembroStoreBase, Store {
  late final _$membrosAtom =
      Atom(name: '_MembroStoreBase.membros', context: context);

  @override
  ObservableList<Membro> get membros {
    _$membrosAtom.reportRead();
    return super.membros;
  }

  @override
  set membros(ObservableList<Membro> value) {
    _$membrosAtom.reportWrite(value, super.membros, () {
      super.membros = value;
    });
  }

  late final _$loadMembrosAsyncAction =
      AsyncAction('_MembroStoreBase.loadMembros', context: context);

  @override
  Future<void> loadMembros() {
    return _$loadMembrosAsyncAction.run(() => super.loadMembros());
  }

  late final _$addMembroAsyncAction =
      AsyncAction('_MembroStoreBase.addMembro', context: context);

  @override
  Future<void> addMembro(String nome, String fotoPath) {
    return _$addMembroAsyncAction.run(() => super.addMembro(nome, fotoPath));
  }

  @override
  String toString() {
    return '''
membros: ${membros}
    ''';
  }
}
