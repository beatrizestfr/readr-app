package com.example.App_TFG.services;

import com.example.App_TFG.entidades.Libro;
import com.example.App_TFG.entidades.ListaLectura;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.repositories.LibroRepository;
import com.example.App_TFG.repositories.ListaLecturaRepository;
import com.example.App_TFG.repositories.UsuarioRepository;

import jakarta.servlet.http.HttpSession;
import jakarta.transaction.Transactional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;


import java.util.List;
import java.util.Optional;

@Transactional
@Service
public class ListaLecturaService {
    private static final Logger logger = LoggerFactory.getLogger(ListaLecturaService.class);

	
	
    @Autowired
    private ListaLecturaRepository listaLecturaRepository;
    @Autowired
    private LibroRepository libroRepository;
    @Autowired
    private UsuarioRepository usuarioRepository;

    // Listas predeterminadas que serán adaptadas a cada usuario
    private static final List<String> listasPredeterminadasNombres = List.of(
        "To Read",
        "Reading",
        "Read"
    );


 // Método para asegurarse de que cada usuario tenga sus listas predeterminadas
    
    public void asegurarListasPredeterminadas(Usuario usuario) {
        logger.info("Verificando si el usuario tiene listas predeterminadas: {}", usuario.getNombre());

        // Verificar si el usuario ya tiene listas predeterminadas
        for (String nombreLista : listasPredeterminadasNombres) {

            // Comprobar si ya existe una lista con este nombre para el usuario
            Optional<ListaLectura> listaExistente = listaLecturaRepository.findByNombreListaAndUsuario(nombreLista, usuario);
            logger.info("Comprobando existencia de la lista '{}' para el usuario '{}'", nombreLista, usuario.getNombre());

            if (!listaExistente.isPresent()) {
                logger.info("La lista '{}' no existe para el usuario '{}', creando una nueva lista.", nombreLista, usuario.getNombre());

                // Crear y asociar la lista predeterminada al usuario
                ListaLectura nuevaLista = new ListaLectura();
                nuevaLista.setNombreLista(nombreLista);
                nuevaLista.setUsuario(usuario); // Asociamos la lista al usuario
                listaLecturaRepository.save(nuevaLista);
                listaLecturaRepository.flush(); 
                logger.info("Lista '{}' creada y asociada al usuario '{}'", nombreLista, usuario.getNombre());

            }
        }
    }


 // Crear lista de lectura
    public ListaLectura crearListaLectura(ListaLectura listaLectura, Usuario usuario) {
        // Establece el objeto Usuario en la lista
        logger.info("Creando lista de lectura con nombre '{}' para el usuario '{}'",  usuario.getNombre());

        listaLectura.setUsuario(usuario);
        ListaLectura listaCreada = listaLecturaRepository.save(listaLectura);
        logger.info("Lista de lectura '{}' creada con éxito: ID: {} para el usuario '{}'", listaCreada.getNombreLista(), listaCreada.getIdLista(), usuario.getNombre());
        listaLecturaRepository.flush(); 
        return listaCreada;
        
    }

    
    // Obtener lista de lectura por ID
    public Optional<ListaLectura> obtenerListaLecturaPorId(Integer id) {
        logger.info("Buscando lista de lectura con id: {}", id);
        Optional<ListaLectura> lista = listaLecturaRepository.findById(id);
        if (lista.isPresent()) {
            logger.info("Lista encontrada: {}", lista.get());
        } else {
            logger.warn("Lista no encontrada con id: {}", id);
        }
        return lista;
    }
 // Obtener todas las listas de lectura (solo las del usuario)
    public List<ListaLectura> obtenerListasUsuario(String nombreUsuario) {
        // Verificar si el nombre de usuario es nulo o vacío
        if (nombreUsuario == null || nombreUsuario.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no autenticado");
        }

        // Obtener el usuario desde el repositorio (esto puede requerir que tengas un método para buscar el usuario por nombre)
        Usuario usuario = usuarioRepository.findByNombre(nombreUsuario)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no encontrado"));

        // Obtener las listas de lectura del usuario usando su objeto Usuario
        return listaLecturaRepository.findByUsuario(usuario);
    }


 // Eliminar lista de lectura por ID
    public void eliminarListaLectura(Integer id, String usuarioNombre) {
        Optional<ListaLectura> listaOpt = listaLecturaRepository.findById(id);
        if (listaOpt.isPresent()) {
            ListaLectura lista = listaOpt.get();
            if (lista.getUsuario().getNombre().equals(usuarioNombre) || esAdmin(usuarioNombre)) {
                listaLecturaRepository.deleteById(id);
            } else {
                throw new IllegalArgumentException("No se puede eliminar la lista: permisos insuficientes");
            }
        } else {
            throw new IllegalArgumentException("Lista de lectura no encontrada");
        }
    }


