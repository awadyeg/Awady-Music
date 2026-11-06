import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Visual style generator for mood and genre cards.
class MoodVisualStyle {
  const MoodVisualStyle({
    required this.colors,
    required this.icon,
    required this.accentCircleColor,
  });

  /// Generates a deterministic visual style based on the mood [title].
  factory MoodVisualStyle.forTitle(String title) {
    final lower = title.toLowerCase();

    if (lower.contains('chill') ||
        lower.contains('relax') ||
        lower.contains('peace')) {
      return const MoodVisualStyle(
        colors: [Color(0xFF0F766E), Color(0xFF1E3A8A)],
        icon: LucideIcons.wind,
        accentCircleColor: Color(0x332DD4BF),
      );
    }
    if (lower.contains('workout') ||
        lower.contains('energy') ||
        lower.contains('power') ||
        lower.contains('gym')) {
      return const MoodVisualStyle(
        colors: [Color(0xFFEA580C), Color(0xFFDC2626)],
        icon: LucideIcons.flame,
        accentCircleColor: Color(0x33F97316),
      );
    }
    if (lower.contains('focus') ||
        lower.contains('study') ||
        lower.contains('work')) {
      return const MoodVisualStyle(
        colors: [Color(0xFF4338CA), Color(0xFF6D28D9)],
        icon: LucideIcons.brain,
        accentCircleColor: Color(0x33818CF8),
      );
    }
    if (lower.contains('romance') ||
        lower.contains('love') ||
        lower.contains('romantic')) {
      return const MoodVisualStyle(
        colors: [Color(0xFFBE185D), Color(0xFFE11D48)],
        icon: LucideIcons.heart,
        accentCircleColor: Color(0x33F43F5E),
      );
    }
    if (lower.contains('party') ||
        lower.contains('dance') ||
        lower.contains('club')) {
      return const MoodVisualStyle(
        colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
        icon: LucideIcons.sparkles,
        accentCircleColor: Color(0x33C084FC),
      );
    }
    if (lower.contains('sad') ||
        lower.contains('rain') ||
        lower.contains('melanchol') ||
        lower.contains('blue')) {
      return const MoodVisualStyle(
        colors: [Color(0xFF334155), Color(0xFF1E293B)],
        icon: LucideIcons.cloudRain,
        accentCircleColor: Color(0x3394A3B8),
      );
    }
    if (lower.contains('happy') ||
        lower.contains('summer') ||
        lower.contains('feel good') ||
        lower.contains('sun')) {
      return const MoodVisualStyle(
        colors: [Color(0xFFD97706), Color(0xFFB45309)],
        icon: LucideIcons.sun,
        accentCircleColor: Color(0x33FBBF24),
      );
    }
    if (lower.contains('arabic') ||
        lower.contains('tarab') ||
        lower.contains('shaabi') ||
        lower.contains('oud') ||
        lower.contains('egypt')) {
      return const MoodVisualStyle(
        colors: [Color(0xFF854D0E), Color(0xFF92400E)],
        icon: LucideIcons.music2,
        accentCircleColor: Color(0x33F59E0B),
      );
    }
    if (lower.contains('commute') ||
        lower.contains('drive') ||
        lower.contains('road') ||
        lower.contains('car')) {
      return const MoodVisualStyle(
        colors: [Color(0xFF1D4ED8), Color(0xFF0369A1)],
        icon: LucideIcons.car,
        accentCircleColor: Color(0x3338BDF8),
      );
    }
    if (lower.contains('sleep') ||
        lower.contains('night') ||
        lower.contains('bed')) {
      return const MoodVisualStyle(
        colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
        icon: LucideIcons.moon,
        accentCircleColor: Color(0x33818CF8),
      );
    }
    if (lower.contains('rock') || lower.contains('metal')) {
      return const MoodVisualStyle(
        colors: [Color(0xFF374151), Color(0xFF111827)],
        icon: LucideIcons.guitar,
        accentCircleColor: Color(0x336B7280),
      );
    }
    if (lower.contains('hip') || lower.contains('rap')) {
      return const MoodVisualStyle(
        colors: [Color(0xFF78350F), Color(0xFF451A03)],
        icon: LucideIcons.mic,
        accentCircleColor: Color(0x33D97706),
      );
    }
    if (lower.contains('like') ||
        lower.contains('favorite') ||
        lower.contains('favourite')) {
      return const MoodVisualStyle(
        colors: [Color(0xFF991B1B), Color(0xFFDC2626)],
        icon: LucideIcons.heart,
        accentCircleColor: Color(0x33EF4444),
      );
    }

    final palettes = [
      (
        colors: [const Color(0xFF0D9488), const Color(0xFF115E59)],
        icon: LucideIcons.music,
        circle: const Color(0x3314B8A6),
      ),
      (
        colors: [const Color(0xFF6366F1), const Color(0xFF4338CA)],
        icon: LucideIcons.disc,
        circle: const Color(0x33A5B4FC),
      ),
      (
        colors: [const Color(0xFFD946EF), const Color(0xFFA21CAF)],
        icon: LucideIcons.sparkles,
        circle: const Color(0x33F0ABFC),
      ),
      (
        colors: [const Color(0xFF0284C7), const Color(0xFF0369A1)],
        icon: LucideIcons.headphones,
        circle: const Color(0x3338BDF8),
      ),
      (
        colors: [const Color(0xFFEA580C), const Color(0xFF9A3412)],
        icon: LucideIcons.radio,
        circle: const Color(0x33FB923C),
      ),
      (
        colors: [const Color(0xFF059669), const Color(0xFF065F46)],
        icon: LucideIcons.audioLines,
        circle: const Color(0x3334D399),
      ),
    ];

    final p = palettes[title.hashCode.abs() % palettes.length];
    return MoodVisualStyle(
      colors: p.colors,
      icon: p.icon,
      accentCircleColor: p.circle,
    );
  }

  final List<Color> colors;
  final IconData icon;
  final Color accentCircleColor;
}
