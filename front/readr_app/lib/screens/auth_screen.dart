import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // Controla si estamos en login o registro
  final _formKey = GlobalKey<FormState>(); // Llave para validar el formulario
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final String apiUrl = "http://10.0.2.2:8080/auth";

  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> loginUser(String email, String password) async {
    try {
      print("Datos enviados: ${jsonEncode({
            "email": email,
            "password": password
          })}");
      final response = await http.post(
        Uri.parse("$apiUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Código de estado: ${response.statusCode}");
      print("Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Inicio de sesión exitoso: ${data["message"]}");
        Navigator.pushReplacementNamed(context, "/perfil_screen");
      } else {
        print("Error en el login: ${response.body}");
      }
    } catch (error) {
      print("Error de conexión: $error");
    }
  }

  Future<void> registerUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      if (response.statusCode == 201) {
        var data = jsonDecode(response.body);
        print("Registro exitoso: ${data["message"]}");
        Navigator.pushReplacementNamed(context, "/perfil_screen");
      } else {
        print("Error en el registro: ${response.body}");
      }
    } catch (error) {
      print("Error de conexión: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin ? "Iniciar Sesión" : "Registro",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (!isLogin)
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "El nombre es obligatorio";
                      }
                      return null;
                    },
                  ),
                TextFormField(
                  controller: emailController,
                  decoration:
                      const InputDecoration(labelText: "Correo Electrónico"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El correo es obligatorio";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Contraseña"),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "La contraseña debe tener al menos 6 caracteres";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();
                      String name = nameController.text.trim();

                      if (isLogin) {
                        loginUser(email, password);
                      } else {
                        registerUser(name, email, password);
                      }
                    }
                  },
                  child: Text(isLogin ? "Iniciar Sesión" : "Registrarse"),
                ),
                TextButton(
                  onPressed: toggleAuthMode,
                  child: Text(isLogin
                      ? "¿No tienes cuenta? Regístrate"
                      : "¿Ya tienes cuenta? Inicia sesión"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
