import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/features/legal/legal_documents.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Available legal tabs
enum LegalTab { disclaimer, terms, privacy, licenses }

/// Legal screen rendering bundled Disclaimer, Terms of Use, Privacy Policy,
/// and Open Source Licenses with glass styling and zero-dependency markdown.
class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key, this.initialTab = LegalTab.disclaimer});

  final LegalTab initialTab;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  late LegalTab _selectedTab;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged(LegalTab tab) {
    if (_selectedTab != tab) {
      setState(() => _selectedTab = tab);
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  String _getDocumentMarkdown(LegalTab tab) {
    switch (tab) {
      case LegalTab.disclaimer:
        return LegalDocuments.disclaimer;
      case LegalTab.terms:
        return LegalDocuments.terms;
      case LegalTab.privacy:
        return LegalDocuments.privacy;
      case LegalTab.licenses:
        return LegalDocuments.licenses;
    }
  }

  String _tabLabel(LegalTab tab) {
    switch (tab) {
      case LegalTab.disclaimer:
        return 'Disclaimer';
      case LegalTab.terms:
        return 'Terms';
      case LegalTab.privacy:
        return 'Privacy';
      case LegalTab.licenses:
        return 'Licenses';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final markdown = _getDocumentMarkdown(_selectedTab);

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Back',
                    child: IconButton(
                      tooltip: 'Back',
                      icon: Icon(
                        LucideIcons.chevronLeft,
                        color: tokens.textPrimary,
                        size: 24,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/settings');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Legal & Licenses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: LegalTab.values.map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(_tabLabel(tab)),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? tokens.accent : tokens.textDim,
                      ),
                      backgroundColor: tokens.glassFill,
                      selectedColor: tokens.accent.withValues(alpha: 0.18),
                      side: BorderSide(
                        color: isSelected
                            ? tokens.accent.withValues(alpha: 0.5)
                            : tokens.glassStroke,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          GlassTokens.radiusCapsule,
                        ),
                      ),
                      onSelected: (_) => _onTabChanged(tab),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // Document body
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: GlassSurface(
                  padding: const EdgeInsets.all(20),
                  child: MarkdownBodyView(markdown: markdown, tokens: tokens),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lightweight, zero-dependency Markdown renderer for headings, bullet points,
/// bold, italic and paragraphs.
class MarkdownBodyView extends StatelessWidget {
  const MarkdownBodyView({
    required this.markdown,
    required this.tokens,
    super.key,
  });

  final String markdown;
  final GlassTokens tokens;

  @override
  Widget build(BuildContext context) {
    final lines = markdown.split('\n');
    final widgets = <Widget>[];

    var i = 0;
    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        i++;
        continue;
      }

      if (trimmed.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              trimmed.substring(2),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              trimmed.substring(3),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              trimmed.substring(4),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        final content = trimmed.substring(2);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 8, left: 2),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: tokens.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    _parseInlineSpans(content, tokens),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: tokens.textDim,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Normal paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text.rich(
              _parseInlineSpans(trimmed, tokens),
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: tokens.textDim,
              ),
            ),
          ),
        );
      }
      i++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  /// Parses **bold**, *italic*, and `code` inline spans.
  InlineSpan _parseInlineSpans(String text, GlassTokens tokens) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'(\*\*.*?\*\*|\*.*?\*|`.*?`)');
    final matches = regex.allMatches(text);

    var lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: TextStyle(color: tokens.textDim),
          ),
        );
      }

      final matchedStr = match.group(0)!;
      if (matchedStr.startsWith('**') && matchedStr.endsWith('**')) {
        spans.add(
          TextSpan(
            text: matchedStr.substring(2, matchedStr.length - 2),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
        );
      } else if (matchedStr.startsWith('*') && matchedStr.endsWith('*')) {
        spans.add(
          TextSpan(
            text: matchedStr.substring(1, matchedStr.length - 1),
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: tokens.textDim,
            ),
          ),
        );
      } else if (matchedStr.startsWith('`') && matchedStr.endsWith('`')) {
        spans.add(
          TextSpan(
            text: matchedStr.substring(1, matchedStr.length - 1),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: tokens.accent,
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: TextStyle(color: tokens.textDim),
        ),
      );
    }

    return TextSpan(children: spans);
  }
}
