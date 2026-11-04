import 'package:awady_music/core/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:awady_music/core/l10n/app_localizations.dart';

extension L10nContextExtension on BuildContext {
  L10n get l10n => L10n.of(this)!;
}
