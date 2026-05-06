import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../model/usuario.dart';

class AuthService {

  final _storage = const FlutterSecureStorage();

  Future<Usuario> login(String usuario, String pwd) async {
    final response = await http.post(
      Uri.parse(api_config.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario': usuario,
        'pwd': pwd,
      }),
    );

    if( response.statusCode == 200) {

      final data = jsonDecode(response.body);
      final user = Usuario.fromJson(data);

      //Guardar los datos de la API
      await _storage.write(key: 'token', value: user.token);
      await _storage.write(key: 'usuario', value: user.usuario);
      await _storage.write(key: 'rol', value: user.token);
      await _storage.write(key: 'tecnico_id', value: data['id'].toString());

      return user;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Usuario o contraseña incorrectos');
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }


  Future<String?> getTecnicoId() async {
    return await _storage.read(key: 'tecnico_id');
  }

  Future<String?> getUsuario() async {
    return await _storage.read(key: 'usuario');
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }






}

