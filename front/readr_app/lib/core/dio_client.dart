import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DioClient {
  static Dio? _dio;

  static Future<Dio> getInstance() async {
    if (_dio != null) return _dio!;

    final appDocDir = await getApplicationDocumentsDirectory();
    final cookiePath = Directory('${appDocDir.path}/.cookies');

    // Crea el directorio si no existe
    if (!await cookiePath.exists()) {
      await cookiePath.create(recursive: true);
    }

    final cookieJar = PersistCookieJar(storage: FileStorage(cookiePath.path));

    _dio = Dio()..interceptors.add(CookieManager(cookieJar));

    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("Request: ${options.uri}");
        print("Request Headers: ${options.headers}");
        return handler.next(options); // Continuar con la solicitud
      },
      onResponse: (response, handler) {
        print("Response status: ${response.statusCode}");
        print("Response Headers: ${response.headers}");
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          for (var cookie in cookies) {
            print("Cookie: $cookie");
          }
        }
        return handler.next(response); // Continuar con la respuesta
      },
      onError: (DioError e, handler) {
        print("Error: ${e.response?.statusCode}");
        return handler.next(e); // Continuar con el error
      },
    ));

    return _dio!;
  }
}
