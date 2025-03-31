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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@CrossOrigin(origins = "*")
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
    public ResponseEntity<Map<String, Object>> register(@RequestBody Usuario usuario) {
        Map<String, Object> response = new HashMap<>();

    	try {
        	System.out.println("Datos recibidos en el controlador: " + usuario);
        	System.out.println("Datos recibidos en el controlador: email=" + usuario.getEmail() + ", password=" + usuario.getPassword());
        	
        	
        	// planteo ls utilixscion de rdye metodo y di borrarlo, ver funcionmamiento din el .
//        	 if (usuario.getRoles() != null) {
//                 for (Rol rol : usuario.getRoles()) {
//                     if (rol.getIdRol() == null) { // Si el rol no tiene ID, buscarlo por nombre
//                         Optional<Rol> rolExistente = rolRepository.findByNombre(rol.getNombre());
//                         if (rolExistente.isPresent()) {
//                             rol.setIdRol(rolExistente.get().getIdRol()); // Asignar el ID del rol existente
//                         } else {
//                             rolRepository.save(rol); // Guardar el rol si no existe
//                         }
//                     }
//                 }
//             }
        	 
        	 if (usuario.getRoles() != null) {
                 List<Rol> rolesPersistidos = new ArrayList<>();
                 for (Rol rol : usuario.getRoles()) {
                     Optional<Rol> rolExistente = rolRepository.findByNombre(rol.getNombre());
                     if (rolExistente.isPresent()) {
                         rolesPersistidos.add(rolExistente.get());
                     } else {
                         rolRepository.save(rol); // Guardar nuevo rol
                         rolesPersistidos.add(rol);
                     }
                 }
                 usuario.setRoles(rolesPersistidos); // Asignar roles persistidos al usuario
             }
        	 
        	 
        	 
            // Llamar al servicio para manejar el registro
            authenticationService.register(
                usuario.getEmail(),
                usuario.getPassword(), 
                usuario.getAvatarUrl(),
                usuario.getRoles(),
                usuario.getNombre()
            );

            // Responder con éxito
            // Construir respuesta JSON
            response.put("message", "Registro exitoso");
            response.put("nombre", usuario.getNombre());
            response.put("email", usuario.getEmail());
            response.put("role", usuario.getRoles() != null && !usuario.getRoles().isEmpty()
                    ? usuario.getRoles().get(0).getNombre()
                    : "User (por defecto)");
    	
    	return ResponseEntity.ok(response);
    } catch (IllegalArgumentException e) {
        response.put("error", e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    } catch (Exception e) {
        System.err.println("Error al registrar usuario: " + e);
        response.put("error", "Error inesperado: " + e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }
    }
    
 // Ruta para cerrar sesión (log out)
    @PostMapping("/logout")
    public ResponseEntity<String> logout(HttpServletRequest request, HttpServletResponse response) {
        request.getSession().invalidate(); // Invalida la sesión actual
        return ResponseEntity.ok("Log out exitoso");

    }
}
