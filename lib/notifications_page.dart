import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: currentUser == null
          ? const Center(
              child: Text('Connectez-vous pour voir vos notifications.'),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('notifications')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                final notifications = snapshot.data?.docs ?? [];
                if (notifications.isEmpty) {
                  return const Center(
                    child: Text('Aucune notification pour le moment.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = notifications[index].data();
                    final title = data['title']?.toString() ?? 'Notification';
                    final body = data['body']?.toString() ?? '';
                    final specialistName =
                        data['specialistName']?.toString() ?? '';
                    final read = data['read'] as bool? ?? false;
                    final timestamp = data['createdAt'] as Timestamp?;
                    final date = timestamp != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                            timestamp.millisecondsSinceEpoch,
                          )
                        : null;
                    final formattedDate = date != null
                        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
                        : 'Date inconnue';

                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: read ? Colors.grey.shade300 : Colors.blue,
                        ),
                      ),
                      tileColor: Colors.white,
                      title: Text(title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (specialistName.isNotEmpty)
                            Text('Dr. $specialistName'),
                          const SizedBox(height: 4),
                          Text(body),
                          const SizedBox(height: 8),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        read ? Icons.mark_email_read : Icons.mark_email_unread,
                        color: read ? Colors.green : Colors.red,
                      ),
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .collection('notifications')
                            .doc(notifications[index].id)
                            .update({'read': true});
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
