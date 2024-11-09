package com.example.App_TFG.repositories;

import com.example.App_TFG.entidades.Reviews;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ReviewsRepository extends JpaRepository<Reviews, Integer> {
    List<Reviews> findByLibroId(Integer idLibro); // Buscar reseñas por libro
    List<Reviews> findByUsuarioId(Integer idUsuario); // Buscar reseñas por usuario
}
