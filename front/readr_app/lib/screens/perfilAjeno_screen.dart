import 'package:flutter/material.dart';
import 'usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'seguidores_screen.dart';
import 'seguidos_screen.dart';
import 'Lista.dart';
import 'LibroDetalle_screen.dart';
import 'Libro.dart';
import 'listaListaslibros_screen.dart';
import '../core/dio_client.dart';
import 'package:dio/dio.dart';
import 'listaLecturaDetalles_screen.dart';
import '../models/Review.dart';
import 'package:intl/intl.dart';

class PerfilAjenoScreen extends StatefulWidget {
  final Usuario usuarioP;

  const PerfilAjenoScreen({Key? key, required this.usuarioP}) : super(key: key);

  @override
  _PerfilAjenoScreenState createState() => _PerfilAjenoScreenState();
}

class _PerfilAjenoScreenState extends State<PerfilAjenoScreen> {
  late int seguidores;
  late int seguidos;
  late bool siguiendo;
  late List<Usuario> seguidoresList;
  late List<Usuario> seguidosList;

  List<Lista> listas = [];
  List<Libro> libros = [];

  List<Review> resenas = [];
  List<bool> expandedList = [];

  Dio? dio;

  @override
  void initState() {
    super.initState();
    seguidores = 0;
    seguidos = 0;
    siguiendo = false;
    seguidoresList = [];
    seguidosList = [];
    _initializeDio();
    _obtenerDatosUsuario();
    _cargarListasYLibros();
    verificarSiSiguiendo();
    fetchResenasDeUsuario();
  }

  Future<void> _initializeDio() async {
    dio = await DioClient.getInstance(); // Ahora se obtiene de forma asíncrona
    // Llama al API o lo que necesites hacer después de que dio esté listo
  }

  Future<void> _obtenerDatosUsuario() async {
    // Obtén los seguidores y seguidos desde el backend
    final seguidoresResponse = await http.get(Uri.parse(
        'http://10.0.2.2:8080/api/usuarios/seguidores/${widget.usuarioP.idUsuario}'));
    final seguidosResponse = await http.get(Uri.parse(
        'http://10.0.2.2:8080/api/usuarios/siguiendo/${widget.usuarioP.idUsuario}'));

    if (seguidoresResponse.statusCode == 200 &&
        seguidosResponse.statusCode == 200) {
      // Procesa la respuesta
      final List<dynamic> seguidoresData = json.decode(seguidoresResponse.body);
      final List<dynamic> seguidosData = json.decode(seguidosResponse.body);

      setState(() {
        seguidores = seguidoresData.length;
        seguidos = seguidosData.length;
        seguidoresList =
            seguidoresData.map((item) => Usuario.fromJson(item)).toList();
        seguidosList =
            seguidosData.map((item) => Usuario.fromJson(item)).toList();
      });
    }
  }

