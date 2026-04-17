import 'package:allo_secours/disponibilitedr.dart';
import 'package:allo_secours/login.dart';
import 'package:allo_secours/rdvspecialiste.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Specialistedashboard extends StatelessWidget {
  static const Color _blue = Color(0xFF1565C0);

  final String? uid;
  final String? name;

  const Specialistedashboard({super.key, this.uid, this.name});

  @override
  Widget build(BuildContext context) {
    final displayName = (name?.isNotEmpty == true) ? name! : 'Docteur';

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          },
        ),
        title: Text("Dr. $displayName"),
        backgroundColor: _blue,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟢 HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tableau de bord",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Bienvenue $displayName 👨‍⚕️",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 📊 STATS
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 170,
                    child: _confirmedAppointmentsCountCard(uid),
                  ),
                  SizedBox(
                    width: 170,
                    child: _pendingAppointmentsCountCard(uid),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Actions rapides",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 14,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: [
                  _actionButton(
                    "Rendez-vous",
                    Icons.event,
                    uid != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RdvSpecialiste(
                                  specialistId: uid!,
                                  specialistName: displayName,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                  _actionButton(
                    "Disponibilité",
                    Icons.schedule,
                    uid != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Disponibilitedr(
                                  uid: uid!,
                                  name: displayName,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Rendez-vous confirmés",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              if (uid == null)
                const Center(child: Text("Identifiant médecin manquant."))
              else
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('appointments')
                      .where('specialistId', isEqualTo: uid)
                      .where('status', isEqualTo: 'confirmé')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('Aucun rendez-vous confirmé'),
                      );
                    }

                    final appointments = snapshot.data!.docs;

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appointments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final data = appointments[index].data();

                        final String patientName =
                            data['patientName'] ?? 'Patient';

                        final dateTime = DateTime.tryParse(
                          data['dateTime'] ?? '',
                        );

                        final formattedDate = dateTime != null
                            ? '${dateTime.day}/${dateTime.month}/${dateTime.year}'
                            : 'Date inconnue';

                        final formattedHour = dateTime != null
                            ? '${dateTime.hour}:${dateTime.minute}'
                            : 'Heure inconnue';

                        return _rdvCard(
                          context,
                          appointments[index].id,
                          patientName,
                          formattedDate,
                          formattedHour,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 📊 CARD
  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: _blue, size: 28),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmedAppointmentsCountCard(String? uid) {
    if (uid == null) {
      return _statCard("RDV confirmés", "-", Icons.check_circle);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('specialistId', isEqualTo: uid)
          .where('status', isEqualTo: 'confirmé')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _statCard("RDV confirmés", "$count", Icons.check_circle);
      },
    );
  }

  Widget _pendingAppointmentsCountCard(String? uid) {
    if (uid == null) {
      return _statCard("En attente", "-", Icons.hourglass_top);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('specialistId', isEqualTo: uid)
          .where('status', isEqualTo: 'en attente')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _statCard("En attente", "$count", Icons.hourglass_top);
      },
    );
  }

  // ⚡ ACTION BUTTON
  Widget _actionButton(String title, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1565C0)),
            const SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }

  // 🔥 RDV CARD AVEC CONFIRMATION
  Widget _rdvCard(
    BuildContext context,
    String docId,
    String name,
    String date,
    String hour,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(name),
            subtitle: Text("$date à $hour"),
            trailing: const Icon(Icons.calendar_month),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Builder(
              builder: (BuildContext scaffoldContext) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _blue),
                  onPressed: () {
                    showDialog(
                      context: scaffoldContext,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title: const Text("Confirmation"),
                        content: const Text("Avez-vous déjà reçu ce patient ?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text("Non"),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext);

                              await FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc(docId)
                                  .delete();

                              ScaffoldMessenger.of(
                                scaffoldContext,
                              ).showSnackBar(
                                const SnackBar(content: Text("Patient retiré")),
                              );
                            },
                            child: const Text(
                              "Oui",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    "Retirer",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
