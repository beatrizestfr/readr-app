import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'seguidores_screen.dart';
import 'seguidos_screen.dart';
import 'editasP_screen.dart';

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

  int? idUsuario;

  final String baseUrl = 'http://10.0.2.2:8080/api/usuarios';

  @override
  void initState() {
    super.initState();
    cargarIdUsuario();
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
                  child: const Text('Editar perfil'),
                ),
              ),
              const SizedBox(height: 20),
              const LinearProgressIndicator(
                value: 0.5,
                backgroundColor: Colors.grey,
                color: Colors.blue,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Listas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navegar a pantalla de listas
                    },
                    child: const Text('Ver todo'),
                  ),
                ],
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Ir a la pantalla de detalles de lista
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text('Lista ${index + 1}')),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Libros',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navegar a pantalla de libros
                    },
                    child: const Text('Ver todo'),
                  ),
                ],
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Ir a la pantalla de detalles de libro
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text('Libro ${index + 1}')),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
