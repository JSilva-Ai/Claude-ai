/// What a piece of evidence *is*.
///
/// A property of the datum, decided at capture, and separate on purpose from
/// what may be *done* with it: that second question belongs to the person who
/// owns the data, changes with their settings, and will be answered by
/// `UserProcessingPolicy` in a later phase. Collapsing the two would bake one
/// person's preference into the classification of everybody's data.
///
/// Stamped now because classifying retroactively is impossible — by the time
/// the policy exists, the evidence it must govern has already been captured.
enum DataSensitivity {
  ordinary,
  financial,
  legal,
  health,
  intimate;

  /// Anything above [ordinary] is what a conservative default refuses to send
  /// off the device. The decision itself is not made here — this only says
  /// which side of the line the datum falls on.
  bool get isElevated => this != DataSensitivity.ordinary;
}
