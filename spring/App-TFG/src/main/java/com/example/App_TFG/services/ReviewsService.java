package com.example.App_TFG.services;

import com.example.App_TFG.entidades.Reviews;
import com.example.App_TFG.repositories.ReviewsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ReviewsService {

    @Autowired
    private ReviewsRepository reviewsRepository;

    // Crear reseña
    public Reviews crearReseña(Reviews reseña) {
        return reviewsRepository.save(reseña);
    }

    // Obtener reseña por ID
    public Optional<Reviews> obtenerReseñaPorId(Integer id) {
        return reviewsRepository.findById(id);
    }

    // Obtener reseñas por libro
    public List<Reviews> obtenerReseñasPorLibro(Integer idLibro) {
        return reviewsRepository.findByLibro_IdLibro(idLibro);
    }

    // Obtener reseñas por usuario
    public List<Reviews> obtenerReseñasPorUsuario(Integer idUsuario) {
        return reviewsRepository.findByUsuario_IdUsuario(idUsuario);
    }

    // Eliminar reseña por ID
    public void eliminarReseña(Integer id) {
        reviewsRepository.deleteById(id);
    }
    
    // Editar reseña
    public Reviews editarReseña(Integer idReseña, String nuevoContenido) {
        Optional<Reviews> reseñaOpt = reviewsRepository.findById(idReseña);
        if (reseñaOpt.isPresent()) {
            Reviews reseña = reseñaOpt.get();
            reseña.setContenido(nuevoContenido);  // Modifica el contenido de la reseña

            return reviewsRepository.save(reseña);  // Guarda los cambios en la base de datos
        } else {
            throw new IllegalArgumentException("Reseña no encontrada");
        }
    }
}

