import 'package:mobx/mobx.dart';
import 'package:contador/data/database_helper.dart';
import 'package:contador/models/membro.dart';

part 'membro_store.g.dart';

class MembroStore = _MembroStoreBase with _$MembroStore;

abstract class _MembroStoreBase with Store {
  final DatabaseHelper _databaseHelper;

  _MembroStoreBase(DatabaseHelper databaseHelper) : _databaseHelper = databaseHelper;

  @observable
  ObservableList<Membro> membros = ObservableList<Membro>();

  @action
  Future<void> loadMembros() async {
    try {
      membros.clear();
      membros.addAll(await _databaseHelper.queryAllMembers());
    } catch (e) {
      print('Erro ao carregar membros: $e');
    }
  }

  @action
  Future<void> addMembro(String nome, String fotoPath) async {
    try {
      await _databaseHelper.insertMember(Membro(nome: nome, foto: fotoPath));
      await loadMembros();
    } catch (e) {
      print('Erro ao adicionar membro: $e');
    }
  }

// Adicione abaixo os métodos para atualizar, excluir ou qualquer outra operação necessária
// utilizando as funcionalidades do Firebase.
}
