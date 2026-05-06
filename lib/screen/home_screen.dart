import 'dart:math';
import 'package:flutter/material.dart';
import 'formulario_screen.dart';
import 'acta_silo_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [

          // Fondo dividido en 2 colores
          Column(
            children: [
              SizedBox(
                height: screenHeight * 0.48,
                width: double.infinity,
                child: CustomPaint(
                  painter: _FondoGrisPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
              Expanded(child: Container(color: Colors.white)),
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

          // Tarjeta flotante
          Positioned(
            top: screenHeight * 0.38,
            left: 24,
            right: 24,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // Título
                    const Text(
                      '¿Qué formato vas a llenar?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Selecciona el formulario que necesitas',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // Botón Informe de servicios
                    _OpcionBoton(
                      icono: Icons.assignment_outlined,
                      titulo: 'Informe de servicios',
                      subtitulo: 'Registra el servicio realizado',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FormularioScreen()),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botón Acta mantenimiento silo
                    _OpcionBoton(
                      icono: Icons.build_outlined,
                      titulo: 'Acta mantenimiento silo',
                      subtitulo: 'Registra el mantenimiento del silo',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ActaSiloScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcionBoton extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _OpcionBoton({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFF8DD2F), width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [

            // Ícono con fondo gris circular
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF8DD2F),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: Colors.white, size: 26),
            ),

            const SizedBox(width: 16),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitulo,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Flecha
            const Icon(Icons.chevron_right, color: Color(0xFFF8DD2F), size: 24),
          ],
        ),
      ),
    );
  }
}

class _FondoGrisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = const Color(0xFFC8C8C8);
    final decorColor = const Color(0xFFBBBBBB);
    final dotColor = const Color(0xFFB8B8B8);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = baseColor,
    );

    final paintArco = Paint()
      ..color = decorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Arcos esquina superior izquierda
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 0), radius: size.width * 0.55),
      0, pi / 2, false, paintArco,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 0), radius: size.width * 0.38),
      0, pi / 2, false, paintArco,
    );

    // Arcos esquina inferior derecha
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width, size.height), radius: size.width * 0.55),
      pi, pi / 2, false, paintArco,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width, size.height), radius: size.width * 0.38),
      pi, pi / 2, false, paintArco,
    );

    // Puntos esquina superior derecha
    _dibujarPuntos(canvas, dotColor,
      offsetX: size.width, offsetY: 0,
      columnas: 7, filas: 6, espaciado: 18,
      crecerHaciaIzquierda: true, crecerHaciaAbajo: true,
    );

    // Puntos esquina inferior izquierda
    _dibujarPuntos(canvas, dotColor,
      offsetX: 0, offsetY: size.height,
      columnas: 7, filas: 6, espaciado: 18,
      crecerHaciaIzquierda: false, crecerHaciaAbajo: false,
    );
  }

  void _dibujarPuntos(Canvas canvas, Color color, {
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

        canvas.drawCircle(Offset(dx, dy), radio, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
