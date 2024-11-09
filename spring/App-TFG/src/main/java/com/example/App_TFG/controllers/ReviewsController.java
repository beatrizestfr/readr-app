package com.example.App_TFG.controllers;

import com.example.App_TFG.entidades.Reviews;
import com.example.App_TFG.services.ReviewsService;
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

    // Crear reseña
    @PostMapping
    public ResponseEntity<Reviews> crearReseña(@RequestBody Reviews reseña) {
        Reviews reseñaCreada = reviewsService.crearReseña(reseña);
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
    public ResponseEntity<Void> eliminarReseña(@PathVariable Integer id) {
        reviewsService.eliminarReseña(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
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

