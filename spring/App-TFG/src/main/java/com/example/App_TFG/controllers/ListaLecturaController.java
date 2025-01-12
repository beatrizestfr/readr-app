package com.example.App_TFG.controllers;

import com.example.App_TFG.entidades.ListaLectura;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.services.ListaLecturaService;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;
@RestController
@RequestMapping("/api/listas-lectura")
public class ListaLecturaController {

    @Autowired
    private ListaLecturaService listaLecturaService;
    
    // Crear lista de lectura
    @PostMapping
    public ResponseEntity<ListaLectura> crearListaLectura(@RequestBody ListaLectura listaLectura, HttpSession session) {
        // Obtener el nombre del usuario desde la sesión
    	Usuario usuario = (Usuario) session.getAttribute("usuario");
    	if (usuario == null) {
    	    return new ResponseEntity<>(HttpStatus.UNAUTHORIZED); // Usuario no autenticado
    	}
       

        // Crear la lista de lectura
        ListaLectura listaCreada = listaLecturaService.crearListaLectura(listaLectura, usuario);

        // Asegurar las listas predeterminadas
        listaLecturaService.asegurarListasPredeterminadas(usuario);

        return new ResponseEntity<>(listaCreada, HttpStatus.CREATED);
    }
    

    // Obtener lista de lectura por ID
    @GetMapping("/{id}")
    public ResponseEntity<ListaLectura> obtenerListaLecturaPorId(@PathVariable Integer id) {
        Optional<ListaLectura> listaOpt = listaLecturaService.obtenerListaLecturaPorId(id);
        return listaOpt.map(lista -> new ResponseEntity<>(lista, HttpStatus.OK))
                       .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @GetMapping
    public List<ListaLectura> obtenerTodasLasListas(HttpSession session) {
        // Obtener el usuario desde la sesión
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        
        // Verificar si el usuario está presente en la sesión
        if (usuario == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no autenticado");
        }

        // Obtener las listas de lectura del usuario usando su nombre
        return listaLecturaService.obtenerListasUsuario(usuario.getNombre());
    }


 // Eliminar lista de lectura
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarListaLectura(@PathVariable Integer id, HttpSession session) {
        // Obtener el usuario desde la sesión
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        // Verificar si el usuario está presente en la sesión
        if (usuario == null) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED); // Usuario no autenticado
        }

        try {
            // Llamar al servicio para eliminar la lista
            listaLecturaService.eliminarListaLectura(id, usuario.getNombre());
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (IllegalArgumentException e) {
            if (e.getMessage().contains("permisos insuficientes")) {
                return new ResponseEntity<>(HttpStatus.FORBIDDEN); // Usuario no tiene permiso para eliminar
            }
            return new ResponseEntity<>(HttpStatus.NOT_FOUND); // Lista no encontrada
        }
    }


 // Añadir libro a una lista de lectura
    @PutMapping("/{idLista}/libros/{idLibro}")
    public ResponseEntity<Void> añadirLibroALista(@PathVariable Integer idLista, @PathVariable Integer idLibro, HttpSession session) {
        // Obtener el usuario desde la sesión
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        // Verificar si el usuario está presente en la sesión
        if (usuario == null) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED); // Usuario no autenticado
        }

        // Verificar si el usuario es admin o si la lista pertenece al usuario
        boolean esAdmin = listaLecturaService.esAdmin(usuario.getNombre());
        if (esAdmin || listaLecturaService.perteneceAlUsuario(idLista, usuario.getNombre()) || listaLecturaService.esListaPredeterminada(idLista)) {
            listaLecturaService.añadirLibroALista(idLista, idLibro, usuario);
            return new ResponseEntity<>(HttpStatus.OK);
        }

        return new ResponseEntity<>(HttpStatus.FORBIDDEN); // Usuario no tiene permiso para añadir
    }



 // Eliminar libro de una lista de lectura
    @DeleteMapping("/{idLista}/libros/{idLibro}")
    public ResponseEntity<Void> eliminarLibroDeLista(@PathVariable Integer idLista, @PathVariable Integer idLibro, HttpSession session) {
        try {
            // Obtener el usuario desde la sesión
            Usuario usuario = (Usuario) session.getAttribute("usuario");

            // Verificar si el usuario está presente en la sesión
            if (usuario == null) {
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED); // Usuario no autenticado
            }

            // Verificar si el usuario es admin o si la lista pertenece al usuario
            boolean esAdmin = listaLecturaService.esAdmin(usuario.getNombre());
            if (esAdmin || listaLecturaService.perteneceAlUsuario(idLista, usuario.getNombre()) || listaLecturaService.esListaPredeterminada(idLista)) {
                listaLecturaService.eliminarLibroDeLista(idLista, idLibro, usuario);
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            }

            return new ResponseEntity<>(HttpStatus.FORBIDDEN); // Usuario no tiene permiso para eliminar
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND); // Error si la lista o el libro no se encuentran
        }
    }

}
