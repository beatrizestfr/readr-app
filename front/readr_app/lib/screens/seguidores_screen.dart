import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'perfilAjeno_screen.dart';
import '../models/usuario.dart';

class SeguidoresScreen extends StatefulWidget {
  final int idUsuario;
  const SeguidoresScreen({super.key, required this.idUsuario});

  @override
  State<SeguidoresScreen> createState() => _SeguidoresScreenState();
}

class _SeguidoresScreenState extends State<SeguidoresScreen> {
  List<Usuario> seguidoresList = [];

  @override
  void initState() {
    super.initState();
    cargarSeguidores();
  }

  Future<void> cargarSeguidores() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2:8080/api/usuarios/seguidores/${widget.idUsuario}'));

    if (response.statusCode == 200) {
      final List<dynamic> seguidoresData = json.decode(response.body);
      setState(() {
        seguidoresList =
            seguidoresData.map((e) => Usuario.fromJson(e)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron cargar los seguidores')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seguidores")),
      body: ListView.builder(
        itemCount: seguidoresList.length,
        itemBuilder: (context, index) {
          final usuario = seguidoresList[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: usuario.avatarUrl.isNotEmpty
                  ? NetworkImage(usuario.avatarUrl)
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
            ),
            title: Text(usuario.nombre),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerfilAjenoScreen(usuarioP: usuario),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
