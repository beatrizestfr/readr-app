import 'libro.dart';
import 'usuario.dart';

class Lista {
  final int idLista;
  final String nombreLista;
  final DateTime fechaCreacion;
  final List<Libro> libros; // Relación con la lista de libros

  Lista({
    required this.idLista,
    required this.nombreLista,
    required this.fechaCreacion,
    required this.libros,
  });

  // Método de fábrica para crear una Lista desde un JSON
  factory Lista.fromJson(Map<String, dynamic> json) {
    print("🧩 Parseando Lista: $json");

    var librosJson = json['libros'];
    List<Libro> librosList = [];

    if (librosJson != null && librosJson is List) {
      librosList = librosJson.map((libroJson) {
        print("📕 Libro individual JSON: $libroJson");
        return Libro.fromJson(libroJson);
      }).toList();
    } else {
      print("⚠️ Lista sin libros o campo 'libros' es null");
    }

    return Lista(
      idLista: json['idLista'],
      nombreLista: json['nombreLista'],
      fechaCreacion: DateTime.parse(
          json['fechaCreacion']), // Convierte la fecha a DateTime
      libros: librosList,
    );
  }

  // Convertir la Lista a JSON (si fuera necesario para enviar datos al servidor)
  Map<String, dynamic> toJson() {
    return {
      'id': idLista,
      'nombreLista': nombreLista,
      'fechaCreacion':
          fechaCreacion.toIso8601String(), // Convierte la fecha a string
      'libros': libros
          .map((libro) => libro.toJson())
          .toList(), // Convierte los libros a JSON
    };
  }
}
