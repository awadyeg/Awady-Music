import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Notifier tracking offline status from connectivity stream
class OfflineNotifier extends Notifier<bool> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  bool build() {
    _init();
    ref.onDispose(() => _subscription?.cancel());
    return false;
  }

  void _init() {
    try {
      _subscription = Connectivity().onConnectivityChanged.listen((results) {
        state =
            results.isEmpty ||
            results.every((r) => r == ConnectivityResult.none);
      });
    } on Object {
      // In testing environments without native connectivity plugin
    }
  }

  bool get isOffline => state;

  set isOffline(bool offline) {
    state = offline;
  }
}

final isOfflineProvider = NotifierProvider<OfflineNotifier, bool>(
  OfflineNotifier.new,
);

/// Thin glass strip positioned under status bar when offline
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: isOffline
          ? SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Center(
                  child: GlassSurface(
                    radius: GlassTokens.radiusCapsule,
                    strong: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.wifiOff,
                          size: 14,
                          color: tokens.accent,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.appOffline,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: tokens.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
