package com.example.App_TFG.entidades;

import jakarta.persistence.*;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "Roles")
public class Rol {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idRol;

    @Column(nullable = false, length = 50)
    private String nombre;

    // Relación con Usuario (muchos a muchos)
    @JsonIgnore //Esto evitará que la lista de usuarios en Rol sea serializada
    @ManyToMany(mappedBy = "roles")
    private List<Usuario> usuarios;

    // Constructor sin parámetros
    public Rol() {}
    
    // Constructor
    public Rol(String nombre) {
        this.nombre = nombre;
    }

    // Getters y Setters
    public Integer getIdRol() {
        return idRol;
    }

    public void setIdRol(Integer idRol) {
        this.idRol = idRol;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public List<Usuario> getUsuarios() {
        return usuarios;
    }

    public void setUsuarios(List<Usuario> usuarios) {
        this.usuarios = usuarios;
    }
}

