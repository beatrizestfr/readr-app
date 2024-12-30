package com.example.App_TFG.entidades;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "Libros")
public class Libro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idLibro;

    @Column(nullable = false, length = 255)
    private String titulo;

    private String autor;

    @Column(name = "imagen_url")
    private String imagenUrl;

    private String sinopsis;

    @Column(name = "google_books_id", unique = true)
    private String googleBooksId;

    // Relación Muchos a Muchos con ListaLectura
    @ManyToMany(mappedBy = "libros")
    private List<ListaLectura> listasLectura;

    // Constructor con todos los parámetros
    public Libro(String titulo, String autor, String imagenUrl, String sinopsis, String googleBooksId) {
        this.titulo = titulo;
        this.autor = autor;
        this.imagenUrl = imagenUrl;
        this.sinopsis = sinopsis;
        this.googleBooksId = googleBooksId;
    }

  

    // Getters y Setters

    public Integer getIdLibro() {
        return idLibro;
    }

    public void setIdLibro(Integer idLibro) {
        this.idLibro = idLibro;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getAutor() {
        return autor;
    }

    public void setAutor(String autor) {
        this.autor = autor;
    }

    public String getImagenUrl() {
        return imagenUrl;
    }

    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }

    public String getSinopsis() {
        return sinopsis;
    }

    public void setSinopsis(String sinopsis) {
        this.sinopsis = sinopsis;
    }

    public String getGoogleBooksId() {
        return googleBooksId;
    }

    public void setGoogleBooksId(String googleBooksId) {
        this.googleBooksId = googleBooksId;
    }

    public List<ListaLectura> getListasLectura() {
        return listasLectura;
    }

    public void setListasLectura(List<ListaLectura> listasLectura) {
        this.listasLectura = listasLectura;
    }
}
