import 'package:allo_secours/listhospital.dart';
import 'package:allo_secours/listpharmacie.dart';
import 'package:allo_secours/medicament.dart';
import 'package:allo_secours/login.dart';
import 'package:allo_secours/notification_service.dart';
import 'package:allo_secours/notifications_page.dart';
import 'package:allo_secours/rdv.dart';
import 'package:allo_secours/specialistes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Patient extends StatefulWidget {
  final String? name;

  const Patient({super.key, this.name});

  @override
  State<Patient> createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> items = [
    {"title": "Hôpitaux", "icon": Icons.local_hospital},
    {"title": "Pharmacies", "icon": Icons.local_pharmacy},
    {"title": "Médicaments", "icon": Icons.medication},
    {"title": "Spécialistes", "icon": Icons.person},
    {"title": "Rendez-vous", "icon": Icons.calendar_month},
    {"title": "Urgences", "icon": Icons.emergency},
    {"title": "Imagerie / Radio", "icon": Icons.medical_services},
    {"title": "Mes recherches", "icon": Icons.search},
    {"title": "Votre avis", "icon": Icons.rate_review},
  ];

  final Color primary = pharmacyPrimaryColor;
  final Color secondary = pharmacySecondaryColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.initFCM();
      NotificationService.saveToken();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final String notificationText =
            message.notification?.body ??
            message.notification?.title ??
            message.data['body']?.toString() ??
            '';

        if (notificationText.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(notificationText)));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // 🟢 DRAWER MENU COMPLET
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, secondary]),
              ),
              child: const SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Allô Secours",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Menu principal",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                children: [
                  _drawerItem(Icons.local_hospital, "Hôpitaux", 0),
                  _drawerItem(Icons.local_pharmacy, "Pharmacies", 1),
                  _drawerItem(Icons.medication, "Médicaments", 2),
                  _drawerItem(Icons.person, "Spécialistes", 3),
                  _drawerItem(Icons.calendar_month, "Rendez-vous", 4),
                  _drawerItem(Icons.emergency, "Urgences", 5),
                  _drawerItem(Icons.medical_services, "Imagerie / Radio", 6),
                  _drawerItem(Icons.search, "Mes recherches", 7),
                  _drawerItem(Icons.rate_review, "Votre avis", 8),
                ],
              ),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Bonjour ${widget.name?.isNotEmpty == true ? widget.name : 'utilisateur'}",
          style: const TextStyle(fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),

            // 🟢 BANNIÈRE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                height: 150,
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(colors: [primary, secondary]),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Recherchez vos services de santé\nHôpitaux • Pharmacies • Spécialistes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.health_and_safety,
                      color: Colors.white,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_dot(true), _dot(false), _dot(false)],
            ),

            const SizedBox(height: 20),

            // 🟢 GRID MENU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _pageForItem(index),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(items[index]["icon"], size: 40, color: primary),
                          const SizedBox(height: 10),
                          Text(
                            items[index]["title"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // 🟢 BOTTOM NAV (future extension)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
            );
            return;
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
            setState(() => currentIndex = index);
            return;
          }

          setState(() => currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "List"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
        ],
      ),
    );
  }

  // 🟢 DRAWER ITEM NAVIGATION
  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: primary),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => _pageForItem(index)),
        );
      },
    );
  }

  Widget _dot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 10 : 6,
      height: isActive ? 10 : 6,
      decoration: BoxDecoration(
        color: isActive ? primary : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _pageForItem(int index) {
    switch (index) {
      case 0:
        return const Hospital();
      case 1:
        return const Pharmacie();
      case 2:
        return const Medicament();
      case 3:
        return const Specialistes();
      case 4:
        return const Rdv();
      default:
        return ItemPage(title: items[index]["title"]);
    }
  }
}

// 🟢 PAGE GENERIQUE
class ItemPage extends StatelessWidget {
  final String title;

  const ItemPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Page $title', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
