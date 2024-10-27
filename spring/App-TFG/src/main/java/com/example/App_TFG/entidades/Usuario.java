package com.example.App_TFG.entidades;

import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "Usuarios")
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idUsuario;

    @Column(nullable = false, length = 100)
    private String nombre;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Column(nullable = false)
    private String password;

    private String avatarUrl;


@Column(name = "fecha_registro", updatable = false)
private LocalDateTime fechaRegistro = LocalDateTime.now();

    // Relaciones
    @OneToMany(mappedBy = "usuario")
    private List<ListaLectura> listasLectura;

    @OneToMany(mappedBy = "usuario")
    private List<Reviews> reseñas;
    
    @ManyToMany
    @JoinTable(
        name = "Usuarios_Roles",
        joinColumns = @JoinColumn(name = "id_usuario"),
        inverseJoinColumns = @JoinColumn(name = "id_rol")
    )
    private List<Roles> roles;

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

	public List<Roles> getRoles() {
		return roles;
	}

	public void setRoles(List<Roles> roles) {
		this.roles = roles;
	}

    
}