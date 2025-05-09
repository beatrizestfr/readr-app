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

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;


@Service
public class AuthenticationService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private RolRepository rolRepository;
    
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();


    
    public Optional<Usuario> login(String email, String passwordCifrada, HttpSession session) {

        Optional<Usuario> usuario = usuarioRepository.findByEmail(email); 
        if (usuario.isPresent() && passwordEncoder.matches(passwordCifrada, usuario.get().getPassword())) {
            session.setAttribute("usuario", usuario.get());  // Guardar el usuario en la sesión
            return usuario;
        }
        return Optional.empty(); // Usuario o contraseña incorrectos
    }
  
    public Usuario register(String email, String contra, String avatarUrl, List<Rol> roles, String nombre) {
        System.out.println("Parámetros recibidos en el servicio: email=" + email + ", password=" + contra);

        Optional<Usuario> usuarioExistente = usuarioRepository.findByEmail(email);
        if (usuarioExistente.isPresent()) {
            throw new IllegalArgumentException("El correo electrónico ya está registrado.");
        }

        String contraCifrada = passwordEncoder.encode(contra);

        Usuario nuevoUsuario = new Usuario(nombre, email, contraCifrada, roles, avatarUrl);

        if (avatarUrl == null || avatarUrl.isEmpty()) {
            avatarUrl = "";
        }
        nuevoUsuario.setAvatarUrl(avatarUrl);

        if (roles == null || roles.isEmpty()) {
            Rol rolDefault = new Rol("User");
            nuevoUsuario.setRoles(List.of(rolDefault));
        }

        Usuario usuarioGuardado = usuarioRepository.save(nuevoUsuario);
        return usuarioGuardado;
    }



    // Verificar si el usuario es Admin
    public boolean isAdmin(Usuario usuario) {
        return usuario.getRoles().stream()
                      .anyMatch(rol -> rol.getNombre().equals("Admin"));
    }

}
