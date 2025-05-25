package com.example.App_TFG.controllers;

import com.example.App_TFG.entidades.Rol;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.repositories.RolRepository;
import com.example.App_TFG.services.AuthenticationService;
import com.example.App_TFG.services.ListaLecturaService;

import jakarta.servlet.http.Cookie;
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
    
    @Autowired
    private ListaLecturaService listaLecturaService;

    
    // Ruta para el login
 // Añadir un HttpOnly y Secure cookie para manejar la sesión
    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> requestBody, HttpSession session, HttpServletResponse response) {
        try {
            String email = requestBody.get("email");
            String password = requestBody.get("password");

            if (email == null || password == null) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("error", "El email y la contraseña son obligatorios.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
            }

            Optional<Usuario> usuarioOptional = authenticationService.login(email, password, session);

            if (usuarioOptional.isPresent()) {
                Usuario usuario = usuarioOptional.get();
                session.setAttribute("usuario", usuario);

                // Crear una cookie de sesión con HttpOnly y Secure activados
                Cookie cookie = new Cookie("JSESSIONID", session.getId());
                cookie.setHttpOnly(true);  // Solo accesible desde el servidor
               // cookie.setSecure(true);    // Solo enviada por HTTPS
                cookie.setPath("/");       // Válida para todo el dominio
                response.addCookie(cookie);

                logger.info("Usuario autenticado y guardado en la sesión: " + usuario.getIdUsuario());

                String rol = authenticationService.isAdmin(usuario) ? "Admin" : "User";

                Map<String, Object> responseMap = new HashMap<>();
                responseMap.put("mensaje", "Login exitoso");
                responseMap.put("rol", rol);
                responseMap.put("id", usuario.getIdUsuario());
                responseMap.put("nombre", usuario.getNombre());

                return ResponseEntity.ok(responseMap);
            } else {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("error", "Credenciales incorrectas");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse);
            }
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Error inesperado: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

 
 // Ruta para el registro
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody Usuario usuario) {
        Map<String, Object> response = new HashMap<>();

        try {
            System.out.println("Datos recibidos en el controlador: " + usuario);
            System.out.println("Datos recibidos en el controlador: email=" + usuario.getEmail() + ", password=" + usuario.getPassword());

            if (usuario.getRoles() != null) {
                List<Rol> rolesPersistidos = new ArrayList<>();
                for (Rol rol : usuario.getRoles()) {
                    Optional<Rol> rolExistente = rolRepository.findByNombre(rol.getNombre());
                    if (rolExistente.isPresent()) {
                        rolesPersistidos.add(rolExistente.get());
                    } else {
                        rolRepository.save(rol);
                        rolesPersistidos.add(rol);
                    }
                }
                usuario.setRoles(rolesPersistidos);
            }

            // Llamar al servicio y obtener el usuario registrado
            Usuario usuarioRegistrado = authenticationService.register(
                usuario.getEmail(),
                usuario.getPassword(),
                usuario.getAvatarUrl(),
                usuario.getRoles(),
                usuario.getNombre()
            );
            listaLecturaService.asegurarListasPredeterminadas(usuarioRegistrado);

            // Construir respuesta JSON
            response.put("message", "Registro exitoso");
            response.put("id", usuarioRegistrado.getIdUsuario());
            response.put("nombre", usuarioRegistrado.getNombre());
            response.put("email", usuarioRegistrado.getEmail());

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
    public ResponseEntity<String> logout(HttpSession session, HttpServletResponse response) {
        // Invalida la sesión actual
        session.invalidate();

        // Borra la cookie de sesión 
        Cookie cookie = new Cookie("JSESSIONID", null);
        cookie.setPath("/");
        cookie.setHttpOnly(true);
        cookie.setMaxAge(0); // Expira de inmediato
        response.addCookie(cookie);

        return ResponseEntity.ok("Sesión cerrada correctamente");
    }

}
