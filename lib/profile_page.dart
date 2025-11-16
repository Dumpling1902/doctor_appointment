import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController lugarNacimientoController = TextEditingController();
  final TextEditingController padecimientosController = TextEditingController();

  String rolSeleccionado = 'Paciente'; // Valor por defecto
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar datos del usuario
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      nombreController.text = data['nombre'] ?? '';
      edadController.text = data['edad'] ?? '';
      lugarNacimientoController.text = data['lugarNacimiento'] ?? '';
      padecimientosController.text = data['padecimientos'] ?? '';
      setState(() {
        rolSeleccionado = data['rol'] ?? 'Paciente';
      });
    }
  }

  // Guardar datos del usuario 
  Future<void> _saveUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    await _firestore.collection('usuarios').doc(user.uid).set({
      'nombre': nombreController.text.trim(),
      'edad': edadController.text.trim(),
      'lugarNacimiento': lugarNacimientoController.text.trim(),
      'padecimientos': padecimientosController.text.trim(),
      'rol': rolSeleccionado, // Guardar el rol
      'email': user.email,
      'uid': user.uid,
    });

    setState(() => _loading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Información guardada exitosamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: Colors.blue[700],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del correo
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue[700],
                          child: Icon(
                            rolSeleccionado == 'Médico' 
                              ? Icons.medical_services 
                              : Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.email ?? 'No disponible',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: rolSeleccionado == 'Médico' 
                              ? Colors.blue[100] 
                              : Colors.green[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            rolSeleccionado,
                            style: TextStyle(
                              color: rolSeleccionado == 'Médico' 
                                ? Colors.blue[900] 
                                : Colors.green[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Información General",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown para seleccionar el rol
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: rolSeleccionado,
                      decoration: const InputDecoration(
                        labelText: "Rol",
                        prefixIcon: Icon(Icons.badge),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: ['Paciente', 'Médico'].map((String rol) {
                        return DropdownMenuItem<String>(
                          value: rol,
                          child: Text(rol),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            rolSeleccionado = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Para colocar el nombre
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: "Nombre completo",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Para colocar la edad
                  TextField(
                    controller: edadController,
                    decoration: const InputDecoration(
                      labelText: "Edad",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Para colocar el lugar de nacimiento
                  TextField(
                    controller: lugarNacimientoController,
                    decoration: const InputDecoration(
                      labelText: "Lugar de nacimiento",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Para colocar los padecimientos
                  TextField(
                    controller: padecimientosController,
                    decoration: const InputDecoration(
                      labelText: "Padecimientos",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_information),
                      helperText: "Describe tus condiciones médicas o enfermedades",
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  // Botón para guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveUserData,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue[700],
                      ),
                      child: const Text(
                        "Guardar información",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botón para volver
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Volver",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}