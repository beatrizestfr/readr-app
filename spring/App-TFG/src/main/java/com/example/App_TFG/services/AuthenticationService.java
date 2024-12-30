package com.example.App_TFG.services;

import com.example.App_TFG.entidades.Rol;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.repositories.RolRepository;
import com.example.App_TFG.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthenticationService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private RolRepository rolRepository;

    // Lógica de login (sin hash en el backend)
    public Optional<Usuario> login(String email, String passwordCifrada) {
        Optional<Usuario> usuario = usuarioRepository.findByEmail(email); // Buscar usuario por email
        if (usuario.isPresent() && passwordCifrada.equals(usuario.get().getPassword())) {
            return usuario; // Usuario autenticado correctamente
        }
        return Optional.empty(); // Usuario o contraseña incorrectos
    }

    // Lógica de registro
    public void register(String nombre, String email, String passwordCifrada) {
        // Verificar si el correo ya está registrado
        Optional<Usuario> usuarioExistente = usuarioRepository.findByEmail(email);
        if (usuarioExistente.isPresent()) {
            throw new IllegalArgumentException("El correo electrónico ya está registrado.");
        }

        // Crear el nuevo usuario
        Usuario nuevoUsuario = new Usuario();
        nuevoUsuario.setNombre(nombre);
        nuevoUsuario.setEmail(email);
        nuevoUsuario.setPassword(passwordCifrada); // La contraseña ya viene cifrada

        // Asignar el rol "User" por defecto
        Rol rolUser = rolRepository.findByNombre("ROLE_USER").orElseThrow(() -> 
            new IllegalArgumentException("Rol de usuario no encontrado.")
        );
        nuevoUsuario.setRol(rolUser);

        // Guardar el nuevo usuario en la base de datos
        usuarioRepository.save(nuevoUsuario);
    }

    // Verificar si el usuario es Admin
    public boolean isAdmin(Usuario usuario) {
        return usuario.getRol().getNombre().equals("ROLE_ADMIN");
    }
}
