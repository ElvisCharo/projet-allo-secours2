import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Disponibilitedr extends StatefulWidget {
  final String uid;
  final String name;

  const Disponibilitedr({super.key, required this.uid, required this.name});

  @override
  State<Disponibilitedr> createState() => _DisponibilitedrState();
}

class _DisponibilitedrState extends State<Disponibilitedr> {
  final List<String> _days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  final Map<String, bool> _selectedDays = {};
  final Map<String, TimeOfDay?> _startTimes = {};
  final Map<String, TimeOfDay?> _endTimes = {};

  bool _isSaving = false;
  bool _isLoading = true;

  _DisponibilitedrState() {
    for (final day in _days) {
      _selectedDays[day] = false;
      _startTimes[day] = null;
      _endTimes[day] = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('doctorAvailability')
          .doc(widget.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          final availability = Map<String, dynamic>.from(
            data['availability'] ?? {},
          );
          for (final day in _days) {
            if (availability.containsKey(day)) {
              final dayData = Map<String, dynamic>.from(availability[day]);
              _selectedDays[day] = true;
              _startTimes[day] = _parseTime(dayData['start']?.toString() ?? '');
              _endTimes[day] = _parseTime(dayData['end']?.toString() ?? '');
            }
          }
        }
      }
    } catch (_) {
      // ignore load errors
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime(String day, bool isStart) async {
    final current = isStart ? _startTimes[day] : _endTimes[day];
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTimes[day] = picked;
        } else {
          _endTimes[day] = picked;
        }
      });
    }
  }

  Future<void> _saveAvailability() async {
    final selectedDays = _days
        .where((day) => _selectedDays[day] == true)
        .toList();

    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne au moins un jour.')),
      );
      return;
    }

    for (final day in selectedDays) {
      final start = _startTimes[day];
      final end = _endTimes[day];
      if (start == null || end == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Choisis l’heure de début et de fin pour $day.'),
          ),
        );
        return;
      }
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'L’heure de fin doit être après l’heure de début pour $day.',
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    final availability = <String, Map<String, String>>{};
    for (final day in selectedDays) {
      availability[day] = {
        'start': _formatTime(_startTimes[day]!),
        'end': _formatTime(_endTimes[day]!),
      };
    }

    try {
      await FirebaseFirestore.instance
          .collection('doctorAvailability')
          .doc(widget.uid)
          .set({
            'availability': availability,
            'updatedAt': FieldValue.serverTimestamp(),
            'doctorName': widget.name,
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disponibilités enregistrées.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disponibilité de ${widget.name}'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Sélectionne les jours et les heures où tu es disponible :',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _days.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final day = _days[index];
                        return Column(
                          children: [
                            CheckboxListTile(
                              title: Text(day),
                              value: _selectedDays[day],
                              onChanged: (value) {
                                setState(() {
                                  _selectedDays[day] = value ?? false;
                                  if (!_selectedDays[day]!) {
                                    _startTimes[day] = null;
                                    _endTimes[day] = null;
                                  }
                                });
                              },
                            ),
                            if (_selectedDays[day] == true)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 8,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _pickTime(day, true),
                                        child: Text(
                                          _startTimes[day] == null
                                              ? 'Début'
                                              : 'Début: ${_formatTime(_startTimes[day]!)}',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _pickTime(day, false),
                                        child: Text(
                                          _endTimes[day] == null
                                              ? 'Fin'
                                              : 'Fin: ${_formatTime(_endTimes[day]!)}',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isSaving ? null : _saveAvailability,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
    );
  }
}
