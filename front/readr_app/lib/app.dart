import 'package:flutter/material.dart';
import '../screens/auth_screen.dart'; // Importamos la pantalla de autenticación
import '../screens/perfil_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la etiqueta "debug"
      title: 'Readr.',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 137, 96, 207)),
        useMaterial3: true,
      ),
      initialRoute: '/', // Definimos la ruta inicial
      routes: {
        '/': (context) => const AuthScreen(), // Pantalla de autenticación
        '/perfil_screen': (context) =>
            PerfilScreen(), // Nueva pantalla de perfil
      },
    );
  }
}
