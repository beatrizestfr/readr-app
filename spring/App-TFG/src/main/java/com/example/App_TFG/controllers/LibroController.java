package com.example.App_TFG.controllers;

import com.example.App_TFG.dto.BookDTO;
import com.example.App_TFG.entidades.Libro;
import com.example.App_TFG.services.LibroService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/libros")
public class LibroController {

    @Autowired
    private LibroService libroService; // Inyección del servicio

    // Buscar libros en la API de Google
    @GetMapping("/buscar")
    public ResponseEntity<List<BookDTO>> buscarLibros(@RequestParam String titulo, @RequestParam(required = false) String autor) {
        // Llamada al servicio para buscar libros en Google
        List<BookDTO> librosGoogle = libroService.buscarLibrosEnGoogle(titulo, autor);

        if (librosGoogle.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND); // Si no se encuentran libros
        }

        return new ResponseEntity<>(librosGoogle, HttpStatus.OK); // Si se encuentran libros
    }

    // Añadir libro a la base de datos 
    @PostMapping("/agregar")
    public ResponseEntity<Void> agregar(@RequestParam String titulo, @RequestParam(required = false) String autor) {
        // Llamada al servicio para añadir el libro a la lista del usuario
        Libro libroAñadido = libroService.añadirLibro(titulo, autor);

        if (libroAñadido != null) {
            return new ResponseEntity<>(HttpStatus.CREATED); // Respuesta exitosa
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND); // Si no se encuentra el libro
        }
    }
}

