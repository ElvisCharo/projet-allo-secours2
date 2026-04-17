import 'package:allo_secours/login.dart';
import 'package:allo_secours/register.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool _dialogShown = false;
  String _permissionStatus = 'Non déterminé';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dialogShown && mounted) {
        _dialogShown = true;
        _showNotificationDialog();
      }
    });
  }

  Future<void> _showNotificationDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Activer les notifications'),
          content: const Text(
            'Souhaitez-vous activer les notifications pour recevoir des alertes importantes ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _permissionStatus = 'Non merci';
                });
              },
              child: const Text('Non merci'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final settings = await FirebaseMessaging.instance
                    .requestPermission(
                      alert: true,
                      badge: true,
                      sound: true,
                      announcement: false,
                      carPlay: false,
                      criticalAlert: false,
                      provisional: false,
                    );
                String statusLabel;
                switch (settings.authorizationStatus) {
                  case AuthorizationStatus.authorized:
                    statusLabel = 'autorisé';
                    break;
                  case AuthorizationStatus.provisional:
                    statusLabel = 'provisoire';
                    break;
                  case AuthorizationStatus.denied:
                    statusLabel = 'refusé';
                    break;
                  default:
                    statusLabel = 'non déterminé';
                }
                print('Notification permission: $statusLabel');
                if (mounted) {
                  setState(() {
                    _permissionStatus = statusLabel;
                  });
                }
              },
              child: const Text('Autoriser'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.health_and_safety, size: 100, color: blue),
                const SizedBox(height: 20),
                const Text(
                  'Bienvenue sur Allo Secours',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Votre plateforme de santé rapide et simple',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Text('Statut notifications : $_permissionStatus'),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Qui êtes-vous ?'),
                            content: const Text(
                              'Choisissez votre profil avant de créer un compte.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const Register(
                                        initialRole: 'patient',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Patient'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const Register(
                                        initialRole: 'specialiste',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Spécialiste'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Créer un compte',
                      style: TextStyle(color: blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
