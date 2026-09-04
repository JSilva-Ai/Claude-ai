import 'package:loop/domain/evidence/capture_integrity.dart';
import 'package:loop/domain/evidence/data_sensitivity.dart';
import 'package:loop/domain/evidence/source_ref.dart';
import 'package:loop/domain/source/source_observation.dart';

import 'fixtures.dart' show t0;

/// A message-like observation — an email or similar, source-neutral like
/// every other observation this file builds.
SourceObservation messageObservation({
  String locator = 'email:message/1',
  String? accountRef,
  CaptureIntegrity integrity = CaptureIntegrity.verbatim,
  String? excerpt = "I'll send it Friday",
  DateTime? at,
}) =>
    SourceObservation(
      source: SourceRef(
        source: EvidenceSource.email,
        locator: locator,
        accountRef: accountRef,
      ),
      capturedAt: at ?? t0,
      integrity: integrity,
      excerpt: excerpt,
    );

/// A calendar-like observation.
SourceObservation calendarObservation({
  String locator = 'calendar:event/abc',
  CaptureIntegrity integrity = CaptureIntegrity.parsed,
  String? excerpt = 'Proposal review, 10:00',
  DateTime? at,
}) =>
    SourceObservation(
      source: SourceRef(source: EvidenceSource.calendar, locator: locator),
      capturedAt: at ?? t0,
      integrity: integrity,
      excerpt: excerpt,
    );

/// A manual observation — the user's own entry, source-neutral like any
/// other, never a special case.
SourceObservation manualObservation({
  String locator = 'manual:note/1',
  String? excerpt = 'Call the dentist',
  DateTime? at,
}) =>
    SourceObservation(
      source: SourceRef(source: EvidenceSource.manual, locator: locator),
      capturedAt: at ?? t0,
      integrity: CaptureIntegrity.userReported,
      excerpt: excerpt,
      sensitivity: DataSensitivity.ordinary,
    );
