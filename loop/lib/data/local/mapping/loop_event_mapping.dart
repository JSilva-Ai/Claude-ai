import 'package:drift/drift.dart';

import '../../../domain/ids.dart';
import '../../../domain/loop/loop_event.dart';
import '../../../domain/loop/loop_state.dart';
import '../database/loop_database.dart';
import 'enum_codec.dart';
import 'persisted_time.dart';

/// Domain → storage. Proves the schema can hold every field `LoopEvent`
/// carries without loss.
LoopEventRecordsCompanion loopEventToCompanion(LoopEvent event) {
  return LoopEventRecordsCompanion.insert(
    loopId: event.loop.value,
    sequence: event.sequence,
    kind: encodeEnum(event.kind),
    actor: encodeEnum(event.actor),
    atMillis: toPersistedMillis(event.at),
    fromState: Value<String?>(
      event.from == null ? null : encodeEnum(event.from!),
    ),
    toState: Value<String?>(event.to == null ? null : encodeEnum(event.to!)),
    abandonReason: Value<String?>(
      event.reason == null ? null : encodeEnum(event.reason!),
    ),
    evidenceId: Value<String?>(event.evidence?.value),
  );
}

/// Storage → domain.
LoopEvent loopEventFromRecord(LoopEventRecord row) {
  return LoopEvent(
    loop: LoopId.parse(row.loopId),
    sequence: row.sequence,
    kind: decodeEnum(LoopEventKind.values, row.kind),
    actor: decodeEnum(TransitionActor.values, row.actor),
    at: fromPersistedMillis(row.atMillis),
    from: row.fromState == null
        ? null
        : decodeEnum(LoopState.values, row.fromState!),
    to: row.toState == null ? null : decodeEnum(LoopState.values, row.toState!),
    reason: row.abandonReason == null
        ? null
        : decodeEnum(AbandonReason.values, row.abandonReason!),
    evidence: row.evidenceId == null ? null : EvidenceId.parse(row.evidenceId!),
  );
}
