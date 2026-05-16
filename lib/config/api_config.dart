class api_config {

  //URL de la API
  static const String base_url = 'http://192.168.1.169:8080';

  //Endpoint de autenticacion
  static const String login = '$base_url/auth/login';

  //Endpoints del formulario
  static const String crear_formulario = '$base_url/formulario/crear';

  static const String listar_formularios = '$base_url/formulario/listar';

  static const String formulario_tecnico = '$base_url/formulario/tecnico';

  //Endpoints para el acta silo
  static const String crear_act_silo = '$base_url/acta-silo/crear';

  static const String listar_acta_silo = '$base_url/acta-silo/listar';

  static const String acta_silo_tecnico = '$base_url/acta-silo/tecnico';


}