class Foto {
  final int id;
  final String name;
  final String path;

  Foto({
    required this.id,
    required this.name,
    required this.path,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
    };
  }

  static Foto fromMap(Map<String, dynamic> map) {
    return Foto(
      id: map['id'],
      name: map['name'],
      path: map['path'],
    );
  }
}
