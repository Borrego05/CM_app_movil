import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../config/api_config.dart';
import '../model/acta_silo.dart';
import 'auth_service.dart';

class ActaSiloService {

  final AuthService _authService = AuthService();

  // Crear acta de silo con imágenes opcionales
  Future<Uint8List> crearActaSilo(
      ActaSilo actaSilo,
      List<File> imagenes,
      File firmaTecnico,
      ) async {

    // 1. Obtiene el token guardado
    final token = await _authService.getToken();

    // 2. Crea la petición multipart
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(api_config.crear_act_silo),
    );

    // 3. Agrega el token en el header
    request.headers['Authorization'] = 'Bearer $token';

    // 4. Agrega los datos del acta como JSON
    request.fields['data'] = jsonEncode(actaSilo.toJson());

    // 5. Agrega la firma del técnico
    request.files.add(await http.MultipartFile.fromPath(
      'firmaTecnico',
      firmaTecnico.path,
      contentType: MediaType('image', 'png'),
    ));

    // 6. Agrega las imágenes solo si existen
    if (imagenes != null && imagenes.isNotEmpty) {
      for (File imagen in imagenes) {
        request.files.add(await http.MultipartFile.fromPath(
          'imagenes',
          imagen.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }
    }

    // 6. Envía la petición y espera la respuesta
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Retorna los bytes del PDF generado
      return response.bodyBytes;
    } else {
      throw Exception('Error al crear el acta: ${response.body}');
    }
  }
}