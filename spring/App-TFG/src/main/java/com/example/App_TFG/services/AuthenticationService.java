package com.example.App_TFG.services;

import com.example.App_TFG.entidades.Rol;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.repositories.RolRepository;
import com.example.App_TFG.repositories.UsuarioRepository;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class AuthenticationService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private RolRepository rolRepository;

    // Lógica de login (sin hash en el backend)
    public Optional<Usuario> login(String email, String passwordCifrada, HttpSession session) {

        Optional<Usuario> usuario = usuarioRepository.findByEmail(email); 
        if (usuario.isPresent() && passwordCifrada.equals(usuario.get().getPassword())) {
            session.setAttribute("usuario", usuario.get());  // Guardar el usuario en la sesión
            return usuario;
        }
        return Optional.empty(); // Usuario o contraseña incorrectos
    }
  
    public void register(String email, String contraCifrada, String avatarUrl, List<Rol> roles, String nombre) {
        System.out.println("Parámetros recibidos en el servicio: email=" + email + ", password=" + contraCifrada);

        // Verificar si el correo ya está registrado
        Optional<Usuario> usuarioExistente = usuarioRepository.findByEmail(email);
        if (usuarioExistente.isPresent()) {
            throw new IllegalArgumentException("El correo electrónico ya está registrado.");
        }

        // Crear una nueva instancia de Usuario
        Usuario nuevoUsuario = new Usuario( nombre,  email,  contraCifrada,  roles,  avatarUrl);
        nuevoUsuario.setEmail(email);
        nuevoUsuario.setPassword(contraCifrada); // Asignar directamente la contraseña cifrada

        // Asignar un avatar por defecto si no se proporciona
        if (avatarUrl == null || avatarUrl.isEmpty()) {
            avatarUrl = ""; // Valor por defecto
        }
        nuevoUsuario.setAvatarUrl(avatarUrl);

        // Asignar roles por defecto si no se proporcionan
        if (roles == null || roles.isEmpty()) {
            Rol rolDefault = new Rol("User");
            nuevoUsuario.setRoles(List.of(rolDefault));
        } 
        System.out.println("Usuario a guardar: " + nuevoUsuario);
        // Guardar el nuevo usuario en la base de datos
        usuarioRepository.save(nuevoUsuario);
    }


    // Verificar si el usuario es Admin
    public boolean isAdmin(Usuario usuario) {
        return usuario.getRoles().stream()
                      .anyMatch(rol -> rol.getNombre().equals("Admin"));
    }

}
