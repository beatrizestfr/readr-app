package com.example.App_TFG.services;

import com.example.App_TFG.dto.UsuarioDTO;
import com.example.App_TFG.entidades.Rol;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.repositories.UsuarioRepository;

import java.nio.file.Path;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.util.UUID;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;

@Service //Marca esta clase como un servicio, lo que indica a Spring que esta clase es un componente de lógica de negocio.
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;//instancia de UsuarioRepository, que es la interfaz que conecta con la base de datos para la entidad Usuario.


    // Buscar usuario por ID
//    public Optional<Usuario> obtenerUsuarioPorId(Integer id) { // presenta un usuario encontrado o no 
//        return usuarioRepository.findById(id);
//    }
    
    public Optional<UsuarioDTO> obtenerUsuarioPorId(Integer id) {
        return usuarioRepository.findById(id)
                .map(usuario -> new UsuarioDTO(usuario.getIdUsuario(), usuario.getNombre(), usuario.getEmail(), usuario.getAvatarUrl()));
    }

    
//    public Optional<Usuario> buscarPorNombre(String nombre) {
//        return usuarioRepository.findByNombre(nombre);
//    }

    
    public Optional<UsuarioDTO> buscarPorNombre(String nombre) {
        return usuarioRepository.findByNombre(nombre)
                .map(usuario -> new UsuarioDTO(usuario.getIdUsuario(), usuario.getNombre(), usuario.getEmail(), usuario.getAvatarUrl()));
    }

 // Seguir a otro usuario
    public void seguirUsuario(UsuarioDTO usuarioDTO, UsuarioDTO usuarioASeguirDTO) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findById(usuarioDTO.getIdUsuario());
        Optional<Usuario> usuarioASeguirOpt = usuarioRepository.findById(usuarioASeguirDTO.getIdUsuario());

        if (usuarioOpt.isPresent() && usuarioASeguirOpt.isPresent()) {
            Usuario usuario = usuarioOpt.get();
            Usuario usuarioASeguir = usuarioASeguirOpt.get();

            usuario.getSiguiendo().add(usuarioASeguir);
            usuarioASeguir.getSeguidores().add(usuario);

            usuarioRepository.save(usuario);
            usuarioRepository.save(usuarioASeguir);
        }
    }

    // Dejar de seguir a un usuario
    public void dejarDeSeguirUsuario(UsuarioDTO usuarioDTO, UsuarioDTO usuarioADejarDeSeguirDTO) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findById(usuarioDTO.getIdUsuario());
        Optional<Usuario> usuarioADejarDeSeguirOpt = usuarioRepository.findById(usuarioADejarDeSeguirDTO.getIdUsuario());

        if (usuarioOpt.isPresent() && usuarioADejarDeSeguirOpt.isPresent()) {
            Usuario usuario = usuarioOpt.get();
            Usuario usuarioADejarDeSeguir = usuarioADejarDeSeguirOpt.get();

            usuario.getSiguiendo().remove(usuarioADejarDeSeguir);
            usuarioADejarDeSeguir.getSeguidores().remove(usuario);

            usuarioRepository.save(usuario);
            usuarioRepository.save(usuarioADejarDeSeguir);
        }
    }


    // Obtener lista de seguidores
    public List<Usuario> obtenerSeguidores(Integer idUsuario) {
        return usuarioRepository.findById(idUsuario)
                .map(Usuario::getSeguidores)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));
    }

    // Obtener lista de usuarios seguidos
    public List<Usuario> obtenerSiguiendo(Integer idUsuario) {
        return usuarioRepository.findById(idUsuario)
                .map(Usuario::getSiguiendo)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));
    }

    // edicion de usuario:
    
    public String subirFotoPerfil(MultipartFile file) {
        try {
            String nombreArchivo = UUID.randomUUID() + "_" + file.getOriginalFilename();//es como dar un DNI único al archivo,
            //para que no se repita con otros.
            Path ruta = Paths.get("uploads/" + nombreArchivo);
            Files.copy(file.getInputStream(), ruta, StandardCopyOption.REPLACE_EXISTING);
            
            System.out.println("📂 Guardando imagen con nombre: " + nombreArchivo);
            System.out.println("🌐 URL generada: http://10.0.2.2:8080/uploads/" + nombreArchivo);

            return "http://10.0.2.2:8080/uploads/" + nombreArchivo;
        } catch (IOException e) {
            throw new RuntimeException("Error al guardar la imagen", e);
        }
    }


}
