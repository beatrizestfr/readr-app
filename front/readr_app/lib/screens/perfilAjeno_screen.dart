import 'package:flutter/material.dart';
import 'usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'seguidores_screen.dart';
import 'seguidos_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    seguidores = 0;
    seguidos = 0;
    siguiendo = false;
    seguidoresList = [];
    seguidosList = [];
    _obtenerDatosUsuario();
    verificarSiSiguiendo();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuarioP.nombre),
        centerTitle: true,
      ),
      body: Padding(
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
                                    fontWeight: FontWeight.bold, fontSize: 18)),
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
                                    fontWeight: FontWeight.bold, fontSize: 18)),
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
            const LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey,
              color: Colors.blue,
            ),
            const SizedBox(height: 30),
            _buildSection('Listas', Colors.blue[100], 'Lista'),
            const SizedBox(height: 20),
            _buildSection('Libros', Colors.green[100], 'Libro'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Color? color, String itemPrefix) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                // Navegar a pantalla correspondiente
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
                  // Navegar a detalle
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('$itemPrefix ${index + 1}')),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
