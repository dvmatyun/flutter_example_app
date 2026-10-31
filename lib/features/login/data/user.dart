class User {
  const User({required this.id, required this.name, required this.login});

  factory User.fromJson(Map<String, Object?> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    login: json['login'] as String,
  );

  final String id;
  final String name;
  final String login;

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'login': login};
}
