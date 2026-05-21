class api_config {

  //URL de la API
  static const String base_url = 'https://cmbackend-production-d885.up.railway.app';

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