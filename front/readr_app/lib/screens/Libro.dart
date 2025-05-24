class Libro {
  final int id;
  final String titulo;
  final String autor;
  final String imagenUrl;
  final String sinopsis;
  final String googleBooksId;

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.imagenUrl,
    required this.sinopsis,
    required this.googleBooksId,
  });

  // Método de fábrica para crear un Libro desde un JSON
  factory Libro.fromJson(Map<String, dynamic> json) {
    // print("📘 Parseando Libro: $json");

    return Libro(
      id: json['idLibro'], // id del libro
      titulo: json['titulo'], // Título del libro
      autor: json['autor'] ??
          '', // Autor del libro (puede ser null, por eso el ?? '')
      imagenUrl: json['sinopsis'] ?? '', // URL de la imagen (puede ser null)
      sinopsis: json['imagenUrl'] ?? '', // Sinopsis (puede ser null)
      googleBooksId:
          json['googleBooksId'] ?? '', // ID de Google Books (puede ser null)
    );
  }

  // Convertir un Libro a JSON (si fuera necesario para enviar datos al servidor)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'imagenUrl': imagenUrl,
      'sinopsis': sinopsis,
      'googleBooksId': googleBooksId,
    };
  }
}