    // Verificar si un usuario es administrador
    public boolean esAdmin(String username) {
        // Lógica para verificar si el usuario tiene el rol de admin
        return "admin".equals(username); // Esto puede depender de tu implementación de roles
    }

    // Verificar si el usuario es el propietario de la lista
    public boolean perteneceAlUsuario(Integer idLista, String usuario) {
        Optional<ListaLectura> listaOpt = listaLecturaRepository.findById(idLista);
        return listaOpt.map(lista -> lista.getUsuario().getNombre().equals(usuario)).orElse(false);
    }

    // Verificar si una lista es predeterminada
    public boolean esListaPredeterminada(Integer idLista) {
        Optional<ListaLectura> listaOpt = listaLecturaRepository.findById(idLista);
        return listaOpt.isPresent() && listasPredeterminadasNombres.contains(listaOpt.get().getNombreLista());
    }

 // Añadir libro a una lista de lectura
    public void añadirLibroALista(Integer idLista, Integer idLibro, Usuario usuario) {
        logger.info("Intentando añadir libro {} a la lista {} para el usuario {}", idLibro, idLista, usuario);

        if (usuario == null) {
            logger.warn("Intento de añadir libro sin usuario autenticado.");
            throw new IllegalArgumentException("Usuario no autenticado");
        }

        Optional<ListaLectura> listaOpt = listaLecturaRepository.findById(idLista);
        Optional<Libro> libroOpt = libroRepository.findById(idLibro);

        if (listaOpt.isEmpty()) {
            logger.warn("Lista con ID {} no encontrada.", idLista);
            throw new IllegalArgumentException("Lista no encontrada");
        }

        if (libroOpt.isEmpty()) {
            logger.warn("Libro con ID {} no encontrado.", idLibro);
            throw new IllegalArgumentException("Libro no encontrado");
        }

        ListaLectura lista = listaOpt.get();
        logger.info("Lista encontrada: {} pertenece a usuario {}", lista.getIdLista(), lista.getUsuario().getIdUsuario());

        if (!lista.getUsuario().getIdUsuario().equals(usuario.getIdUsuario())) {
            logger.warn("El usuario {} no es el propietario de la lista {}", usuario.getIdUsuario(), lista.getIdLista());
            throw new IllegalArgumentException("No puedes añadir un libro a esta lista");
        }

        logger.info("Añadiendo libro {} a la lista {}", libroOpt.get().getIdLibro(), lista.getIdLista());
        lista.getLibros().add(libroOpt.get());
        listaLecturaRepository.save(lista);
        logger.info("Libro añadido correctamente.");
    }


    // Eliminar libro de una lista de lectura
    public void eliminarLibroDeLista(Integer idLista, Integer idLibro, Usuario usuario) {
        if (usuario == null) {
            throw new IllegalArgumentException("Usuario no autenticado");
        }

        Optional<ListaLectura> listaOpt = listaLecturaRepository.findById(idLista);
        Optional<Libro> libroOpt = libroRepository.findById(idLibro);

        if (listaOpt.isPresent() && libroOpt.isPresent()) {
            ListaLectura lista = listaOpt.get();
            if (lista.getUsuario().getIdUsuario().equals(usuario.getIdUsuario())) {
                lista.getLibros().remove(libroOpt.get());
                listaLecturaRepository.save(lista);
            } else {
                throw new IllegalArgumentException("No puedes eliminar un libro de esta lista");
            }
        } else {
            throw new IllegalArgumentException("Lista o libro no encontrado");
        }
    }

    public Optional<ListaLectura> obtenerListaPorNombreYUsuario(String nombreLista, Usuario usuario) {
        return listaLecturaRepository.findByNombreListaAndUsuario(nombreLista, usuario);
    }
    public Optional<ListaLectura> obtenerListaPorId(Integer idLista) {
        return listaLecturaRepository.findById(idLista);
    }
    
    public List<ListaLectura> obtenerListasPorIdUsuario(Integer idUsuario) {
        return listaLecturaRepository.findByUsuarioIdUsuario(idUsuario);
    }

    public Optional<List<Libro>> obtenerLibrosLeidosPorUsuarioId(Integer idUsuario) {
        Optional<ListaLectura> listaRead = listaLecturaRepository.findByNombreListaAndUsuarioIdUsuario("Read", idUsuario);

        return listaRead.map(ListaLectura::getLibros);
    }



}
