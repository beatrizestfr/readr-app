package com.example.App_TFG.repositories;

import java.util.Optional;

import com.example.App_TFG.entidades.Rol;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RolRepository extends JpaRepository<Rol, Integer> {

    // Método para buscar un rol por su nombre
    Optional<Rol> findByNombre(String nombre);
}