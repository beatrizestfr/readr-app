package com.example.App_TFG.entidades;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Reviews")
public class Reviews {

    @Id
    @Column(name = "id_Reseña", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idReseña;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String contenido;

    @Column(name = "fecha", updatable = false)
    private LocalDateTime fecha = LocalDateTime.now();

    // Relación con Usuario
    @ManyToOne
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    // Relación con Libros
    @ManyToOne
    @JoinColumn(name = "id_libro", nullable = false)
    private Libro libro;

    @Column(nullable = false)
    private int rating;

    
    // Getters y Setters

    public Integer getIdReseña() {
        return idReseña;
    }

    public void setIdReseña(Integer idReseña) {
        this.idReseña = idReseña;
    }

    public String getContenido() {
        return contenido;
    }

    public void setContenido(String contenido) {
        this.contenido = contenido;
    }

    public LocalDateTime getFecha() {
        return fecha;
    }

    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }

    public Libro getLibro() {
        return libro;
    }

    public void setLibro(Libro libro) {
        this.libro = libro;
    }
    
    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

}
