package com.example.App_TFG.controllers;

import com.example.App_TFG.entidades.Libro;
import com.example.App_TFG.entidades.ListaLectura;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.services.ListaLecturaService;

import jakarta.servlet.http.HttpSession;
import jakarta.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
@RestController
@RequestMapping("/api/listas-lectura")
public class ListaLecturaController {
	
	 private static final Logger logger = LoggerFactory.getLogger(ListaLecturaService.class);

    @Autowired
    private ListaLecturaService listaLecturaService;
    
    // Crear lista de lectura
    @Transactional
    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ListaLectura> crearListaLectura(@RequestBody ListaLectura listaLectura, HttpSession session) {
        // Obtener el nombre del usuario desde la sesión
    	Usuario usuario = (Usuario) session.getAttribute("usuario");
    	if (usuario == null) {
    	    return new ResponseEntity<>(HttpStatus.UNAUTHORIZED); // Usuario no autenticado
    	}
    	logger.info("Usuario autenticado: {} (ID: {})", usuario.getNombre(), usuario.getIdUsuario());
        logger.info("Datos recibidos para crear la lista: {}", listaLectura);

        // Crear la lista de lectura
        ListaLectura listaCreada = listaLecturaService.crearListaLectura(listaLectura, usuario);
        logger.info("Lista creada: {} (ID: {}) para el usuario: {}", listaCreada.getNombreLista(), listaCreada.getIdLista(), usuario.getNombre());

        // Asegurar las listas predeterminadas
        listaLecturaService.asegurarListasPredeterminadas(usuario);

        return new ResponseEntity<>(listaCreada, HttpStatus.CREATED);
    }
    

    // Obtener lista de lectura por ID
    @GetMapping("/{id}")
    public ResponseEntity<ListaLectura> obtenerListaLecturaPorId(@PathVariable Integer id) {
        logger.info("Buscando lista de lectura con id: {}", id);

        Optional<ListaLectura> listaOpt = listaLecturaService.obtenerListaLecturaPorId(id);
        
        
        
        return listaOpt.map(lista -> new ResponseEntity<>(lista, HttpStatus.OK))
                       .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
  


    // todas las listad de lectura de un susuario
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

    @GetMapping("/read")
    public ResponseEntity<List<Libro>> obtenerLibrosLeidos(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        Optional<ListaLectura> listaRead = listaLecturaService
            .obtenerListaPorNombreYUsuario("Read", usuario);

        if (listaRead.isPresent()) {
            return new ResponseEntity<>(listaRead.get().getLibros(), HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
    
    @GetMapping("/libros/id/{idLista}")
    public ResponseEntity<List<Libro>> obtenerLibrosDeListaPorId(
            @PathVariable Integer idLista,
            HttpSession session) {

//        Usuario usuario = (Usuario) session.getAttribute("usuario");
//        if (usuario == null) {
//            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
//        }

        Optional<ListaLectura> listaOpt = listaLecturaService.obtenerListaPorId(idLista);

        if (listaOpt.isPresent() ) {
            return new ResponseEntity<>(listaOpt.get().getLibros(), HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
    @GetMapping("/listas-predeterminadas")
    public ResponseEntity<Map<String, Integer>> obtenerListasPredeterminadas(HttpSession session) {
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        if (usuario == null) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        Map<String, Integer> listas = new HashMap<>();
        listas.put("To Read", listaLecturaService.obtenerListaPorNombreYUsuario("To Read", usuario).map(ListaLectura::getIdLista).orElse(null));
        listas.put("Reading", listaLecturaService.obtenerListaPorNombreYUsuario("Reading", usuario).map(ListaLectura::getIdLista).orElse(null));
        listas.put("Read", listaLecturaService.obtenerListaPorNombreYUsuario("Read", usuario).map(ListaLectura::getIdLista).orElse(null));

        return new ResponseEntity<>(listas, HttpStatus.OK);
    }

    @GetMapping("/usuario/{idUsuario}")
    public ResponseEntity<List<ListaLectura>> obtenerListasPorIdUsuario(@PathVariable Integer idUsuario) {
        List<ListaLectura> listas = listaLecturaService.obtenerListasPorIdUsuario(idUsuario);

        if (listas.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        } else {
            return new ResponseEntity<>(listas, HttpStatus.OK);
        }
    }

    @GetMapping("/read/{idUsuario}")
    public ResponseEntity<List<Libro>> obtenerLibrosLeidosPorUsuarioId(@PathVariable Integer idUsuario) {
        Optional<List<Libro>> librosLeidos = listaLecturaService.obtenerLibrosLeidosPorUsuarioId(idUsuario);

        if (librosLeidos.isPresent()) {
            return new ResponseEntity<>(librosLeidos.get(), HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }



}
