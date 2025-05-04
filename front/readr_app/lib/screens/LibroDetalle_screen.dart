import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'Libro.dart';
import 'Lista.dart';
import '../core/dio_client.dart';

class LibroDetalle_screen extends StatefulWidget {
  final int idLibro;

  const LibroDetalle_screen({super.key, required this.idLibro});

  @override
  State<LibroDetalle_screen> createState() => _LibroDetalleScreenState();
}

class _LibroDetalleScreenState extends State<LibroDetalle_screen> {
  late Future<Libro> _libroFuture;
  Map<String, int> listasPredeterminadas = {};
  String estadoLectura = "To Read"; // Estado inicial
  bool libroFinalizado = false;

  @override
  void initState() {
    super.initState();
    _libroFuture = fetchLibro();
    fetchListasPredeterminadas();
  }

  Future<Libro> fetchLibro() async {
    final dio = await DioClient.getInstance();
    try {
      final response = await dio.get(
        'http://10.0.2.2:8080/api/libros/${widget.idLibro}',
      );

      if (response.statusCode == 200) {
        return Libro.fromJson(response.data);
      } else {
        throw Exception('Error al cargar el libro');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> fetchListasPredeterminadas() async {
    final dio = await DioClient.getInstance();
    try {
      final response = await dio.get(
        'http://10.0.2.2:8080/api/listas-lectura/listas-predeterminadas',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        setState(() {
          listasPredeterminadas = {
            'To Read': data['To Read'],
            'Reading': data['Reading'],
            'Read': data['Read'],
          };
        });
        checkEstadoLibro(); // Llamamos a la función que chequea el estado del libro
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al cargar las listas predeterminadas')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al cargar las listas predeterminadas')),
      );
    }
  }

  void checkEstadoLibro() async {
    // Lógica para comprobar si el libro está en alguna lista
    final dio = await DioClient.getInstance();
    try {
      final response = await dio.get(
        'http://10.0.2.2:8080/api/listas-lectura',
      );

      if (response.statusCode == 200) {
        List<Lista> listas =
            (response.data as List).map((e) => Lista.fromJson(e)).toList();

        // Revisamos en qué lista está el libro
        for (var lista in listas) {
          if (lista.libros.contains(widget.idLibro)) {
            if (lista.nombreLista == 'To Read') {
              setState(() {
                estadoLectura = 'To Read';
              });
            } else if (lista.nombreLista == 'Reading') {
              setState(() {
                estadoLectura = 'Reading';
              });
            } else if (lista.nombreLista == 'Read') {
              setState(() {
                estadoLectura = 'Read';
                libroFinalizado = true; // Si está en "Read", lo deshabilitamos
              });
            }
            return; // Si lo encontramos, no seguimos buscando más
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al verificar el estado del libro')),
      );
    }
  }

  Future<void> moverLibroA(String nuevaLista) async {
    final dio = await DioClient.getInstance();
    final idListaNueva = listasPredeterminadas[nuevaLista];
    final idListaActual = listasPredeterminadas[estadoLectura];

    if (idListaNueva == null) return;

    // 1. Eliminar de la lista actual
    if (idListaActual != null && idListaActual != idListaNueva) {
      try {
        final deleteResponse = await dio.delete(
          'http://10.0.2.2:8080/api/listas-lectura/$idListaActual/libros/${widget.idLibro}',
        );

        if (deleteResponse.statusCode != 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Error al eliminar el libro de la lista anterior')),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al eliminar el libro de la lista anterior')),
        );
        return;
      }
    }

    // 2. Añadir a la nueva lista
    try {
      final putResponse = await dio.put(
        'http://10.0.2.2:8080/api/listas-lectura/$idListaNueva/libros/${widget.idLibro}',
      );

      if (putResponse.statusCode == 200) {
        setState(() {
          estadoLectura = nuevaLista;
          if (nuevaLista == "Read") {
            libroFinalizado = true;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Libro movido a $nuevaLista')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al mover el libro')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al mover el libro')),
      );
    }
  }

  void manejarBotonLectura() {
    if (estadoLectura == "To Read") {
      moverLibroA("Reading");
    } else if (estadoLectura == "Reading") {
      moverLibroA("Read");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Libro')),
      body: FutureBuilder<Libro>(
        future: _libroFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final libro = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.33,
                  child: Image.network(libro.imagenUrl, fit: BoxFit.contain),
                ),
                const SizedBox(height: 16),

                // Título
                Text(
                  libro.titulo,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Sinopsis
                Text(
                  libro.sinopsis,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),

                // Botón de progreso de lectura
                listasPredeterminadas.isEmpty
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: libroFinalizado ? null : manejarBotonLectura,
                        child: Text(libroFinalizado ? 'Read' : estadoLectura),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              libroFinalizado ? Colors.grey : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                const SizedBox(height: 30),

                // Reseña y valoración
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Aquí irá tu reseña y valoración',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
