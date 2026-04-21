import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthMapLauncher {
  static Future<void> openPlace(
    BuildContext context, {
    required String name,
    required String city,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final query = '$name, $city, Benin';

    final launchTargets = <Uri>[
      if (Platform.isAndroid) Uri.parse('geo:0,0?q=${Uri.encodeComponent(query)}'),
      if (Platform.isIOS)
        Uri.parse(
          'http://maps.apple.com/?q=${Uri.encodeQueryComponent(query)}',
        ),
      Uri.https(
        'www.google.com',
        '/maps/search/',
        {'api': '1', 'query': query},
      ),
    ];

    await _launchFirstAvailable(
      messenger,
      launchTargets,
      errorMessage: 'Impossible d’ouvrir la carte pour cet établissement.',
    );
  }

  static Future<void> openNearbyCategory(
    BuildContext context, {
    required String category,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      final position = await _getCurrentPosition();
      final latLng = '${position.latitude},${position.longitude}';

      final launchTargets = <Uri>[
        if (Platform.isAndroid)
          Uri.parse(
            'geo:$latLng?q=${Uri.encodeComponent(category)}',
          ),
        if (Platform.isIOS)
          Uri.parse(
            'http://maps.apple.com/?ll=$latLng&q=${Uri.encodeQueryComponent(category)}',
          ),
        Uri.https(
          'www.google.com',
          '/maps/search/',
          {'api': '1', 'query': '$category près de moi'},
        ),
      ];

      await _launchFirstAvailable(
        messenger,
        launchTargets,
        errorMessage: 'Impossible d’ouvrir la carte près de votre position.',
      );
    } on _LocationException catch (error) {
      _showMessage(messenger, error.message);
    } catch (_) {
      _showMessage(
        messenger,
        'Une erreur est survenue pendant la récupération de votre position.',
      );
    }
  }

  static Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const _LocationException(
        'Activez la localisation pour utiliser cette fonction.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const _LocationException(
        'La permission de localisation est nécessaire pour afficher les services proches.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const _LocationException(
        'La permission de localisation est bloquée. Autorisez-la dans les réglages du téléphone.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  static Future<void> _launchFirstAvailable(
    ScaffoldMessengerState? messenger,
    List<Uri> targets, {
    required String errorMessage,
  }) async {
    for (final uri in targets) {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    }

    _showMessage(messenger, errorMessage);
  }

  static void _showMessage(ScaffoldMessengerState? messenger, String message) {
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LocationException implements Exception {
  const _LocationException(this.message);

  final String message;
}
