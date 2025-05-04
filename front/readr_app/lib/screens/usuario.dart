class Usuario {
  final int idUsuario;
  final String nombre;
  final String email;
  final String avatarUrl;
  final List<String> roles; // Lista de roles del usuario

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.email,
    required this.avatarUrl,
    required this.roles, // Asumimos que roles es una lista de strings
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'],
      nombre: json['nombre'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      roles: List<String>.from(
          json['roles'] ?? []), // Convertir la lista de roles desde el JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nombre': nombre,
      'email': email,
      'avatarUrl': avatarUrl,
      'roles': roles, // Convertimos la lista de roles a formato JSON
    };
  }
}
