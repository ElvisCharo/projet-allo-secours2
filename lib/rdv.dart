import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Rdv extends StatelessWidget {
  const Rdv({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Mes rendez-vous")),
      body: user == null
          ? const Center(
              child: Text(
                'Connecte-toi pour voir tes rendez-vous.',
                textAlign: TextAlign.center,
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('patientId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur Firestore : ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun rendez-vous trouvé.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final appointments = snapshot.data!.docs;
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = appointments[index].data();
                    final String doctorName =
                        data['specialistName']?.toString() ?? 'Docteur';
                    final String dateTimeString =
                        data['dateTime']?.toString() ?? '';
                    final dateTime = DateTime.tryParse(dateTimeString);
                    final formattedDate = dateTime != null
                        ? '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}'
                        : 'Date inconnue';
                    final formattedHour = dateTime != null
                        ? '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
                        : 'Heure inconnue';
                    final String status =
                        data['status']?.toString() ?? 'en attente';
                    final String doctorMessage =
                        data['doctorMessage']?.toString() ?? '';

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
                            'Docteur : $doctorName',
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
                          Text(
                            doctorMessage.isNotEmpty
                                ? doctorMessage
                                : status == 'confirmé'
                                ? 'Le docteur a confirmé votre rendez-vous.'
                                : status == 'annulé'
                                ? 'Le rendez-vous a été annulé par le docteur.'
                                : 'En attente de confirmation du docteur.',
                            style: TextStyle(
                              color: status == 'confirmé'
                                  ? Colors.green.shade700
                                  : status == 'annulé'
                                  ? Colors.red.shade700
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
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
