class Membro {
  String? id;
  String nome;
  String? foto;
  DateTime? dataAniversario;
  String? tipoMembro;
  String? endereco;
  bool? presenca; // Marcação de nulabilidade
  String? convivio; // Campo para representar o convívio

  Membro({
    required this.nome,
    this.id,
    this.foto,
    this.dataAniversario,
    this.tipoMembro,
    this.endereco,
    this.presenca = false, // Valor padrão
    this.convivio, // Adicionando o campo convivio
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'foto': foto,
      'dataAniversario': dataAniversario?.toIso8601String(),
      'tipoMembro': tipoMembro,
      'endereco': endereco,
      'presenca': presenca,
      'convivio': convivio, // Incluindo convivio no mapa
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'foto': foto,
      'dataAniversario': dataAniversario?.toIso8601String(),
      'tipoMembro': tipoMembro,
      'endereco': endereco,
      'presenca': presenca,
      'convivio': convivio,
    };
  }

  factory Membro.fromMap(Map<String, dynamic> map) {
    return Membro(
      id: map['id'],
      nome: map['nome'],
      foto: map['foto'],
      dataAniversario: map['dataAniversario'] != null
          ? DateTime.parse(map['dataAniversario'])
          : null,
      tipoMembro: map['tipoMembro'],
      endereco: map['endereco'],
      presenca: map['presenca'],
      convivio: map['convivio'],
    );
  }
}
