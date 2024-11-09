package com.example.App_TFG.services;

import com.example.App_TFG.entidades.Libro;
import com.example.App_TFG.entidades.ListaLectura;
import com.example.App_TFG.repositories.LibroRepository;
import com.example.App_TFG.repositories.ListaLecturaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ListaLecturaService {

    @Autowired
    private ListaLecturaRepository listaLecturaRepository;
    @Autowired
    private LibroRepository libroRepository; 

    // Crear lista de lectura
    public ListaLectura crearListaLectura(ListaLectura listaLectura) {
        return listaLecturaRepository.save(listaLectura);
    }

    // Obtener lista de lectura por ID
    public Optional<ListaLectura> obtenerListaLecturaPorId(Integer id) {
        return listaLecturaRepository.findById(id);
    }

    // Obtener lista de lectura por nombre
    public Optional<ListaLectura> obtenerListaLecturaPorNombre(String nombre) {
        return listaLecturaRepository.findByNombreLista(nombre);
    }

    // Obtener todas las listas de lectura
    public List<ListaLectura> obtenerTodasLasListas() {
        return listaLecturaRepository.findAll();
    }

    // Eliminar lista de lectura por ID
    public void eliminarListaLectura(Integer id) {
        listaLecturaRepository.deleteById(id);
    }
 // Añadir un libro a una lista de lectura
    public void añadirLibroALista(Integer idLista, Integer idLibro) {
        Optional<ListaLectura> listaOpt = listaLecturaRepository.findById(idLista); // Usamos el repositorio de ListaLectura
        Optional<Libro> libroOpt = libroRepository.findById(idLibro); // Usamos el repositorio de Libro

        if (listaOpt.isPresent() && libroOpt.isPresent()) {
            ListaLectura lista = listaOpt.get();
            Libro libro = libroOpt.get();

            // Añadir el libro a la lista
            lista.getLibros().add(libro);

            // Guardar los cambios
            listaLecturaRepository.save(lista);
        } else {
            throw new IllegalArgumentException("Lista o libro no encontrado");
        }
    }

    // Eliminar un libro de una lista de lectura
    public void eliminarLibroDeLista(Integer idLista, Integer idLibro) {
        Optional<ListaLectura> listaOpt = listaLecturaRepository.findById(idLista);
        Optional<Libro> libroOpt = libroRepository.findById(idLibro);

        if (listaOpt.isPresent() && libroOpt.isPresent()) {
            ListaLectura lista = listaOpt.get();
            Libro libro = libroOpt.get();

            // Eliminar el libro de la lista
            lista.getLibros().remove(libro);

            // Guardar los cambios
            listaLecturaRepository.save(lista);
        } else {
            throw new IllegalArgumentException("Lista o libro no encontrado");
        }
    }

}

