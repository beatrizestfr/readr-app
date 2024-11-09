package com.example.App_TFG.repositories;

import com.example.App_TFG.entidades.ListaLectura;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface ListaLecturaRepository extends JpaRepository<ListaLectura, Integer> {
    Optional<ListaLectura> findByNombreLista(String nombreLista);
    // Buscar lista de lectura por nombre
}

