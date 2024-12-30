package com.example.App_TFG.dto;

import java.util.List;

public class GoogleBooksResponse {
    private List<GoogleBookItem> items;

    // Getters y setters
    public List<GoogleBookItem> getItems() {
        return items;
    }

    public void setItems(List<GoogleBookItem> items) {
        this.items = items;
    }
}