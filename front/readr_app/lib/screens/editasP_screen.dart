import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class EditarPerfil extends StatefulWidget {
  final int userId;

  const EditarPerfil({required this.userId});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final TextEditingController _nombreController = TextEditingController();
  File? _imagenSeleccionada;

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  Future<void> guardarCambios() async {
    final uri =
        Uri.parse('http://10.0.2.2:8080/api/usuarios/editar/${widget.userId}');
    var request = http.MultipartRequest('PUT', uri);

    request.fields['nombre'] = _nombreController.text;

    if (_imagenSeleccionada != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        _imagenSeleccionada!.path,
      ));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Perfil actualizado');
      Navigator.pop(context); // volver atrás
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 10),
            _imagenSeleccionada != null
                ? Image.file(_imagenSeleccionada!, height: 100)
                : Text("No se ha seleccionado imagen"),
            ElevatedButton(
              onPressed: seleccionarImagen,
              child: Text('Seleccionar Imagen'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: guardarCambios,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
