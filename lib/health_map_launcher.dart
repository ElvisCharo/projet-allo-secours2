import 'package:flutter/foundation.dart';
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
    final normalizedCity = city == 'Autres villes' ? 'Benin' : city;
    final query = '$name, $normalizedCity, Benin';

    final launchTargets = <_LaunchTarget>[
      ..._platformMapTargets(query),
      _LaunchTarget(
        uri: Uri.https(
          'www.google.com',
          '/maps/search/',
          {'api': '1', 'query': query},
        ),
        mode: LaunchMode.platformDefault,
      ),
      _LaunchTarget(
        uri: Uri.https('maps.google.com', '/', {'q': query}),
        mode: LaunchMode.platformDefault,
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

      final nearbyQuery = '$category proche de moi';
      final launchTargets = <_LaunchTarget>[
        ..._platformNearbyTargets(latLng, category),
        _LaunchTarget(
          uri: Uri.https(
            'www.google.com',
            '/maps/search/',
            {'api': '1', 'query': nearbyQuery},
          ),
          mode: LaunchMode.platformDefault,
        ),
        _LaunchTarget(
          uri: Uri.https('maps.google.com', '/', {'q': nearbyQuery}),
          mode: LaunchMode.platformDefault,
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
    List<_LaunchTarget> targets, {
    required String errorMessage,
  }) async {
    for (final target in targets) {
      try {
        if (await launchUrl(target.uri, mode: target.mode)) {
          return;
        }
      } catch (_) {
        continue;
      }
    }

    _showMessage(messenger, errorMessage);
  }

  static List<_LaunchTarget> _platformMapTargets(String query) {
    if (kIsWeb) {
      return const <_LaunchTarget>[];
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return <_LaunchTarget>[
          _LaunchTarget(
            uri: Uri.parse('geo:0,0?q=${Uri.encodeComponent(query)}'),
            mode: LaunchMode.externalApplication,
          ),
        ];
      case TargetPlatform.iOS:
        return <_LaunchTarget>[
          _LaunchTarget(
            uri: Uri.parse(
              'http://maps.apple.com/?q=${Uri.encodeQueryComponent(query)}',
            ),
            mode: LaunchMode.externalApplication,
          ),
        ];
      default:
        return const <_LaunchTarget>[];
    }
  }

  static List<_LaunchTarget> _platformNearbyTargets(
    String latLng,
    String category,
  ) {
    if (kIsWeb) {
      return const <_LaunchTarget>[];
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return <_LaunchTarget>[
          _LaunchTarget(
            uri: Uri.parse('geo:$latLng?q=${Uri.encodeComponent(category)}'),
            mode: LaunchMode.externalApplication,
          ),
        ];
      case TargetPlatform.iOS:
        return <_LaunchTarget>[
          _LaunchTarget(
            uri: Uri.parse(
              'http://maps.apple.com/?ll=$latLng&q=${Uri.encodeQueryComponent(category)}',
            ),
            mode: LaunchMode.externalApplication,
          ),
        ];
      default:
        return const <_LaunchTarget>[];
    }
  }

  static void _showMessage(ScaffoldMessengerState? messenger, String message) {
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LocationException implements Exception {
  const _LocationException(this.message);

  final String message;
}

class _LaunchTarget {
  const _LaunchTarget({
    required this.uri,
    required this.mode,
  });

  final Uri uri;
  final LaunchMode mode;
}
