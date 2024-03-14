import 'membro.dart';

class Convivio {
  String? id;
  String nome;
  String endereco;
  List<String> responsaveis;
  DateTime dia;
  List<Membro> membros;
  String? fotoUrl; // Campo para armazenar a URL da foto do convívio

  Convivio({
    this.id,
    required this.nome,
    required this.endereco,
    required this.responsaveis,
    required this.dia,
    required this.membros,
    this.fotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'endereco': endereco,
      'responsaveis': responsaveis,
      'dia': dia.toIso8601String(),
      'membros': membros.map((membro) => membro.id).toList(),
      'fotoUrl': fotoUrl, // Adicionando a URL da foto ao mapa
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
      fotoUrl: map['fotoUrl'], // Carregando a URL da foto
    );
  }

  void adicionarMembro(Membro membro) {
    membros.add(membro);
  }
}
