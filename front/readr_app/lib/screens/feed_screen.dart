import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/dio_client.dart';
import '../models/Review.dart';
import 'LibroDetalle_screen.dart';
import 'package:intl/intl.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Review> reviews = [];
  List<bool> expandedList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final dio = await DioClient.getInstance();

      // Hacer la solicitud para obtener las reseñas del feed
      final response = await dio.get('http://10.0.2.2:8080/api/resenas/feed');
      if (response.statusCode == 200) {
        setState(() {
          // Convertir las reseñas a una lista de objetos Review
          reviews = (response.data as List)
              .map((reviewJson) => Review.fromJson(reviewJson))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Error al obtener reseñas: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error de red: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novedades'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                final formattedDate =
                    DateFormat('dd/MM/yyyy').format(review.fecha);

                if (expandedList.length < reviews.length) {
                  expandedList.add(false);
                }

                final isExpanded = expandedList[index];
                final bool shouldTruncate = review.contenido.length > 200;

                return Container(
                  constraints: const BoxConstraints(minHeight: 180),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LibroDetalle_screen(idLibro: review.idLibro),
                            ),
                          );
                        },
                        child: Container(
                          width: 120,
                          height: 180,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(review.imagenLibroUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.nombreUsuario,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.yellow,
                                  size: 18,
                                );
                              }),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              review.contenido,
                              maxLines: isExpanded ? null : 6,
                              overflow: isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                            if (!isExpanded && shouldTruncate)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    expandedList[index] = true;
                                  });
                                },
                                child: const Text(
                                  'Leer más',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
