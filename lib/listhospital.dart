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

  Future<void> _openMap(BuildContext context, String hopital, String ville) async {
    final query = '${hopital.replaceAll(' ', '+')},+${ville},+Bénin';
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir Google Maps.'),
        ),
      );
    }
  }

  Future<void> _openNearbyHospitals(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=hôpital+près+de+moi',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir Google Maps.'),
        ),
      );
    }
  }

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
                return ListTile(
                  leading: const Icon(
                    Icons.local_hospital,
                    color: Colors.redAccent,
                  ),
                  title: Text(hopital),
                  onTap: () => _openMap(context, hopital, entry.key),
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Color(0xFF1565C0)),
                    onPressed: () => _openMap(context, hopital, entry.key),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),

      // ✅ Bouton flottant "Près de moi"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNearbyHospitals(context),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.my_location, color: Colors.white),
        label: const Text("Près de moi"),
      ),
    );
  }
}
