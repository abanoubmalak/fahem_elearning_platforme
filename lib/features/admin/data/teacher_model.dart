class AssignedSubject {
  final String subject;
  final String stage;
  final String term;

  AssignedSubject({
    required this.subject,
    required this.stage,
    required this.term,
  });

  bool matches(AssignedSubject other) =>
      subject == other.subject && stage == other.stage && term == other.term;

  AssignedSubject copyWith({String? subject, String? stage, String? term}) =>
      AssignedSubject(
        subject: subject ?? this.subject,
        stage:   stage   ?? this.stage,
        term:    term    ?? this.term,
      );

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'stage':   stage,
    'term':    term,
  };

  factory AssignedSubject.fromJson(Map<String, dynamic> json) => AssignedSubject(
    subject: json['subject'],
    stage:   json['stage'],
    term:    json['term'],
  );
}


class TeacherModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<AssignedSubject> subjects;

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subjects,
  });

  TeacherModel copyWith({
    String? name,
    String? email,
    String? phone,
    List<AssignedSubject>? subjects,
  }) =>
      TeacherModel(
        id:       id,
        name:     name     ?? this.name,
        email:    email    ?? this.email,
        phone:    phone    ?? this.phone,
        subjects: subjects ?? this.subjects,
      );
}
