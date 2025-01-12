package com.example.App_TFG.controllers;

import com.example.App_TFG.dto.UsuarioDTO;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.services.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController // Indica que esta clase es un controlador de una API REST
@RequestMapping("/api/usuarios") // Define la ruta base para este controlador
public class UsuarioController {
// manejará las peticiones HTTP relacionadas con las operaciones que puedes realizar con los usuarios, como la creación, autenticación, seguimiento, etc.
    @Autowired
    private UsuarioService usuarioService; // Inyecta el servicio de Usuario para la lógica de negocio



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



    @PostMapping("/seguir/{idSeguir}") // Ruta para seguir a otro usuario
    public ResponseEntity<String> seguirUsuario(@RequestParam Integer idUsuario, @PathVariable Integer idSeguir) {
        Optional<Usuario> usuarioOpt = usuarioService.obtenerUsuarioPorId(idUsuario);
        Optional<Usuario> usuarioASeguirOpt = usuarioService.obtenerUsuarioPorId(idSeguir);

        if (usuarioOpt.isPresent() && usuarioASeguirOpt.isPresent()) {
            Usuario usuario = usuarioOpt.get();
            Usuario usuarioASeguir = usuarioASeguirOpt.get();
            
            usuarioService.seguirUsuario(usuario, usuarioASeguir);

            // Mensaje personalizado con los nombres
            String mensaje = usuario.getNombre() + " ahora sigues a " + usuarioASeguir.getNombre();
            return new ResponseEntity<>(mensaje, HttpStatus.OK);
        } else {
            return new ResponseEntity<>("Usuario no encontrado", HttpStatus.NOT_FOUND);
        }
    }


    @PostMapping("/dejarDeSeguir/{idSeguir}") // Ruta para dejar de seguir a un usuario
    public ResponseEntity<String> dejarDeSeguir(@RequestParam Integer idUsuario, @PathVariable Integer idSeguir) {
        Optional<Usuario> usuarioOpt = usuarioService.obtenerUsuarioPorId(idUsuario);
        Optional<Usuario> usuarioADejarDeSeguirOpt = usuarioService.obtenerUsuarioPorId(idSeguir);

        if (usuarioOpt.isPresent() && usuarioADejarDeSeguirOpt.isPresent()) {
            Usuario usuario = usuarioOpt.get();
            Usuario usuarioADejarDeSeguir = usuarioADejarDeSeguirOpt.get();
            
            usuarioService.dejarDeSeguirUsuario(usuario, usuarioADejarDeSeguir);

            // Mensaje personalizado con los nombres
            String mensaje = usuario.getNombre() + " has dejado de seguir a " + usuarioADejarDeSeguir.getNombre();
            return new ResponseEntity<>(mensaje, HttpStatus.OK);
        } else {
            return new ResponseEntity<>("Usuario no encontrado", HttpStatus.NOT_FOUND);
        }
    }


    // Obtener lista de seguidores de un usuario
    @GetMapping("/seguidores/{id}") // Ruta para obtener los seguidores
    public ResponseEntity<List<UsuarioDTO>> obtenerSeguidores(@PathVariable Integer id) {
        List<Usuario> seguidores = usuarioService.obtenerSeguidores(id);
        
        // Convertir la lista de seguidores a DTOs
        List<UsuarioDTO> seguidoresDTO = seguidores.stream()
                .map(usuario -> new UsuarioDTO(usuario.getIdUsuario(), usuario.getNombre(), usuario.getEmail(), usuario.getAvatarUrl()))
                .collect(Collectors.toList());

        return new ResponseEntity<>(seguidoresDTO, HttpStatus.OK);
    }


    // Obtener lista de usuarios seguidos por un usuario
    @GetMapping("/siguiendo/{id}") // Ruta para obtener a los usuarios seguidos
    public ResponseEntity<List<UsuarioDTO>> obtenerSiguiendo(@PathVariable Integer id) {
        List<Usuario> siguiendo = usuarioService.obtenerSiguiendo(id);
        
        List<UsuarioDTO> siguiendoDTO = siguiendo.stream()
                .map(usuario -> new UsuarioDTO(usuario.getIdUsuario(), usuario.getNombre(), usuario.getEmail(), usuario.getAvatarUrl()))
                .collect(Collectors.toList());
        return new ResponseEntity<>(siguiendoDTO, HttpStatus.OK);
    }



}

