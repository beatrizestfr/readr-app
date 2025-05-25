import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/dio_client.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>(); // validar el formulario
  //Controladores de texto que permiten leer y manipular el texto ingresado
  //en los campos correspondientes
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final String apiUrl = "http://10.0.2.2:8080/auth";
  bool _obscurePassword = true;

  String? loginErrorMessage;

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
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print("🔐 Código de estado: ${response.statusCode}");
      print("📥 Datos recibidos: ${response.data}");

      final cookies = response.headers['set-cookie'];
      if (cookies != null && cookies.isNotEmpty) {
        print('🍪 JSESSIONID: ${cookies[0]}');
      } else {
        print('❌ No se encontró JSESSIONID en las cookies');
      }

      if (response.statusCode == 200) {
        final data = response.data;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', data['id']);
        await prefs.setString('userName', data['nombre']);
        print('💾 ID guardado: ${data['id']}');
        print('💾 Nombre guardado: ${data['nombre']}');

        Navigator.pushReplacementNamed(context, "/home");
      } else {
        setState(() {
          loginErrorMessage =
              "Credenciales incorrectas. Revisa el correo y la contraseña.";
        });
      }
    } on DioException catch (e) {
      print("🔥 Dio error: ${e.response?.statusCode} - ${e.response?.data}");

      setState(() {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          loginErrorMessage =
              "Credenciales incorrectas. Revisa el correo y la contraseña.";
        } else {
          loginErrorMessage = "Error al iniciar sesión. Inténtalo de nuevo.";
        }
      });
    } catch (error) {
      print("💣 Error general: $error");
      setState(() {
        loginErrorMessage = "Error desconocido. Inténtalo más tarde.";
      });
    }
  }

  Future<void> registerUser(String nombre, String email, String password,
      BuildContext context) async {
    try {
      final dio = await DioClient.getInstance();

      final response = await dio.post(
        "$apiUrl/register",
        data: {
          "email": email,
          "password": password,
          "nombre": nombre,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        print("✅ Registro exitoso: ${data["message"]} 🎉");
// Después del registro exitoso:
        await loginUser(email, password, context);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', data['id']);
        await prefs.setString('userName', data['nombre']);

        print(
            "💾 Usuario registrado con ID: ${data['id']} y nombre: ${data['nombre']}");

        Navigator.pushReplacementNamed(context, "/home");
      } else {
        print("🚫 Error en el registro: ${response.data}");
      }
    } on DioException catch (e) {
      print(
          "🔥 Error de Dio al registrar: ${e.response?.statusCode} - ${e.response?.data}");
    } catch (error) {
      print("💥 Error general de conexión: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.3,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/logo2.png"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
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
                                        decoration: const InputDecoration(
                                            labelText: "Nombre"),
                                        validator: (value) =>
                                            value == null || value.isEmpty
                                                ? "El nombre es obligatorio"
                                                : null,
                                      ),
                                    TextFormField(
                                      controller: emailController,
                                      decoration: const InputDecoration(
                                          labelText: "Correo Electrónico"),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "El correo es obligatorio";
                                        }
                                        final emailRegex = RegExp(
                                            r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"); // expresión regular básica
                                        if (!emailRegex.hasMatch(value)) {
                                          return "Correo no válido";
                                        }
                                        return null;
                                      },
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
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: _obscurePassword,
                                      validator: (value) => value == null ||
                                              value.length < 6
                                          ? "La contraseña debe tener al menos 6 caracteres"
                                          : null,
                                    ),
                                    if (isLogin && loginErrorMessage != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          loginErrorMessage!,
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          String email =
                                              emailController.text.trim();
                                          String password =
                                              passwordController.text.trim();
                                          String name =
                                              nameController.text.trim();
                                          if (isLogin) {
                                            loginUser(email, password, context);
                                          } else {
                                            registerUser(
                                                name, email, password, context);
                                          }
                                        }
                                      },
                                      child: Text(
                                        isLogin
                                            ? "Iniciar Sesión"
                                            : "Registrarse",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
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
                                          color: Colors.black,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
