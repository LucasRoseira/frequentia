class Attendance {
  String? id;
  Map<String, List<Map<String, dynamic>>> datesAttendance;

  Attendance({this.id, required this.datesAttendance});

  factory Attendance.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Attendance(id: null, datesAttendance: {});
    }

    return Attendance(
      id: map['id'],
      datesAttendance: (map['presencas'] ?? {}).map<String, List<Map<String, dynamic>>>(
            (key, value) => MapEntry<String, List<Map<String, dynamic>>>(
          key,
          (value as List?)?.map((date) => (date as Map<String, dynamic>?) ?? {}).toList() ?? [],
        ),
      ),
    );
  }
}
