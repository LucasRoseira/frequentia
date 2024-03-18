import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contador/models/membro.dart';
import 'package:contador/models/presenca.dart';
import 'package:contador/models/foto.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  final CollectionReference members = FirebaseFirestore.instance.collection('members');
  final CollectionReference attendances = FirebaseFirestore.instance.collection('attendances');
  final CollectionReference photos = FirebaseFirestore.instance.collection('photos');
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  // Singleton setup
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  factory DatabaseHelper() {
    return _instance;
  }

  Future<int> insertMember(Membro membro) async {
    try {
      await members.add({
        'nome': membro.nome,
        'fotoPath': membro.foto,
      });
      // Since Firestore generates unique IDs, you don't need to return an ID.
      return 1; // Assuming success
    } catch (e) {
      print('Error inserting member: $e');
      return 0; // Indicating failure
    }
  }

  Future<List<Membro>> queryAllMembers() async {
    try {
      QuerySnapshot querySnapshot = await members.get();
      return querySnapshot.docs.map((doc) => Membro.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error querying all members: $e');
      return [];
    }
  }

  Future<int> insertAttendance(Attendance attendance) async {
    try {
      DocumentReference result = await attendances.add({
        //'memberId': attendance.memberId,

        //'present': attendance.present,
      });
      return result.id.hashCode; // or int.parse(result.id)
    } catch (e) {
      print('Error inserting attendance: $e');
      return -1;
    }
  }

  // ... Other methods follow a similar pattern

  Future<int> deleteMember(String id) async {
    try {
      await members.doc(id).delete();
      return 1; // Assuming success
    } catch (e) {
      print('Error deleting member with ID $id: $e');
      return 0; // Indicating failure
    }
  }

  Future<int> updateMember(Membro membro) async {
    try {
      await members.doc(membro.id.toString()).update({
        'nome': membro.nome,
        'fotoPath': membro.foto,
      });
      return 1; // Assuming success
    } catch (e) {
      print('Error updating member with ID ${membro.id}: $e');
      return 0; // Indicating failure
    }
  }

  // ... Other methods follow a similar pattern

  Future<List<Foto>> queryAllPhotos() async {
    try {
      QuerySnapshot querySnapshot = await photos.get();
      return querySnapshot.docs.map((doc) => Foto.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error querying all photos: $e');
      return [];
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<bool> checkAttendanceExists(String memberId, DateTime date) async {
    try {
      QuerySnapshot querySnapshot = await attendances
          .where('memberId', isEqualTo: memberId)
          .where('date', isEqualTo: _formatDate(date))
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking attendance existence: $e');
      return false;
    }
  }



  Future<List<DateTime>> queryAllAttendanceDates() async {
    try {
      QuerySnapshot querySnapshot = await attendances.get();
      Set<DateTime> dates = {};
      for (var doc in querySnapshot.docs) {
        String dateString = doc['date'];
        try {
          DateTime date = DateFormat('dd/MM/yyyy').parse(dateString);
          dates.add(date);
        } catch (e) {
          print('Error parsing date: $dateString');
        }
      }
      return dates.toList();
    } catch (e) {
      print('Error querying all attendance dates: $e');
      return [];
    }
  }
  Future<List<Attendance>> queryAllAttendances() async {
    try {
      QuerySnapshot querySnapshot = await attendances.get();
      return querySnapshot.docs.map((doc) => Attendance.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error querying all attendances: $e');
      return [];
    }
  }

  Future<List<Attendance>> queryAttendances(String memberId) async {
    try {
      QuerySnapshot querySnapshot = await attendances
          .where('memberId', isEqualTo: memberId) // Filtra por memberId
          .get();

      return querySnapshot.docs.map((doc) => Attendance.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error querying attendances: $e');
      return [];
    }
  }


  Future<List<Membro>> searchMembersByName(String name) async {
    try {
      QuerySnapshot querySnapshot = await members.where('nome', isEqualTo: name).get();
      return querySnapshot.docs.map((doc) => Membro.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error searching members by name: $e');
      return [];
    }
  }
}
