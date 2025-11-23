import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphicsPage extends StatelessWidget {
  const GraphicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estadísticas y Gráficas"),
        backgroundColor: Colors.blue[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('citas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final citas = snapshot.data!.docs;
          final citasPorMes = _processCitasPorMes(citas);
          final citasStatus = _processCitasStatus(citas);

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Análisis de Citas Médicas",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Visualización de datos en tiempo real",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildChartCard(
                    title: "Citas por Mes",
                    subtitle: "Distribución mensual de citas creadas",
                    icon: Icons.bar_chart,
                    iconColor: Colors.blue,
                    child: SizedBox(
                      height: 300,
                      child: _buildBarChart(citasPorMes),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildChartCard(
                    title: "Estado de Citas",
                    subtitle: "Completadas vs Pendientes",
                    icon: Icons.pie_chart,
                    iconColor: Colors.green,
                    child: SizedBox(
                      height: 300,
                      child: _buildPieChart(citasStatus),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSummaryCard(citas.length, citasStatus),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<int, int> citasPorMes) {
    if (citasPorMes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No hay datos disponibles",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final barGroups = citasPorMes.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blue[600],
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (citasPorMes.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
        barGroups: barGroups,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                               'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    months[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> citasStatus) {
    final completadas = citasStatus['completadas'] ?? 0;
    final pendientes = citasStatus['pendientes'] ?? 0;
    final total = completadas + pendientes;

    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No hay datos disponibles",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: [
                PieChartSectionData(
                  value: completadas.toDouble(),
                  title: '${((completadas / total) * 100).toStringAsFixed(0)}%',
                  color: Colors.green[600],
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: pendientes.toDouble(),
                  title: '${((pendientes / total) * 100).toStringAsFixed(0)}%',
                  color: Colors.orange[600],
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.green[600]!, "Completadas", completadas),
            const SizedBox(width: 24),
            _buildLegendItem(Colors.orange[600]!, "Pendientes", pendientes),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "$label: $value",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(int totalCitas, Map<String, int> citasStatus) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumen General",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  Icons.event_note,
                  "Total",
                  totalCitas.toString(),
                  Colors.blue,
                ),
                _buildSummaryItem(
                  Icons.check_circle,
                  "Completadas",
                  (citasStatus['completadas'] ?? 0).toString(),
                  Colors.green,
                ),
                _buildSummaryItem(
                  Icons.pending,
                  "Pendientes",
                  (citasStatus['pendientes'] ?? 0).toString(),
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Map<int, int> _processCitasPorMes(List<QueryDocumentSnapshot> citas) {
    final Map<int, int> citasPorMes = {};
    
    for (var cita in citas) {
      final data = cita.data() as Map<String, dynamic>;
      final fechaHora = data['fechaHora'] as Timestamp?;
      
      if (fechaHora != null) {
        final fecha = fechaHora.toDate();
        final mes = fecha.month;
        citasPorMes[mes] = (citasPorMes[mes] ?? 0) + 1;
      }
    }
    
    return citasPorMes;
  }

  Map<String, int> _processCitasStatus(List<QueryDocumentSnapshot> citas) {
    final ahora = DateTime.now();
    int completadas = 0;
    int pendientes = 0;
    
    for (var cita in citas) {
      final data = cita.data() as Map<String, dynamic>;
      final fechaHora = data['fechaHora'] as Timestamp?;
      
      if (fechaHora != null) {
        final fecha = fechaHora.toDate();
        if (fecha.isBefore(ahora)) {
          completadas++;
        } else {
          pendientes++;
        }
      }
    }
    
    return {
      'completadas': completadas,
      'pendientes': pendientes,
    };
  }
}
