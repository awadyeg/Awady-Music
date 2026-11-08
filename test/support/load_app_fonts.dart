import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads every font in the app font manifest, including package icon fonts.
///
/// `flutter test` otherwise draws text with the Ahem font (solid squares) and
/// icon fonts as empty boxes. CI golden tests still force Ahem onto their
/// theme after this load, so the committed CI baselines stay comparable.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifest = await rootBundle.loadStructuredData<List<dynamic>>(
    'FontManifest.json',
    (string) async => json.decode(string) as List<dynamic>,
  );

  for (final entry in manifest) {
    final definition = entry as Map<String, dynamic>;
    final family = _fontFamily(definition);
    final fonts = definition['fonts'];
    if (family.isEmpty || fonts is! List<dynamic> || fonts.isEmpty) {
      continue;
    }
    final loader = FontLoader(family);
    for (final face in fonts) {
      final asset = (face as Map<String, dynamic>)['asset'] as String;
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}

String _fontFamily(Map<String, dynamic> definition) {
  final family = definition['family'];
  if (family is! String || family.isEmpty) return '';
  // Current Flutter manifests already store package fonts as
  // `packages/<package>/<family>`. Older manifests stored the bare family
  // and a `packages/...` asset path.
  if (family.contains('/')) return family;
  final fonts = definition['fonts'];
  if (fonts is! List<dynamic> || fonts.isEmpty) return family;
  final asset = (fonts.first as Map<String, dynamic>)['asset'];
  if (asset is! String || !asset.startsWith('packages/')) return family;
  final packageName = asset.split('/')[1];
  return 'packages/$packageName/$family';
}
