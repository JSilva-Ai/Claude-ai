import 'package:flutter/material.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/loop_dimens.dart';
import '../../../../core/theme/loop_theme.dart';

/// The language picker behind the header's menu button.
///
/// LOOP ships in three languages, and on a device set to a fourth the only way
/// to see any of them is to choose one. "System" stays the default, because an
/// app that ignores the device language is the one people complain about.
Future<void> showLanguageSheet(BuildContext context) {
  final LocaleController controller = LocaleScope.of(context);

  return showModalBottomSheet<void>(
    context: context,
    barrierColor: const Color(0xB3000000),
    builder: (BuildContext sheetContext) {
      final AppLocalizations l10n = AppLocalizations.of(sheetContext);

      final List<(Locale?, String)> options = <(Locale?, String)>[
        (null, l10n.languageSystem),
        (const Locale('en'), l10n.languageEnglish),
        (const Locale('pt'), l10n.languagePortuguese),
        (const Locale('es'), l10n.languageSpanish),
      ];

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LoopSpacing.md,
            LoopSpacing.xs,
            LoopSpacing.md,
            LoopSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LoopSpacing.xs,
                  vertical: LoopSpacing.xs,
                ),
                child: Text(l10n.language, style: sheetContext.text.titleLarge),
              ),
              for (final (Locale? locale, String label) in options)
                ListTile(
                  title: Text(label, style: sheetContext.text.titleMedium),
                  trailing: controller.locale == locale
                      ? Icon(
                          Icons.check_rounded,
                          color: sheetContext.accents.aiText,
                        )
                      : null,
                  selected: controller.locale == locale,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(LoopRadius.sm),
                  ),
                  onTap: () {
                    controller.select(locale);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}
