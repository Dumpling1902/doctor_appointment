import 'package:flutter/material.dart';

class MedicalTipsPage extends StatelessWidget {
  const MedicalTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consejos Médicos"),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Consejos para Dolores Leves",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Aquí encontrarás consejos para aliviar dolores leves. "
            "Si los síntomas persisten, consulta a un médico.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Consejos para el dolor de cabeza
          _buildTipCard(
            "Dolor de Cabeza",
            Icons.face,
            Colors.orange,
            [
              "Descansa en un lugar tranquilo y oscuro",
              "Aplica compresas frías en la frente",
              "Mantente hidratado, bebe agua regularmente",
              "Evita ruidos fuertes y luces brillantes",
              "Si el dolor persiste más de 48 horas, consulta a un médico",
            ],
          ),

          // Consejos para el dolor de garganta
          _buildTipCard(
            "Dolor de Garganta",
            Icons.mic_off,
            Colors.red,
            [
              "Haz gárgaras con agua tibia y sal",
              "Bebe líquidos calientes como té con miel",
              "Evita alimentos irritantes o muy condimentados",
              "Mantén el ambiente húmedo",
              "Descansa tu voz lo más posible",
            ],
          ),

          // Consejos para el dolor muscular
          _buildTipCard(
            "Dolor Muscular",
            Icons.fitness_center,
            Colors.blue,
            [
              "Aplica compresas frías las primeras 48 horas",
              "Después puedes usar calor para relajar los músculos",
              "Realiza estiramientos suaves",
              "Descansa el área afectada",
              "Masajea suavemente la zona dolorida",
            ],
          ),

          // Consejos para el dolor de estómago
          _buildTipCard(
            "Dolor de Estómago",
            Icons.restaurant,
            Colors.purple,
            [
              "Come alimentos suaves y de fácil digestión",
              "Evita comidas grasosas o picantes",
              "Bebe infusiones de manzanilla o menta",
              "Come porciones pequeñas",
              "Evita acostarte inmediatamente después de comer",
            ],
          ),

          // Consejos para el resfriado
          _buildTipCard(
            "Resfriado Común",
            Icons.ac_unit,
            Colors.cyan,
            [
              "Descansa lo suficiente",
              "Bebe muchos líquidos",
              "Consume alimentos ricos en vitamina C",
              "Usa pañuelos desechables",
              "Lava tus manos frecuentemente",
            ],
          ),

          const SizedBox(height: 24),

          // Una advertencia para que los usuarios tomen precauciones
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[700], size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Importante: Estos consejos son para dolores leves. "
                      "Si el dolor es severo o persiste, consulta a un médico.",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

        ],
      ),
    );
  }

  Widget _buildTipCard(
    String title,
    IconData icon,
    Color color,
    List<String> tips,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tips.map((tip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}