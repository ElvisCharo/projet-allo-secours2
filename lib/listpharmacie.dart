import 'package:flutter/material.dart';

import 'health_map_launcher.dart';

const Color pharmacyPrimaryColor = Color(0xFF1565C0);
const Color pharmacySecondaryColor = Color(0xFF42A5F5);

const Map<String, List<String>> pharmacies = {
  "Cotonou": [
    "Pharmacie Camp Guézo",
    "Pharmacie Fidjrossè",
    "Pharmacie Sainte Rita",
    "Pharmacie du Port",
    "Pharmacie Tokpa",
    "Pharmacie La Madone",
  ],
  "Abomey-Calavi": [
    "Pharmacie de Calavi Centre",
    "Pharmacie Zogbadjè",
    "Pharmacie Togoudo",
    "Pharmacie de l'Université",
    "Pharmacie Hêvié",
  ],
  "Porto-Novo": [
    "Pharmacie Lagune",
    "Pharmacie du Plateau",
    "Pharmacie de Porto-Novo Centre",
    "Pharmacie Avassa",
  ],
  "Parakou": [
    "Pharmacie Centrale de Parakou",
    "Pharmacie Albarika",
    "Pharmacie Nima",
    "Pharmacie du Marché",
  ],
  "Autres villes": [
    "Pharmacie de Bohicon Centre",
    "Pharmacie de Ouidah",
    "Pharmacie de Lokossa",
    "Pharmacie de Natitingou",
    "Pharmacie de Djougou",
  ],
};

class Pharmacie extends StatelessWidget {
  const Pharmacie({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text("💊 Pharmacies du Bénin"),
        centerTitle: true,
        backgroundColor: pharmacyPrimaryColor,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: pharmacies.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
              leading: const Icon(Icons.location_on, color: pharmacyPrimaryColor),
              title: Text(
                entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: entry.value.map((pharmacy) {
                return ListTile(
                  leading: const Icon(Icons.local_pharmacy, color: Colors.green),
                  title: Text(pharmacy),
                  onTap: () => HealthMapLauncher.openPlace(
                    context,
                    name: pharmacy,
                    city: entry.key,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: pharmacyPrimaryColor),
                    onPressed: () => HealthMapLauncher.openPlace(
                      context,
                      name: pharmacy,
                      city: entry.key,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),

      // ✅ FAB pour "Pharmacie près de moi"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => HealthMapLauncher.openNearbyCategory(
          context,
          category: 'pharmacie',
        ),
        backgroundColor: pharmacyPrimaryColor,
        icon: const Icon(Icons.my_location, color: Colors.white),
        label: const Text("Près de moi"),
      ),
    );
  }
}
