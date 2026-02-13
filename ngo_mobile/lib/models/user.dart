class User {
  final int id;
  final String? name; // Le nom n'est pas dans le JWT, on le rend optionnel
  final String email;
  final String? role;

  User({
    required this.id,
    this.name,
    required this.email,
    this.role,
  });

  // Cette factory peut servir à d'autres endroits de l'app
  factory User.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return User(
      id: toInt(json['id']),
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }
}
