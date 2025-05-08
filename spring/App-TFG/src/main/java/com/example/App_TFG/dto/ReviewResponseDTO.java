package com.example.App_TFG.dto;

import java.time.LocalDateTime;

import com.example.App_TFG.entidades.Reviews;

public class ReviewResponseDTO {
    private Integer idReseña;
    private String contenido;
    private int rating;
    private String nombreUsuario;
    private String avatarUsuario;
    private LocalDateTime fecha;
    private Integer idLibro; 
    private String imagenLibroUrl; // Nueva propiedad para la portada

    // Constructor
    public ReviewResponseDTO(Reviews reseña) {
        this.idReseña = reseña.getIdReseña();
        this.contenido = reseña.getContenido();
        this.rating = reseña.getRating();
        this.nombreUsuario = reseña.getUsuario().getNombre();
        this.avatarUsuario = reseña.getUsuario().getAvatarUrl(); 
        this.fecha = reseña.getFecha();
        this.idLibro = reseña.getLibro().getIdLibro(); 
        this.imagenLibroUrl = reseña.getLibro().getSinopsis(); // Se obtiene la portada
    }

    // Getters y Setters
    public Integer getId() {
        return idReseña;
    }

    public void setId(Integer id) {
        this.idReseña = id;
    }

    public String getContenido() {
        return contenido;
    }

    public void setContenido(String contenido) {
        this.contenido = contenido;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getNombreUsuario() {
        return nombreUsuario;
    }

    public void setNombreUsuario(String nombreUsuario) {
        this.nombreUsuario = nombreUsuario;
    }

    public String getAvatarUsuario() {
        return avatarUsuario;
    }

    public void setAvatarUsuario(String avatarUsuario) {
        this.avatarUsuario = avatarUsuario;
    }

    public LocalDateTime getFecha() {
        return fecha;
    }

    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }

    public Integer getIdLibro() {
        return idLibro;
    }

    public void setIdLibro(Integer idLibro) {
        this.idLibro = idLibro;
    }

    public String getImagenLibroUrl() {
        return imagenLibroUrl;
    }

    public void setImagenLibroUrl(String imagenLibroUrl) {
        this.imagenLibroUrl = imagenLibroUrl;
    }
}