  Future<void> verificarSiSiguiendo() async {
    final prefs = await SharedPreferences.getInstance();
    final idUsuarioSesion = prefs.getInt('userId');

    if (idUsuarioSesion != null) {
      final url =
          'http://10.0.2.2:8080/api/usuarios/siguiendo/$idUsuarioSesion/${widget.usuarioP.idUsuario}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final bool estaSiguiendo = json.decode(response.body) as bool;
        setState(() {
          siguiendo = estaSiguiendo;
        });
      } else {
        print("No se pudo verificar si se sigue al usuario");
      }
    }
  }

  Future<void> _seguirODejarDeSeguir() async {
    final prefs = await SharedPreferences.getInstance();
    final idUsuarioSesion = prefs.getInt('userId');
    final url = siguiendo
        ? 'http://10.0.2.2:8080/api/usuarios/dejarDeSeguir/${widget.usuarioP.idUsuario}'
        : 'http://10.0.2.2:8080/api/usuarios/seguir/${widget.usuarioP.idUsuario}';

    final response = await http.post(Uri.parse(url), body: {
      'idUsuario': idUsuarioSesion.toString(),
    });

    if (response.statusCode == 200) {
      setState(() {
        siguiendo = !siguiendo;
      });
    }
  }

  // Método para cargar listas y libros del perfil ajeno
  Future<void> _cargarListasYLibros() async {
    try {
      final dio = await DioClient.getInstance();

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          print('📤 Request: ${options.uri}');
          print('🧾 Headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Response: ${response.statusCode}');
          print('🍪 Cookies: ${response.headers['set-cookie']}');
          return handler.next(response);
        },
        onError: (e, handler) {
          print('❌ Error: ${e.response?.statusCode}');
          return handler.next(e);
        },
      ));

      // Obtener listas de lectura del usuario ajeno
      final responseListas = await dio.get(
        'http://10.0.2.2:8080/api/listas-lectura/usuario/${widget.usuarioP.idUsuario}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Obtener libros de la lista "Read" del usuario ajeno
      final responseLibros = await dio.get(
        'http://10.0.2.2:8080/api/listas-lectura/read/${widget.usuarioP.idUsuario}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (responseListas.statusCode == 200) {
        final data = responseListas.data as List;
        listas = data.map((item) => Lista.fromJson(item)).toList();
      } else {
        print("Error al obtener listas: ${responseListas.statusCode}");
      }

      if (responseLibros.statusCode == 200) {
        final data = responseLibros.data as List;
        libros = data.map((item) => Libro.fromJson(item)).toList();
      } else {
        print("Error al obtener libros: ${responseLibros.statusCode}");
      }

      setState(() {}); // Refresca la UI
    } catch (e) {
      print("Error al cargar listas/libros: $e");
    }
  }

  Future<void> fetchResenasDeUsuario() async {
    if (widget.usuarioP.idUsuario == null) return;
    final dio = await DioClient.getInstance();
    print("🚀 Iniciando la solicitud para obtener las reseñas del usuario...");

    try {
      final url =
          'http://10.0.2.2:8080/api/resenas/usuario/${widget.usuarioP.idUsuario}';
      print("🔄 Realizando la petición GET a la URL: $url");

      final response = await dio.get(url);
      print("✅ Respuesta recibida: ${response.statusCode}");

      if (response.statusCode == 200) {
        setState(() {
          print("👍 Respuesta 200 OK: Procesando las reseñas...");
          resenas =
              (response.data as List).map((r) => Review.fromJson(r)).toList();
          expandedList = List<bool>.filled(resenas.length, false);
        });
      } else {
        print("❌ Error: Código de estado no 200: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Ocurrió un error al cargar reseñas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuarioP.nombre),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // 👈 Añadido aquí
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: widget.usuarioP.avatarUrl.isNotEmpty
                        ? NetworkImage(widget.usuarioP.avatarUrl)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 20),
                  // cifras
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Navegar a la pantalla de seguidores
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeguidoresScreen(
                                        idUsuario: widget.usuarioP.idUsuario),
                                  ),
                                );
                              },
                              child: Text('$seguidores',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ),
                            const Text('Seguidores'),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Navegar a la pantalla de seguidos
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeguidosScreen(
                                        idUsuario: widget.usuarioP.idUsuario),
                                  ),
                                );
                              },
                              child: Text('$seguidos',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ),
                            const Text('Seguidos'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _seguirODejarDeSeguir,
                  child: Text(siguiendo ? 'Dejar de seguir' : 'Seguir'),
                ),
              ),
              const SizedBox(height: 20),
              // LISTAS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Listas',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => listaListaslibros_screen(
                                  idUsuario: widget.usuarioP.idUsuario,
                                  esPropio: false,
                                ),
                              ),
                            );
                          },
                          child: const Text('Ver más'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: listas.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: listas.length,
                            itemBuilder: (context, index) {
                              final lista = listas[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListaLecturaDetallesScreen(
                                        idLista: lista.idLista,
                                        nombreLista: lista.nombreLista,
                                        esPropia: false,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 213, 215, 216),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      lista.nombreLista ?? 'Sin nombre',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(child: Text('No hay listas')),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

              // LIBROS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Libros',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            final lista = listas.firstWhere(
                                (elemento) => elemento.nombreLista == 'Read');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ListaLecturaDetallesScreen(
                                  idLista: lista.idLista,
                                  nombreLista: lista.nombreLista,
                                  esPropia: false,
                                ),
                              ),
                            );
                          },
                          child: const Text('Ver más'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: libros.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: libros.length,
                            itemBuilder: (context, index) {
                              final libro = libros[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LibroDetalle_screen(
                                          idLibro: libro.id),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Imagen del libro
                                      Container(
                                        height: 120,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                libro.imagenUrl ?? ''),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      // Título debajo de la imagen
                                      Text(
                                        libro.titulo ?? 'Sin título',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(child: Text('No hay libros')),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              //lista de reseñas
              resenas.isEmpty
                  ? const Center(child: Text("Aún no hay reseñas."))
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: resenas.length,
                      itemBuilder: (context, index) {
                        final review = resenas[index];
                        final formattedDate =
                            DateFormat('dd/MM/yyyy').format(review.fecha);

                        // Control de truncado y expandido
                        final isExpanded = expandedList.length > index
                            ? expandedList[index]
                            : false;
                        final contenido = review.contenido;
                        final bool shouldTruncate = contenido.length > 200;
                        final displayText = (!shouldTruncate || isExpanded)
                            ? contenido
                            : contenido.substring(0, 200) + '...';

                        return Container(
                          constraints: const BoxConstraints(minHeight: 180),
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LibroDetalle_screen(
                                          idLibro: review.idLibro),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 120,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(review.imagenLibroUrl),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Puntuación estrellas
                                    Row(
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
                                    const SizedBox(height: 8),
                                    // Contenido de la reseña (truncado o completo)
                                    Text(displayText),
                                    if (shouldTruncate)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            expandedList[index] = !isExpanded;
                                          });
                                        },
                                        child: Text(
                                          isExpanded
                                              ? 'Mostrar menos'
                                              : 'Leer más',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    // Fecha publicación
                                    Text(
                                      'Publicado el $formattedDate',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
