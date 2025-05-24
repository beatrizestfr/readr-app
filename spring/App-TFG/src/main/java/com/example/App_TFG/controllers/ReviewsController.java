package com.example.App_TFG.controllers;

import com.example.App_TFG.dto.ReviewDTO;
import com.example.App_TFG.dto.ReviewResponseDTO;
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
@RequestMapping("/api/resenas")
public class ReviewsController {

    @Autowired
    private ReviewsService reviewsService;

    @Autowired
    private AuthenticationService authenticationService;

    // Crear reseña
    @Transactional
    @PostMapping("/{idLibro}")
    public ResponseEntity<ReviewResponseDTO> crearReseña(@PathVariable Integer idLibro, 
                                               @RequestBody ReviewDTO reviewDTO,
                                               HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        Reviews reseñaCreada = reviewsService.crearReseña(idLibro, reviewDTO, usuario);
        return new ResponseEntity<>(new ReviewResponseDTO(reseñaCreada), HttpStatus.CREATED);
    }

 // Obtener reseña por ID
    @GetMapping("/{idReseña}")
    public ResponseEntity<ReviewResponseDTO> obtenerReseñaPorId(@PathVariable Integer idReseña) {
        System.out.println("📥 Solicitando reseña con ID: " + idReseña);
        
        Optional<Reviews> reseñaOpt = reviewsService.obtenerReseñaPorId(idReseña);

        if (reseñaOpt.isPresent()) {
            Reviews reseña = reseñaOpt.get();
            System.out.println("✅ Reseña encontrada: " + reseña.getContenido());
            
            ReviewResponseDTO dto = new ReviewResponseDTO(reseña);
            System.out.println("📦 DTO creado: " + dto.getContenido() + " | Usuario: " + dto.getNombreUsuario());
            
            return new ResponseEntity<>(dto, HttpStatus.OK);
        } else {
            System.out.println("❌ No se encontró reseña con ID: " + idReseña);
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }


    // Obtener reseñas por libro
    @GetMapping("/libro/{idLibro}")
    public ResponseEntity<List<ReviewResponseDTO>> obtenerReseñasPorLibro(@PathVariable Integer idLibro) {
        List<ReviewResponseDTO> reseñasDTO = reviewsService.obtenerReseñasPorLibro(idLibro);
        return ResponseEntity.ok(reseñasDTO);
    }


    // Obtener reseñas por usuario
    @GetMapping("/usuario/{idUsuario}")
    public List<ReviewResponseDTO> obtenerReseñasPorUsuario(@PathVariable Integer idUsuario) {
        return reviewsService.obtenerReseñasDTOPorUsuario(idUsuario);
    }


    // Eliminar reseña
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarReseña(@PathVariable Integer id, HttpSession session) {
        Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
        if (usuarioActual == null) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        Optional<Reviews> reseñaOpt = reviewsService.obtenerReseñaPorId(id);
        if (reseñaOpt.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        Reviews reseña = reseñaOpt.get();

        if (authenticationService.isAdmin(usuarioActual) || 
            reseña.getUsuario().getIdUsuario().equals(usuarioActual.getIdUsuario())) {
            reviewsService.eliminarReseña(id);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } else {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
    }

    // Editar reseña
    @PutMapping("/{idResena}")
    public ResponseEntity<Reviews> editarReseña(@PathVariable Integer idReseña,
                                                @RequestBody ReviewDTO reviewDTO) {
        try {
            Reviews reseñaActualizada = reviewsService.editarReseña(idReseña, reviewDTO);
            return ResponseEntity.ok(reseñaActualizada);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Feed
    @GetMapping("/feed")
    public ResponseEntity<List<ReviewResponseDTO>> obtenerFeed(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        List<ReviewResponseDTO> feedDTO = reviewsService.obtenerFeedParaUsuario(usuario);
        return ResponseEntity.ok(feedDTO);
    }

}
