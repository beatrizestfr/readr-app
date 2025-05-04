import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/dio_client.dart';

class AuthScreen extends StatefulWidget {
  // estado mutable , cambia entre login y register
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // variales de estado
  bool isLogin = true; // Controla si estamos en login o registro
  final _formKey = GlobalKey<FormState>(); // Llave para validar el formulario
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final Dio dio = Dio();
  final String apiUrl = "http://10.0.2.2:8080/auth";

  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> loginUser(
      String email, String password, BuildContext context) async {
    try {
      final dio = await DioClient.getInstance();

      final response = await dio.post(
        "$apiUrl/login",
        data: {
          "email": email,
          "password": password,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      print("Código de estado: ${response.statusCode}");
      print("Datos recibidos: ${response.data}");

      // Imprimir las cookies de la respuesta
      final cookies = response.headers['set-cookie'];
      if (cookies != null && cookies.isNotEmpty) {
        print('JSESSIONID: ${cookies[0]}');
      } else {
        print('No se encontró JSESSIONID en las cookies');
      }

      if (response.statusCode == 200) {
        final data = response.data;

        // Guardar ID y nombre en SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', data['id']);
        await prefs.setString('userName', data['nombre']);

        print('ID guardado: ${data['id']}');
        print('Nombre guardado: ${data['nombre']}');

        // Ir a la pantalla principal
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        print("Error en el login: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      print("Error de Dio: ${e.response?.statusCode} - ${e.response?.data}");
    } catch (error) {
      print("Error general: $error");
    }
  }

  Future<void> registerUser(String nombre, String email, String password,
      BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"email": email, "password": password, "nombre": nombre}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Registro exitoso: ${data["message"]}");

// Guardar ID y nombre en SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', data['id']);
        await prefs.setString('userName', data['nombre']);

        Navigator.pushReplacementNamed(context, "/home");
      } else {
        print("Error en el registro: ${response.body}");
      }
    } catch (error) {
      print("Error de conexión: $error");
    }
  }

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Imagen en la parte superior
          Container(
            width: double.infinity,
            height:
                MediaQuery.of(context).size.height * 0.3, // Menos de un tercio
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/logo2.png"), // Asegúrate de que el archivo esté en tu proyecto
              ),
            ),
          ),
          // Formulario dentro de una caja con borde negro
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(
                    30.0), // Espacio entre el formulario y la pantalla
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black), // Borde negro
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLogin ? "Iniciar Sesión" : "Registro",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!isLogin)
                          TextFormField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(labelText: "Nombre"),
                            validator: (value) => value == null || value.isEmpty
                                ? "El nombre es obligatorio"
                                : null,
                          ),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                              labelText: "Correo Electrónico"),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value == null || value.isEmpty
                              ? "El correo es obligatorio"
                              : null,
                        ),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText:
                              _obscurePassword, // Aquí se controla si el texto está oculto o visible
                          validator: (value) => value == null ||
                                  value.length < 6
                              ? "La contraseña debe tener al menos 6 caracteres"
                              : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              String email = emailController.text.trim();
                              String password = passwordController.text.trim();
                              String name = nameController.text.trim();
                              if (isLogin) {
                                loginUser(email, password, context);
                              } else {
                                registerUser(name, email, password, context);
                              }
                            }
                          },
                          child: Text(
                            isLogin ? "Iniciar Sesión" : "Registrarse",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: toggleAuthMode,
                          child: Text(
                            isLogin
                                ? "¿No tienes cuenta? Regístrate"
                                : "¿Ya tienes cuenta? Inicia sesión",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 0, 0, 0),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
