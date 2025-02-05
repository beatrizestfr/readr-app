package com.example.App_TFG.dto;

import java.util.List;

public class BookDTO {
    private String title;
    private List<String> authors;
    private String imagenUrl;
    private String sinopsis;
    private String googleBooksId;

    // Constructor
    public BookDTO(String title, List<String> authors, String imagenUrl, String sinopsis,  String googleBooksId) {
        this.title = title;
        this.authors = authors;
        this.imagenUrl = imagenUrl;
        this.sinopsis = sinopsis;
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
}
