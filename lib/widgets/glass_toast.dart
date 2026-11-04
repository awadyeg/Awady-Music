import 'dart:async';

import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ToastMessage {
  const ToastMessage({
    required this.message,
    this.icon,
    this.duration = const Duration(milliseconds: 4500),
  });

  final String message;
  final IconData? icon;
  final Duration duration;
}

class ToastNotifier extends Notifier<ToastMessage?> {
  Timer? _timer;

  @override
  ToastMessage? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void show(
    String message, {
    IconData? icon,
    Duration duration = const Duration(milliseconds: 4500),
  }) {
    _timer?.cancel();
    state = ToastMessage(message: message, icon: icon, duration: duration);
    _timer = Timer(duration, () {
      state = null;
    });
  }

  void clear() {
    _timer?.cancel();
    state = null;
  }
}

final toastProvider = NotifierProvider<ToastNotifier, ToastMessage?>(
  ToastNotifier.new,
);

class GlassToast extends ConsumerWidget {
  const GlassToast({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toast = ref.watch(toastProvider);
    final tokens = Theme.of(context).glass;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
      child: toast == null
          ? const SizedBox.shrink()
          : Padding(
              key: ValueKey(toast.message),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: GlassSurface(
                radius: GlassTokens.radiusCapsule,
                strong: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (toast.icon != null) ...[
                      Icon(toast.icon, size: 18, color: tokens.textPrimary),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        toast.message,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: tokens.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
