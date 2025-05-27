import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import '../models/Lista.dart';
import 'listaLecturaDetalles_screen.dart';

class listaListaslibros_screen extends StatefulWidget {
  final int idUsuario;
  final bool esPropio;

  const listaListaslibros_screen({
    Key? key,
    required this.idUsuario,
    required this.esPropio,
  }) : super(key: key);

  @override
  _ListaListasLibrosScreenState createState() =>
      _ListaListasLibrosScreenState();
}

class _ListaListasLibrosScreenState extends State<listaListaslibros_screen> {
  List<Lista> listas = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _cargarListas();
  }

  Future<void> _cargarListas() async {
    final dio = await DioClient.getInstance();

    try {
      final response = await dio.get(
          'http://10.0.2.2:8080/api/listas-lectura/usuario/${widget.idUsuario}');

      if (response.statusCode == 200) {
        final List data = response.data;
        setState(() {
          listas = data.map((item) => Lista.fromJson(item)).toList();
          loading = false;
        });
      } else {
        _mostrarError("Error al cargar listas.");
      }
    } catch (e) {
      _mostrarError("Error de conexión: $e");
    }
  }

  Future<void> _crearYRedirigir() async {
    final dio = await DioClient.getInstance();

    final nombreLista = await showDialog<String>(
      context: context,
      builder: (context) {
        String nombre = '';
        return AlertDialog(
          title: const Text("Nueva Lista de Lectura"),
          content: TextField(
            onChanged: (value) => nombre = value,
            decoration: const InputDecoration(hintText: "Nombre de la lista"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(nombre),
              child: const Text("Crear"),
            ),
          ],
        );
      },
    );

    if (nombreLista == null || nombreLista.trim().isEmpty) return;

    try {
      final response = await dio.post(
        'http://10.0.2.2:8080/api/listas-lectura',
        data: {'nombreLista': nombreLista},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final nuevaLista = Lista.fromJson(response.data);

        // Redirige directamente a la nueva lista
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListaLecturaDetallesScreen(
              idLista: nuevaLista.idLista,
              nombreLista: nuevaLista.nombreLista,
              esPropia: widget.esPropio,
            ),
          ),
        );

        _cargarListas(); // Recargar al volver
      } else {
        _mostrarError("Error al crear la lista.");
      }
    } catch (e) {
      _mostrarError("Error de conexión o formato: $e");
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _confirmarEliminarLista(int idLista) async {
    final dio = await DioClient.getInstance();

    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Estás seguro?"),
        content: const Text(
            "¿Quieres eliminar esta lista de lectura? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      try {
        final response = await dio
            .delete('http://10.0.2.2:8080/api/listas-lectura/$idLista');
        if (response.statusCode == 204) {
          _mostrarError("Lista eliminada correctamente.");
          _cargarListas();
        } else {
          _mostrarError("No se pudo eliminar la lista.");
        }
      } catch (e) {
        _mostrarError("Error al eliminar la lista: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('listas de lectura'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : listas.isEmpty
              ? const Center(child: Text('No tienes listas todavía'))
              : RefreshIndicator(
                  onRefresh: _cargarListas,
                  child: ListView.builder(
                    itemCount: listas.length,
                    itemBuilder: (context, index) {
                      final lista = listas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          title: Text(lista.nombreLista,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Libros: ${lista.libros.length}'),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ListaLecturaDetallesScreen(
                                  idLista: lista.idLista,
                                  nombreLista: lista.nombreLista,
                                  esPropia: widget.esPropio,
                                ),
                              ),
                            );
                            _cargarListas(); // Refrescar al volver
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!["read", "to read", "reading"]
                                  .contains(lista.nombreLista.toLowerCase()))
                                if (widget.esPropio &&
                                    ![
                                      "read",
                                      "to read",
                                      "reading"
                                    ].contains(lista.nombreLista.toLowerCase()))
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.black),
                                    tooltip: 'Eliminar lista',
                                    onPressed: () =>
                                        _confirmarEliminarLista(lista.idLista),
                                  ),
                              const Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: widget.esPropio
          ? FloatingActionButton(
              onPressed: _crearYRedirigir,
              child: const Icon(
                Icons.add,
                color: Colors.white, // Ícono blanco
              ),
              tooltip: 'Agregar lista',
              backgroundColor: Colors.black, // Fondo negro
            )
          : null,
    );
  }
}
