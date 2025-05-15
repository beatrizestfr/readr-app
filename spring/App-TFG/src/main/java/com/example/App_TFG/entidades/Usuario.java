package com.example.App_TFG.entidades;

import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonManagedReference;

@Entity
@Table(name = "Usuarios")
public class Usuario {

	 @Id
	    @GeneratedValue(strategy = GenerationType.IDENTITY)
	    @Column(name = "id_usuario") 
	    private Integer idUsuario;

	    @Column(name = "nombre") 
	    private String nombre;

	    @Column(name = "email", nullable = false, unique = true)
	    private String email;

	    @Column(name = "password", nullable = false)
	    private String password;

	    @Column(name = "avatar_url")
	    private String avatarUrl;

	    @Column(name = "fecha_registro", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
	    private LocalDateTime fechaRegistro;

	    @ManyToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER)
	    @JoinTable(
	        name = "usuario_rol", 
	        joinColumns = @JoinColumn(name = "usuario_id"), 
	        inverseJoinColumns = @JoinColumn(name = "rol_id")
	    )
	    private List<Rol> roles;

	    @OneToMany(fetch = FetchType.EAGER, mappedBy = "usuario")
	    @JsonManagedReference // evitar serie infinita
	    private List<ListaLectura> listasLectura;

	    @OneToMany(mappedBy = "usuario")
	    private List<Reviews> reseñas;

	    @ManyToMany
	    @JoinTable(name = "Seguidores", joinColumns = @JoinColumn(name = "id_seguidor"), inverseJoinColumns = @JoinColumn(name = "id_seguido"))
	    private List<Usuario> siguiendo; // Usuarios a los que este usuario sigue

	    @ManyToMany(mappedBy = "siguiendo")
	    private List<Usuario> seguidores; // Usuarios que siguen a este usuario

	    // Constructor vacío necesario para JPA
	    public Usuario() {}

	    // Constructor con parámetros
	    public Usuario(String nombre, String email, String password, List<Rol> roles, String avatarUrl) {
	        this.nombre = nombre;
	        this.email = email;
	        this.password = password;
	        this.roles = roles != null ? roles : List.of(new Rol("User"));  // Asigna un rol por defecto si roles es null
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

    public List<Rol> getRoles() {
        return roles;
    }

    public void setRoles(List<Rol> roles) {
        this.roles = roles;
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
    
    @Override
    public String toString() {
        return "Usuario{" +
                "email='" + email + '\'' +
                ", password='" + password + '\'' +
                ", avatarUrl='" + avatarUrl + '\'' +
                ", roles=" + roles +
                ", nombre='" + nombre + '\'' +
                '}';
    }

}
