import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'seguidores_screen.dart';
import 'seguidos_screen.dart';
import 'Lista.dart';
import 'LibroDetalle_screen.dart';
import 'Libro.dart';
import 'editasP_screen.dart';
import 'listaListaslibros_screen.dart';
import '../core/dio_client.dart';
import 'package:dio/dio.dart';
import 'listaLecturaDetalles_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String avatarUrl = ""; // URL de la foto del usuario
  int seguidores = 0;
  int seguidos = 0;
  String nombreUsuario = "";

  List<Lista> listas = [];
  List<Libro> libros = [];

  int? idUsuario;

  final String baseUrl = 'http://10.0.2.2:8080/api/usuarios';
  Dio? dio;

  @override
  void initState() {
    super.initState();
    _initializeDio();
    cargarIdUsuario();
  }

  // Método para inicializar Dio
  Future<void> _initializeDio() async {
    dio = await DioClient.getInstance(); // Ahora se obtiene de forma asíncrona
    // Llama al API o lo que necesites hacer después de que dio esté listo
  }

  Future<void> cargarIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    final nombre = prefs.getString('userName');

    if (id != null) {
      setState(() {
        idUsuario = id;
        nombreUsuario = nombre ?? "Usuario";
      });

      await cargarDatosPerfil();
      await cargarListasYLibros();
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
          avatarUrl = usuarioData['avatarUrl'] != null &&
                  usuarioData['avatarUrl'].isNotEmpty
              ? 'http://10.0.2.2:8080${usuarioData['avatarUrl']}'
              : "";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombreUsuario.isNotEmpty ? nombreUsuario : 'Perfil'),
        centerTitle: true,
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
            ],
          ),
        ),
      ),
    );
  }
}
