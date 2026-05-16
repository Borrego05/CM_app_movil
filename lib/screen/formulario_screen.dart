import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../model/formulario.dart';
import '../service/auth_service.dart';
import '../service/formulario_service.dart';
import 'pdf_viewer_screen.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {

  // ── FORM KEY ────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── CONTROLADORES DE TEXTO ──────────────────────────────────
  final _clienteController = TextEditingController();
  final _contactoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _obraController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _materialesController = TextEditingController();
  final _nombreTecnicoFormController = TextEditingController();
  final _telefonoTecnicoController = TextEditingController();
  final _nombreRecibeController = TextEditingController();
  final _cedulaRecibeController = TextEditingController();

  // ── SERVICIOS ───────────────────────────────────────────────
  final _authService = AuthService();
  final _formularioService = FormularioService();
  final _imagePicker = ImagePicker();

  // ── SPEECH TO TEXT ──────────────────────────────────────────
  final SpeechToText _speech = SpeechToText();
  bool _sttDisponible = false;
  bool _escuchando = false;
  String _textoAntesDictar = '';

  // ── ESTADO ──────────────────────────────────────────────────
  bool _cargando = false;
  List<File> _imagenes = [];
  String? _errorImagenes;

  // ── FIRMA CLIENTE ────────────────────────────────────────────
  final _firmaClienteController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );
  String? _errorFirma;

  // ── TIPOS Y CLASES DE MANTENIMIENTO ─────────────────────────
  final List<String> _tiposMantenimiento = [
    'Inspección',
    'Mantenimiento preventivo',
    'Mantenimiento correctivo',
    'Mantenimiento predictivo',
  ];

  final List<String> _clasesMantenimiento = [
    'Estructural',
    'Mecánico',
    'Eléctrico',
    'Neumático',
    'Hidráulico',
    'Automatización y control',
    'Izaje de cargas',
  ];

  List<String> _tiposSeleccionados = [];
  List<String> _clasesSeleccionadas = [];
  String? _errorTipos;
  String? _errorClases;

  // ── MÉTODOS ─────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _inicializarSTT();
  }

  Future<void> _inicializarSTT() async {
    final disponible = await _speech.initialize(
      onError: (error) => setState(() => _escuchando = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _escuchando = false);
        }
      },
    );
    setState(() => _sttDisponible = disponible);
  }

  Future<void> _toggleEscuchar() async {
    if (!_sttDisponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El micrófono no está disponible en este dispositivo')),
      );
      return;
    }

    if (_escuchando) {
      await _speech.stop();
      setState(() => _escuchando = false);
      return;
    }

    // Guarda el texto existente para concatenar la voz al final
    _textoAntesDictar = _descripcionController.text.trim().isEmpty
        ? ''
        : '${_descripcionController.text.trim()} ';

    setState(() => _escuchando = true);

    await _speech.listen(
      localeId: 'es_CO',
      listenFor: const Duration(minutes: 2),
      pauseFor: const Duration(seconds: 4),
      onResult: (result) {
        setState(() {
          _descripcionController.text = _textoAntesDictar + result.recognizedWords;
          // Mueve el cursor al final
          _descripcionController.selection = TextSelection.fromPosition(
            TextPosition(offset: _descripcionController.text.length),
          );
        });
      },
    );
  }

  Future<File> _corregirRotacion(File archivo) async {
    final bytes = await archivo.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return archivo;
    final corregida = img.bakeOrientation(original);
    final dir = await getTemporaryDirectory();
    final tempFile = File('${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(img.encodeJpg(corregida, quality: 85));
    return tempFile;
  }

  Future<void> _tomarFoto() async {
    final XFile? foto = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (foto != null) {
      final corregida = await _corregirRotacion(File(foto.path));
      setState(() {
        _imagenes.add(corregida);
        _errorImagenes = null;
      });
    }
  }

  Future<void> _seleccionarDeGaleria() async {
    final List<XFile> seleccionadas = await _imagePicker.pickMultiImage(imageQuality: 85);
    for (final XFile foto in seleccionadas) {
      final corregida = await _corregirRotacion(File(foto.path));
      setState(() {
        _imagenes.add(corregida);
        _errorImagenes = null;
      });
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF8DD2F),
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Tomar foto'),
                onTap: () { Navigator.pop(context); _tomarFoto(); },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF8DD2F),
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Seleccionar de galería'),
                onTap: () { Navigator.pop(context); _seleccionarDeGaleria(); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _eliminarImagen(int index) {
    setState(() {
      _imagenes.removeAt(index);
    });
  }

  void _mostrarTiposMantenimiento() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tipo de mantenimiento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ..._tiposMantenimiento.map((tipo) => CheckboxListTile(
              title: Text(tipo),
              value: _tiposSeleccionados.contains(tipo),
              activeColor: const Color(0xFFF8DD2F),
              onChanged: (bool? value) {
                setModalState(() {
                  setState(() {
                    if (value == true) {
                      _tiposSeleccionados.add(tipo);
                    } else {
                      _tiposSeleccionados.remove(tipo);
                    }
                    _errorTipos = null;
                  });
                });
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _mostrarClasesMantenimiento() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Clase de mantenimiento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ..._clasesMantenimiento.map((clase) => CheckboxListTile(
              title: Text(clase),
              value: _clasesSeleccionadas.contains(clase),
              activeColor: const Color(0xFFF8DD2F),
              onChanged: (bool? value) {
                setModalState(() {
                  setState(() {
                    if (value == true) {
                      _clasesSeleccionadas.add(clase);
                    } else {
                      _clasesSeleccionadas.remove(clase);
                    }
                    _errorClases = null;
                  });
                });
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _validarCamposExtra() {
    bool valido = true;
    setState(() {
      if (_tiposSeleccionados.isEmpty) {
        _errorTipos = 'Selecciona al menos un tipo de mantenimiento';
        valido = false;
      } else {
        _errorTipos = null;
      }
      if (_clasesSeleccionadas.isEmpty) {
        _errorClases = 'Selecciona al menos una clase de mantenimiento';
        valido = false;
      } else {
        _errorClases = null;
      }
      if (_imagenes.isEmpty) {
        _errorImagenes = 'Agrega al menos una imagen del servicio';
        valido = false;
      } else {
        _errorImagenes = null;
      }
      if (_firmaClienteController.isEmpty) {
        _errorFirma = 'La firma del cliente es obligatoria';
        valido = false;
      } else {
        _errorFirma = null;
      }
    });
    return valido;
  }

  Future<void> _enviar() async {
    final formularioValido = _formKey.currentState!.validate();
    final extrasValidos = _validarCamposExtra();

    if (!formularioValido || !extrasValidos) return;

    setState(() => _cargando = true);

    try {
      final tecnicoId = await _authService.getTecnicoId();

      final bytes = await _firmaClienteController.toPngBytes();
      final path = '${Directory.systemTemp.path}/firma_cliente.png';
      final firmaCliente = File(path)..writeAsBytesSync(bytes!);

      final formulario = Formulario(
        cliente: _clienteController.text,
        contacto: _contactoController.text,
        direccion: _direccionController.text,
        obra: _obraController.text,
        telefono: _telefonoController.text,
        descripcion: _descripcionController.text,
        materiales_utilizados: _materialesController.text,
        tipo_mantenimiento: _tiposSeleccionados.join(', '),
        clases_mantenimiento: _clasesSeleccionadas.join(', '),
        fk_tecnico_id: int.parse(tecnicoId!),
        nombre_tecnico: _nombreTecnicoFormController.text,
        telefono_tecnico: _telefonoTecnicoController.text,
        nombre_recibe: _nombreRecibeController.text,
        cedula_recibe: _cedulaRecibeController.text,
      );

      final pdfBytes = await _formularioService.crearFormulario(
        formulario,
        _imagenes,
        firmaCliente,
      );

      final dir = await getTemporaryDirectory();
      final pdfFile = File('${dir.path}/informe_servicio.pdf');
      await pdfFile.writeAsBytes(pdfBytes);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(
              pdfFile: pdfFile,
              titulo: 'Informe de Servicios',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  // ── INTERFAZ ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Informe de Servicios'),
        backgroundColor: const Color(0xFFF8DD2F),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── DATOS DEL CLIENTE ──────────────────────────
              _seccion('Datos del cliente'),
              _campo('Cliente', _clienteController),
              _campo('Contacto', _contactoController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              _campo('Dirección', _direccionController),
              _campo('Obra', _obraController),
              _campo('Teléfono', _telefonoController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              const SizedBox(height: 20),

              // ── TIPO DE MANTENIMIENTO ──────────────────────
              _seccion('Tipo de mantenimiento'),
              GestureDetector(
                onTap: _mostrarTiposMantenimiento,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: _errorTipos != null ? Border.all(color: Colors.red) : null,
                  ),
                  child: Text(
                    _tiposSeleccionados.isEmpty
                        ? 'Seleccionar tipo de mantenimiento'
                        : _tiposSeleccionados.join(', '),
                    style: TextStyle(
                      color: _tiposSeleccionados.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
              if (_errorTipos != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(_errorTipos!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),

              const SizedBox(height: 15),

              // ── CLASE DE MANTENIMIENTO ─────────────────────
              _seccion('Clase de mantenimiento'),
              GestureDetector(
                onTap: _mostrarClasesMantenimiento,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: _errorClases != null ? Border.all(color: Colors.red) : null,
                  ),
                  child: Text(
                    _clasesSeleccionadas.isEmpty
                        ? 'Seleccionar clase de mantenimiento'
                        : _clasesSeleccionadas.join(', '),
                    style: TextStyle(
                      color: _clasesSeleccionadas.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
              if (_errorClases != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(_errorClases!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),

              const SizedBox(height: 20),

              // ── DESCRIPCIÓN ────────────────────────────────
              _seccion('Descripción del trabajo realizado'),
              Stack(
                children: [
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 6,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Descripción del trabajo realizado...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      filled: true,
                      fillColor: _escuchando
                          ? const Color(0xFFFFFDE7)
                          : Colors.grey[100],
                      contentPadding: const EdgeInsets.fromLTRB(14, 14, 48, 40),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: _escuchando
                            ? const BorderSide(color: Color(0xFFF8DD2F), width: 2)
                            : BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: _escuchando
                            ? const BorderSide(color: Color(0xFFF8DD2F), width: 2)
                            : const BorderSide(color: Colors.grey),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Este campo es obligatorio' : null,
                  ),

                  // Botón micrófono — esquina inferior derecha
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleEscuchar,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _escuchando
                              ? const Color(0xFFF8DD2F)
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                          boxShadow: _escuchando
                              ? [BoxShadow(
                                  color: const Color(0xFFF8DD2F).withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )]
                              : [],
                        ),
                        child: Icon(
                          _escuchando ? Icons.mic : Icons.mic_none,
                          color: _escuchando ? Colors.white : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Indicador "Escuchando..." cuando STT está activo
                  if (_escuchando)
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.red.shade400),
                          const SizedBox(width: 4),
                          Text(
                            'Escuchando...',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // ── MATERIALES ─────────────────────────────────
              _seccion('Materiales utilizados'),
              TextFormField(
                controller: _materialesController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Ej: Aceite, filtros, tornillos',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Este campo es obligatorio' : null,
              ),

              const SizedBox(height: 20),

              // ── IMÁGENES ───────────────────────────────────
              _seccion('Imágenes del servicio'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._imagenes.asMap().entries.map((entry) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          entry.value,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _eliminarImagen(entry.key),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  )),
                  GestureDetector(
                    onTap: _mostrarOpcionesImagen,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _errorImagenes != null ? Colors.red[50] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _errorImagenes != null ? Colors.red : Colors.grey,
                        ),
                      ),
                      child: const Icon(Icons.add, size: 40, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              if (_errorImagenes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(_errorImagenes!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),

              const SizedBox(height: 20),

              // ── ENTREGA ────────────────────────────────────
              _seccion('Entrega'),
              _campo('Nombre del técnico', _nombreTecnicoFormController),
              _campo('Celular del técnico', _telefonoTecnicoController, keyboardType: TextInputType.phone),

              // ── RECIBE ─────────────────────────────────────
              _seccion('Recibe'),
              _campo('Nombre de quien recibe', _nombreRecibeController),
              _campo('Cédula de quien recibe', _cedulaRecibeController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),

              const SizedBox(height: 20),

              // ── FIRMA CLIENTE ──────────────────────────────
              _seccion('Firma del cliente'),
              _widgetFirma(),

              const SizedBox(height: 30),

              // ── BOTÓN ENVIAR ───────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _enviar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8DD2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enviar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── WIDGETS AUXILIARES ───────────────────────────────────────

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _campo(String hint, TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        style: const TextStyle(fontSize: 16),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Este campo es obligatorio' : null,
      ),
    );
  }

  Widget _widgetFirma() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _errorFirma != null ? Colors.red : Colors.grey,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Signature(
              controller: _firmaClienteController,
              backgroundColor: Colors.white,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  _firmaClienteController.clear();
                  setState(() => _errorFirma = null);
                },
                icon: const Icon(Icons.clear, color: Colors.red),
                label: const Text('Limpiar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          if (_errorFirma != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _errorFirma!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _clienteController.dispose();
    _contactoController.dispose();
    _direccionController.dispose();
    _obraController.dispose();
    _telefonoController.dispose();
    _descripcionController.dispose();
    _materialesController.dispose();
    _nombreTecnicoFormController.dispose();
    _telefonoTecnicoController.dispose();
    _nombreRecibeController.dispose();
    _cedulaRecibeController.dispose();
    _firmaClienteController.dispose();
    super.dispose();
  }
}
