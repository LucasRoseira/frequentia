import 'package:mobx/mobx.dart';
import 'package:contador/data/database_helper.dart';
import 'package:contador/models/membro.dart';

part 'membro_store.g.dart';

class MembroStore = _MembroStoreBase with _$MembroStore;

abstract class _MembroStoreBase with Store {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @observable
  ObservableList<Membro> membros = ObservableList<Membro>();

  @action
  Future<void> loadMembros() async {
    membros.clear();
    membros.addAll(await _databaseHelper.queryAllMembers());
  }

  @action
  Future<void> addMembro(String nome, String fotoPath) async {
    // Adapte o método para lidar com o novo formato de Membro
    await _databaseHelper.insertMember(Membro(nome: nome, foto: fotoPath));
    await loadMembros();
  }
}
