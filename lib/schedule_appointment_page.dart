import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  const ScheduleAppointmentPage({super.key});

  @override
  State<ScheduleAppointmentPage> createState() =>
      _ScheduleAppointmentPageState();
}

class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _motivoController = TextEditingController();
  String? _nombreUsuario;
  String? _usuarioId;
  DateTime? _fechaSeleccionada;
  String? _citaEnEdicion;
  String? _doctorSeleccionado;
  String? _doctorNombreSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _usuarioId = user.uid;
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
        initialTime: TimeOfDay.fromDateTime(
            _fechaSeleccionada ?? DateTime.now()),
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

  Future<bool> _validarCitaDuplicada() async {
    if (_usuarioId == null || _fechaSeleccionada == null || _doctorSeleccionado == null) {
      return true;
    }

    Query query = _firestore
        .collection('citas')
        .where('usuarioId', isEqualTo: _usuarioId);
    
    final snapshot = await query.get();
    
    for (var doc in snapshot.docs) {
      if (_citaEnEdicion != null && doc.id == _citaEnEdicion) {
        continue;
      }

      final data = doc.data() as Map<String, dynamic>;
      final fechaCita = (data['fechaHora'] as Timestamp).toDate();
      final doctorCita = data['doctorId'] as String?;

      if (doctorCita == _doctorSeleccionado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ya tienes una cita programada con $_doctorNombreSeleccionado'),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 3),
          ),
        );
        return false;
      }

      final duracionCita = const Duration(hours: 1);
      final finCitaExistente = fechaCita.add(duracionCita);
      final finCitaNueva = _fechaSeleccionada!.add(duracionCita);

      final hayTraslape = (_fechaSeleccionada!.isBefore(finCitaExistente) &&
          finCitaNueva.isAfter(fechaCita));

      if (hayTraslape) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ya tienes una cita programada en ese horario.\n'
              'Cita existente: ${fechaCita.day}/${fechaCita.month}/${fechaCita.year} '
              'a las ${fechaCita.hour}:${fechaCita.minute.toString().padLeft(2, '0')}'
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 4),
          ),
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _guardarCita() async {
    if (_motivoController.text.isEmpty || 
        _fechaSeleccionada == null || 
        _doctorSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos incluyendo el doctor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final esValido = await _validarCitaDuplicada();
    if (!esValido) {
      return;
    }

    final data = {
      'usuarioId': _usuarioId,
      'nombreUsuario': _nombreUsuario ?? 'Sin nombre',
      'motivo': _motivoController.text.trim(),
      'fechaHora': Timestamp.fromDate(_fechaSeleccionada!),
      'doctorId': _doctorSeleccionado,
      'doctorNombre': _doctorNombreSeleccionado,
      'creadoEn': FieldValue.serverTimestamp(),
    };

    if (_citaEnEdicion == null) {
      await _firestore.collection('citas').add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✓ Cita creada correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      await _firestore.collection('citas').doc(_citaEnEdicion).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✓ Cita actualizada"),
          backgroundColor: Colors.green,
        ),
      );
    }

    _motivoController.clear();
    setState(() {
      _fechaSeleccionada = null;
      _citaEnEdicion = null;
      _doctorSeleccionado = null;
      _doctorNombreSeleccionado = null;
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
      _doctorSeleccionado = data['doctorId'];
      _doctorNombreSeleccionado = data['doctorNombre'];
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('usuarios')
                  .where('rol', isEqualTo: 'Médico')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final doctores = snapshot.data!.docs;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("Seleccionar Doctor"),
                      value: _doctorSeleccionado,
                      items: doctores.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final nombre = data['nombre'] ?? 'Doctor sin nombre';
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Row(
                            children: [
                              const Icon(Icons.medical_services, 
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(nombre),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _doctorSeleccionado = value;
                          final doctorDoc = doctores.firstWhere((doc) => doc.id == value);
                          final data = doctorDoc.data() as Map<String, dynamic>;
                          _doctorNombreSeleccionado = data['nombre'] ?? 'Doctor';
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _seleccionarFechaYHora,
              icon: const Icon(Icons.calendar_today),
              label: Text(_fechaSeleccionada == null 
                  ? "Seleccionar Fecha y Hora"
                  : "Fecha: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year} ${_fechaSeleccionada!.hour}:${_fechaSeleccionada!.minute.toString().padLeft(2, '0')}"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _motivoController,
              decoration: const InputDecoration(
                labelText: "Motivo de la cita",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _guardarCita,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                _citaEnEdicion == null ? "Guardar Cita" : "Actualizar Cita",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            
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

                final todasLasCitas = snapshot.data!.docs;
                final citas = todasLasCitas.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['usuarioId'] == _usuarioId || 
                         !data.containsKey('usuarioId');
                }).toList();
                
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
                    final fecha = (data['fechaHora'] as Timestamp?)?.toDate() ??
                        DateTime.now();
                    final doctorNombre = data['doctorNombre'] ?? 'Doctor no asignado';
                    
                    return Dismissible(
                      key: Key(cita.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (_) => _eliminarCita(cita.id),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.event_note, color: Colors.blue),
                          title: Text(
                            data['motivo'] ?? 'Sin motivo',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Doctor: $doctorNombre\n'
                            'Fecha: ${fecha.day}/${fecha.month}/${fecha.year} '
                            'a las ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}\n'
                            'Por: ${data['nombreUsuario'] ?? 'Desconocido'}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editarCita(cita.id, data),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
