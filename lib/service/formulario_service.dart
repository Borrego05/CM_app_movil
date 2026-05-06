import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../config/api_config.dart';
import '../model/formulario.dart';
import 'auth_service.dart';

class FormularioService {

  final AuthService _authService = AuthService();

  Future<Uint8List> crearFormulario(
      Formulario formulario,
      List<File> imagenes,
      File firmaTecnico,
      ) async {

    final token = await _authService.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(api_config.crear_formulario),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['data'] = jsonEncode(formulario.toJson());

    request.files.add(await http.MultipartFile.fromPath(
      'firmaTecnico',
      firmaTecnico.path,
      contentType: MediaType('image', 'png'),
    ));

    for (File imagen in imagenes) {
      request.files.add(await http.MultipartFile.fromPath(
        'imagenes',
        imagen.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Error al crear el formulario: ${response.body}');
    }
  }
}
