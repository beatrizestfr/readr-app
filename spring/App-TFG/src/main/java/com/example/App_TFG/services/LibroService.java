package com.example.App_TFG.services;

import com.example.App_TFG.entidades.Libro;
import com.example.App_TFG.repositories.LibroRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class LibroService {

    @Autowired
    private LibroRepository libroRepository; // Inyección del repositorio

    // Crear un nuevo libro
    public Libro crearLibro(Libro libro) {
        return libroRepository.save(libro); // Guarda el libro en la base de datos
    }

    // Obtener un libro por su ID
    public Optional<Libro> obtenerLibroPorId(Integer id) {
        return libroRepository.findById(id); // Busca el libro por su ID
    }

    // Obtener un libro por su título
    public Optional<Libro> obtenerLibroPorTitulo(String titulo) {
        return libroRepository.findByTitulo(titulo); // Busca el libro por su título
    }

    // Obtener un libro por su googleBooksId
    public Optional<Libro> obtenerLibroPorGoogleBooksId(String googleBooksId) {
        return libroRepository.findByGoogleBooksId(googleBooksId); // Busca el libro por su googleBooksId
    }

    // Obtener todos los libros
    public List<Libro> obtenerTodosLosLibros() {
        return libroRepository.findAll(); // Retorna todos los libros
    }

    // Eliminar un libro
    public void eliminarLibro(Integer id) {
        libroRepository.deleteById(id); // Elimina el libro por su ID
    }
}
