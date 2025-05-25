import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'perfilAjeno_screen.dart';
import '../models/usuario.dart';
import 'LibroDetalle_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  List<Usuario> _usuarios = [];
  List<dynamic> _resultados = [];
  bool _isLoading = false;
  bool _isSearchingUsers =
      true; // Variable para controlar la búsqueda de usuarios o libros

  // Función para buscar usuarios y libros
  Future<void> buscarUsuariosYLibros() async {
    setState(() {
      _isLoading = true;
      _resultados = []; // Limpiar resultados anteriores
    });

    final String query = _controller.text;

    try {
      if (_isSearchingUsers) {
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
      } else {
        // Buscar libros
        final librosResponse = await http.get(
          Uri.parse('http://10.0.2.2:8080/api/libros/buscar?titulo=$query'),
        );

        if (librosResponse.statusCode == 200) {
          List<dynamic> librosData = jsonDecode(librosResponse.body);
          setState(() {
            _resultados.addAll(librosData);
          });
        }
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

  // Función para agregar un libro
  Future<int?> agregarLibro(String titulo, String autor) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/libros/agregar'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'titulo': titulo,
          'autor': autor,
        },
      );

      if (response.statusCode == 201) {
        final int idLibro = int.parse(response.body);
        return idLibro;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '                        Buscar',
          textAlign: TextAlign.center,
        ), // Título centrado
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pestañas para cambiar entre usuarios y libros
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón de "Usuarios"
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isSearchingUsers =
                          true; // Cambiar a búsqueda de usuarios
                      _resultados = []; // Limpiar resultados
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSearchingUsers
                        ? Colors.black
                        : Colors.grey[300], // Cambiar color de fondo
                    foregroundColor: _isSearchingUsers
                        ? Colors.white
                        : Colors.black, // Cambiar color de texto
                  ),
                  child: const Text('Usuarios'),
                ),
                const SizedBox(width: 20),
                // Botón de "Libros"
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isSearchingUsers = false; // Cambiar a búsqueda de libros
                      _resultados = []; // Limpiar resultados
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isSearchingUsers
                        ? Colors.black
                        : Colors.grey[300], // Cambiar color de fondo
                    foregroundColor: !_isSearchingUsers
                        ? Colors.white
                        : Colors.black, // Cambiar color de texto
                  ),
                  child: const Text('Libros'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: _isSearchingUsers
                          ? 'Buscar por nombre de usuario'
                          : 'Buscar por título de libro',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: buscarUsuariosYLibros,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _resultados.length,
                      itemBuilder: (context, index) {
                        final item = _resultados[index];
                        if (_isSearchingUsers && item is Usuario) {
                          // Mostrar usuario
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(item.avatarUrl),
                            ),
                            title: Text(item.nombre),
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
                        } else if (!_isSearchingUsers &&
                            item is Map<String, dynamic>) {
                          // Mostrar libro
                          return ListTile(
                            leading: item['imagenUrl'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['imagenUrl'],
                                      width: 50,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.book);
                                      },
                                    ),
                                  )
                                : const Icon(Icons
                                    .book), // Si no hay imagen, mostrar un icono genérico
                            title: Text(item['title'] ?? 'Sin título'),
                            subtitle: Text(
                              item['authors'] is List
                                  ? (item['authors'] as List).join(', ')
                                  : (item['authors']?.toString() ??
                                      'Sin autor'),
                            ),
                            onTap: () async {
                              final String titulo =
                                  item['title'] ?? 'Sin título';
                              final String autor = item['authors'] is List
                                  ? (item['authors'] as List).join(', ')
                                  : (item['authors']?.toString() ??
                                      'Sin autor');
                              final int? idLibro =
                                  await agregarLibro(titulo, autor);

                              if (idLibro != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LibroDetalle_screen(idLibro: idLibro),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("No se pudo agregar el libro")),
                                );
                              }
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
