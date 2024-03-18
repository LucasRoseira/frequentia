
import 'package:firebase_database/firebase_database.dart';
import 'package:contador/models/membro.dart';

class FirebaseService {
  final databaseReference = FirebaseDatabase.instance.reference();

  Future<void> cadastrarMembro(Membro membro) async {
    await databaseReference.child('membros').push().set(membro.toJson());
  }
}
