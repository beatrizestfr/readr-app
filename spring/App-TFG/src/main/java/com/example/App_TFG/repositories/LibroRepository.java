package com.example.App_TFG.repositories;

import com.example.App_TFG.entidades.Libro;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface LibroRepository extends JpaRepository<Libro, Integer> {
    // Método para encontrar un libro por su título
    Optional<Libro> findByTitulo(String titulo);
    
    // Método para buscar un libro por su googleBooksId (si existe)
    Optional<Libro> findByGoogleBooksId(String googleBooksId);
    
    Optional<Libro> findById(Integer idLibro);

}
