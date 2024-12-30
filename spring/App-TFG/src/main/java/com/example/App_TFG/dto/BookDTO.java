package com.example.App_TFG.dto;

import java.util.List;

public class BookDTO {
    private String title;
    private List<String> authors;
    private String sinopsis;
    private String imagenUrl;
    private String googleBooksId;

    // Constructor
    public BookDTO(String title, List<String> authors, String sinopsis, String imagenUrl, String googleBooksId) {
        this.title = title;
        this.authors = authors;
        this.sinopsis = sinopsis;
        this.imagenUrl = imagenUrl;
        this.googleBooksId = googleBooksId;
    }

    // Getters y setters
    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public List<String> getAuthors() {
        return authors;
    }

    public void setAuthors(List<String> authors) {
        this.authors = authors;
    }

    public String getSinopsis() {
        return sinopsis;
    }

    public void setSinopsis(String sinopsis) {
        this.sinopsis = sinopsis;
    }

    public String getImagenUrl() {
        return imagenUrl;
    }

    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }

    public String getGoogleBooksId() {
        return googleBooksId;
    }

    public void setGoogleBooksId(String googleBooksId) {
        this.googleBooksId = googleBooksId;
    }
}
