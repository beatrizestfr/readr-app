package com.example.App_TFG.controllers;

import com.example.App_TFG.entidades.ListaLectura;
import com.example.App_TFG.services.ListaLecturaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/listas-lectura")
public class ListaLecturaController {

    @Autowired
    private ListaLecturaService listaLecturaService;

    // Crear lista de lectura
    @PostMapping
    public ResponseEntity<ListaLectura> crearListaLectura(@RequestBody ListaLectura listaLectura) {
        ListaLectura listaCreada = listaLecturaService.crearListaLectura(listaLectura);
        return new ResponseEntity<>(listaCreada, HttpStatus.CREATED);
    }

    // Obtener lista de lectura por ID
    @GetMapping("/{id}")
    public ResponseEntity<ListaLectura> obtenerListaLecturaPorId(@PathVariable Integer id) {
        Optional<ListaLectura> listaOpt = listaLecturaService.obtenerListaLecturaPorId(id);
        return listaOpt.map(lista -> new ResponseEntity<>(lista, HttpStatus.OK))
                       .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    // Obtener lista de lectura por nombre
    @GetMapping("/nombre/{nombre}")
    public ResponseEntity<ListaLectura> obtenerListaLecturaPorNombre(@PathVariable String nombre) {
        Optional<ListaLectura> listaOpt = listaLecturaService.obtenerListaLecturaPorNombre(nombre);
        return listaOpt.map(lista -> new ResponseEntity<>(lista, HttpStatus.OK))
                       .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    // Obtener todas las listas de lectura
    @GetMapping
    public List<ListaLectura> obtenerTodasLasListas() {
        return listaLecturaService.obtenerTodasLasListas();
    }

    // Eliminar lista de lectura por ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarListaLectura(@PathVariable Integer id) {
        listaLecturaService.eliminarListaLectura(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
    
 // Añadir libro a una lista de lectura
    @PutMapping("/{idLista}/libros/{idLibro}")
    public ResponseEntity<Void> añadirLibroALista(@PathVariable Integer idLista, @PathVariable Integer idLibro) {
        try {
            listaLecturaService.añadirLibroALista(idLista, idLibro);
            return new ResponseEntity<>(HttpStatus.OK); // Código 200 OK
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND); // Código 404 si no se encuentra lista o libro
        }
    }

 // Eliminar libro de una lista de lectura
    @DeleteMapping("/{idLista}/libros/{idLibro}")
    public ResponseEntity<Void> eliminarLibroDeLista(@PathVariable Integer idLista, @PathVariable Integer idLibro) {
        try {
            listaLecturaService.eliminarLibroDeLista(idLista, idLibro);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT); // Código 204 si la eliminación fue exitosa
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND); // Código 404 si no se encuentra lista o libro
        }
    }

}
