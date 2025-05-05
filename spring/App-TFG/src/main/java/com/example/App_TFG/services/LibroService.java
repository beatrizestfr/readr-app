package com.example.App_TFG.services;

import com.example.App_TFG.dto.BookDTO;
import com.example.App_TFG.dto.GoogleBookItem;
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

import java.util.ArrayList;
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

    // Obtener un libro por su googleBooksId
    public Optional<Libro> obtenerLibroPorGoogleBooksId(String googleBooksId) {
        return libroRepository.findByGoogleBooksId(googleBooksId);
    }

    // Buscar libros usando la API de Google Books por título y autor
    public List<BookDTO> buscarLibrosEnGoogle(String titulo, String autor) {
        String url = apiUrl + "?q=" + titulo;
        if (autor != null && !autor.isEmpty()) {
            url += "+inauthor:" + autor;
        }
        url += "&key=" + apiKey;

        ResponseEntity<GoogleBooksResponse> response = restTemplate.getForEntity(url, GoogleBooksResponse.class);

        if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
            GoogleBooksResponse googleBooksResponse = response.getBody();

            // Aseguramos que items no sea null, y si es así, usamos una lista vacía
            List<GoogleBookItem> items = googleBooksResponse.getItems() != null ? googleBooksResponse.getItems() : new ArrayList<>();

            return items.stream()
                .map(item -> {
                    GoogleBookVolumeInfo volumeInfo = item.getVolumeInfo();

                    // Creamos el DTO de libro usando solo título y autor
                    return new BookDTO(volumeInfo.getTitle(), volumeInfo.getAuthors(), volumeInfo.getDescription(),
                            volumeInfo.getImageLinks() != null ? volumeInfo.getImageLinks().getThumbnail() : null, item.getId());
                })
                .collect(Collectors.toList());
        }

        return List.of(); // Retorna una lista vacía si no se encuentra ningún libro o la respuesta es incorrecta
    }


    // Añadir un libro a la lista del usuario si existe en Google Books
    public Libro añadirLibro(String titulo, String autor) {
        List<BookDTO> librosEncontrados = buscarLibrosEnGoogle(titulo, autor);
        if (!librosEncontrados.isEmpty()) {
            // Si el libro ya existe en la base de datos, no lo agregamos de nuevo
            BookDTO libroDTO = librosEncontrados.get(0);
            Optional<Libro> libroExistente = libroRepository.findByGoogleBooksId(libroDTO.getGoogleBooksId());
            if (libroExistente.isPresent()) {
                return libroExistente.get();
            } else {
            	
            	  // Recorte de la URL de la imagen si supera el tamaño máximo permitido
                String imagenUrl = libroDTO.getImagenUrl();
                int maxLength = 500;  
                if (imagenUrl != null && imagenUrl.length() > maxLength) {
                    imagenUrl = imagenUrl.substring(0, maxLength);  // Recorta la cadena al tamaño permitido
                }
                // Si el libro no existe, lo agregamos
                Libro libro = new Libro(libroDTO.getTitle(), String.join(", ", libroDTO.getAuthors() ),  libroDTO.getImagenUrl(),libroDTO.getSinopsis(), libroDTO.getGoogleBooksId());
                return libroRepository.save(libro); // Guardamos el libro en la base de datos
            }
        }
        return null; // Retorna null si no se encuentra ningún libro
    }
    
    public Optional<Libro> obtenerPorId(Integer id) {
        return libroRepository.findById(id);
    }

}
