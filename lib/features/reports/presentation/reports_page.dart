import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class ReportDashboard extends StatefulWidget {
  @override
  _ReportDashboardState createState() => _ReportDashboardState();
}

class _ReportDashboardState extends State<ReportDashboard> {
  final List<Map<String, dynamic>> activos = [
    {"tipo": "Computadora", "estado": "funcionando", "costo": 1200.0},
    {"tipo": "Monitor", "estado": "mantenimiento", "costo": 300.0},
    {"tipo": "Impresora", "estado": "fuera_de_servicio", "costo": 400.0},
    {"tipo": "Computadora", "estado": "funcionando", "costo": 1500.0},
    {"tipo": "Monitor", "estado": "funcionando", "costo": 250.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text(
          'Dashboard de Reportes',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
            onPressed: _generatePDF,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  title: ChartTitle(
                    text: 'Costos por Tipo',
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: _getBarSeries(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SfCircularChart(
                  title: ChartTitle(
                    text: 'Estado de Activos',
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  legend:
                      Legend(isVisible: true, position: LegendPosition.bottom),
                  series: _getPieSeries(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarSeries<Map<String, dynamic>, String>> _getBarSeries() {
    Map<String, double> tipoCosto = {};
    for (var activo in activos) {
      tipoCosto[activo['tipo']] =
          (tipoCosto[activo['tipo']] ?? 0) + activo['costo'];
    }

    return [
      BarSeries<Map<String, dynamic>, String>(
        dataSource: tipoCosto.entries
            .map((entry) => {"tipo": entry.key, "costo": entry.value})
            .toList(),
        xValueMapper: (data, _) => data['tipo'],
        yValueMapper: (data, _) => data['costo'],
        dataLabelSettings: const DataLabelSettings(isVisible: true),
      ),
    ];
  }

  List<PieSeries<Map<String, dynamic>, String>> _getPieSeries() {
    Map<String, int> estadoCount = {};
    for (var activo in activos) {
      estadoCount[activo['estado']] = (estadoCount[activo['estado']] ?? 0) + 1;
    }

    return [
      PieSeries<Map<String, dynamic>, String>(
        dataSource: estadoCount.entries
            .map((entry) => {"estado": entry.key, "cantidad": entry.value})
            .toList(),
        xValueMapper: (data, _) => data['estado'],
        yValueMapper: (data, _) => data['cantidad'],
        dataLabelSettings: const DataLabelSettings(isVisible: true),
      ),
    ];
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Reporte de Activos",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                data: [
                  ['Tipo', 'Estado', 'Costo'],
                  ...activos.map((activo) => [
                        activo['tipo'],
                        activo['estado'],
                        activo['costo'].toString()
                      ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/reporte.pdf");
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF generado: ${file.path}'),
        action: SnackBarAction(
          label: 'Abrir',
          onPressed: () => OpenFile.open(file.path),
        ),
      ),
    );
  }
}
