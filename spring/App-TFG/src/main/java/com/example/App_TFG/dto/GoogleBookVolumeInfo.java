package com.example.App_TFG.dto;

import java.util.List;

public class GoogleBookVolumeInfo {
    private String title;
    private List<String> authors;
    private String description; // Para la sinopsis
    private GoogleBookImageLinks imageLinks; // Para la imagen

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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public GoogleBookImageLinks getImageLinks() {
        return imageLinks;
    }

    public void setImageLinks(GoogleBookImageLinks imageLinks) {
        this.imageLinks = imageLinks;
    }
}
