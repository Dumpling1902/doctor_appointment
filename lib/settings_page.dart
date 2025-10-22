import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // El perfil del usuario
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text(
                "Perfil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text("Ver y editar tu información personal"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, Routes.profile);
              },
            ),
          ),
          const SizedBox(height: 12),

          // La información sobre la privacidad
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.orange),
              title: const Text(
                "Privacidad",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text("Configuración de privacidad"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, Routes.privacy);
              },
            ),
          ),
          const SizedBox(height: 12),

          // La información sobre nosotros
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.green),
              title: const Text(
                "Sobre Nosotros",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text("Información sobre la aplicación"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, Routes.about);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Esto es para Cerrar Sesión
          Card(
            elevation: 2,
            color: Colors.red[50],
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Cerrar Sesión",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              subtitle: const Text("Salir de tu cuenta"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Cerrar Sesión"),
                    content: const Text("¿Estás seguro de que deseas cerrar sesión?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Cerrar Sesión",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _auth.signOut();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, Routes.login);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}