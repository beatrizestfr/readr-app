import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'perfilAjeno_screen.dart';
import 'usuario.dart';

class SeguidosScreen extends StatefulWidget {
  final int idUsuario;
  const SeguidosScreen({super.key, required this.idUsuario});

  @override
  State<SeguidosScreen> createState() => _SeguidosScreenState();
}

class _SeguidosScreenState extends State<SeguidosScreen> {
  List<Usuario> seguidosList = [];

  @override
  void initState() {
    super.initState();
    cargarSeguidos();
  }

  Future<void> cargarSeguidos() async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2:8080/api/usuarios/siguiendo/${widget.idUsuario}'));

    if (response.statusCode == 200) {
      final List<dynamic> seguidosData = json.decode(response.body);
      setState(() {
        seguidosList = seguidosData.map((e) => Usuario.fromJson(e)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar los seguidos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seguidos")),
      body: ListView.builder(
        itemCount: seguidosList.length,
        itemBuilder: (context, index) {
          final usuario = seguidosList[index];
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
