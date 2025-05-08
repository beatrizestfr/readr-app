package com.example.App_TFG.services;

import com.example.App_TFG.dto.ReviewDTO;
import com.example.App_TFG.dto.ReviewResponseDTO;
import com.example.App_TFG.entidades.Libro;
import com.example.App_TFG.entidades.Reviews;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.repositories.LibroRepository;
import com.example.App_TFG.repositories.ReviewsRepository;
import com.example.App_TFG.repositories.UsuarioRepository;

import jakarta.transaction.Transactional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ReviewsService {

    private static final Logger logger = LoggerFactory.getLogger(ReviewsService.class);

    @Autowired
    private ReviewsRepository reviewsRepository;
    
    @Autowired
    private UsuarioRepository usuarioRepository;


    @Autowired
    private LibroRepository libroRepository;

    // Crear reseña
    public Reviews crearReseña(Integer idLibro, ReviewDTO reviewDTO, Usuario usuario) {
        logger.info("Creando una nueva reseña para el libro {}", idLibro);

        Libro libro = libroRepository.findById(idLibro)
                .orElseThrow(() -> new IllegalArgumentException("Libro no encontrado"));

        Reviews nuevaReseña = new Reviews();
        nuevaReseña.setContenido(reviewDTO.getContenido());
        nuevaReseña.setRating(reviewDTO.getRating());
        nuevaReseña.setLibro(libro);
        nuevaReseña.setUsuario(usuario);

        return reviewsRepository.save(nuevaReseña);
    }

    // Obtener reseña por ID
    public Optional<Reviews> obtenerReseñaPorId(Integer idReseña) {
        return reviewsRepository.findById(idReseña);
    }

    // Obtener reseñas por libro
    public List<ReviewResponseDTO> obtenerReseñasPorLibro(Integer idLibro) {
        List<Reviews> reseñas = reviewsRepository.findByLibro_IdLibro(idLibro);
        return reseñas.stream()
                      .map(ReviewResponseDTO::new)
                      .collect(Collectors.toList());
    }

    // Obtener reseñas por usuario
    public List<Reviews> obtenerReseñasPorUsuario(Integer idUsuario) {
        return reviewsRepository.findByUsuario_IdUsuario(idUsuario);
    }

    // Eliminar reseña
    public void eliminarReseña(Integer id) {
        reviewsRepository.deleteById(id);
    }

    // Editar reseña
    public Reviews editarReseña(Integer idReseña, ReviewDTO reviewDTO) {
        Reviews reseña = reviewsRepository.findById(idReseña)
                .orElseThrow(() -> new IllegalArgumentException("Reseña no encontrada"));

        reseña.setContenido(reviewDTO.getContenido());
        reseña.setRating(reviewDTO.getRating());

        return reviewsRepository.save(reseña);
    }

    // Feed
    public List<ReviewResponseDTO> obtenerFeedParaUsuario(Usuario usuario) {
        // Forzar carga de "siguiendo"
        usuario = usuarioRepository.findByIdWithSiguiendo(usuario.getIdUsuario());

        List<Usuario> seguidos = new ArrayList<>(usuario.getSiguiendo());
        seguidos.add(usuario); // incluir sus propias reseñas

        List<Reviews> reseñas = reviewsRepository.findByUsuarioInOrderByFechaDesc(seguidos);
        return reseñas.stream()
                      .map(ReviewResponseDTO::new)
                      .collect(Collectors.toList());
    }


}
