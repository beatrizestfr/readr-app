package com.example.App_TFG.entidades;

import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "Usuarios")
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idUsuario;
    private String nombre;
    private String email;
    private String password;
    private String avatarUrl;
    private LocalDateTime fechaRegistro = LocalDateTime.now();

    // Relación con el rol
    @ManyToOne
    @JoinColumn(name = "id_rol")
    private Rol rol;

    // Relaciones
    @OneToMany(mappedBy = "usuario")
    private List<ListaLectura> listasLectura;

    @OneToMany(mappedBy = "usuario")
    private List<Reviews> reseñas;

    // Relaciones de seguimiento
    @ManyToMany
    @JoinTable(name = "Seguidores", joinColumns = @JoinColumn(name = "id_seguidor"), inverseJoinColumns = @JoinColumn(name = "id_seguido"))
    private List<Usuario> siguiendo; // Usuarios a los que este usuario sigue

    @ManyToMany(mappedBy = "siguiendo")
    private List<Usuario> seguidores; // Usuarios que siguen a este usuario

    // Constructor sin parámetros (inicializa con valores predeterminados)
    public Usuario() {
        this.rol = new Rol("User");
        this.fechaRegistro = LocalDateTime.now();
    }

    // Constructor con parámetros para inicializar todos los atributos importantes
    public Usuario(String nombre, String email, String password, Rol rol, String avatarUrl) {
        this.nombre = nombre;
        this.email = email;
        this.password = password;
        this.rol = rol != null ? rol : new Rol("User");  // Asigna un rol por defecto si es null
        this.avatarUrl = avatarUrl;
        this.fechaRegistro = LocalDateTime.now();  // Siempre se asigna la fecha actual
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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public Rol getRol() {
        return rol;
    }

    public void setRol(Rol rol) {
        this.rol = rol;
    }

    public List<ListaLectura> getListasLectura() {
        return listasLectura;
    }

    public void setListasLectura(List<ListaLectura> listasLectura) {
        this.listasLectura = listasLectura;
    }

    public List<Reviews> getReseñas() {
        return reseñas;
    }

    public void setReseñas(List<Reviews> reseñas) {
        this.reseñas = reseñas;
    }

    public List<Usuario> getSiguiendo() {
        return siguiendo;
    }

    public void setSiguiendo(List<Usuario> siguiendo) {
        this.siguiendo = siguiendo;
    }

    public List<Usuario> getSeguidores() {
        return seguidores;
    }

    public void setSeguidores(List<Usuario> seguidores) {
        this.seguidores = seguidores;
    }
}
