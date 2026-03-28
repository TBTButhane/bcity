class Client {
  final int id;
  final String name;
  final String code;
  final int contactCount;

  const Client({
    required this.id,
    required this.name,
    required this.code,
    required this.contactCount,
  });

  // Deserialize from a DB row or JSON map
  factory Client.fromMap(Map<String, dynamic> map) => Client(
    id: map['id'] as int,
    name: map['name'] as String,
    code: map['code'] as String,
    contactCount: (map['contact_count'] as int?) ?? 0,
  );

  // Serialize back to a map
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'code': code,
    'contact_count': contactCount,
  };

  // Returns a copy with specific fields overridden — used for updates
  Client copyWith({
    int? id,
    String? name,
    String? code,
    int? contactCount,
  }) => Client(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    contactCount: contactCount ?? this.contactCount,
  );

  @override
  String toString() => 'Client(id: $id, name: $name, code: $code, contacts: $contactCount)';

  @override
  bool operator ==(Object other) => other is Client && other.id == id && other.code == code;

  @override
  int get hashCode => Object.hash(id, code);
}
