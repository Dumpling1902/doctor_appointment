import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userRole = "Paciente";
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              'gradientColors': [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
              'unread': true,
            },
            {
              'nombre': 'María González',
              'mensaje': 'Gracias por la consulta de ayer',
              'hora': 'Ayer',
              'avatar': Icons.person,
              'gradientColors': [const Color(0xFF66BB6A), const Color(0xFF4CAF50)],
              'unread': false,
            },
            {
              'nombre': 'Carlos Rodríguez',
              'mensaje': 'Necesito los resultados de laboratorio',
              'hora': 'Hace 2 días',
              'avatar': Icons.person,
              'gradientColors': [const Color(0xFFFF9800), const Color(0xFFF57C00)],
              'unread': true,
            },
          ]
        : [
            {
              'nombre': 'Dr. García',
              'mensaje': 'Su cita está confirmada para mañana',
              'hora': '2:15 PM',
              'avatar': Icons.medical_services,
              'gradientColors': [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
              'unread': true,
            },
            {
              'nombre': 'Dra. Martínez',
              'mensaje': 'Los resultados están listos',
              'hora': 'Ayer',
              'avatar': Icons.medical_services,
              'gradientColors': [const Color(0xFF66BB6A), const Color(0xFF4CAF50)],
              'unread': false,
            },
            {
              'nombre': 'Dr. López',
              'mensaje': 'Recuerde tomar su medicamento',
              'hora': 'Hace 3 días',
              'avatar': Icons.medical_services,
              'gradientColors': [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
              'unread': false,
            },
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Mensajes",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _animationController,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: mensajesIlustrativos.length,
                itemBuilder: (context, index) {
                  final mensaje = mensajesIlustrativos[index];
                  return _buildMessageCard(mensaje, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> mensaje, int index) {
    final gradientColors = mensaje['gradientColors'] as List<Color>;
    final isUnread = mensaje['unread'] as bool? ?? false;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Funcionalidad no disponible - Solo ilustrativo"),
                  backgroundColor: Colors.blue[700],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      mensaje['avatar'] as IconData,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                mensaje['nombre'] as String,
                                style: TextStyle(
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 16,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  mensaje['hora'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (isUnread) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: gradientColors[0],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mensaje['mensaje'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}