import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'perfilAjeno_screen.dart';
import 'usuario.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  List<Usuario> _usuarios = [];
  bool _isLoading = false;

  Future<void> buscarUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    final String nombre = _controller.text;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/usuarios/nombre/$nombre'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          _usuarios = [
            Usuario.fromJson(data)
          ]; // lo convertimos en lista con un solo elemento
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Error en la API: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error al obtener datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar Usuarios')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: buscarUsuarios,
              child: Text('Buscar'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _usuarios.length,
                      itemBuilder: (context, index) {
                        final usuario = _usuarios[index];
                        return ListTile(
                          title: Text(usuario.nombre),
                          subtitle: Text(usuario.email),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PerfilAjenoScreen(usuarioP: usuario),
                              ),
                            );
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
