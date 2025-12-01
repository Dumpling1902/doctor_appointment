import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacidad"),
        backgroundColor: Colors.orange[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Política de Privacidad",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "En DoctorAppointmentApp, nos tomamos muy en serio la privacidad de nuestros usuarios. "
              "Esta política describe cómo recopilamos, usamos y protegemos tu información personal.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              "Información que Recopilamos",
              "Recopilamos información personal como tu nombre, correo electrónico, número de teléfono "
              "e historial médico cuando te registras y utilizas nuestra aplicación.",
            ),
            
            _buildSection(
              "Cómo Usamos tu Información",
              "Utilizamos tu información para proporcionarte nuestros servicios, mejorar la experiencia "
              "del usuario, y comunicarnos contigo sobre tus citas y consultas médicas.",
            ),
            
            _buildSection(
              "Seguridad de los Datos",
              "Implementamos medidas de seguridad apropiadas para proteger tu información personal "
              "contra acceso no autorizado, alteración o destrucción. Utilizamos Firebase y cifrado "
              "para mantener tus datos seguros.",
            ),
            
            _buildSection(
              "Compartir Información",
              "No compartimos tu información personal con terceros, excepto cuando sea necesario "
              "para proporcionar nuestros servicios o cuando la ley lo requiera.",
            ),
            
            _buildSection(
              "Tus Derechos",
              "Tienes derecho a acceder, corregir o eliminar tu información personal en cualquier momento. "
              "Puedes hacerlo desde la sección de perfil o contactándonos directamente.",
            ),
            
            const SizedBox(height: 24),
            const Text(
              "Última actualización: Octubre 2025",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
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