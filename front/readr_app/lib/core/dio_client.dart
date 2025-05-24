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

    if (!await cookiePath.exists()) {
      await cookiePath.create(recursive: true);
      print("📁 Directorio de cookies creado en: ${cookiePath.path}");
    }

    final cookieJar = PersistCookieJar(storage: FileStorage(cookiePath.path));
    _dio = Dio()..interceptors.add(CookieManager(cookieJar));

    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("📤 Enviando petición:");
        print("  🔗 URL: ${options.uri}");
        print("  🧾 Headers: ${options.headers}");
        if (options.data != null) {
          print("  📦 Body: ${options.data}");
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("✅ Respuesta recibida:");
        print("  🔢 Status: ${response.statusCode}");
        print("  🧾 Headers: ${response.headers}");
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          for (var cookie in cookies) {
            print("🍪 Cookie recibida: $cookie");
          }
        }
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        print("❌ Error en la petición:");
        if (e.response != null) {
          print("  🔢 Status: ${e.response?.statusCode}");
          print("  🧾 Headers: ${e.response?.headers}");
          print("  📄 Data: ${e.response?.data}");
        } else {
          print("  💥 Error sin respuesta del servidor: ${e.message}");
        }
        return handler.next(e);
      },
    ));

    print("⚙️ DioClient inicializado correctamente.");
    return _dio!;
  }
}
