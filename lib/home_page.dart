import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _selectedIndex = 0; 
  String userName = "Usuario"; 

  @override
  void initState() {
    super.initState();
    _loadUserName(); 
  }
  Future<void> _loadUserName() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      if (data['nombre'] != null && data['nombre'].toString().isNotEmpty) {
        setState(() {
          userName = data['nombre'];
        });
      } else {
        setState(() {
          userName = user.email?.split('@')[0] ?? 'Usuario';
        });
      }
    } else {
      setState(() {
        userName = user.email?.split('@')[0] ?? 'Usuario';
      });
    }
  }
  void _onItemTapped(int index) {
    if (index == 0) {
      return;
    } else if (index == 1) {
      // Esto para poder ir a los mensajes
      Navigator.pushNamed(context, Routes.messages);
    } else if (index == 2) {
      // Esto para poder ir a la configuración
      Navigator.pushNamed(context, Routes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("DoctorAppointmentApp"),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // La parte del saludo al usuario
              Text(
                "¡Hola, $userName!",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "¿En qué podemos ayudarte?",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Poder agendar una cita
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.scheduleAppointment);
                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 48,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Agendar una Cita",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Los consejos médicos
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.medicalTips);
                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services,
                              color: Colors.white,
                              size: 48,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Consejos Médicos",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // La sección de especialistas
              const Text(
                "Especialistas",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // La lista de especialistas
              _buildSpecialistCard(
                "Cardiología",
                "Especialista en el corazón",
                Icons.favorite,
                Colors.red,
              ),
              _buildSpecialistCard(
                "Pediatría",
                "Cuidado de niños y adolescentes",
                Icons.child_care,
                Colors.orange,
              ),
              _buildSpecialistCard(
                "Dermatología",
                "Cuidado de la piel",
                Icons.face,
                Colors.pink,
              ),
              _buildSpecialistCard(
                "Neurología",
                "Especialista del sistema nervioso",
                Icons.psychology,
                Colors.purple,
              ),
              _buildSpecialistCard(
                "Traumatología",
                "Huesos y articulaciones",
                Icons.healing,
                Colors.blue,
              ),

              const SizedBox(height: 32),

              const Text(
                "Médicos Populares",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDoctorCard(
                "Dr. Juan Pérez",
                "Cardiólogo",
                "4.9",
                Icons.person,
              ),
              _buildDoctorCard(
                "Dra. María García",
                "Pediatra",
                "4.8",
                Icons.person,
              ),
            ],
          ),
        ),
      ),

      // La barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }

  //Este es el widget para crear las tarjetas de los especialistas
  Widget _buildSpecialistCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Seleccionaste $title")),
          );
        },
      ),
    );
  }

  // Este es el widget para poder crear las tarjetas de los doctores populares
  Widget _buildDoctorCard(String name, String specialty, String rating, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue[700]),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(specialty),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}