package com.example.App_TFG.repositories;

import com.example.App_TFG.entidades.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {

    // Método para buscar un usuario por su nombre de usuario
    Optional<Usuario> findByNombre(String nombre);
    
    Optional<Usuario> findById(int id);

    
    @Query("SELECT u FROM Usuario u LEFT JOIN FETCH u.siguiendo WHERE u.idUsuario = :id")
    Usuario findByIdWithSiguiendo(@Param("id") Integer id);


    // Método para buscar un usuario por su email
    Optional<Usuario> findByEmail(String email);
}
