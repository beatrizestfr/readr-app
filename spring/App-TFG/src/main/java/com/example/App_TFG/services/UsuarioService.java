package com.example.App_TFG.services;

import com.example.App_TFG.entidades.Rol;
import com.example.App_TFG.entidades.Usuario;
import com.example.App_TFG.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service //Marca esta clase como un servicio, lo que indica a Spring que esta clase es un componente de lógica de negocio.
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;//instancia de UsuarioRepository, que es la interfaz que conecta con la base de datos para la entidad Usuario.


    // Buscar usuario por ID
    public Optional<Usuario> obtenerUsuarioPorId(Integer id) { // presenta un usuario encontrado o no 
        return usuarioRepository.findById(id);
    }
    
    public Optional<Usuario> buscarPorNombre(String nombre) {
        return usuarioRepository.findByNombre(nombre);
    }


    // Seguir a otro usuario
    public void seguirUsuario(Usuario usuario, Usuario usuarioASeguir) {
        usuario.getSiguiendo().add(usuarioASeguir);
        usuarioASeguir.getSeguidores().add(usuario);
        usuarioRepository.save(usuario);
        usuarioRepository.save(usuarioASeguir);
    }
    
    //dejar de seguir 
    public void dejarDeSeguirUsuario(Usuario usuario, Usuario usuarioADejarDeSeguir) {
        usuario.getSiguiendo().remove(usuarioADejarDeSeguir);
        usuarioADejarDeSeguir.getSeguidores().remove(usuario);
        usuarioRepository.save(usuario);
        usuarioRepository.save(usuarioADejarDeSeguir);
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


}
