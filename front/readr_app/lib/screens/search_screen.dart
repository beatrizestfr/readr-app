import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'perfilAjeno_screen.dart';
import 'usuario.dart';
import 'LibroDetalle_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  List<Usuario> _usuarios = [];
  List<dynamic> _resultados =
      []; // Lista que contendrá tanto usuarios como libros
  bool _isLoading = false;

  Future<void> buscarUsuariosYLibros() async {
    setState(() {
      _isLoading = true;
      _resultados = []; // Limpiar resultados anteriores
    });

    final String query = _controller.text;

    try {
      // Buscar usuarios
      final usuariosResponse = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/usuarios/nombre/$query'),
      );

      if (usuariosResponse.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(usuariosResponse.body);
        setState(() {
          _usuarios = [Usuario.fromJson(data)];
          _resultados.addAll(_usuarios);
        });
      }

      // Buscar libros
      final librosResponse = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/libros/buscar?titulo=$query'),
      );

      if (librosResponse.statusCode == 200) {
        List<dynamic> librosData = jsonDecode(librosResponse.body);
        setState(() {
          _resultados.addAll(librosData); // Agregar libros a los resultados
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error al obtener datos: $e');
    }
  }

  // Función para agregar un libro a la base de datos
  Future<void> agregarLibro(int id) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/libros/agregar'),
      body: {
        'titulo':
            'Titulo del libro', // Aquí agregas el título y autor si lo tienes.
        'autor': 'Autor del libro',
      },
    );

    if (response.statusCode == 201) {
      print("Libro agregado exitosamente");
    } else {
      print("Error al agregar libro");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar Usuarios y Libros')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre o título de libro',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: buscarUsuariosYLibros,
              child: Text('Buscar'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _resultados.length,
                      itemBuilder: (context, index) {
                        final item = _resultados[index];
                        if (item is Usuario) {
                          // Mostrar usuario
                          return ListTile(
                            title: Text(item.nombre),
                            subtitle: Text(item.email),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PerfilAjenoScreen(usuarioP: item),
                                ),
                              );
                            },
                          );
                        } else if (item is Map<String, dynamic>) {
                          // Mostrar libro
                          return ListTile(
                            title: Text(item['title'] ?? 'Sin título'),
                            subtitle: Text(item['author'] ?? 'Sin autor'),
                            onTap: () async {
                              // Primero agregar el libro
                              await agregarLibro(
                                  item['id']); // Agregar el libro

                              // Después navegar a la pantalla de detalles
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LibroDetalle_screen(idLibro: item['id']),
                                ),
                              );
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
