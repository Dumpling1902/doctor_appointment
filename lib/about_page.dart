import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre Nosotros"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.local_hospital,
                size: 100,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 24),
            
            const Center(
              child: Text(
                "DoctorAppointmentApp",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            const Center(
              child: Text(
                "Tu salud, nuestra prioridad",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              "Nuestra Misión",
              "En DoctorAppointmentApp, nuestra misión es facilitar el acceso a servicios de salud "
              "de calidad, conectando a pacientes con los mejores profesionales médicos de manera "
              "rápida, segura y eficiente.",
            ),
            
            _buildSection(
              "¿Quiénes Somos?",
              "Somos un equipo de profesionales dedicados a mejorar la experiencia de atención médica. "
              "Nuestra plataforma permite agendar citas, consultar especialistas y recibir consejos "
              "médicos de forma fácil y accesible.",
            ),
            
            _buildSection(
              "Nuestros Servicios",
              "• Agendamiento de citas médicas\n"
              "• Acceso a múltiples especialidades médicas\n"
              "• Consejos médicos para dolores leves\n"
              "• Historial médico digital seguro\n"
              "• Recordatorios de citas",
            ),
            
            _buildSection(
              "Valores",
              "• Compromiso con la salud del paciente\n"
              "• Confidencialidad y seguridad\n"
              "• Innovación en servicios de salud\n"
              "• Accesibilidad para todos",
            ),
            
            const SizedBox(height: 24),
            
            const Center(
              child: Text(
                "Versión 1.0.0",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            const Center(
              child: Text(
                "© 2025 DoctorAppointmentApp",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Volver"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}