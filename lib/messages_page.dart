import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userRole = "Paciente";

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        userRole = data['rol'] ?? 'Paciente';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mensajesIlustrativos = userRole == 'Médico'
        ? [
            {
              'nombre': 'Juan Pérez',
              'mensaje': '¿Podría cambiar mi cita del viernes?',
              'hora': '10:30 AM',
              'avatar': Icons.person,
              'color': Colors.blue,
            },
            {
              'nombre': 'María González',
              'mensaje': 'Gracias por la consulta de ayer',
              'hora': 'Ayer',
              'avatar': Icons.person,
              'color': Colors.green,
            },
            {
              'nombre': 'Carlos Rodríguez',
              'mensaje': 'Necesito los resultados de laboratorio',
              'hora': 'Hace 2 días',
              'avatar': Icons.person,
              'color': Colors.orange,
            },
          ]
        : [
            {
              'nombre': 'Dr. García',
              'mensaje': 'Su cita está confirmada para mañana',
              'hora': '2:15 PM',
              'avatar': Icons.medical_services,
              'color': Colors.blue,
            },
            {
              'nombre': 'Dra. Martínez',
              'mensaje': 'Los resultados están listos',
              'hora': 'Ayer',
              'avatar': Icons.medical_services,
              'color': Colors.green,
            },
            {
              'nombre': 'Dr. López',
              'mensaje': 'Recuerde tomar su medicamento',
              'hora': 'Hace 3 días',
              'avatar': Icons.medical_services,
              'color': Colors.purple,
            },
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensajes"),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            color: Colors.amber[100],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[900]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Contenido ilustrativo - Sin funcionalidad",
                    style: TextStyle(
                      color: Colors.amber[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mensajesIlustrativos.length,
              itemBuilder: (context, index) {
                final mensaje = mensajesIlustrativos[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (mensaje['color'] as Color).withOpacity(0.2),
                    child: Icon(
                      mensaje['avatar'] as IconData,
                      color: mensaje['color'] as Color,
                    ),
                  ),
                  title: Text(
                    mensaje['nombre'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    mensaje['mensaje'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    mensaje['hora'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Funcionalidad no disponible - Solo ilustrativo"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}