import 'package:flutter/material.dart';
import '../core/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/Libro.dart';
import '../models/Lista.dart';

class SearchLibro_screen extends StatefulWidget {
  final int idLista;

  const SearchLibro_screen({Key? key, required this.idLista}) : super(key: key);

  @override
  _SearchLibroScreenState createState() => _SearchLibroScreenState();
}

class _SearchLibroScreenState extends State<SearchLibro_screen> {
  TextEditingController _controller = TextEditingController();
  List<dynamic> _resultados = [];
  bool _isLoading = false;

  // Buscar libros
  Future<void> buscarLibros() async {
    setState(() {
      _isLoading = true;
      _resultados = [];
    });

    final String query = _controller.text.trim();
    print("Buscando libros con el título: $query");

    try {
      final dio = await DioClient.getInstance();
      final response = await dio.get(
        'http://10.0.2.2:8080/api/libros/buscar',
        queryParameters: {'titulo': query},
      );

      if (response.statusCode == 200) {
        print("Respuesta de la API: ${response.data}");
        setState(() {
          _resultados = response.data;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ Error al buscar libros: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Agregar libro a una lista de lectura
  Future<void> agregarLibroAListaEnLista(int libroId) async {
    try {
      final dio = await DioClient.getInstance();
      final response = await dio.put(
        'http://10.0.2.2:8080/api/listas-lectura/${widget.idLista}/libros/$libroId',
      );

      print("📨 Respuesta: ${response.data}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Libro añadido a la lista"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No se pudo agregar el libro"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("🔥 Error al agregar libro a lista: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al agregar el libro"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Agregar libro a la base de datos
  Future<int?> agregarLibroAListaBaseDeDatos(
      String titulo, String autor) async {
    try {
      final dio = await DioClient.getInstance();
      final response = await dio.post(
        'http://10.0.2.2:8080/api/libros/agregar',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: {
          'titulo': titulo,
          'autor': autor,
        },
      );

      if (response.statusCode == 201) {
        final int idLibro = int.parse(response.data.toString());
        print("✅ Libro agregado con ID: $idLibro");
        return idLibro;
      } else {
        print("❌ Error al agregar libro. Código: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("🔥 Excepción al agregar libro: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar Libros')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Buscar por título de libro',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: buscarLibros,
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
                        final String titulo = item['title'] ?? 'Sin título';
                        final String autor = (item['authors'] is List)
                            ? (item['authors'] as List).join(', ')
                            : (item['authors']?.toString() ?? 'Sin autor');

                        return ListTile(
                          title: Text(titulo),
                          subtitle: Text(autor),
                          onTap: () async {
                            final int? libroId =
                                await agregarLibroAListaBaseDeDatos(
                                    titulo, autor);
                            if (libroId != null) {
                              await agregarLibroAListaEnLista(libroId);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("No se pudo agregar el libro"),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
