package com.example.App_TFG.controllers;

import com.example.App_TFG.entidades.Reviews;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.services.AuthenticationService;
import com.example.App_TFG.services.ReviewsService;

import jakarta.servlet.http.HttpSession;
import jakarta.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/reseñas")
public class ReviewsController {

    @Autowired
    private ReviewsService reviewsService;
    
    @Autowired
    private AuthenticationService authenticationService;

 // Crear reseña
    @Transactional
    @PostMapping("/{idLibro}")
    public ResponseEntity<Reviews> crearReseña(@PathVariable Integer idLibro, @RequestBody String contenido,  HttpSession session) {
    	Usuario usuario = (Usuario) session.getAttribute("usuario");

        Reviews reseñaCreada = reviewsService.crearReseña(idLibro, contenido, usuario);
        return new ResponseEntity<>(reseñaCreada, HttpStatus.CREATED);
    }

    // Obtener reseña por ID
    @GetMapping("/{id}")
    public ResponseEntity<Reviews> obtenerReseñaPorId(@PathVariable Integer id) {
        Optional<Reviews> reseñaOpt = reviewsService.obtenerReseñaPorId(id);
        return reseñaOpt.map(reseña -> new ResponseEntity<>(reseña, HttpStatus.OK))
                        .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    // Obtener reseñas por libro
    @GetMapping("/libro/{idLibro}")
    public List<Reviews> obtenerReseñasPorLibro(@PathVariable Integer idLibro) {
        return reviewsService.obtenerReseñasPorLibro(idLibro);
    }

    // Obtener reseñas por usuario
    @GetMapping("/usuario/{idUsuario}")
    public List<Reviews> obtenerReseñasPorUsuario(@PathVariable Integer idUsuario) {
        return reviewsService.obtenerReseñasPorUsuario(idUsuario);
    }

 // Eliminar reseña por ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarReseña(@PathVariable Integer id, HttpSession session) {
        // Obtener el usuario actual desde la sesión
        Usuario usuarioActual = (Usuario) session.getAttribute("usuario");  // Suponiendo que el usuario se guarda en la sesión con la clave "usuario"
        
        if (usuarioActual == null) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);  // Si el usuario no está autenticado
        }

        // Obtener la reseña a eliminar
        Optional<Reviews> reseñaOpt = reviewsService.obtenerReseñaPorId(id);
        if (reseñaOpt.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);  // Si no se encuentra la reseña
        }

        Reviews reseña = reseñaOpt.get();
        
        // Verificar si el usuario tiene permiso para eliminar la reseña
        if (authenticationService.isAdmin(usuarioActual) || reseña.getUsuario().getIdUsuario().equals(usuarioActual.getIdUsuario())) {
            reviewsService.eliminarReseña(id);  // Eliminar reseña
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);  // Respuesta exitosa
        } else {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);  // Si el usuario no tiene permiso
        }
    }
    
    // Endpoint para editar una reseña
    @PutMapping("/{idReseña}")
    public ResponseEntity<Reviews> editarReseña(@PathVariable Integer idReseña,
                                                @RequestBody String nuevoContenido) {
        try {
            Reviews reseñaActualizada = reviewsService.editarReseña(idReseña, nuevoContenido);
            return ResponseEntity.ok(reseñaActualizada);  // Retorna la reseña actualizada
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();  // Si no se encuentra la reseña, retorna 404
        }
    }
}

