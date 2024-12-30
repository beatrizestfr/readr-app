package com.example.App_TFG.services;

import com.example.App_TFG.dto.BookDTO;
import com.example.App_TFG.dto.GoogleBookVolumeInfo;
import com.example.App_TFG.dto.GoogleBooksResponse;
import com.example.App_TFG.entidades.Libro;
import com.example.App_TFG.repositories.LibroRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class LibroService {

    @Autowired
    private LibroRepository libroRepository;

    @Value("${google.books.api.url}")
    private String apiUrl;

    @Value("${google.books.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    // Crear un nuevo libro
    public Libro crearLibro(Libro libro) {
        return libroRepository.save(libro);
    }

    // Obtener un libro por su ID
    public Optional<Libro> obtenerLibroPorId(Integer id) {
        return libroRepository.findById(id);
    }

    // Obtener un libro por su título
    public Optional<Libro> obtenerLibroPorTitulo(String titulo) {
        return libroRepository.findByTitulo(titulo);
    }

    // Obtener un libro por su googleBooksId
    public Optional<Libro> obtenerLibroPorGoogleBooksId(String googleBooksId) {
        return libroRepository.findByGoogleBooksId(googleBooksId);
    }

    // Obtener todos los libros
    public List<Libro> obtenerTodosLosLibros() {
        return libroRepository.findAll();
    }

    // Eliminar un libro
    public void eliminarLibro(Integer id) {
        libroRepository.deleteById(id);
    }
// --------------------------------------------------------------------------------------------
    
    // Buscar libros usando la API de Google Books por título y autor
    public List<Libro> buscarLibrosEnGoogle(String titulo, String autor) {
        String url = apiUrl + "?q=" + titulo;
        if (autor != null && !autor.isEmpty()) {
            url += "+inauthor:" + autor;
        }
        url += "&key=" + apiKey;

        ResponseEntity<GoogleBooksResponse> response = restTemplate.getForEntity(url, GoogleBooksResponse.class);

        if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
            return response.getBody().getItems().stream()
                .map(item -> {
                    GoogleBookVolumeInfo volumeInfo = item.getVolumeInfo();

                    // Creamos el libro usando solo título y autor en el constructor
                    Libro libro = new Libro(volumeInfo.getTitle(), String.join(", ", volumeInfo.getAuthors()), volumeInfo.getDescription(), 
                            volumeInfo.getImageLinks() != null ? volumeInfo.getImageLinks().getThumbnail() : null, item.getId());


                    return libro;
                })
                .collect(Collectors.toList());
        }
        return List.of(); // Retorna una lista vacía si no se encuentra ningún libro
    }

    // Añadir un libro a las listas del usuario si existe en Google Books
    public Libro añadirLibroALaLista(String titulo, String autor) {
        List<Libro> librosEncontrados = buscarLibrosEnGoogle(titulo, autor);
        if (!librosEncontrados.isEmpty()) {
            Libro libro = librosEncontrados.get(0); // Tomamos el primer libro encontrado
            return crearLibro(libro); // Añadimos el libro a la base de datos
        }
        return null; // Retorna null si no se encuentra ningún libro
    }
}
