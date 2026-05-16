import 'dart:math';
import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _cargando = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await _authService.login(
        _usuarioController.text,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error de login: $e');
      setState(() {
        if (e.toString().contains('Connection refused') || e.toString().contains('SocketException')) {
          _error = 'No se pudo conectar con el servidor. Revisa la IP y el Firewall.';
        } else {
          _error = 'Usuario o contraseña incorrectos';
        }
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [

          // Fondo dividido en 2 colores
          Column(
            children: [
              // Sección superior gris con decoración
              SizedBox(
                height: screenHeight * 0.48,
                width: double.infinity,
                child: CustomPaint(
                  painter: _FondoGrisPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
              // Sección inferior blanca
              Expanded(
                child: Container(color: Colors.white),
              ),
            ],
          ),

          // Logo centrado en la sección gris
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.48,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Image.asset(
                  'assets/control_mezclas_mejorado.png',
                  width: 200,
                ),
              ),
            ),
          ),

          // Tarjeta flotante sobre los 2 colores
          Positioned(
            top: screenHeight * 0.38,
            left: 24,
            right: 24,
            bottom: 0,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
              child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // Título
                    const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Campo usuario
                    TextField(
                      controller: _usuarioController,
                      decoration: InputDecoration(
                        hintText: 'Usuario',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Campo contraseña
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.lock, color: Colors.grey),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    // Mensaje de error
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Botón Iniciar
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF8DD2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _cargando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Iniciar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _FondoGrisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = const Color(0xFFC8C8C8);
    final decorColor = const Color(0xFFBBBBBB); // ligeramente más oscuro para los arcos
    final dotColor = const Color(0xFFB8B8B8);   // para los puntos

    // Fondo base
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = baseColor);

    final paintArco = Paint()
      ..color = decorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Arco esquina superior izquierda
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 0), radius: size.width * 0.55),
      0,
      pi / 2,
      false,
      paintArco,
    );
    // Segundo arco esquina superior izquierda (más pequeño)
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 0), radius: size.width * 0.38),
      0,
      pi / 2,
      false,
      paintArco,
    );

    // Arco esquina inferior derecha
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width, size.height),
          radius: size.width * 0.55),
      pi,
      pi / 2,
      false,
      paintArco,
    );
    // Segundo arco esquina inferior derecha
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width, size.height),
          radius: size.width * 0.38),
      pi,
      pi / 2,
      false,
      paintArco,
    );

    // Puntos esquina superior derecha
    _dibujarPuntos(
      canvas,
      dotColor,
      offsetX: size.width,
      offsetY: 0,
      columnas: 7,
      filas: 6,
      espaciado: 18,
      crecerHaciaIzquierda: true,
      crecerHaciaAbajo: true,
    );

    // Puntos esquina inferior izquierda
    _dibujarPuntos(
      canvas,
      dotColor,
      offsetX: 0,
      offsetY: size.height,
      columnas: 7,
      filas: 6,
      espaciado: 18,
      crecerHaciaIzquierda: false,
      crecerHaciaAbajo: false,
    );
  }

  void _dibujarPuntos(
    Canvas canvas,
    Color color, {
    required double offsetX,
    required double offsetY,
    required int columnas,
    required int filas,
    required double espaciado,
    required bool crecerHaciaIzquierda,
    required bool crecerHaciaAbajo,
  }) {
    for (int col = 0; col < columnas; col++) {
      for (int fila = 0; fila < filas; fila++) {
        // El radio va disminuyendo a medida que se aleja de la esquina
        final distancia = sqrt(col * col + fila * fila);
        final maxDist = sqrt((columnas - 1.0) * (columnas - 1.0) + (filas - 1.0) * (filas - 1.0));
        final radio = 3.5 * (1.0 - distancia / maxDist);

        if (radio < 0.3) continue;

        final dx = crecerHaciaIzquierda
            ? offsetX - (col + 1) * espaciado
            : offsetX + (col + 1) * espaciado;

        final dy = crecerHaciaAbajo
            ? offsetY + (fila + 1) * espaciado
            : offsetY - (fila + 1) * espaciado;

        canvas.drawCircle(
          Offset(dx, dy),
          radio,
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
