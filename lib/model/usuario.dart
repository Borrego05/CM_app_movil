class Usuario {

  final String token;
  final String usuario;
  final String rol;

  Usuario({
    required this.token,
    required this.usuario,
    required this.rol,
});

  factory Usuario.fromJson(Map<String, dynamic> json)
  {
    return Usuario(
      token: json['token'],
      usuario: json['usuario'],
      rol: json['rol'],
    );
  }
}