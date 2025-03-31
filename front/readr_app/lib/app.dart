import 'package:flutter/material.dart';
import '../screens/auth_screen.dart'; // Importamos la pantalla de autenticación
import '../screens/bienv_screen.dart';
import '../screens/home_screen.dart';

class MyApp extends StatelessWidget {
  /// no cambia su conyenido despues de ser coonstruido
  const MyApp({super.key}); // cpnstructor

  // raiz de la app
  @override
  Widget build(BuildContext context) {
    //construye y devuelve la interfaz gráfica del widget.
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la etiqueta "debug"
      title: 'Readr.',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 2, 2, 2)),
        useMaterial3: true,
      ),
      initialRoute: '/', // Inicia en la pantalla de bienvenida
      routes: {
        '/': (context) => const BienvScreen(), // Pantalla de bienvenida
        '/auth': (context) => const AuthScreen(), // Autenticación
        '/home': (context) =>
            const HomeScreen(), // Contenedor con la barra de navegación
      },
    );
  }
}
