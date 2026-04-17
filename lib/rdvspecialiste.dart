import 'package:allo_secours/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RdvSpecialiste extends StatelessWidget {
  final String specialistId;
  final String specialistName;

  const RdvSpecialiste({
    super.key,
    required this.specialistId,
    required this.specialistName,
  });

  Future<void> _updateAppointmentStatus(
    BuildContext context,
    String appointmentId,
    String status,
    String doctorMessage,
    String snackbarMessage,
  ) async {
    final appointmentRef = FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId);

    final snapshot = await appointmentRef.get();
    if (!snapshot.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rendez-vous introuvable.')));
      return;
    }

    final patientId = snapshot['patientId']?.toString();
    final updateData = <String, Object?>{
      'status': status,
      'doctorConfirmed': status == 'confirmé',
      'doctorCancelled': status == 'annulé',
      'doctorMessage': doctorMessage,
    };

    if (status == 'confirmé') {
      updateData['confirmedAt'] = FieldValue.serverTimestamp();
    }
    if (status == 'annulé') {
      updateData['canceledAt'] = FieldValue.serverTimestamp();
    }

    await appointmentRef.update(updateData);

    if (patientId != null && patientId.isNotEmpty) {
      await NotificationService.createNotificationForPatient(
        patientId: patientId,
        appointmentId: appointmentId,
        specialistId: specialistId,
        specialistName: specialistName,
        title: status == 'confirmé'
            ? 'Rendez-vous confirmé'
            : 'Rendez-vous annulé',
        body: doctorMessage,
        status: status,
      );
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(snackbarMessage)));
  }

  Future<void> _confirmAppointment(
    BuildContext context,
    String appointmentId,
  ) async {
    await _updateAppointmentStatus(
      context,
      appointmentId,
      'confirmé',
      'Le rendez-vous a été confirmé par le docteur.',
      'Le rendez-vous a été confirmé.',
    );
  }

  Future<void> _cancelAppointment(
    BuildContext context,
    String appointmentId,
  ) async {
    await _updateAppointmentStatus(
      context,
      appointmentId,
      'annulé',
      'Le docteur a annulé ce rendez-vous. Veuillez revoir vos rendez-vous.',
      'Le rendez-vous a été annulé.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rendez-vous de Dr. $specialistName')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('specialistId', isEqualTo: specialistId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun rendez-vous trouvé.'));
          }

          final appointments = snapshot.data!.docs.toList();
          appointments.sort((a, b) {
            final aDate =
                DateTime.tryParse(a.data()['dateTime']?.toString() ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final bDate =
                DateTime.tryParse(b.data()['dateTime']?.toString() ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return aDate.compareTo(bDate);
          });
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = appointments[index].data();
              final String patientName =
                  data['patientName']?.toString() ?? 'Patient';
              final String dateTimeString = data['dateTime']?.toString() ?? '';
              final dateTime = DateTime.tryParse(dateTimeString);
              final formattedDate = dateTime != null
                  ? '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}'
                  : 'Date inconnue';
              final formattedHour = dateTime != null
                  ? '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
                  : 'Heure inconnue';
              final String status = data['status']?.toString() ?? 'en attente';
              final bool isConfirmed = status == 'confirmé';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Date : $formattedDate'),
                    const SizedBox(height: 4),
                    Text('Heure : $formattedHour'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            status == 'confirmé'
                                ? 'Confirmé par le docteur'
                                : status == 'annulé'
                                ? 'Rendez-vous annulé'
                                : 'En attente de confirmation',
                            style: TextStyle(
                              color: status == 'confirmé'
                                  ? Colors.green.shade700
                                  : status == 'annulé'
                                  ? Colors.red.shade700
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (status != 'annulé')
                          Row(
                            children: [
                              if (!isConfirmed)
                                ElevatedButton(
                                  onPressed: () => _confirmAppointment(
                                    context,
                                    appointments[index].id,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text('Confirmer'),
                                ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _cancelAppointment(
                                  context,
                                  appointments[index].id,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                ),
                                child: const Text('Annuler'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
