package com.example.App_TFG.repositories;

import com.example.App_TFG.entidades.ListaLectura;
import com.example.App_TFG.entidades.Usuario;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ListaLecturaRepository extends JpaRepository<ListaLectura, Integer> {
    // Buscar lista de lectura por nombre
    Optional<ListaLectura> findByNombreLista(String nombreLista);

    // Buscar lista de lectura por nombre y usuario
    Optional<ListaLectura> findByNombreListaAndUsuario(String nombreLista, Usuario usuario);

    // Obtener todas las listas de lectura de un usuario por sesio 
    List<ListaLectura> findByUsuario(Usuario usuario);
    //por id 
    List<ListaLectura> findByUsuarioIdUsuario(Integer idUsuario);
    
    Optional<ListaLectura> findByNombreListaAndUsuarioIdUsuario(String nombreLista, Integer idUsuario);


}
