package com.example.App_TFG.controllers;

import com.example.App_TFG.entidades.Rol;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.repositories.RolRepository;
import com.example.App_TFG.services.AuthenticationService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/auth")
public class AuthenticationController {

    private static final Logger logger = LoggerFactory.getLogger(AuthenticationService.class);

	
    @Autowired
    private AuthenticationService authenticationService;
    
    @Autowired
    private  RolRepository rolRepository ;
    
    // Ruta para el login
    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody Map<String, String> requestBody, HttpSession session) {
        try {
            // Extraer los datos del cuerpo de la solicitud
            String email = requestBody.get("email");
            String password = requestBody.get("password");

            if (email == null || password == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("El email y la contraseña son obligatorios.");
            }

            // Intentar realizar el login
            Optional<Usuario> usuarioOptional = authenticationService.login(email, password, session);

            if (usuarioOptional.isPresent()) {
                Usuario usuario = usuarioOptional.get();

                // **ALMACENAR USUARIO EN LA SESIÓN**
                session.setAttribute("usuario", usuario); 
                logger.info("Usuario autenticado y guardado en la sesión: " + usuario.getIdUsuario());

                if (authenticationService.isAdmin(usuario)) {
                    return ResponseEntity.ok("Login exitoso, rol: Admin");
                } else {
                    return ResponseEntity.ok("Login exitoso, rol: User");
                }
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body("Credenciales incorrectas");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error inesperado: " + e.getMessage());
        }
    }


 
 // Ruta para el registro
    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody Usuario usuario) {
        try {
        	System.out.println("Datos recibidos en el controlador: " + usuario);
        	System.out.println("Datos recibidos en el controlador: email=" + usuario.getEmail() + ", password=" + usuario.getPassword());
        	
        	// planteo ls utilixscion de rdye metodo y di borrarlo, ver funcionmamiento din el .
        	 if (usuario.getRoles() != null) {
                 for (Rol rol : usuario.getRoles()) {
                     if (rol.getIdRol() == null) { // Si el rol no tiene ID, buscarlo por nombre
                         Optional<Rol> rolExistente = rolRepository.findByNombre(rol.getNombre());
                         if (rolExistente.isPresent()) {
                             rol.setIdRol(rolExistente.get().getIdRol()); // Asignar el ID del rol existente
                         } else {
                             rolRepository.save(rol); // Guardar el rol si no existe
                         }
                     }
                 }
             }
            // Llamar al servicio para manejar el registro
            authenticationService.register(
                usuario.getEmail(),
                usuario.getPassword(), // Contraseña cifrada desde el front
                usuario.getAvatarUrl(),
                usuario.getRoles(),
                usuario.getNombre()
            );

            // Responder con éxito
            return ResponseEntity.ok("Registro exitoso. Rol asignado: " +
                    (usuario.getRoles() != null && !usuario.getRoles().isEmpty()
                            ? usuario.getRoles().get(0).getNombre()
                            : "User (por defecto)"));
        } catch (IllegalArgumentException e) {
            // Manejar errores de negocio
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
        	System.out.printf("Error al registrar usuario: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error inesperado: " + e.getMessage());
        }
    }
    
 // Ruta para cerrar sesión (log out)
    @PostMapping("/logout")
    public ResponseEntity<String> logout(HttpServletRequest request, HttpServletResponse response) {
        request.getSession().invalidate(); // Invalida la sesión actual
        return ResponseEntity.ok("Log out exitoso");

    }
}
