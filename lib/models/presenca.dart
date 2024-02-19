class Attendance {
  int? id;
  late int memberId;
  late DateTime date;
  late bool present;

  Attendance({this.id, required this.memberId, required this.date, required this.present});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'date': date.toIso8601String(),
      'present': present ? 1 : 0,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      // Tratar o caso em que o mapa é nulo
      return Attendance(id: null, memberId: 0, date: DateTime.now(), present: false);
    }

    return Attendance(
      id: map['id'],
      memberId: map['memberId'] ?? 0,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      present: map['present'] == 1,
    );
  }
}
