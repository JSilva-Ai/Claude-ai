/// Which of the three greetings the hour calls for.
enum DayPart { morning, afternoon, evening }

/// Morning until noon, afternoon until 18:00, evening after that.
///
/// The boundaries are the ones the three launch languages share. They are not
/// universal — plenty of cultures cut the day differently — so this is the one
/// place to change when a locale needs its own rule, rather than a `switch`
/// spreading through the widgets.
DayPart dayPartFor(DateTime time) {
  final int hour = time.hour;
  if (hour < 12) return DayPart.morning;
  if (hour < 18) return DayPart.afternoon;
  return DayPart.evening;
}
