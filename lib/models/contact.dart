class Contact {
  final int id;
  final String name;
  final String surname;
  final String email;
  final String code;
  final int contactCount;

  const Contact({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.code,
    required this.contactCount,
  });

  // Deserialize from a DB row or JSON map
  factory Contact.fromMap(Map<String, dynamic> map) => Contact(
    id: map['id'] as int,
    name: map['name'] as String,
    surname: map['surname'] as String,
    email: map['email'] as String,
    code: map['code'] as String,
    contactCount: (map['contact_count'] as int?) ?? 0,
  );

  // Serialize back to a map
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'surname': surname,
    'email': email,
    'code': code,
    'contact_count': contactCount,
  };

  // Returns a copy with specific fields overridden — used for updates
  Contact copyWith({
    int? id,
    String? name,
    String? surname,
    String? email,
    String? code,
    int? contactCount,
  }) => Contact(
    id: id ?? this.id,
    name: name ?? this.name,
    surname: surname ?? this.surname,
    email: email ?? this.email,
    code: code ?? this.code,
    contactCount: contactCount ?? this.contactCount,
  );

  @override
  String toString() => 'Contact(id: $id, name: $name, surname: $surname, email: $email, code: $code, contacts: $contactCount)';

  @override
  bool operator ==(Object other) => other is Contact && other.id == id && other.code == code;

  @override
  int get hashCode => Object.hash(id, code);
}
