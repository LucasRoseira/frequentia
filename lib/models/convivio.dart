import 'membro.dart';


class Convivio {
  String? id;
  String nome;
  String endereco;
  List<String> responsaveis;
  DateTime dia;
  List<Membro> membros;

  Convivio({
    this.id,
    required this.nome,
    required this.endereco,
    required this.responsaveis,
    required this.dia,
    required this.membros,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'endereco': endereco,
      'responsaveis': responsaveis,
      'dia': dia.toIso8601String(),
      'membros': membros.map((membro) => membro.id).toList(),
    };
  }

  factory Convivio.fromMap(Map<String, dynamic> map) {
    return Convivio(
      id: map['id'],
      nome: map['nome'],
      endereco: map['endereco'],
      responsaveis: List<String>.from(map['responsaveis']),
      dia: DateTime.parse(map['dia']),
      membros: [], // Membros serão carregados posteriormente
    );
  }

  void adicionarMembro(Membro membro) {
    membros.add(membro);
  }
}

