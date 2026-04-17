import 'package:allo_secours/patient.dart';
import 'package:allo_secours/specialistedashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final String initialRole;

  const Register({super.key, this.initialRole = "patient"});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final specialiteController = TextEditingController();
  final hopitalController = TextEditingController();

  String role = "patient";

  @override
  void initState() {
    super.initState();
    role = widget.initialRole;
  }

  Future<void> register() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      Map<String, dynamic> userData = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "role": role,
      };

      // ➕ si spécialiste
      if (role == "specialiste") {
        userData["specialite"] = specialiteController.text.trim();
        userData["hopital"] = hopitalController.text.trim();
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(userData);

      // REDIRECTION
      if (role == "patient") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Patient(name: nameController.text.trim()),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Specialistedashboard(
              uid: uid,
              name: nameController.text.trim(),
            ),
          ),
        );
      }
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
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const Icon(Icons.health_and_safety, size: 80, color: blue),
            const SizedBox(height: 10),
            Text(
              role == "specialiste"
                  ? "Inscription Spécialiste"
                  : "Inscription Patient",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mot de passe"),
            ),

            const SizedBox(height: 20),

            // 🔥 champs spéciaux médecin
            if (role == "specialiste") ...[
              TextField(
                controller: specialiteController,
                decoration: const InputDecoration(labelText: "Spécialité"),
              ),
              TextField(
                controller: hopitalController,
                decoration: const InputDecoration(labelText: "Hôpital"),
              ),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: register,
                child: const Text("Créer le compte"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
