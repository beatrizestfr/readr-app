package com.example.App_TFG.repositories;

import com.example.App_TFG.entidades.Reviews;
import com.example.App_TFG.entidades.Usuario;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ReviewsRepository extends JpaRepository<Reviews, Integer> {
    List<Reviews> findByLibro_IdLibro(Integer idLibro); // Buscar reseñas por libro
    List<Reviews> findByUsuario_IdUsuario(Integer idUsuario); // Buscar reseñas por usuario
    List<Reviews> findByUsuarioInOrderByFechaDesc(List<Usuario> usuarios);


}
