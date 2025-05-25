import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'seguidores_screen.dart';
import 'seguidos_screen.dart';
import '../models/Lista.dart';
import 'LibroDetalle_screen.dart';
import '../models/Libro.dart';
import '../models/Review.dart';
import 'editasP_screen.dart';
import 'listaListaslibros_screen.dart';
import '../core/dio_client.dart';
import 'package:dio/dio.dart';
import 'listaLecturaDetalles_screen.dart';
import 'package:intl/intl.dart';

class PerfilScreen extends StatefulWidget {
  //puede cambiar mientras se muestra en la app
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() =>
      _PerfilScreenState(); //StatefulWidget necesita
  // una clase extra para manejar el estado dinámico
}

class _PerfilScreenState extends State<PerfilScreen> {
  String avatarUrl = ""; // URL de la foto del usuario
  int seguidores = 0;
  int seguidos = 0;
  String nombreUsuario = "";

  List<Review> resenas = [];
  List<bool> expandedList = [];

  List<Lista> listas = [];
  List<Libro> libros = [];

  int? idUsuario;

  final String baseUrl = 'http://10.0.2.2:8080/api/usuarios';
  Dio? dio; // librería para hacer peticiones HTTP

  @override
  void initState() {
    super.initState();
    _initializeDio();
    cargarIdUsuario();
  }

  // Método para inicializar Dio
  Future<void> _initializeDio() async {
    dio = await DioClient.getInstance(); // Ahora se obtiene de forma asíncrona
  }

  Future<void> cargarIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    final nombre = prefs.getString('userName');

    if (id != null) {
      setState(() {
        //avisa a Flutter que ha cambiado algo y necesita redibujar la pantalla
        idUsuario = id;
        nombreUsuario = nombre ?? "Usuario";
      });

      print("🧠 ID del usuario cargado: $idUsuario");

      // Carga el resto de los datos
      await cargarDatosPerfil();
      await cargarListasYLibros();
      await fetchResenasDeUsuario();
      setState(() {}); // Actualiza la UI después de cargar las reseñas
    } else {
      print("No se encontró el ID del usuario en SharedPreferences.");
    }
  }

  Future<void> cargarDatosPerfil() async {
    if (idUsuario == null) return;

    try {
      // Obtener los datos de seguidores
      final responseSeguidores =
          await http.get(Uri.parse('$baseUrl/seguidores/$idUsuario'));
      final responseSeguidos =
          await http.get(Uri.parse('$baseUrl/siguiendo/$idUsuario'));
      final responseUsuario = await http.get(Uri.parse('$baseUrl/$idUsuario'));

      // Verificar si la respuesta de los seguidores y seguidos fue exitosa
      if (responseSeguidores.statusCode == 200 &&
          responseSeguidos.statusCode == 200) {
        final List<dynamic> seguidoresData =
            json.decode(responseSeguidores.body);
        final List<dynamic> seguidosData = json.decode(responseSeguidos.body);

        setState(() {
          seguidores = seguidoresData.length;
          seguidos = seguidosData.length;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('No se pudieron cargar los datos de seguidores/seguidos'),
        ));
      }

      // Verificar si la respuesta del usuario fue exitosa
      if (responseUsuario.statusCode == 200) {
        final usuarioData = json.decode(responseUsuario.body);

        setState(() {
          // Actualizamos los datos del nombre y avatar
          nombreUsuario =
              usuarioData['nombre'] ?? 'Usuario'; // Cambié a 'nombre'
          avatarUrl = usuarioData['avatarUrl'] ?? "";
          print("🖼️ Avatar final a mostrar: $avatarUrl");
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No se pudieron cargar los datos del usuario'),
        ));
      }
    } catch (e) {
      print('Error al cargar datos del perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al cargar los datos del perfil'),
      ));
    }
  }

  Future<void> cargarListasYLibros() async {
    try {
      final dio = await DioClient.getInstance();

      if (dio != null) {
        print("🚀 Iniciando carga de listas y libros...");

        // Obtener listas de lectura
        final responseListas = await dio.get(
          'http://10.0.2.2:8080/api/listas-lectura',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        // Obtener libros de la lista "Read"
        final responseLibros = await dio.get(
          'http://10.0.2.2:8080/api/listas-lectura/read',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );
        // Comprobamos si las respuestas son correctas
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
      } else {
        print("Dio es nulo, no se pueden hacer las solicitudes");
      }
    } catch (e) {
      print("Error al cargar listas/libros: $e");
    }
  }

  Future<void> fetchResenasDeUsuario() async {
    if (idUsuario == null) return;
    final dio = await DioClient.getInstance();
    print("🚀 Iniciando la solicitud para obtener las reseñas del usuario...");

    try {
      final url = 'http://10.0.2.2:8080/api/resenas/usuario/$idUsuario';

      final response = await dio.get(url);

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

  Future<void> logoutUser(BuildContext context) async {
    final String logoutUrl = "http://10.0.2.2:8080/auth/logout";

    try {
      final dio = await DioClient.getInstance();

      final response = await dio.post(
        logoutUrl,
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      print("🚪 Logout status: ${response.statusCode}");

      // Limpia datos locales del usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('userName');
      print("🧹 SharedPreferences limpiado");

      // Redirige al usuario al login (AuthScreen)
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (Route<dynamic> route) => false,
      );
    } on DioException catch (e) {
      print(
          "⚠️ Error al hacer logout: ${e.response?.statusCode} - ${e.response?.data}");
      // Opcional: Mostrar un diálogo o snackbar de error
    } catch (e) {
      print("💥 Excepción inesperada durante logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombreUsuario.isNotEmpty ? nombreUsuario : 'Perfil'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await logoutUser(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Cerrar sesión'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Foto de perfil
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 20),
                  // Seguidores y Seguidos
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SeguidoresScreen(idUsuario: idUsuario!),
                                  ),
                                );
                              },
                              child: Text(
                                '$seguidores',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            const Text('Seguidores'),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SeguidosScreen(idUsuario: idUsuario!),
                                  ),
                                );
                              },
                              child: Text(
                                '$seguidos',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
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
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarPerfil(userId: idUsuario!),
                      ),
                    );
                    await cargarIdUsuario();
                    setState(
                        () {}); // Esto fuerza la reconstrucción del widget con los datos nuevos
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  child: const Text(
                    'Editar perfil',
                    style: TextStyle(color: Colors.white), // texto blanco
                  ),
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
                                  idUsuario: idUsuario!,
                                  esPropio: true,
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
                                        esPropia: true,
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
                                  esPropia: true,
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
