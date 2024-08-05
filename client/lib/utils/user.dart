class User {
  final String name;
  final String dni;
  final bool active; // Cambiar de Bool a bool

  User({required this.name, required this.dni, required this.active});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      dni: json['dni'] as String,
      active: json['active'] as bool, // Cambiar de Bool a bool
    );
  }

  @override
  String toString() {
    return 'User(name: $name, dni: $dni, active: $active)'; // Corregir el formato de la cadena
  }
}
