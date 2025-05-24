import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../core/dio_client.dart';

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
    print("🖼️ Abriendo galería para seleccionar imagen...");
    final pickedFile = await picker.pickImage(
        source:
            ImageSource.gallery); //image picker permite acceder a la galeria

    if (pickedFile != null) {
      print("✅ Imagen seleccionada: ${pickedFile.path}");
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    } else {
      print("❌ No se seleccionó ninguna imagen.");
    }
  }

  Future<void> guardarCambios() async {
    try {
      print("🚀 Iniciando proceso de guardado...");
      Dio dio = await DioClient.getInstance();

      String url = 'http://10.0.2.2:8080/api/usuarios/editar/${widget.userId}';
      print("🔗 Endpoint: $url");

      Map<String, dynamic> dataMap = {
        'nombre': _nombreController.text,
      };

      if (_imagenSeleccionada != null) {
        print("📤 Preparando imagen para envío: ${_imagenSeleccionada!.path}");
        dataMap['avatar'] = await MultipartFile.fromFile(
          _imagenSeleccionada!.path,
          filename: _imagenSeleccionada!.path.split('/').last,
        );
      } else {
        print("⚠️ No hay imagen nueva seleccionada.");
      }

      FormData formData = FormData.fromMap(dataMap);

      final response = await dio.put(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        print("🎉 Perfil actualizado correctamente.");
        Navigator.pop(context);
      } else {
        print("❌ Error al actualizar: Código ${response.statusCode}");
      }
    } catch (e) {
      print("💥 Excepción al guardar perfil: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                  ),
                  SizedBox(height: 20),
                  if (_imagenSeleccionada != null)
                    Image.file(_imagenSeleccionada!, height: 100),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: seleccionarImagen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Seleccionar Imagen'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: guardarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Guardar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
