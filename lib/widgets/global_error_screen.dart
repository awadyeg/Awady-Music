import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Global error display screen shown when an unhandled render error occurs
class GlobalErrorScreen extends StatelessWidget {
  const GlobalErrorScreen({this.onReload, this.details, super.key});

  final VoidCallback? onReload;
  final String? details;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ContentSurface(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: tokens.danger.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.triangleAlert,
                      color: tokens.danger,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.errorTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.errorBody,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: tokens.textDim,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (details != null && details!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      details!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: tokens.textFaint,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Semantics(
                    button: true,
                    label: l10n.errorReload,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.accent,
                        foregroundColor: tokens.onAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            GlassTokens.radiusCapsule,
                          ),
                        ),
                      ),
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: Text(
                        l10n.errorReload,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: onReload,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Boundary catching build-time throws and rendering GlobalErrorScreen
class AppErrorBoundary extends StatefulWidget {
  const AppErrorBoundary({required this.child, this.onReload, super.key});

  final Widget child;
  final VoidCallback? onReload;

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
  }

  void _reset() {
    setState(() => _error = null);
    widget.onReload?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return GlobalErrorScreen(details: _error.toString(), onReload: _reset);
    }

    return widget.child;
  }
}
