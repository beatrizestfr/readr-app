class Review {
  final String contenido;
  final int rating;
  final String nombreUsuario;
  final String avatarUsuario;
  final DateTime fecha;
  final int idLibro;
  final String imagenLibroUrl;
  final int id;

  // Constructor
  Review({
    required this.contenido,
    required this.rating,
    required this.nombreUsuario,
    required this.avatarUsuario,
    required this.fecha,
    required this.idLibro,
    required this.imagenLibroUrl,
    required this.id,
  });

  // Método para convertir un JSON a una instancia de Review
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      contenido: json['contenido'],
      rating: json['rating'],
      nombreUsuario: json['nombreUsuario'],
      avatarUsuario: json['avatarUsuario'],
      fecha: DateTime.parse(json['fecha']),
      idLibro: json['idLibro'],
      imagenLibroUrl: json['imagenLibroUrl'],
      id: json['id'],
    );
  }

  // Método para convertir la instancia de Review a un JSON
  Map<String, dynamic> toJson() {
    return {
      'contenido': contenido,
      'rating': rating,
      'nombreUsuario': nombreUsuario,
      'avatarUsuario': avatarUsuario,
      'fecha': fecha.toIso8601String(),
      'idLibro': idLibro,
      'imagenLibroUrl': imagenLibroUrl,
      'id': id,
    };
  }
}
