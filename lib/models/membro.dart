class Membro {
  int? id;
  late String nome;
  String? foto; // Adição do campo foto

  Membro({this.id, required this.nome, this.foto});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'foto': foto,
    };
  }

  factory Membro.fromMap(Map<String, dynamic> map) {
    return Membro(
      id: map['id'],
      nome: map['nome'],
      foto: map['foto'],
    );
  }
}
