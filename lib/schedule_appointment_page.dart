import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  const ScheduleAppointmentPage({super.key});

  @override
  State<ScheduleAppointmentPage> createState() => _ScheduleAppointmentPageState();
}

class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _motivoController = TextEditingController();
  String? _nombreUsuario;
  DateTime? _fechaSeleccionada;
  String? _citaEnEdicion;
  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }
  Future<void> _cargarNombreUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _nombreUsuario = doc.data()!['nombre'] ?? 'Usuario sin nombre';
        });
      }
    }
  }
  Future<void> _seleccionarFechaYHora() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaSeleccionada ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _fechaSeleccionada = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }
  Future<void> _guardarCita() async {
    if (_motivoController.text.isEmpty || _fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }
    final data = {
      'nombreUsuario': _nombreUsuario ?? 'Sin nombre',
      'motivo': _motivoController.text.trim(),
      'fechaHora': Timestamp.fromDate(_fechaSeleccionada!),
      'creadoEn': FieldValue.serverTimestamp(),
    };
    if (_citaEnEdicion == null) {
      await _firestore.collection('citas').add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cita creada correctamente")),
      );
    } else {
      await _firestore.collection('citas').doc(_citaEnEdicion).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cita actualizada")),
      );
    }
    _motivoController.clear();
    setState(() {
      _fechaSeleccionada = null;
      _citaEnEdicion = null;
    });
  }
  Future<void> _eliminarCita(String id) async {
    await _firestore.collection('citas').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cita eliminada")),
    );
  }
  void _editarCita(String id, Map<String, dynamic> data) {
    setState(() {
      _citaEnEdicion = id;
      _motivoController.text = data['motivo'] ?? '';
      _fechaSeleccionada =
          (data['fechaHora'] as Timestamp?)?.toDate() ?? DateTime.now();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agendar una Cita"),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Agendar una Cita Médica",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Selecciona la fecha y el motivo para tu consulta médica.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.calendar_month, size: 70, color: Colors.blue[700]),
                    const SizedBox(height: 16),
                    Text(
                      _nombreUsuario == null
                          ? "Cargando usuario..."
                          : "Usuario: $_nombreUsuario",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _motivoController,
                      decoration: const InputDecoration(
                        labelText: "Motivo de la cita",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _fechaSeleccionada == null
                                ? 'No se ha seleccionado fecha y hora'
                                : 'Fecha: ${_fechaSeleccionada!.toLocal()}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          color: Colors.blue[700],
                          onPressed: _seleccionarFechaYHora,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _guardarCita,
                      icon: const Icon(Icons.check_circle),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      label: Text(
                        _citaEnEdicion == null
                            ? "Programar Cita"
                            : "Guardar Cambios",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Citas Programadas:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('citas')
                  .orderBy('fechaHora', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final citas = snapshot.data!.docs;
                if (citas.isEmpty) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "No hay citas programadas.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: citas.length,
                  itemBuilder: (context, index) {
                    final cita = citas[index];
                    final data = cita.data() as Map<String, dynamic>;
                    final fecha =
                        (data['fechaHora'] as Timestamp?)?.toDate() ?? DateTime.now();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.event_note, color: Colors.blue),
                        title: Text(
                          data['motivo'] ?? 'Sin motivo',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            'Fecha: ${fecha.toLocal()} \nPor: ${data['nombreUsuario'] ?? 'Desconocido'}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editarCita(cita.id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarCita(cita.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text("Volver", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
