import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'models.dart';

const kGlass = Color(0x0DFFFFFF);
const kBorde = Color(0x1AFFFFFF);
const kMute = Color(0xFF94A3B8);
const kCyan = Color(0xFF22D3EE);
const kFondo = Color(0xFF0B1220);

const _colores = <String, Color>{
  'Brasil': Color(0xFFFACC15),
  'Alemania': Color(0xFFF87171),
  'Italia': Color(0xFF3B82F6),
  'Argentina': Color(0xFF67E8F9),
  'España': Color(0xFFFB923C),
  'Francia': Color(0xFFA78BFA),
  'Uruguay': Color(0xFF34D399),
  'Inglaterra': Color(0xFFF472B6),
};

const _codigos = <String, String>{
  'Brasil': 'BRA',
  'Alemania': 'ALE',
  'Italia': 'ITA',
  'Argentina': 'ARG',
  'España': 'ESP',
  'Francia': 'FRA',
  'Uruguay': 'URU',
  'Inglaterra': 'ING',
};

String _normalizarNombre(String nombre) => nombre.trim().replaceAll(RegExp(r'\s+'), ' ');

String _buscarNombreCanonico(String nombre) {
  final valor = _normalizarNombre(nombre);
  final clave = valor.toLowerCase();

  for (final entrada in _colores.keys) {
    if (entrada.toLowerCase() == clave) return entrada;
  }
  return valor;
}

Color colorSeleccion(String nombre) => _colores[_buscarNombreCanonico(nombre)] ?? kMute;

String codigoSeleccion(String nombre) {
  final canonico = _buscarNombreCanonico(nombre);
  return _codigos[canonico] ??
      (canonico.length >= 3 ? canonico.substring(0, 3).toUpperCase() : canonico.toUpperCase());
}

/// Tarjeta con efecto "cristal".
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: kGlass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorde),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: child,
    );
  }
}

class SeleccionBadge extends StatelessWidget {
  const SeleccionBadge(this.nombre, {super.key, this.size = 44});

  final String nombre;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = colorSeleccion(nombre);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(46),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        codigoSeleccion(nombre),
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: size * 0.28),
      ),
    );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.icono,
    required this.etiqueta,
    required this.color,
    this.numero,
    this.texto,
  });

  final IconData icono;
  final String etiqueta;
  final Color color;
  final int? numero;
  final String? texto;

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withAlpha(40), shape: BoxShape.circle),
            child: Icon(icono, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (numero != null)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: numero!.toDouble()),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Text('${v.round()}', style: estilo),
                  )
                else
                  Text(texto ?? '-', style: estilo, overflow: TextOverflow.ellipsis),
                Text(etiqueta, style: const TextStyle(color: kMute)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TitulosBarChart extends StatelessWidget {
  const TitulosBarChart({super.key, required this.datos});

  final List<TitulosSeleccion> datos;

  @override
  Widget build(BuildContext context) {
    final maxTitulos = datos.fold<int>(0, (a, d) => d.titulos > a ? d.titulos : a);
    final maxY = (maxTitulos + 1).toDouble();
    const pequeno = TextStyle(color: kMute, fontSize: 11, fontWeight: FontWeight.w600);

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(color: kBorde, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (v, _) => Text('${v.toInt()}', style: pequeno),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= datos.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(codigoSeleccion(datos[i].nombre), style: pequeno),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${datos[group.x].nombre}\n${rod.toY.toInt()} títulos',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < datos.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: datos[i].titulos.toDouble(),
                    width: 22,
                    color: colorSeleccion(datos[i].nombre),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: kGlass,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class TitulosDonut extends StatelessWidget {
  const TitulosDonut({super.key, required this.datos});

  final List<TitulosSeleccion> datos;

  @override
  Widget build(BuildContext context) {
    final total = datos.fold<int>(0, (a, d) => a + d.titulos);
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 62,
                  sections: [
                    for (final d in datos)
                      if (d.titulos > 0)
                        PieChartSectionData(
                          value: d.titulos.toDouble(),
                          color: colorSeleccion(d.nombre),
                          radius: 34,
                          title: '${d.titulos}',
                          titleStyle: const TextStyle(fontWeight: FontWeight.w800, color: kFondo),
                        ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$total',
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
                  const Text('títulos', style: TextStyle(color: kMute)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final d in datos)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: colorSeleccion(d.nombre), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(d.nombre, style: const TextStyle(fontSize: 12, color: kMute)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class MundialTile extends StatelessWidget {
  const MundialTile({super.key, required this.mundial});

  final Mundial mundial;

  @override
  Widget build(BuildContext context) {
    final color = colorSeleccion(mundial.campeon);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: Text('${mundial.anio}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            ),
            SeleccionBadge(mundial.campeon, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mundial.campeon,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('vs ${mundial.subcampeon} · ${mundial.sede}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kMute, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(mundial.marcador,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
