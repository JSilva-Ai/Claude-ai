import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/loop_colors.dart';
import '../../../../core/theme/loop_dimens.dart';
import '../../../../core/theme/loop_theme.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/countdown.dart';
import '../../../../core/widgets/loop_surface.dart';
import '../../../../core/widgets/pressable.dart';
import '../../models/upcoming_item.dart';

/// The next commitment on the clock, with how long is left.
///
/// The countdown is computed from [UpcomingItem.scheduledAt] on every build and
/// the widget re-builds itself on the interval the countdown says it needs —
/// a minute below a day, a quarter of an hour above it. A card that said
/// "in 4h 18m" for as long as the app stayed open would be worse than showing
/// nothing, because it would be believed.
class UpNextCard extends StatefulWidget {
  const UpNextCard({
    required this.item,
    this.clock = const Clock(),
    this.onPressed,
    this.onAddToCalendar,
    super.key,
  });

  final UpcomingItem item;
  final Clock clock;
  final VoidCallback? onPressed;
  final VoidCallback? onAddToCalendar;

  @override
  State<UpNextCard> createState() => _UpNextCardState();
}

class _UpNextCardState extends State<UpNextCard> {
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleTick();
  }

  @override
  void didUpdateWidget(UpNextCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) _scheduleTick();
  }

  void _scheduleTick() {
    _timer?.cancel();
    final Countdown countdown = Countdown.between(
      widget.clock.now(),
      widget.item.scheduledAt,
    );
    _timer = Timer.periodic(countdown.refreshInterval, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LoopAccents accents = context.accents;
    final DateTime now = widget.clock.now();

    final String when = _formatWhen(context, l10n, now);
    final String left = _formatCountdown(
      l10n,
      Countdown.between(now, widget.item.scheduledAt),
    );

    return Pressable(
      onPressed: widget.onPressed,
      isButton: widget.onPressed != null,
      semanticLabel: '${l10n.upNext}. ${widget.item.title}. $when. $left',
      child: ExcludeSemantics(
        child: LoopSurface(
          padding: const EdgeInsets.symmetric(
            horizontal: LoopSpacing.md,
            vertical: LoopSpacing.sm + 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.upNext,
                style: context.text.labelMedium?.copyWith(
                  color: accents.aiText,
                ),
              ),
              const SizedBox(height: LoopSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          widget.item.title,
                          style: context.text.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: LoopSpacing.xxs),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: accents.textTertiary,
                            ),
                            const SizedBox(width: LoopSpacing.xxs + 2),
                            Flexible(
                              child: Text(
                                when,
                                style: context.text.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: LoopSpacing.sm),
                  // The countdown is allowed to wrap rather than being pinned
                  // to one line: "en 4 h 18 min" is half again the width of
                  // "in 4h 18m", and it must not push the button off the card.
                  Flexible(
                    child: Text(
                      left,
                      textAlign: TextAlign.end,
                      style: context.text.titleMedium?.copyWith(
                        color: accents.aiText,
                      ),
                    ),
                  ),
                  if (widget.onAddToCalendar != null) ...<Widget>[
                    const SizedBox(width: LoopSpacing.sm),
                    Semantics(
                      button: true,
                      label: l10n.addToCalendar,
                      child: Pressable(
                        onPressed: widget.onAddToCalendar,
                        minSize: LoopSizes.minTouchTarget,
                        child: const _CalendarButton(),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatWhen(
    BuildContext context,
    AppLocalizations l10n,
    DateTime now,
  ) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    // 2:00 PM in English, 14:00 in Portuguese and Spanish — decided by the
    // locale's own convention rather than by a format string we picked.
    final String time = DateFormat.jm(locale).format(widget.item.scheduledAt);

    return switch (relativeDayFor(now, widget.item.scheduledAt)) {
      RelativeDay.today => l10n.upNextToday(time),
      RelativeDay.tomorrow => l10n.upNextTomorrow(time),
      RelativeDay.other => l10n.upNextOnDate(
          DateFormat.MMMEd(locale).format(widget.item.scheduledAt),
          time,
        ),
    };
  }

  String _formatCountdown(AppLocalizations l10n, Countdown countdown) {
    return switch (countdown.unit) {
      CountdownUnit.overdue => l10n.countdownOverdue,
      CountdownUnit.now => l10n.countdownNow,
      CountdownUnit.minutes => l10n.countdownMinutes(countdown.major),
      CountdownUnit.hoursMinutes =>
        l10n.countdownHoursMinutes(countdown.major, countdown.minor),
      CountdownUnit.daysHours =>
        l10n.countdownDaysHours(countdown.major, countdown.minor),
    };
  }
}

class _CalendarButton extends StatelessWidget {
  const _CalendarButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LoopSizes.headerButton,
      height: LoopSizes.headerButton,
      decoration: BoxDecoration(
        color: LoopColors.surfaceRaised,
        borderRadius: const BorderRadius.all(LoopRadius.sm),
        border: Border.all(color: context.accents.border),
      ),
      child: Icon(
        Icons.calendar_month_rounded,
        size: 19,
        color: context.accents.aiText,
      ),
    );
  }
}
