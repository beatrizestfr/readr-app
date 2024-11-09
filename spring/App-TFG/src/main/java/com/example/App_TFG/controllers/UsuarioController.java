package com.example.App_TFG.controllers;

import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.services.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController // Indica que esta clase es un controlador de una API REST
@RequestMapping("/api/usuarios") // Define la ruta base para este controlador
public class UsuarioController {
// manejará las peticiones HTTP relacionadas con las operaciones que puedes realizar con los usuarios, como la creación, autenticación, seguimiento, etc.
    @Autowired
    private UsuarioService usuarioService; // Inyecta el servicio de Usuario para la lógica de negocio

    // Crear un nuevo usuario
    @PostMapping("/crear") // Asocia esta acción a una petición POST en "/api/usuarios/crear"
    public ResponseEntity<Usuario> crearUsuario(@RequestBody Usuario usuario) {
        Usuario nuevoUsuario = usuarioService.crearUsuario(usuario); // Llama al servicio para crear el usuario
        return new ResponseEntity<>(nuevoUsuario, HttpStatus.CREATED); // Devuelve el usuario creado con un código 201
    }

    // Buscar un usuario por su ID
    @GetMapping("/{id}") // Asocia esta acción a una petición GET en "/api/usuarios/{id}"
    public ResponseEntity<Usuario> obtenerUsuarioPorId(@PathVariable Integer id) {
        Optional<Usuario> usuarioOpt = usuarioService.obtenerUsuarioPorId(id); // Busca al usuario por ID
        return usuarioOpt.map(usuario -> new ResponseEntity<>(usuario, HttpStatus.OK)) // Si el usuario existe
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND)); // Si no, devuelve 404 Not Found
    }

    // Buscar un usuario por su nombre
    @GetMapping("/nombre/{nombre}") // Asocia esta acción a una petición GET en "/api/usuarios/nombre/{nombre}"
    public ResponseEntity<Usuario> buscarPorNombre(@PathVariable String nombre) {
        Optional<Usuario> usuarioOpt = usuarioService.buscarPorNombre(nombre); // Busca al usuario por nombre
        return usuarioOpt.map(usuario -> new ResponseEntity<>(usuario, HttpStatus.OK)) // Si existe, retorna 200 OK
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND)); // Si no, retorna 404 Not Found
    }

    // Autenticar a un usuario
    @PostMapping("/autenticar") // Asocia esta acción a una petición POST en "/api/usuarios/autenticar"
    public ResponseEntity<String> autenticarUsuario(@RequestBody Usuario usuario) {
        boolean autenticado = usuarioService.autenticarUsuario(usuario.getNombre(), usuario.getPassword()); // Llama al servicio para autenticar
        if (autenticado) {
            return new ResponseEntity<>("Usuario autenticado correctamente", HttpStatus.OK); // Si es exitoso, retorna un mensaje de éxito
        } else {
            return new ResponseEntity<>("Credenciales incorrectas", HttpStatus.UNAUTHORIZED); // Si falla, devuelve 401 Unauthorized
        }
    }

    // Seguir a otro usuario
    @PostMapping("/seguir/{idSeguir}") // Ruta para seguir a otro usuario
    public ResponseEntity<String> seguirUsuario(@RequestParam Integer idUsuario, @PathVariable Integer idSeguir) {
        Optional<Usuario> usuarioOpt = usuarioService.obtenerUsuarioPorId(idUsuario);
        Optional<Usuario> usuarioASeguirOpt = usuarioService.obtenerUsuarioPorId(idSeguir);

        if (usuarioOpt.isPresent() && usuarioASeguirOpt.isPresent()) {
            usuarioService.seguirUsuario(usuarioOpt.get(), usuarioASeguirOpt.get());
            return new ResponseEntity<>("Ahora sigues a este usuario", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("Usuario no encontrado", HttpStatus.NOT_FOUND);
        }
    }

    // Dejar de seguir a un usuario
    @PostMapping("/dejarDeSeguir/{idSeguir}") // Ruta para dejar de seguir a un usuario
    public ResponseEntity<String> dejarDeSeguir(@RequestParam Integer idUsuario, @PathVariable Integer idSeguir) {
        Optional<Usuario> usuarioOpt = usuarioService.obtenerUsuarioPorId(idUsuario);
        Optional<Usuario> usuarioADejarDeSeguirOpt = usuarioService.obtenerUsuarioPorId(idSeguir);

        if (usuarioOpt.isPresent() && usuarioADejarDeSeguirOpt.isPresent()) {
            usuarioService.dejarDeSeguirUsuario(usuarioOpt.get(), usuarioADejarDeSeguirOpt.get());
            return new ResponseEntity<>("Dejaste de seguir a este usuario", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("Usuario no encontrado", HttpStatus.NOT_FOUND);
        }
    }

    // Obtener lista de seguidores de un usuario
    @GetMapping("/seguidores/{id}") // Ruta para obtener los seguidores
    public ResponseEntity<List<Usuario>> obtenerSeguidores(@PathVariable Integer id) {
        List<Usuario> seguidores = usuarioService.obtenerSeguidores(id);
        return new ResponseEntity<>(seguidores, HttpStatus.OK);
    }

    // Obtener lista de usuarios seguidos por un usuario
    @GetMapping("/siguiendo/{id}") // Ruta para obtener a los usuarios seguidos
    public ResponseEntity<List<Usuario>> obtenerSiguiendo(@PathVariable Integer id) {
        List<Usuario> siguiendo = usuarioService.obtenerSiguiendo(id);
        return new ResponseEntity<>(siguiendo, HttpStatus.OK);
    }

    // Cambiar de cuenta (cambiar usuario)
    @PostMapping("/cambiarCuenta") // Ruta para cambiar la cuenta
    public ResponseEntity<String> cambiarUsuario(@RequestBody Usuario usuario) {
        boolean usuarioCambiado = usuarioService.cambiarUsuario(usuario.getNombre(), usuario.getPassword()); // Llama al servicio
        if (usuarioCambiado) {
            return new ResponseEntity<>("Cambio de cuenta exitoso", HttpStatus.OK); // Si el cambio es exitoso, se retorna OK
        } else {
            return new ResponseEntity<>("Credenciales incorrectas", HttpStatus.UNAUTHORIZED); // Si falla, retorna Unauthorized
        }
    }

}

