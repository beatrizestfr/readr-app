package com.example.App_TFG.controllers;

import com.example.App_TFG.dto.BookDTO;
import com.example.App_TFG.entidades.Libro;
import com.example.App_TFG.services.LibroService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/libros")
public class LibroController {

    @Autowired
    private LibroService libroService; // Inyección del servicio

    // Crear un nuevo libro
    @PostMapping
    public ResponseEntity<Libro> crearLibro(@RequestBody Libro libro) {
        Libro libroCreado = libroService.crearLibro(libro);
        return new ResponseEntity<>(libroCreado, HttpStatus.CREATED);
    }

    // Obtener todos los libros
    @GetMapping
    public List<BookDTO> obtenerTodosLosLibros() {
        List<Libro> libros = libroService.obtenerTodosLosLibros();
        List<BookDTO> bookDTOs = libros.stream()
            .map(libro -> new BookDTO(libro.getTitulo(), List.of(libro.getAutor()), libro.getSinopsis(), libro.getImagenUrl(), libro.getGoogleBooksId()))
            .collect(Collectors.toList());
        return bookDTOs;
    }

    // Obtener un libro por su ID
    @GetMapping("/{id}")
    public ResponseEntity<BookDTO> obtenerLibroPorId(@PathVariable Integer id) {
        Optional<Libro> libroOpt = libroService.obtenerLibroPorId(id);
        return libroOpt.map(libro -> new ResponseEntity<>(new BookDTO(libro.getTitulo(), List.of(libro.getAutor()), libro.getSinopsis(), libro.getImagenUrl(), libro.getGoogleBooksId()), HttpStatus.OK))
                       .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    // Obtener un libro por su título
    @GetMapping("/titulo/{titulo}")
    public ResponseEntity<BookDTO> obtenerLibroPorTitulo(@PathVariable String titulo) {
        Optional<Libro> libroOpt = libroService.obtenerLibroPorTitulo(titulo);
        return libroOpt.map(libro -> new ResponseEntity<>(new BookDTO(libro.getTitulo(), List.of(libro.getAutor()), libro.getSinopsis(), libro.getImagenUrl(), libro.getGoogleBooksId()), HttpStatus.OK))
                       .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    // Obtener un libro por su googleBooksId
    @GetMapping("/google/{googleBooksId}")
    public ResponseEntity<BookDTO> obtenerLibroPorGoogleBooksId(@PathVariable String googleBooksId) {
        Optional<Libro> libroOpt = libroService.obtenerLibroPorGoogleBooksId(googleBooksId);
        return libroOpt.map(libro -> new ResponseEntity<>(new BookDTO(libro.getTitulo(), List.of(libro.getAutor()), libro.getSinopsis(), libro.getImagenUrl(), libro.getGoogleBooksId()), HttpStatus.OK))
                       .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    // Eliminar un libro por su ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarLibro(@PathVariable Integer id) {
        libroService.eliminarLibro(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
