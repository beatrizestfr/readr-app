import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import 'Lista.dart';
import 'listaLecturaDetalles_screen.dart';

class listaListaslibros_screen extends StatefulWidget {
  const listaListaslibros_screen({Key? key}) : super(key: key);

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
      final response = await dio.get('http://10.0.2.2:8080/api/listas-lectura');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus listas'),
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
                                ),
                              ),
                            );
                            _cargarListas(); // Refrescar al volver
                          },
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearYRedirigir,
        child: const Icon(Icons.add),
        tooltip: 'Agregar lista',
        backgroundColor: Colors.blue,
      ),
    );
  }
}
