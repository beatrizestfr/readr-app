import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'Libro.dart';
import 'Lista.dart';
import '../core/dio_client.dart';
import '../models/Review.dart';

class LibroDetalle_screen extends StatefulWidget {
  final int idLibro;

  const LibroDetalle_screen({super.key, required this.idLibro});

  @override
  State<LibroDetalle_screen> createState() => _LibroDetalleScreenState();
}

class _LibroDetalleScreenState extends State<LibroDetalle_screen> {
  late Future<Libro> _libroFuture;
  Map<String, int> listasPredeterminadas = {};
  String estadoLectura = ""; // Estado inicial
  bool libroFinalizado = false;
  late Future<List<Review>> _resenasFuture;
  bool mostrarSinopsisCompleta = false;

  @override
  void initState() {
    super.initState();
    _libroFuture = fetchLibro();
    fetchListasPredeterminadas();
    _resenasFuture = fetchResenas();
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
    final dio = await DioClient.getInstance();
    try {
      final response = await dio.get(
        'http://10.0.2.2:8080/api/listas-lectura',
      );

      if (response.statusCode == 200) {
        List<Lista> listas =
            (response.data as List).map((e) => Lista.fromJson(e)).toList();

        for (var lista in listas) {
          if (lista.libros.any((libro) => libro.id == widget.idLibro)) {
            setState(() {
              estadoLectura = lista.nombreLista;
              if (estadoLectura == 'Read') {
                libroFinalizado = true;
              }
            });
            return;
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
    if (estadoLectura == "") {
      moverLibroA("To Read");
    } else if (estadoLectura == "To Read") {
      moverLibroA("Reading");
    } else if (estadoLectura == "Reading") {
      moverLibroA("Read");
    }
  }

  String obtenerSiguienteLista() {
    if (estadoLectura == "") {
      return "To Read";
    } else if (estadoLectura == "To Read") {
      return "Reading";
    } else if (estadoLectura == "Reading") {
      return "Read";
    } else {
      return "Read";
    }
  }

//reseñas-------------------------------------------------------------------------------------

// Obtener reseñas por libro
  Future<List<Review>> fetchResenas() async {
    final dio = await DioClient.getInstance();
    print("🚀 Iniciando la solicitud para obtener las reseñas...");

    try {
      print(
          "🔄 Realizando la petición GET a la URL: http://10.0.2.2:8080/api/resenas/libro/${widget.idLibro}");

      final response = await dio
          .get('http://10.0.2.2:8080/api/resenas/libro/${widget.idLibro}');
      print("✅ Respuesta recibida: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("👍 Respuesta 200 OK: Procesando las reseñas...");
        return (response.data as List).map((r) => Review.fromJson(r)).toList();
      } else {
        print(
            "❌ Error: Código de estado no 200, estado: ${response.statusCode}");
        throw Exception('Error al cargar reseñas');
      }
    } catch (e) {
      print("⚠️ Ocurrió un error: $e");
      throw Exception('Error: $e');
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mostrarSinopsisCompleta || libro.sinopsis.length <= 300
                            ? libro.sinopsis
                            : libro.sinopsis.substring(0, 300) + '...',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.justify,
                      ),
                      if (libro.sinopsis.length > 300)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              mostrarSinopsisCompleta =
                                  !mostrarSinopsisCompleta;
                            });
                          },
                          child: Text(
                            mostrarSinopsisCompleta
                                ? 'Mostrar menos'
                                : 'Leer más...',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Botón de progreso de lectura
                listasPredeterminadas.isEmpty
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: libroFinalizado ? null : manejarBotonLectura,
                        child: Text(
                            libroFinalizado ? 'Read' : obtenerSiguienteLista()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: libroFinalizado
                              ? Colors.grey
                              : const Color.fromARGB(255, 0, 0, 0),
                          foregroundColor: Colors.white,
                        ),
                      ),
                const SizedBox(height: 30),

                // Reseña y valoración
                //boton
                ElevatedButton.icon(
                  onPressed: () {
                    mostrarDialogoResena(context);
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    "Añadir review",
                    style: TextStyle(color: Colors.white), // texto blanco
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),

                SizedBox(height: 20),
                //lista de reseñas de otros usuarios
                FutureBuilder<List<Review>>(
                  future: _resenasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Error al cargar reseñas");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("Aún no hay reseñas.");
                    }

                    return Column(
                      children: snapshot.data!.map((review) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(review.avatarUsuario),
                            ),
                            title: Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.nombreUsuario,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(review.contenido),
                                SizedBox(height: 4),
                                Text(
                                  "Publicado el ${review.fecha.day}/${review.fecha.month}/${review.fecha.year}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          const Color.fromARGB(255, 0, 0, 0)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void mostrarDialogoResena(BuildContext context) {
    int estrellasSeleccionadas = 0;
    TextEditingController controllerTexto = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Nueva reseña"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < estrellasSeleccionadas
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setStateDialog(() {
                            estrellasSeleccionadas = index + 1;
                            print(
                                "Estrellas seleccionadas: $estrellasSeleccionadas");
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: controllerTexto,
                    decoration:
                        InputDecoration(hintText: "Escribe tu reseña..."),
                    maxLines: 3,
                    onChanged: (value) {
                      print("Texto de reseña actualizado: $value");
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    print("Diálogo cancelado");
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text("Enviar"),
                  onPressed: () async {
                    if (estrellasSeleccionadas < 1) {
                      // Mostrar error si no hay estrellas seleccionadas
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Error"),
                          content: Text(
                              "Por favor, selecciona al menos una estrella."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    if (controllerTexto.text.trim().isEmpty) {
                      // Mostrar error si el texto está vacío
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Error"),
                          content: Text("Por favor, escribe una reseña."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    print("Enviando reseña...");
                    print("Texto: ${controllerTexto.text}");
                    print("Estrellas: $estrellasSeleccionadas");
                    final dio = await DioClient.getInstance();
                    try {
                      await dio.post(
                        'http://10.0.2.2:8080/api/resenas/${widget.idLibro}',
                        data: {
                          'rating': estrellasSeleccionadas,
                          'contenido': controllerTexto.text,
                        },
                      );
                      print("Reseña enviada correctamente.");
                    } catch (e) {
                      print("Error al enviar la reseña: $e");
                    }
                    Navigator.of(context).pop();
                    setState(() {
                      print("Refrescando lista de reseñas...");
                      _resenasFuture = fetchResenas();
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
