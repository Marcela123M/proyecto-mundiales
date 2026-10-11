import 'package:flutter/material.dart';

import 'api_service.dart';
import 'config.dart';
import 'models.dart';
import 'widgets.dart';

class _Datos {
  const _Datos(this.titulos, this.mundiales);
  final List<TitulosSeleccion> titulos;
  final List<Mundial> mundiales;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _api = ApiService();
  late Future<_Datos> _futuro;
  String? _filtro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<_Datos> _cargar() async {
    final titulos = await _api.titulos();
    final mundiales = await _api.mundiales();
    return _Datos(titulos, mundiales);
  }

  Future<void> _recargar() async {
    setState(() => _futuro = _cargar());
    try {
      await _futuro;
    } catch (_) {
      // El error ya se muestra en pantalla.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF14305A), kFondo, Color(0xFF1E1B4B)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<_Datos>(
            future: _futuro,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator(color: kCyan));
              }
              if (snap.hasError) {
                return _ErrorView(mensaje: '${snap.error}', onReintentar: _recargar);
              }
              return RefreshIndicator(
                onRefresh: _recargar,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: _contenido(snap.data!),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _contenido(_Datos d) {
    final campeones = d.titulos.where((t) => t.titulos > 0).toList();
    final lista = _filtro == null
        ? d.mundiales.reversed.toList()
        : d.mundiales.where((m) => m.campeon == _filtro).toList().reversed.toList();
    final top = d.titulos.first;

    return LayoutBuilder(
      builder: (context, c) {
        final ancho = c.maxWidth > 800;
        final kpiAncho = c.maxWidth > 700 ? (c.maxWidth - 32) / 3 : c.maxWidth;

        final tarjetaBarras = GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Titulo('Títulos por selección'),
              const SizedBox(height: 16),
              TitulosBarChart(datos: d.titulos),
            ],
          ),
        );
        final tarjetaDona = GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Titulo('Reparto de títulos'),
              const SizedBox(height: 16),
              TitulosDonut(datos: d.titulos),
            ],
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (r) => const LinearGradient(
                          colors: [kCyan, Color(0xFFA78BFA)],
                        ).createShader(r),
                        child: const Text(
                          '⚽ Mundiales de Fútbol',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('1930 – 2026 · datos en vivo desde tu API',
                          style: TextStyle(color: kMute)),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _recargar,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: kpiAncho,
                  child: KpiCard(
                      icono: Icons.emoji_events,
                      etiqueta: 'Mundiales jugados',
                      color: kCyan,
                      numero: d.mundiales.length),
                ),
                SizedBox(
                  width: kpiAncho,
                  child: KpiCard(
                      icono: Icons.public,
                      etiqueta: 'Campeones distintos',
                      color: const Color(0xFFA78BFA),
                      numero: campeones.length),
                ),
                SizedBox(
                  width: kpiAncho,
                  child: KpiCard(
                      icono: Icons.star,
                      etiqueta: 'Más títulos',
                      color: const Color(0xFFFACC15),
                      texto: '${top.nombre} (${top.titulos})'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (ancho)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: tarjetaBarras),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: tarjetaDona),
                ],
              )
            else ...[
              tarjetaBarras,
              const SizedBox(height: 16),
              tarjetaDona,
            ],
            const SizedBox(height: 28),
            _Titulo('Todas las finales (${lista.length})'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _filtro == null,
                  onSelected: (_) => setState(() => _filtro = null),
                ),
                for (final t in campeones)
                  ChoiceChip(
                    label: Text('${t.nombre} (${t.titulos})'),
                    selected: _filtro == t.nombre,
                    selectedColor: colorSeleccion(t.nombre).withAlpha(90),
                    onSelected: (_) => setState(() => _filtro = t.nombre),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey(_filtro),
                children: [for (final m in lista) MundialTile(mundial: m)],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Color(0xFFFB7185)),
                const SizedBox(height: 12),
                const Text('No se pudo conectar con la API',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Intentando en: $baseUrl',
                    textAlign: TextAlign.center, style: const TextStyle(color: kMute)),
                const SizedBox(height: 4),
                Text(mensaje,
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kMute, fontSize: 12)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onReintentar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
