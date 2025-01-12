package com.example.App_TFG.dto;

public class UsuarioDTO {
    private Integer idUsuario;
    private String nombre;
    private String email;
    private String avatarUrl;

    // Constructor
    public UsuarioDTO(Integer idUsuario, String nombre, String email, String avatarUrl) {
        this.idUsuario = idUsuario;
        this.nombre = nombre;
        this.email = email;
        this.avatarUrl = avatarUrl;
    }

    // Getters y setters
    public Integer getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Integer idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }
}

