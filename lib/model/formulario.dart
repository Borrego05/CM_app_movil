class Formulario {
  final String cliente;
  final String direccion;
  final String obra;
  final String telefono;
  final String descripcion;
  final String materiales_utilizados;
  final String clases_mantenimiento;
  final String tipo_mantenimiento;
  final String contacto;
  final int fk_tecnico_id;
  final String nombre_tecnico;
  final String telefono_tecnico;
  final String nombre_recibe;
  final String cedula_recibe;

  Formulario({
    required this.cliente,
    required this.contacto,
    required this.direccion,
    required this.obra,
    required this.telefono,
    required this.descripcion,
    required this.materiales_utilizados,
    required this.clases_mantenimiento,
    required this.tipo_mantenimiento,
    required this.fk_tecnico_id,
    required this.nombre_tecnico,
    required this.telefono_tecnico,
    required this.nombre_recibe,
    required this.cedula_recibe,
  });

  Map<String, dynamic> toJson()
  {
    return {
      'cliente': cliente,
      'direccion': direccion,
      'obra': obra,
      'telefono': telefono,
      'descripcion': descripcion,
      'materiales_utilizados': materiales_utilizados,
      'clases_mantenimiento': clases_mantenimiento,
      'tipo_mantenimiento': tipo_mantenimiento,
      'contacto': contacto,
      'fk_tecnico_id': fk_tecnico_id,
      'nombre_tecnico': nombre_tecnico,
      'telefono_tecnico': telefono_tecnico,
      'nombre_recibe': nombre_recibe,
      'cedula_recibe': cedula_recibe,
    };
  }
}