import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:allo_secours/pagerdv.dart';

class Specialistes extends StatelessWidget {
  const Specialistes({super.key});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),

      appBar: AppBar(
        title: const Text("👨‍⚕️ Spécialistes"),
        centerTitle: true,
        backgroundColor: blue,
      ),

      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Choisissez un spécialiste et prenez un rendez-vous à la date qui vous convient",
              style: TextStyle(color: Colors.white),
            ),
          ),

          // LISTE FIRESTORE
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'specialiste')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Aucun spécialiste inscrit pour le moment.'),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data();
                    final String nom =
                        data['name']?.toString() ?? 'Spécialiste';
                    final String specialite =
                        data['specialite']?.toString() ?? 'N/A';
                    final String hopital = data['hopital']?.toString() ?? 'N/A';
                    final bool dispo = data['disponible'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NOM + STATUT
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  nom,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: dispo ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  dispo ? 'Disponible' : 'Occupé',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          Text('🩺 $specialite'),
                          const SizedBox(height: 4),
                          Text('🏥 $hopital'),
                          const SizedBox(height: 8),
                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('doctorAvailability')
                                .doc(doc.id)
                                .snapshots(),
                            builder: (context, availabilitySnapshot) {
                              if (availabilitySnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text(
                                  'Chargement des horaires...',
                                  style: TextStyle(color: Colors.black54),
                                );
                              }

                              if (!availabilitySnapshot.hasData ||
                                  !availabilitySnapshot.data!.exists) {
                                return const Text(
                                  'Horaires non renseignés',
                                  style: TextStyle(color: Colors.black54),
                                );
                              }

                              final availabilityData = availabilitySnapshot
                                  .data!
                                  .data();
                              final availability = availabilityData != null
                                  ? Map<String, dynamic>.from(
                                      availabilityData['availability'] ?? {},
                                    )
                                  : <String, dynamic>{};

                              if (availability.isEmpty) {
                                return const Text(
                                  'Horaires non renseignés',
                                  style: TextStyle(color: Colors.black54),
                                );
                              }

                              return Text(
                                _formatAvailability(availability),
                                style: const TextStyle(color: Colors.black54),
                              );
                            },
                          ),

                          const SizedBox(height: 14),
                          // 🔥 BOUTON RDV CORRIGÉ
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RendezVousPage(
                                      doctorId: doc.id,
                                      doctorName: nom,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                '📅 Prendre RDV',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatAvailability(Map<String, dynamic> availability) {
    final lines = <String>[];
    final orderedDays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

    for (final day in orderedDays) {
      if (availability.containsKey(day)) {
        final dayData = Map<String, dynamic>.from(availability[day] ?? {});
        final start = dayData['start']?.toString() ?? '';
        final end = dayData['end']?.toString() ?? '';
        if (start.isNotEmpty && end.isNotEmpty) {
          lines.add('$day: $start - $end');
        }
      }
    }

    return lines.isEmpty ? 'Horaires non renseignés' : lines.join(' · ');
  }
}
