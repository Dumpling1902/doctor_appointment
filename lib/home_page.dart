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
  String userRole = "Paciente"; // Rol por defecto

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        if (data['nombre'] != null && data['nombre'].toString().isNotEmpty) {
          userName = data['nombre'];
        } else {
          userName = user.email?.split('@')[0] ?? 'Usuario';
        }
        // Cargar el rol del usuario
        userRole = data['rol'] ?? 'Paciente';
      });
    } else {
      setState(() {
        userName = user.email?.split('@')[0] ?? 'Usuario';
        userRole = 'Paciente';
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      return;
    } else if (index == 1) {
      Navigator.pushNamed(context, Routes.messages);
    } else if (index == 2) {
      Navigator.pushNamed(context, Routes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("DoctorAppointmentApp"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          // Indicador de rol en el AppBar
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: userRole == 'Médico' ? Colors.white : Colors.blue[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  userRole == 'Médico' ? Icons.medical_services : Icons.person,
                  size: 16,
                  color: userRole == 'Médico' ? Colors.blue[700] : Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  userRole,
                  style: TextStyle(
                    color: userRole == 'Médico' ? Colors.blue[700] : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userRole == 'Médico' 
                    ? "¡Hola Dr. $userName!" 
                    : "¡Hola, $userName!",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userRole == 'Médico'
                    ? "Bienvenido a tu panel de control"
                    : "¿En qué podemos ayudarte?",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Navegación condicional según el rol
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (userRole == 'Médico') {
                            // Si es médico, ir al Dashboard
                            Navigator.pushNamed(context, Routes.dashboard);
                          } else {
                            // Si es paciente, ir a agendar cita
                            Navigator.pushNamed(context, Routes.scheduleAppointment);
                          }
                        },
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: userRole == 'Médico' 
                              ? Colors.green[700] 
                              : Colors.blue[700],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                userRole == 'Médico' 
                                  ? Icons.dashboard 
                                  : Icons.calendar_today,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                userRole == 'Médico' 
                                  ? "Ver Dashboard" 
                                  : "Agendar una Cita",
                                style: const TextStyle(
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
                              Icon(Icons.medical_services,
                                  color: Colors.white, size: 48),
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
                
                // Sección de especialistas (solo para pacientes)
                if (userRole == 'Paciente') ...[
                  const Text(
                    "Especialistas",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSpecialistCard("Cardiología", "Especialista en el corazón",
                      Icons.favorite, Colors.red),
                  _buildSpecialistCard("Pediatría", "Cuidado de niños y adolescentes",
                      Icons.child_care, Colors.orange),
                  _buildSpecialistCard(
                      "Dermatología", "Cuidado de la piel", Icons.face, Colors.pink),
                  _buildSpecialistCard("Neurología", "Sistema nervioso",
                      Icons.psychology, Colors.purple),
                  _buildSpecialistCard("Traumatología", "Huesos y articulaciones",
                      Icons.healing, Colors.blue),
                ],
                
                // Sección de estadísticas rápidas para médicos
                if (userRole == 'Médico') ...[
                  const Text(
                    "Resumen Rápido",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('citas').snapshots(),
                    builder: (context, snapshot) {
                      final totalCitas = snapshot.hasData ? snapshot.data!.docs.length : 0;
                      final ahora = DateTime.now();
                      final citasProximas = snapshot.hasData 
                        ? snapshot.data!.docs.where((cita) {
                            final data = cita.data() as Map<String, dynamic>;
                            final fechaCita = (data['fechaHora'] as Timestamp?)?.toDate();
                            return fechaCita != null && fechaCita.isAfter(ahora);
                          }).length
                        : 0;
                      
                      return Column(
                        children: [
                          _buildQuickStatCard(
                            "Total de Citas",
                            totalCitas.toString(),
                            Icons.calendar_month,
                            Colors.blue,
                          ),
                          _buildQuickStatCard(
                            "Citas Próximas",
                            citasProximas.toString(),
                            Icons.pending_actions,
                            Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, Routes.dashboard);
                              },
                              icon: const Icon(Icons.dashboard),
                              label: const Text("Ver Dashboard Completo"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildSpecialistCard(
      String title, String subtitle, IconData icon, Color color) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Seleccionaste $title")),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}