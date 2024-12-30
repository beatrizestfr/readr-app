package com.example.App_TFG.dto;

public class GoogleBookItem {
    private GoogleBookVolumeInfo volumeInfo;
    private String id;  // Agregar el campo id

    // Getters y setters
    public GoogleBookVolumeInfo getVolumeInfo() {
        return volumeInfo;
    }

    public void setVolumeInfo(GoogleBookVolumeInfo volumeInfo) {
        this.volumeInfo = volumeInfo;
    }

    public String getId() {
        return id;  // Getter para id
    }

    public void setId(String id) {
        this.id = id;  // Setter para id
    }
}
