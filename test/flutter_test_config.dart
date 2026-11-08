import 'dart:async';

import 'package:alchemist/alchemist.dart';

import 'support/load_app_fonts.dart';

/// Shared test setup.
///
/// Readable platform goldens in this repo were produced on Windows
/// (`goldens/windows/`). Linux, including GitHub-hosted Ubuntu, compares the
/// obscured CI goldens only. Those CI images are the cross-platform baseline
/// and are not regenerated here.
///
/// App fonts are loaded so screenshots and icon glyphs use Inter, IBM Plex
/// Sans Arabic, and Lucide. CI goldens still obscure text into blocks after
/// layout. Those PNG files are not regenerated: `track_tile_states` still
/// differs by 921 pixels (0.30%), almost all of them antialiasing under 8/255
/// plus a 1px rounded-corner column. A threshold wide enough to pass that
/// would also hide a missing icon, so the committed image stays the baseline.
Future<void> testExecutable(Future<void> Function() testMain) {
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        platforms: {HostPlatform.windows},
      ),
    ),
    run: () async {
      await loadAppFonts();
      await testMain();
    },
  );
}
