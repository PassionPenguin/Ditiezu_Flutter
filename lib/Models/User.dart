import 'dart:convert';

class LocalUser extends User {
  bool loginState = false;

  LocalUser({required int id, required String name, required this.loginState})
      : super.init(id: id, name: name);

  LocalUser.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    loginState = json["loginState"];
  }

  @override
  String toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['loginState'] = loginState;
    return json.encode(data);
  }
}

class User {
  int id = -1;
  String name = "";

  User.init({required this.id, required this.name});

  User();

  User copyWith({
    int? id,
    String? name,
  }) {
    return User.init(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User.init(
      id: map['id'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() => 'User(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
