import 'package:flutter/material.dart';
import 'Libro.dart';
import 'LibroDetalle_screen.dart';
import 'Lista.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/dio_client.dart';
import 'package:dio/dio.dart';

class ListaLecturaDetallesScreen extends StatefulWidget {
  final int idLista;
  final String nombreLista;

  const ListaLecturaDetallesScreen({
    Key? key,
    required this.idLista,
    required this.nombreLista,
  }) : super(key: key);

  @override
  State<ListaLecturaDetallesScreen> createState() =>
      _ListaLecturaDetallesScreenState();
}

class _ListaLecturaDetallesScreenState
    extends State<ListaLecturaDetallesScreen> {
  late Future<List<Libro>> _librosFuture;

  @override
  void initState() {
    super.initState();
    _librosFuture = fetchLibrosDeLista(widget.idLista);
  }

  Future<List<Libro>> fetchLibrosDeLista(int idLista) async {
    final dio = await DioClient.getInstance();

    final url = 'http://10.0.2.2:8080/api/listas-lectura/libros/id/$idLista';
    print('📡 Llamando a la API: $url');

    try {
      final response = await dio.get(url);
      print('📥 Status code: ${response.statusCode}');
      print('📥 Data recibido: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Si `data` ya es una lista dinámica
        if (data is List) {
          print('📦 JSON parseado: $data');

          for (var i = 0; i < data.length; i++) {
            print('🔍 Item $i: ${data[i]}');
          }

          return data.map((jsonItem) {
            try {
              final libro = Libro.fromJson(jsonItem);
              print('✅ Libro creado: $libro');
              return libro;
            } catch (e) {
              print('❌ Error al parsear libro: $e');
              throw Exception('Error al parsear un libro');
            }
          }).toList();
        } else {
          print('❌ Error: se esperaba una lista, pero se recibió: $data');
          throw Exception('La respuesta no es una lista de libros');
        }
      } else {
        print('❌ Error en la respuesta: ${response.statusCode}');
        throw Exception('No se pudieron cargar los libros de la lista');
      }
    } catch (e) {
      print('❌ Excepción al hacer la petición: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreLista,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Libro>>(
        future: _librosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Esta lista no tiene libros.'));
          }

          final libros = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: libros.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columnas
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.55,
              ),
              itemBuilder: (context, index) {
                final libro = libros[index];
                return GestureDetector(
                  onTap: () {
                    // Navegar a la pantalla de detalles del libro
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LibroDetalle_screen(
                          idLibro: libro.id,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(libro.imagenUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        libro.titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
