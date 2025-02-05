package com.example.App_TFG.services;

import com.example.App_TFG.entidades.Libro;
import com.example.App_TFG.entidades.Reviews;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.repositories.LibroRepository;
import com.example.App_TFG.repositories.ReviewsRepository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ReviewsService {
	
    private static final Logger logger = LoggerFactory.getLogger(ListaLecturaService.class);


    @Autowired
    private ReviewsRepository reviewsRepository;
    
    @Autowired
    private LibroRepository libroRepository;

    // Crear reseña
    public Reviews crearReseña(Integer idLibro, String contenido, Usuario usuario) {
        logger.info("creando una nueva reseña con contenido {}", contenido);

        // Buscar el libro por el ID
        Libro libroExistente = libroRepository.findById(idLibro)
                                              .orElseThrow(() -> new IllegalArgumentException("Libro no encontrado"));
        logger.info("creando reseña para el libro {}", libroExistente.getIdLibro());

        // Crear una nueva reseña y asignarle el contenido y el libro
        Reviews nuevaReseña = new Reviews();
        logger.info("objeto reseña creado {}", nuevaReseña);

        nuevaReseña.setContenido(contenido);
        logger.info("poniendo el contenido {}", contenido);

        nuevaReseña.setLibro(libroExistente);
        logger.info("asignandole  el libro {} ", libroExistente.getIdLibro());

        nuevaReseña.setUsuario(usuario);
        logger.info("asigandole el usuario  {}", usuario);

        // Guardar la reseña
        return reviewsRepository.save(nuevaReseña);
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

