import 'package:allo_secours/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = false;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() => isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() => userData = userDoc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }

    setState(() => isLoading = false);
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Loginpage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1565C0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Mon Profil",
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 20),

                  // HEADER AVEC AVATAR
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: blue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              userData?['name']?.toString().isNotEmpty == true
                                  ? userData!['name'][0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData?['name']?.toString() ?? 'Utilisateur',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userData?['email']?.toString() ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            userData?['role'] == 'specialiste'
                                ? 'Spécialiste'
                                : 'Patient',
                            style: TextStyle(
                              color: blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // INFOS SUPPLEMENTAIRES SI SPECIALISTE
                  if (userData?['role'] == 'specialiste') ...[
                    const Text(
                      "Informations professionnelles",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (userData?['specialite'] != null) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.medical_services,
                                  color: Color(0xFF1565C0),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Spécialité: ${userData!['specialite']}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (userData?['hopital'] != null) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_hospital,
                                  color: Color(0xFF1565C0),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Hôpital: ${userData!['hopital']}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // OPTIONS
                  const Text(
                    "Paramètres",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // NOTIFICATIONS
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: Color(0xFF1565C0),
                      ),
                      title: const Text("Notifications"),
                      subtitle: const Text("Gérer les notifications"),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: blue,
                      ),
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(height: 12),

                  // AIDE
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.help, color: Color(0xFF1565C0)),
                      title: const Text("Aide & Support"),
                      subtitle: const Text("Contactez-nous"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Support"),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Email: support@allosecours.com"),
                                SizedBox(height: 8),
                                Text("Téléphone: +225 XX XX XX XX XX"),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Fermer"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // A PROPOS
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.info, color: Color(0xFF1565C0)),
                      title: const Text("À propos"),
                      subtitle: const Text("Version 1.0.0"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Allô Secours',
                          applicationVersion: '1.0.0',
                          applicationIcon: const Icon(
                            Icons.local_hospital,
                            color: Color(0xFF1565C0),
                            size: 48,
                          ),
                          children: const [
                            Text(
                              'Application de géolocalisation des services de santé.\n\nTrouvez rapidement les hôpitaux, pharmacies et services d\'urgence près de vous.',
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BOUTON DECONNEXION
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Déconnexion"),
                            content: const Text(
                              "Êtes-vous sûr de vouloir vous déconnecter ?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Annuler"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  logout();
                                },
                                child: const Text(
                                  "Déconnecter",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        "Se déconnecter",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
