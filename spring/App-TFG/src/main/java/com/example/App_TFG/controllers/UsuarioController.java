package com.example.App_TFG.controllers;

import com.example.App_TFG.dto.UsuarioDTO;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.repositories.UsuarioRepository;
import com.example.App_TFG.services.UsuarioService;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController // Indica que esta clase es un controlador de una API REST
@RequestMapping("/api/usuarios") // Define la ruta base para este controlador
public class UsuarioController {
	
	 private final UsuarioRepository usuarioRepository;

	    @Autowired
	    public UsuarioController(UsuarioRepository usuarioRepository) {
	        this.usuarioRepository = usuarioRepository;
	    }
// manejará las peticiones HTTP relacionadas con las operaciones que puedes realizar con los usuarios, como la creación, autenticación, seguimiento, etc.
    @Autowired
    private UsuarioService usuarioService; // Inyecta el servicio de Usuario para la lógica de negocio

    @GetMapping("/detalle/{id}") // Ruta para obtener detalles de perfil de un usuario
    public ResponseEntity<UsuarioDTO> obtenerDetalleUsuario(@PathVariable Integer id) {
        Optional<UsuarioDTO> usuarioOpt = usuarioService.obtenerUsuarioPorId(id);
        
        if (usuarioOpt.isPresent()) {
            return new ResponseEntity<>(usuarioOpt.get(), HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    // Buscar un usuario por su ID
    @GetMapping("/{id}") // Asocia esta acción a una petición GET en "/api/usuarios/{id}"
    public ResponseEntity<UsuarioDTO> obtenerUsuarioPorId(@PathVariable Integer id) {
        Optional<UsuarioDTO> usuarioOpt = usuarioService.obtenerUsuarioPorId(id);
        return usuarioOpt.map(usuario -> new ResponseEntity<>(usuario, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    // Buscar un usuario por su nombre
    @GetMapping("/nombre/{nombre}") // Asocia esta acción a una petición GET en "/api/usuarios/nombre/{nombre}"
    public ResponseEntity<UsuarioDTO> buscarPorNombre(@PathVariable String nombre) {
        Optional<UsuarioDTO> usuarioOpt = usuarioService.buscarPorNombre(nombre);
        return usuarioOpt.map(usuario -> new ResponseEntity<>(usuario, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }



    @PostMapping("/seguir/{idSeguir}") // Ruta para seguir a otro usuario
    public ResponseEntity<String> seguirUsuario(@RequestParam Integer idUsuario, @PathVariable Integer idSeguir) {
        Optional<UsuarioDTO> usuarioOpt = usuarioService.obtenerUsuarioPorId(idUsuario);
        Optional<UsuarioDTO> usuarioASeguirOpt = usuarioService.obtenerUsuarioPorId(idSeguir);

        if (usuarioOpt.isPresent() && usuarioASeguirOpt.isPresent()) {
            UsuarioDTO usuarioDTO = usuarioOpt.get();
            UsuarioDTO usuarioASeguirDTO = usuarioASeguirOpt.get();
            
            // Usar los DTO para seguir al usuario 
            usuarioService.seguirUsuario(usuarioDTO, usuarioASeguirDTO);

            // Mensaje personalizado con los nombres (usando los DTO)
            String mensaje = usuarioDTO.getNombre() + " ahora sigues a " + usuarioASeguirDTO.getNombre();
            return new ResponseEntity<>(mensaje, HttpStatus.OK);
        } else {
            return new ResponseEntity<>("Usuario no encontrado", HttpStatus.NOT_FOUND);
        }
    }


    @PostMapping("/dejarDeSeguir/{idSeguir}") // Ruta para dejar de seguir a un usuario
    public ResponseEntity<String> dejarDeSeguir(@RequestParam Integer idUsuario, @PathVariable Integer idSeguir) {
        Optional<UsuarioDTO> usuarioOpt = usuarioService.obtenerUsuarioPorId(idUsuario);
        Optional<UsuarioDTO> usuarioADejarDeSeguirOpt = usuarioService.obtenerUsuarioPorId(idSeguir);

        if (usuarioOpt.isPresent() && usuarioADejarDeSeguirOpt.isPresent()) {
            UsuarioDTO usuarioDTO = usuarioOpt.get();
            UsuarioDTO usuarioADejarDeSeguirDTO = usuarioADejarDeSeguirOpt.get();
            
            // Usar los DTO para dejar de seguir al usuario 
            usuarioService.dejarDeSeguirUsuario(usuarioDTO, usuarioADejarDeSeguirDTO);

            // Mensaje personalizado con los nombres (usando los DTO)
            String mensaje = usuarioDTO.getNombre() + " has dejado de seguir a " + usuarioADejarDeSeguirDTO.getNombre();
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

    @GetMapping("/siguiendo/{idUsuarioSesion}/{idUsuarioPerfil}")
    public ResponseEntity<Boolean> estaSiguiendo(
            @PathVariable int idUsuarioSesion,
            @PathVariable int idUsuarioPerfil) {
        
        Optional<Usuario> usuarioSesion = usuarioRepository.findById(idUsuarioSesion);
        Optional<Usuario> usuarioPerfil = usuarioRepository.findById(idUsuarioPerfil);

        if (usuarioSesion.isPresent() && usuarioPerfil.isPresent()) {
            boolean siguiendo = usuarioSesion.get().getSiguiendo().contains(usuarioPerfil.get());
            return ResponseEntity.ok(siguiendo);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // edicion de perfil :
    @PutMapping("/editar/{id}")
    public ResponseEntity<String> editarPerfil(
            @PathVariable Integer id,
            @RequestParam("nombre") String nombre,
            @RequestParam(value = "avatar", required = false) MultipartFile avatarFile,
            HttpSession session) {

        Optional<Usuario> usuarioOpt = usuarioRepository.findById(id);

        if (usuarioOpt.isEmpty()) {
            return new ResponseEntity<>("Usuario no encontrado", HttpStatus.NOT_FOUND);
        }

        Usuario usuario = usuarioOpt.get();
        usuario.setNombre(nombre);
        

        if (avatarFile != null && !avatarFile.isEmpty()) {
            System.out.println("🖼️ Recibida imagen: " + avatarFile.getOriginalFilename());

            // Puedes usar un servicio para subir la imagen y guardar la URL
            String url = usuarioService.subirFotoPerfil(avatarFile);
            usuario.setAvatarUrl(url);
        }else {
            System.out.println("⚠️ No se recibió imagen.");
        }

        usuarioRepository.save(usuario);
        
        session.setAttribute("usuario", usuario);

        
        return ResponseEntity.ok("Perfil actualizado correctamente");
    }


} 

