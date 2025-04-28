class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String avatarUrl;

  Usuario(
      {required this.id,
      required this.nombre,
      required this.email,
      required this.avatarUrl});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['idUsuario'],
      nombre: json['nombre'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
