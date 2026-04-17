import 'package:flutter/material.dart';

const Map<String, Map<String, dynamic>> medicamentsInfo = {
  "Paracétamol": {
    "usages": ["Fièvre", "Douleurs légères", "Maux de tête"],
    "precautions": "Éviter le surdosage (risque pour le foie)",
  },
  "Ibuprofène": {
    "usages": ["Inflammation", "Douleurs", "Fièvre"],
    "precautions": "À éviter en cas d’ulcère ou problèmes gastriques",
  },
  "Spasfon": {
    "usages": ["Crampes abdominales", "Douleurs digestives"],
    "precautions": "Usage temporaire uniquement",
  },
  "Maalox": {
    "usages": ["Brûlures d’estomac", "Acidité gastrique"],
    "precautions": "Ne pas utiliser sur le long terme sans avis médical",
  },
  "Gaviscon": {
    "usages": ["Reflux gastrique", "Brûlures d’estomac"],
    "precautions": "Respecter les doses recommandées",
  },
};

class Medicament extends StatefulWidget {
  const Medicament({super.key});

  @override
  State<Medicament> createState() => _MedicamentState();
}

class _MedicamentState extends State<Medicament> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1565C0);

    // filtre recherche
    final filtered = medicamentsInfo.entries.where((entry) {
      return entry.key.toLowerCase().contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),

      appBar: AppBar(
        title: const Text("💊 Médicaments"),
        centerTitle: true,
        backgroundColor: green,
      ),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un médicament...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            ),
          ),

          // � INFO BANNER
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Informations éducatives uniquement. Consultez un professionnel de santé en cas de doute.",
              style: TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 10),

          // 📋 LISTE
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final med = filtered[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      // NOM
                      Text(
                        med.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // USAGES
                      const Text(
                        "🧠 Usages :",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ...List.generate(
                        (med.value["usages"] as List).length,
                        (i) => Text("• ${(med.value["usages"] as List)[i]}"),
                      ),

                      const SizedBox(height: 10),

                      // PRÉCAUTIONS
                      const Text(
                        "⚠️ Précautions :",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        med.value["precautions"],
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
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
