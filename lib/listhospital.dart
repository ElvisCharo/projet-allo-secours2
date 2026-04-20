import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const Map<String, List<String>> hopitaux = {
  "Cotonou": [
    "CNHU-HKM (Centre National Hospitalier Universitaire Hubert K. Maga)",
    "Hôpital de la Mère et de l’Enfant Lagune (HOMEL)",
    "Hôpital Bethesda",
    "Hôpital de zone Suru-Léré",
    "Clinique St Luc",
    "Clinique du Golfe",
    "Hôpital Camp Guézo",
    "CNHU de Cotonou",
  ],
  "Abomey-Calavi": [
    "CHUZ Abomey-Calavi / So-Ava",
    "Hôpital Saint Augustin",
    "Centre Médical Sèdégbé",
    "Hôpital de zone Abomey-Calavi",
    "Clinique Sainte Rita",
    "Clinique Mahouna",
    "Centre de santé Hêvié",
  ],
  "Porto-Novo": [
    "CHD Ouémé-Plateau",
    "Hôpital de zone de Porto-Novo",
    "Clinique Louis Pasteur",
    "Hôpital El-Fateh",
    "Hôpital de l’Ordre de Malte",
    "Centre de santé Lagune",
  ],
  "Parakou": [
    "Hôpital Universitaire de Parakou",
    "Hôpital St Martin de Porres",
    "Hôpital Ahmadiyya",
    "Clinique Espoir",
    "Centre de santé de Parakou",
  ],
  "Autres villes": [
    "Hôpital Saint Jean de Dieu (Tanguiéta)",
    "Hôpital de zone de Bohicon",
    "Hôpital de zone de Ouidah",
    "Hôpital de zone de Djougou",
    "Hôpital de zone de Lokossa",
    "Hôpital de zone de Natitingou",
  ],
};

class Hospital extends StatelessWidget {
  const Hospital({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text("🏥 Hôpitaux du Bénin"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: hopitaux.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              leading: const Icon(
                Icons.location_city,
                color: Color(0xFF1565C0),
              ),

              title: Text(
                entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              children: entry.value.map((hopital) {
                Future<void> _openMap() async {
                  final query =
                      '${hopital.replaceAll(' ', '+')},+${entry.key},+Bénin';
                  final url =
                      'https://www.google.com/maps/search/?api=1&query=$query';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                }

                return ListTile(
                  leading: const Icon(
                    Icons.local_hospital,
                    color: Colors.redAccent,
                  ),
                  title: Text(hopital),
                  onTap: _openMap,
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Color(0xFF1565C0)),
                    onPressed: _openMap,
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
