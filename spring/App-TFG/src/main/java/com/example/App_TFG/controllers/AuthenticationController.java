package com.example.App_TFG.controllers;

import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.services.AuthenticationService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/auth")
public class AuthenticationController {

    @Autowired
    private AuthenticationService authenticationService;

    // Ruta para el login
    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestParam String email, @RequestParam String passwordCifrada) {
        Optional<Usuario> usuarioOptional = authenticationService.login(email, passwordCifrada);

        if (usuarioOptional.isPresent()) {
            Usuario usuario = usuarioOptional.get();
            if (authenticationService.isAdmin(usuario)) {
                return ResponseEntity.ok("Login successful, role: Admin");
            } else {
                return ResponseEntity.ok("Login successful, role: User");
            }
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
        }
    }

    // Ruta para el registro
    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestParam String nombre, @RequestParam String email, @RequestParam String passwordCifrada) {
        try {
            authenticationService.register(nombre, email, passwordCifrada);
            return ResponseEntity.ok("Registration successful, default role: User");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    
 // Ruta para cerrar sesión (log out)
    @PostMapping("/logout")
    public ResponseEntity<String> logout(HttpServletRequest request, HttpServletResponse response) {
        request.getSession().invalidate(); // Invalida la sesión actual
        return ResponseEntity.ok("Logged out successfully");

    }
}
