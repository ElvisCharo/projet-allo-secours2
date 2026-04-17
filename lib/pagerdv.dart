import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RendezVousPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const RendezVousPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<RendezVousPage> createState() => _RendezVousPageState();
}

class _RendezVousPageState extends State<RendezVousPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  Future<void> confirmRdv() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Choisis date et heure")));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connecte-toi pour confirmer le RDV.")),
      );
      return;
    }

    final patientDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!patientDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Données utilisateur introuvables.")),
      );
      return;
    }

    final patientName = patientDoc['name']?.toString() ?? 'Patient';
    final appointmentDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    await FirebaseFirestore.instance.collection('appointments').add({
      'specialistId': widget.doctorId,
      'specialistName': widget.doctorName,
      'patientId': user.uid,
      'patientName': patientName,
      'dateTime': appointmentDate.toIso8601String(),
      'status': 'en attente',
      'doctorConfirmed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "RDV avec ${widget.doctorName} demandé pour le ${_formatDateTime(appointmentDate)}. Le docteur doit encore confirmer.",
        ),
      ),
    );

    Navigator.pop(context);
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/${dateTime.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1565C0);

    return Scaffold(
      appBar: AppBar(
        title: Text("RDV avec ${widget.doctorName}"),
        backgroundColor: blue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // DATE
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                selectedDate == null
                    ? "Choisir une date"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
              onTap: pickDate,
            ),

            const SizedBox(height: 10),

            // HEURE
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                selectedTime == null
                    ? "Choisir une heure"
                    : selectedTime!.format(context),
              ),
              onTap: pickTime,
            ),

            const SizedBox(height: 30),

            // CONFIRMER
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: confirmRdv,
                child: const Text(
                  "Confirmer le rendez-vous",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
