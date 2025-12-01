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
  String userRole = "Paciente";

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
      ),
      body: userRole == 'Médico' ? _buildDoctorDashboard() : _buildPatientHome(),
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
  Widget _buildDoctorDashboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('citas').snapshots(),
      builder: (context, citasSnapshot) {
        if (!citasSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final citas = citasSnapshot.data!.docs;
        final totalCitas = citas.length;

        final ahora = DateTime.now();
        final citasProximas = citas.where((cita) {
          final data = cita.data() as Map<String, dynamic>;
          final fechaCita = (data['fechaHora'] as Timestamp?)?.toDate();
          return fechaCita != null && fechaCita.isAfter(ahora);
        }).length;

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('usuarios')
              .where('rol', isEqualTo: 'Paciente')
              .snapshots(),
          builder: (context, usuariosSnapshot) {
            final totalPacientes = usuariosSnapshot.hasData
                ? usuariosSnapshot.data!.docs.length
                : 0;

            return RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[700]!, Colors.blue[500]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.medical_services,
                            size: 50,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "¡Hola, $userName!",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Panel de Control Médico",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Estadísticas Generales",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.25,
                            children: [
                              _buildStatCard(
                                title: "Total de Citas",
                                value: totalCitas.toString(),
                                icon: Icons.calendar_month,
                                color: Colors.blue,
                                gradient: [
                                  Colors.blue[400]!,
                                  Colors.blue[600]!
                                ],
                              ),
                              _buildStatCard(
                                title: "Citas Próximas",
                                value: citasProximas.toString(),
                                icon: Icons.pending_actions,
                                color: Colors.orange,
                                gradient: [
                                  Colors.orange[400]!,
                                  Colors.orange[600]!
                                ],
                              ),
                              _buildStatCard(
                                title: "Total Pacientes",
                                value: totalPacientes.toString(),
                                icon: Icons.people,
                                color: Colors.green,
                                gradient: [
                                  Colors.green[400]!,
                                  Colors.green[600]!
                                ],
                              ),
                              _buildStatCard(
                                title: "Completadas",
                                value:
                                    (totalCitas - citasProximas).toString(),
                                icon: Icons.check_circle,
                                color: Colors.purple,
                                gradient: [
                                  Colors.purple[400]!,
                                  Colors.purple[600]!
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Próximas Citas",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, Routes.graphics);
                                },
                                icon: const Icon(Icons.bar_chart,
                                    size: 16),
                                label: const Text(
                                  "Ver gráficas",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          _buildProximasCitas(citas, ahora),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildPatientHome() {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26, color: Colors.white),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProximasCitas(List<QueryDocumentSnapshot> citas, DateTime ahora) {
    final citasOrdenadas = citas.where((cita) {
      final data = cita.data() as Map<String, dynamic>;
      final fechaCita = (data['fechaHora'] as Timestamp?)?.toDate();
      return fechaCita != null && fechaCita.isAfter(ahora);
    }).toList();

    citasOrdenadas.sort((a, b) {
      final fechaA =
          ((a.data() as Map<String, dynamic>)['fechaHora'] as Timestamp)
              .toDate();
      final fechaB =
          ((b.data() as Map<String, dynamic>)['fechaHora'] as Timestamp)
              .toDate();
      return fechaA.compareTo(fechaB);
    });

    final proximasTres = citasOrdenadas.take(3).toList();

    if (proximasTres.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No hay citas próximas programadas",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: proximasTres.length,
      itemBuilder: (context, index) {
        final cita = proximasTres[index];
        final data = cita.data() as Map<String, dynamic>;
        final fechaCita = (data['fechaHora'] as Timestamp).toDate();
        final nombrePaciente = data['nombreUsuario'] ?? 'Paciente sin nombre';
        final motivo = data['motivo'] ?? 'Sin motivo';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, color: Colors.blue[700]),
            ),
            title: Text(
              nombrePaciente,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(motivo),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      "${fechaCita.day}/${fechaCita.month}/${fechaCita.year}  "
                      "${fechaCita.hour}:${fechaCita.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
}