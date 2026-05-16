class ActaSilo {

  final String contacto;
  final String cliente;
  final String cedula;
  final String ciudad_cedula;
  final String ciudad;
  final String obra;
  final String numero_silo;
  final String numero_toneladas;
  final String descripcion;
  final String nombre_tecnico;
  final String cedula_tecnico;
  final String tipo_mantenimiento;
  final String clase_mantenimiento;
  final int tecnico_id;
  final String telefono_tecnico;
  final String nombre_recibe;
  final String cedula_recibe;

  ActaSilo({
    required this.contacto,
    required this.cliente,
    required this.cedula,
    required this.ciudad_cedula,
    required this.ciudad,
    required this.obra,
    required this.numero_silo,
    required this.numero_toneladas,
    required this.descripcion,
    required this.nombre_tecnico,
    required this.cedula_tecnico,
    required this.tipo_mantenimiento,
    required this.clase_mantenimiento,
    required this.tecnico_id,
    required this.telefono_tecnico,
    required this.nombre_recibe,
    required this.cedula_recibe,
});

  Map<String, dynamic> toJson() {
    return {
      'contacto': contacto,
      'cliente': cliente,
      'cedula': cedula,
      'ciudad_cedula': ciudad_cedula,
      'ciudad': ciudad,
      'obra': obra,
      'numero_silo': numero_silo,
      'numero_toneladas': numero_toneladas,
      'descripcion': descripcion,
      'nombre_tecnico': nombre_tecnico,
      'cedula_tecnico': cedula_tecnico,
      'tipo_mantenimiento': tipo_mantenimiento,
      'clase_mantenimiento': clase_mantenimiento,
      'tecnico_id': tecnico_id,
      'telefono_tecnico': telefono_tecnico,
      'nombre_recibe': nombre_recibe,
      'cedula_recibe': cedula_recibe,
    };
  }
}