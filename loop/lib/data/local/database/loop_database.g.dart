// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loop_database.dart';

// ignore_for_file: type=lint
class $EvidenceEntriesTable extends EvidenceEntries
    with TableInfo<$EvidenceEntriesTable, EvidenceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidenceEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _capturedAtMillisMeta =
      const VerificationMeta('capturedAtMillis');
  @override
  late final GeneratedColumn<int> capturedAtMillis = GeneratedColumn<int>(
      'captured_at_millis', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sensitivityMeta =
      const VerificationMeta('sensitivity');
  @override
  late final GeneratedColumn<String> sensitivity = GeneratedColumn<String>(
      'sensitivity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceKindMeta =
      const VerificationMeta('sourceKind');
  @override
  late final GeneratedColumn<String> sourceKind = GeneratedColumn<String>(
      'source_kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceLocatorMeta =
      const VerificationMeta('sourceLocator');
  @override
  late final GeneratedColumn<String> sourceLocator = GeneratedColumn<String>(
      'source_locator', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceAccountRefMeta =
      const VerificationMeta('sourceAccountRef');
  @override
  late final GeneratedColumn<String> sourceAccountRef = GeneratedColumn<String>(
      'source_account_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _integrityMeta =
      const VerificationMeta('integrity');
  @override
  late final GeneratedColumn<String> integrity = GeneratedColumn<String>(
      'integrity', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _excerptMeta =
      const VerificationMeta('excerpt');
  @override
  late final GeneratedColumn<String> excerpt = GeneratedColumn<String>(
      'excerpt', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _claimKindMeta =
      const VerificationMeta('claimKind');
  @override
  late final GeneratedColumn<String> claimKind = GeneratedColumn<String>(
      'claim_kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _claimCounterpartyMeta =
      const VerificationMeta('claimCounterparty');
  @override
  late final GeneratedColumn<String> claimCounterparty =
      GeneratedColumn<String>('claim_counterparty', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _claimByMillisMeta =
      const VerificationMeta('claimByMillis');
  @override
  late final GeneratedColumn<int> claimByMillis = GeneratedColumn<int>(
      'claim_by_millis', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _claimSourceQuoteMeta =
      const VerificationMeta('claimSourceQuote');
  @override
  late final GeneratedColumn<String> claimSourceQuote = GeneratedColumn<String>(
      'claim_source_quote', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _producedByIdMeta =
      const VerificationMeta('producedById');
  @override
  late final GeneratedColumn<String> producedById = GeneratedColumn<String>(
      'produced_by_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _producedByVersionMeta =
      const VerificationMeta('producedByVersion');
  @override
  late final GeneratedColumn<String> producedByVersion =
      GeneratedColumn<String>('produced_by_version', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceValueMeta =
      const VerificationMeta('confidenceValue');
  @override
  late final GeneratedColumn<double> confidenceValue = GeneratedColumn<double>(
      'confidence_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _confidenceBasisMeta =
      const VerificationMeta('confidenceBasis');
  @override
  late final GeneratedColumn<String> confidenceBasis = GeneratedColumn<String>(
      'confidence_basis', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMethodIdMeta =
      const VerificationMeta('confidenceMethodId');
  @override
  late final GeneratedColumn<String> confidenceMethodId =
      GeneratedColumn<String>('confidence_method_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMethodVersionMeta =
      const VerificationMeta('confidenceMethodVersion');
  @override
  late final GeneratedColumn<String> confidenceMethodVersion =
      GeneratedColumn<String>('confidence_method_version', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceUnderMeta =
      const VerificationMeta('confidenceUnder');
  @override
  late final GeneratedColumn<String> confidenceUnder = GeneratedColumn<String>(
      'confidence_under', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceComputedAtMillisMeta =
      const VerificationMeta('confidenceComputedAtMillis');
  @override
  late final GeneratedColumn<int> confidenceComputedAtMillis =
      GeneratedColumn<int>('confidence_computed_at_millis', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _assertionKindMeta =
      const VerificationMeta('assertionKind');
  @override
  late final GeneratedColumn<String> assertionKind = GeneratedColumn<String>(
      'assertion_kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aboutEvidenceIdMeta =
      const VerificationMeta('aboutEvidenceId');
  @override
  late final GeneratedColumn<String> aboutEvidenceId = GeneratedColumn<String>(
      'about_evidence_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES evidence_entries (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        capturedAtMillis,
        sensitivity,
        sourceKind,
        sourceLocator,
        sourceAccountRef,
        integrity,
        excerpt,
        claimKind,
        claimCounterparty,
        claimByMillis,
        claimSourceQuote,
        producedById,
        producedByVersion,
        confidenceValue,
        confidenceBasis,
        confidenceMethodId,
        confidenceMethodVersion,
        confidenceUnder,
        confidenceComputedAtMillis,
        assertionKind,
        aboutEvidenceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidence_entries';
  @override
  VerificationContext validateIntegrity(Insertable<EvidenceEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('captured_at_millis')) {
      context.handle(
          _capturedAtMillisMeta,
          capturedAtMillis.isAcceptableOrUnknown(
              data['captured_at_millis']!, _capturedAtMillisMeta));
    } else if (isInserting) {
      context.missing(_capturedAtMillisMeta);
    }
    if (data.containsKey('sensitivity')) {
      context.handle(
          _sensitivityMeta,
          sensitivity.isAcceptableOrUnknown(
              data['sensitivity']!, _sensitivityMeta));
    } else if (isInserting) {
      context.missing(_sensitivityMeta);
    }
    if (data.containsKey('source_kind')) {
      context.handle(
          _sourceKindMeta,
          sourceKind.isAcceptableOrUnknown(
              data['source_kind']!, _sourceKindMeta));
    }
    if (data.containsKey('source_locator')) {
      context.handle(
          _sourceLocatorMeta,
          sourceLocator.isAcceptableOrUnknown(
              data['source_locator']!, _sourceLocatorMeta));
    }
    if (data.containsKey('source_account_ref')) {
      context.handle(
          _sourceAccountRefMeta,
          sourceAccountRef.isAcceptableOrUnknown(
              data['source_account_ref']!, _sourceAccountRefMeta));
    }
    if (data.containsKey('integrity')) {
      context.handle(_integrityMeta,
          integrity.isAcceptableOrUnknown(data['integrity']!, _integrityMeta));
    }
    if (data.containsKey('excerpt')) {
      context.handle(_excerptMeta,
          excerpt.isAcceptableOrUnknown(data['excerpt']!, _excerptMeta));
    }
    if (data.containsKey('claim_kind')) {
      context.handle(_claimKindMeta,
          claimKind.isAcceptableOrUnknown(data['claim_kind']!, _claimKindMeta));
    }
    if (data.containsKey('claim_counterparty')) {
      context.handle(
          _claimCounterpartyMeta,
          claimCounterparty.isAcceptableOrUnknown(
              data['claim_counterparty']!, _claimCounterpartyMeta));
    }
    if (data.containsKey('claim_by_millis')) {
      context.handle(
          _claimByMillisMeta,
          claimByMillis.isAcceptableOrUnknown(
              data['claim_by_millis']!, _claimByMillisMeta));
    }
    if (data.containsKey('claim_source_quote')) {
      context.handle(
          _claimSourceQuoteMeta,
          claimSourceQuote.isAcceptableOrUnknown(
              data['claim_source_quote']!, _claimSourceQuoteMeta));
    }
    if (data.containsKey('produced_by_id')) {
      context.handle(
          _producedByIdMeta,
          producedById.isAcceptableOrUnknown(
              data['produced_by_id']!, _producedByIdMeta));
    }
    if (data.containsKey('produced_by_version')) {
      context.handle(
          _producedByVersionMeta,
          producedByVersion.isAcceptableOrUnknown(
              data['produced_by_version']!, _producedByVersionMeta));
    }
    if (data.containsKey('confidence_value')) {
      context.handle(
          _confidenceValueMeta,
          confidenceValue.isAcceptableOrUnknown(
              data['confidence_value']!, _confidenceValueMeta));
    }
    if (data.containsKey('confidence_basis')) {
      context.handle(
          _confidenceBasisMeta,
          confidenceBasis.isAcceptableOrUnknown(
              data['confidence_basis']!, _confidenceBasisMeta));
    }
    if (data.containsKey('confidence_method_id')) {
      context.handle(
          _confidenceMethodIdMeta,
          confidenceMethodId.isAcceptableOrUnknown(
              data['confidence_method_id']!, _confidenceMethodIdMeta));
    }
    if (data.containsKey('confidence_method_version')) {
      context.handle(
          _confidenceMethodVersionMeta,
          confidenceMethodVersion.isAcceptableOrUnknown(
              data['confidence_method_version']!,
              _confidenceMethodVersionMeta));
    }
    if (data.containsKey('confidence_under')) {
      context.handle(
          _confidenceUnderMeta,
          confidenceUnder.isAcceptableOrUnknown(
              data['confidence_under']!, _confidenceUnderMeta));
    }
    if (data.containsKey('confidence_computed_at_millis')) {
      context.handle(
          _confidenceComputedAtMillisMeta,
          confidenceComputedAtMillis.isAcceptableOrUnknown(
              data['confidence_computed_at_millis']!,
              _confidenceComputedAtMillisMeta));
    }
    if (data.containsKey('assertion_kind')) {
      context.handle(
          _assertionKindMeta,
          assertionKind.isAcceptableOrUnknown(
              data['assertion_kind']!, _assertionKindMeta));
    }
    if (data.containsKey('about_evidence_id')) {
      context.handle(
          _aboutEvidenceIdMeta,
          aboutEvidenceId.isAcceptableOrUnknown(
              data['about_evidence_id']!, _aboutEvidenceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EvidenceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvidenceEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      capturedAtMillis: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}captured_at_millis'])!,
      sensitivity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sensitivity'])!,
      sourceKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_kind']),
      sourceLocator: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_locator']),
      sourceAccountRef: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_account_ref']),
      integrity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}integrity']),
      excerpt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}excerpt']),
      claimKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}claim_kind']),
      claimCounterparty: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}claim_counterparty']),
      claimByMillis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}claim_by_millis']),
      claimSourceQuote: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}claim_source_quote']),
      producedById: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}produced_by_id']),
      producedByVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}produced_by_version']),
      confidenceValue: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}confidence_value']),
      confidenceBasis: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}confidence_basis']),
      confidenceMethodId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}confidence_method_id']),
      confidenceMethodVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence_method_version']),
      confidenceUnder: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}confidence_under']),
      confidenceComputedAtMillis: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}confidence_computed_at_millis']),
      assertionKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assertion_kind']),
      aboutEvidenceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}about_evidence_id']),
    );
  }

  @override
  $EvidenceEntriesTable createAlias(String alias) {
    return $EvidenceEntriesTable(attachedDatabase, alias);
  }
}

class EvidenceEntry extends DataClass implements Insertable<EvidenceEntry> {
  /// The `EvidenceId.value` this row was written for.
  final String id;

  /// One of 'observedFact' | 'inference' | 'userAssertion'. Never an ordinal:
  /// see `lib/data/local/mapping/enum_codec.dart`.
  final String type;

  /// Epoch milliseconds, UTC. See `lib/data/local/mapping/persisted_time.dart`.
  final int capturedAtMillis;

  /// `DataSensitivity`, by name.
  final String sensitivity;

  /// `SourceRef.source` (`EvidenceSource`), by name.
  final String? sourceKind;
  final String? sourceLocator;
  final String? sourceAccountRef;

  /// `CaptureIntegrity`, by name.
  final String? integrity;
  final String? excerpt;

  /// `ClaimKind`, by name.
  final String? claimKind;
  final String? claimCounterparty;
  final int? claimByMillis;
  final String? claimSourceQuote;

  /// `Inference.producedBy` (a `ProducerRef`) — distinct from
  /// [confidenceMethodId]/[confidenceMethodVersion], which is the producer of
  /// the *confidence number*, not of the inference itself. The two usually
  /// agree; the domain keeps them as two fields, so this does too.
  final String? producedById;
  final String? producedByVersion;
  final double? confidenceValue;

  /// `ConfidenceBasis`, by name.
  final String? confidenceBasis;
  final String? confidenceMethodId;
  final String? confidenceMethodVersion;

  /// `CalibrationVersion.value`.
  final String? confidenceUnder;
  final int? confidenceComputedAtMillis;

  /// `AssertionKind`, by name.
  final String? assertionKind;

  /// The inference being judged. Self-referencing: [UserAssertion.about]
  /// points at another row in this same table. Restrictive by default (no
  /// `ON DELETE CASCADE`) — deletion semantics are not designed yet, and a
  /// judged inference disappearing out from under its judgement silently is
  /// exactly the kind of convenience this phase was told not to add.
  final String? aboutEvidenceId;
  const EvidenceEntry(
      {required this.id,
      required this.type,
      required this.capturedAtMillis,
      required this.sensitivity,
      this.sourceKind,
      this.sourceLocator,
      this.sourceAccountRef,
      this.integrity,
      this.excerpt,
      this.claimKind,
      this.claimCounterparty,
      this.claimByMillis,
      this.claimSourceQuote,
      this.producedById,
      this.producedByVersion,
      this.confidenceValue,
      this.confidenceBasis,
      this.confidenceMethodId,
      this.confidenceMethodVersion,
      this.confidenceUnder,
      this.confidenceComputedAtMillis,
      this.assertionKind,
      this.aboutEvidenceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['captured_at_millis'] = Variable<int>(capturedAtMillis);
    map['sensitivity'] = Variable<String>(sensitivity);
    if (!nullToAbsent || sourceKind != null) {
      map['source_kind'] = Variable<String>(sourceKind);
    }
    if (!nullToAbsent || sourceLocator != null) {
      map['source_locator'] = Variable<String>(sourceLocator);
    }
    if (!nullToAbsent || sourceAccountRef != null) {
      map['source_account_ref'] = Variable<String>(sourceAccountRef);
    }
    if (!nullToAbsent || integrity != null) {
      map['integrity'] = Variable<String>(integrity);
    }
    if (!nullToAbsent || excerpt != null) {
      map['excerpt'] = Variable<String>(excerpt);
    }
    if (!nullToAbsent || claimKind != null) {
      map['claim_kind'] = Variable<String>(claimKind);
    }
    if (!nullToAbsent || claimCounterparty != null) {
      map['claim_counterparty'] = Variable<String>(claimCounterparty);
    }
    if (!nullToAbsent || claimByMillis != null) {
      map['claim_by_millis'] = Variable<int>(claimByMillis);
    }
    if (!nullToAbsent || claimSourceQuote != null) {
      map['claim_source_quote'] = Variable<String>(claimSourceQuote);
    }
    if (!nullToAbsent || producedById != null) {
      map['produced_by_id'] = Variable<String>(producedById);
    }
    if (!nullToAbsent || producedByVersion != null) {
      map['produced_by_version'] = Variable<String>(producedByVersion);
    }
    if (!nullToAbsent || confidenceValue != null) {
      map['confidence_value'] = Variable<double>(confidenceValue);
    }
    if (!nullToAbsent || confidenceBasis != null) {
      map['confidence_basis'] = Variable<String>(confidenceBasis);
    }
    if (!nullToAbsent || confidenceMethodId != null) {
      map['confidence_method_id'] = Variable<String>(confidenceMethodId);
    }
    if (!nullToAbsent || confidenceMethodVersion != null) {
      map['confidence_method_version'] =
          Variable<String>(confidenceMethodVersion);
    }
    if (!nullToAbsent || confidenceUnder != null) {
      map['confidence_under'] = Variable<String>(confidenceUnder);
    }
    if (!nullToAbsent || confidenceComputedAtMillis != null) {
      map['confidence_computed_at_millis'] =
          Variable<int>(confidenceComputedAtMillis);
    }
    if (!nullToAbsent || assertionKind != null) {
      map['assertion_kind'] = Variable<String>(assertionKind);
    }
    if (!nullToAbsent || aboutEvidenceId != null) {
      map['about_evidence_id'] = Variable<String>(aboutEvidenceId);
    }
    return map;
  }

  EvidenceEntriesCompanion toCompanion(bool nullToAbsent) {
    return EvidenceEntriesCompanion(
      id: Value(id),
      type: Value(type),
      capturedAtMillis: Value(capturedAtMillis),
      sensitivity: Value(sensitivity),
      sourceKind: sourceKind == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceKind),
      sourceLocator: sourceLocator == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceLocator),
      sourceAccountRef: sourceAccountRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAccountRef),
      integrity: integrity == null && nullToAbsent
          ? const Value.absent()
          : Value(integrity),
      excerpt: excerpt == null && nullToAbsent
          ? const Value.absent()
          : Value(excerpt),
      claimKind: claimKind == null && nullToAbsent
          ? const Value.absent()
          : Value(claimKind),
      claimCounterparty: claimCounterparty == null && nullToAbsent
          ? const Value.absent()
          : Value(claimCounterparty),
      claimByMillis: claimByMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(claimByMillis),
      claimSourceQuote: claimSourceQuote == null && nullToAbsent
          ? const Value.absent()
          : Value(claimSourceQuote),
      producedById: producedById == null && nullToAbsent
          ? const Value.absent()
          : Value(producedById),
      producedByVersion: producedByVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(producedByVersion),
      confidenceValue: confidenceValue == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceValue),
      confidenceBasis: confidenceBasis == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceBasis),
      confidenceMethodId: confidenceMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceMethodId),
      confidenceMethodVersion: confidenceMethodVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceMethodVersion),
      confidenceUnder: confidenceUnder == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceUnder),
      confidenceComputedAtMillis:
          confidenceComputedAtMillis == null && nullToAbsent
              ? const Value.absent()
              : Value(confidenceComputedAtMillis),
      assertionKind: assertionKind == null && nullToAbsent
          ? const Value.absent()
          : Value(assertionKind),
      aboutEvidenceId: aboutEvidenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(aboutEvidenceId),
    );
  }

  factory EvidenceEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvidenceEntry(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      capturedAtMillis: serializer.fromJson<int>(json['capturedAtMillis']),
      sensitivity: serializer.fromJson<String>(json['sensitivity']),
      sourceKind: serializer.fromJson<String?>(json['sourceKind']),
      sourceLocator: serializer.fromJson<String?>(json['sourceLocator']),
      sourceAccountRef: serializer.fromJson<String?>(json['sourceAccountRef']),
      integrity: serializer.fromJson<String?>(json['integrity']),
      excerpt: serializer.fromJson<String?>(json['excerpt']),
      claimKind: serializer.fromJson<String?>(json['claimKind']),
      claimCounterparty:
          serializer.fromJson<String?>(json['claimCounterparty']),
      claimByMillis: serializer.fromJson<int?>(json['claimByMillis']),
      claimSourceQuote: serializer.fromJson<String?>(json['claimSourceQuote']),
      producedById: serializer.fromJson<String?>(json['producedById']),
      producedByVersion:
          serializer.fromJson<String?>(json['producedByVersion']),
      confidenceValue: serializer.fromJson<double?>(json['confidenceValue']),
      confidenceBasis: serializer.fromJson<String?>(json['confidenceBasis']),
      confidenceMethodId:
          serializer.fromJson<String?>(json['confidenceMethodId']),
      confidenceMethodVersion:
          serializer.fromJson<String?>(json['confidenceMethodVersion']),
      confidenceUnder: serializer.fromJson<String?>(json['confidenceUnder']),
      confidenceComputedAtMillis:
          serializer.fromJson<int?>(json['confidenceComputedAtMillis']),
      assertionKind: serializer.fromJson<String?>(json['assertionKind']),
      aboutEvidenceId: serializer.fromJson<String?>(json['aboutEvidenceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'capturedAtMillis': serializer.toJson<int>(capturedAtMillis),
      'sensitivity': serializer.toJson<String>(sensitivity),
      'sourceKind': serializer.toJson<String?>(sourceKind),
      'sourceLocator': serializer.toJson<String?>(sourceLocator),
      'sourceAccountRef': serializer.toJson<String?>(sourceAccountRef),
      'integrity': serializer.toJson<String?>(integrity),
      'excerpt': serializer.toJson<String?>(excerpt),
      'claimKind': serializer.toJson<String?>(claimKind),
      'claimCounterparty': serializer.toJson<String?>(claimCounterparty),
      'claimByMillis': serializer.toJson<int?>(claimByMillis),
      'claimSourceQuote': serializer.toJson<String?>(claimSourceQuote),
      'producedById': serializer.toJson<String?>(producedById),
      'producedByVersion': serializer.toJson<String?>(producedByVersion),
      'confidenceValue': serializer.toJson<double?>(confidenceValue),
      'confidenceBasis': serializer.toJson<String?>(confidenceBasis),
      'confidenceMethodId': serializer.toJson<String?>(confidenceMethodId),
      'confidenceMethodVersion':
          serializer.toJson<String?>(confidenceMethodVersion),
      'confidenceUnder': serializer.toJson<String?>(confidenceUnder),
      'confidenceComputedAtMillis':
          serializer.toJson<int?>(confidenceComputedAtMillis),
      'assertionKind': serializer.toJson<String?>(assertionKind),
      'aboutEvidenceId': serializer.toJson<String?>(aboutEvidenceId),
    };
  }

  EvidenceEntry copyWith(
          {String? id,
          String? type,
          int? capturedAtMillis,
          String? sensitivity,
          Value<String?> sourceKind = const Value.absent(),
          Value<String?> sourceLocator = const Value.absent(),
          Value<String?> sourceAccountRef = const Value.absent(),
          Value<String?> integrity = const Value.absent(),
          Value<String?> excerpt = const Value.absent(),
          Value<String?> claimKind = const Value.absent(),
          Value<String?> claimCounterparty = const Value.absent(),
          Value<int?> claimByMillis = const Value.absent(),
          Value<String?> claimSourceQuote = const Value.absent(),
          Value<String?> producedById = const Value.absent(),
          Value<String?> producedByVersion = const Value.absent(),
          Value<double?> confidenceValue = const Value.absent(),
          Value<String?> confidenceBasis = const Value.absent(),
          Value<String?> confidenceMethodId = const Value.absent(),
          Value<String?> confidenceMethodVersion = const Value.absent(),
          Value<String?> confidenceUnder = const Value.absent(),
          Value<int?> confidenceComputedAtMillis = const Value.absent(),
          Value<String?> assertionKind = const Value.absent(),
          Value<String?> aboutEvidenceId = const Value.absent()}) =>
      EvidenceEntry(
        id: id ?? this.id,
        type: type ?? this.type,
        capturedAtMillis: capturedAtMillis ?? this.capturedAtMillis,
        sensitivity: sensitivity ?? this.sensitivity,
        sourceKind: sourceKind.present ? sourceKind.value : this.sourceKind,
        sourceLocator:
            sourceLocator.present ? sourceLocator.value : this.sourceLocator,
        sourceAccountRef: sourceAccountRef.present
            ? sourceAccountRef.value
            : this.sourceAccountRef,
        integrity: integrity.present ? integrity.value : this.integrity,
        excerpt: excerpt.present ? excerpt.value : this.excerpt,
        claimKind: claimKind.present ? claimKind.value : this.claimKind,
        claimCounterparty: claimCounterparty.present
            ? claimCounterparty.value
            : this.claimCounterparty,
        claimByMillis:
            claimByMillis.present ? claimByMillis.value : this.claimByMillis,
        claimSourceQuote: claimSourceQuote.present
            ? claimSourceQuote.value
            : this.claimSourceQuote,
        producedById:
            producedById.present ? producedById.value : this.producedById,
        producedByVersion: producedByVersion.present
            ? producedByVersion.value
            : this.producedByVersion,
        confidenceValue: confidenceValue.present
            ? confidenceValue.value
            : this.confidenceValue,
        confidenceBasis: confidenceBasis.present
            ? confidenceBasis.value
            : this.confidenceBasis,
        confidenceMethodId: confidenceMethodId.present
            ? confidenceMethodId.value
            : this.confidenceMethodId,
        confidenceMethodVersion: confidenceMethodVersion.present
            ? confidenceMethodVersion.value
            : this.confidenceMethodVersion,
        confidenceUnder: confidenceUnder.present
            ? confidenceUnder.value
            : this.confidenceUnder,
        confidenceComputedAtMillis: confidenceComputedAtMillis.present
            ? confidenceComputedAtMillis.value
            : this.confidenceComputedAtMillis,
        assertionKind:
            assertionKind.present ? assertionKind.value : this.assertionKind,
        aboutEvidenceId: aboutEvidenceId.present
            ? aboutEvidenceId.value
            : this.aboutEvidenceId,
      );
  EvidenceEntry copyWithCompanion(EvidenceEntriesCompanion data) {
    return EvidenceEntry(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      capturedAtMillis: data.capturedAtMillis.present
          ? data.capturedAtMillis.value
          : this.capturedAtMillis,
      sensitivity:
          data.sensitivity.present ? data.sensitivity.value : this.sensitivity,
      sourceKind:
          data.sourceKind.present ? data.sourceKind.value : this.sourceKind,
      sourceLocator: data.sourceLocator.present
          ? data.sourceLocator.value
          : this.sourceLocator,
      sourceAccountRef: data.sourceAccountRef.present
          ? data.sourceAccountRef.value
          : this.sourceAccountRef,
      integrity: data.integrity.present ? data.integrity.value : this.integrity,
      excerpt: data.excerpt.present ? data.excerpt.value : this.excerpt,
      claimKind: data.claimKind.present ? data.claimKind.value : this.claimKind,
      claimCounterparty: data.claimCounterparty.present
          ? data.claimCounterparty.value
          : this.claimCounterparty,
      claimByMillis: data.claimByMillis.present
          ? data.claimByMillis.value
          : this.claimByMillis,
      claimSourceQuote: data.claimSourceQuote.present
          ? data.claimSourceQuote.value
          : this.claimSourceQuote,
      producedById: data.producedById.present
          ? data.producedById.value
          : this.producedById,
      producedByVersion: data.producedByVersion.present
          ? data.producedByVersion.value
          : this.producedByVersion,
      confidenceValue: data.confidenceValue.present
          ? data.confidenceValue.value
          : this.confidenceValue,
      confidenceBasis: data.confidenceBasis.present
          ? data.confidenceBasis.value
          : this.confidenceBasis,
      confidenceMethodId: data.confidenceMethodId.present
          ? data.confidenceMethodId.value
          : this.confidenceMethodId,
      confidenceMethodVersion: data.confidenceMethodVersion.present
          ? data.confidenceMethodVersion.value
          : this.confidenceMethodVersion,
      confidenceUnder: data.confidenceUnder.present
          ? data.confidenceUnder.value
          : this.confidenceUnder,
      confidenceComputedAtMillis: data.confidenceComputedAtMillis.present
          ? data.confidenceComputedAtMillis.value
          : this.confidenceComputedAtMillis,
      assertionKind: data.assertionKind.present
          ? data.assertionKind.value
          : this.assertionKind,
      aboutEvidenceId: data.aboutEvidenceId.present
          ? data.aboutEvidenceId.value
          : this.aboutEvidenceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceEntry(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('capturedAtMillis: $capturedAtMillis, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceLocator: $sourceLocator, ')
          ..write('sourceAccountRef: $sourceAccountRef, ')
          ..write('integrity: $integrity, ')
          ..write('excerpt: $excerpt, ')
          ..write('claimKind: $claimKind, ')
          ..write('claimCounterparty: $claimCounterparty, ')
          ..write('claimByMillis: $claimByMillis, ')
          ..write('claimSourceQuote: $claimSourceQuote, ')
          ..write('producedById: $producedById, ')
          ..write('producedByVersion: $producedByVersion, ')
          ..write('confidenceValue: $confidenceValue, ')
          ..write('confidenceBasis: $confidenceBasis, ')
          ..write('confidenceMethodId: $confidenceMethodId, ')
          ..write('confidenceMethodVersion: $confidenceMethodVersion, ')
          ..write('confidenceUnder: $confidenceUnder, ')
          ..write('confidenceComputedAtMillis: $confidenceComputedAtMillis, ')
          ..write('assertionKind: $assertionKind, ')
          ..write('aboutEvidenceId: $aboutEvidenceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        type,
        capturedAtMillis,
        sensitivity,
        sourceKind,
        sourceLocator,
        sourceAccountRef,
        integrity,
        excerpt,
        claimKind,
        claimCounterparty,
        claimByMillis,
        claimSourceQuote,
        producedById,
        producedByVersion,
        confidenceValue,
        confidenceBasis,
        confidenceMethodId,
        confidenceMethodVersion,
        confidenceUnder,
        confidenceComputedAtMillis,
        assertionKind,
        aboutEvidenceId
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvidenceEntry &&
          other.id == this.id &&
          other.type == this.type &&
          other.capturedAtMillis == this.capturedAtMillis &&
          other.sensitivity == this.sensitivity &&
          other.sourceKind == this.sourceKind &&
          other.sourceLocator == this.sourceLocator &&
          other.sourceAccountRef == this.sourceAccountRef &&
          other.integrity == this.integrity &&
          other.excerpt == this.excerpt &&
          other.claimKind == this.claimKind &&
          other.claimCounterparty == this.claimCounterparty &&
          other.claimByMillis == this.claimByMillis &&
          other.claimSourceQuote == this.claimSourceQuote &&
          other.producedById == this.producedById &&
          other.producedByVersion == this.producedByVersion &&
          other.confidenceValue == this.confidenceValue &&
          other.confidenceBasis == this.confidenceBasis &&
          other.confidenceMethodId == this.confidenceMethodId &&
          other.confidenceMethodVersion == this.confidenceMethodVersion &&
          other.confidenceUnder == this.confidenceUnder &&
          other.confidenceComputedAtMillis == this.confidenceComputedAtMillis &&
          other.assertionKind == this.assertionKind &&
          other.aboutEvidenceId == this.aboutEvidenceId);
}

class EvidenceEntriesCompanion extends UpdateCompanion<EvidenceEntry> {
  final Value<String> id;
  final Value<String> type;
  final Value<int> capturedAtMillis;
  final Value<String> sensitivity;
  final Value<String?> sourceKind;
  final Value<String?> sourceLocator;
  final Value<String?> sourceAccountRef;
  final Value<String?> integrity;
  final Value<String?> excerpt;
  final Value<String?> claimKind;
  final Value<String?> claimCounterparty;
  final Value<int?> claimByMillis;
  final Value<String?> claimSourceQuote;
  final Value<String?> producedById;
  final Value<String?> producedByVersion;
  final Value<double?> confidenceValue;
  final Value<String?> confidenceBasis;
  final Value<String?> confidenceMethodId;
  final Value<String?> confidenceMethodVersion;
  final Value<String?> confidenceUnder;
  final Value<int?> confidenceComputedAtMillis;
  final Value<String?> assertionKind;
  final Value<String?> aboutEvidenceId;
  final Value<int> rowid;
  const EvidenceEntriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.capturedAtMillis = const Value.absent(),
    this.sensitivity = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.sourceLocator = const Value.absent(),
    this.sourceAccountRef = const Value.absent(),
    this.integrity = const Value.absent(),
    this.excerpt = const Value.absent(),
    this.claimKind = const Value.absent(),
    this.claimCounterparty = const Value.absent(),
    this.claimByMillis = const Value.absent(),
    this.claimSourceQuote = const Value.absent(),
    this.producedById = const Value.absent(),
    this.producedByVersion = const Value.absent(),
    this.confidenceValue = const Value.absent(),
    this.confidenceBasis = const Value.absent(),
    this.confidenceMethodId = const Value.absent(),
    this.confidenceMethodVersion = const Value.absent(),
    this.confidenceUnder = const Value.absent(),
    this.confidenceComputedAtMillis = const Value.absent(),
    this.assertionKind = const Value.absent(),
    this.aboutEvidenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EvidenceEntriesCompanion.insert({
    required String id,
    required String type,
    required int capturedAtMillis,
    required String sensitivity,
    this.sourceKind = const Value.absent(),
    this.sourceLocator = const Value.absent(),
    this.sourceAccountRef = const Value.absent(),
    this.integrity = const Value.absent(),
    this.excerpt = const Value.absent(),
    this.claimKind = const Value.absent(),
    this.claimCounterparty = const Value.absent(),
    this.claimByMillis = const Value.absent(),
    this.claimSourceQuote = const Value.absent(),
    this.producedById = const Value.absent(),
    this.producedByVersion = const Value.absent(),
    this.confidenceValue = const Value.absent(),
    this.confidenceBasis = const Value.absent(),
    this.confidenceMethodId = const Value.absent(),
    this.confidenceMethodVersion = const Value.absent(),
    this.confidenceUnder = const Value.absent(),
    this.confidenceComputedAtMillis = const Value.absent(),
    this.assertionKind = const Value.absent(),
    this.aboutEvidenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        capturedAtMillis = Value(capturedAtMillis),
        sensitivity = Value(sensitivity);
  static Insertable<EvidenceEntry> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<int>? capturedAtMillis,
    Expression<String>? sensitivity,
    Expression<String>? sourceKind,
    Expression<String>? sourceLocator,
    Expression<String>? sourceAccountRef,
    Expression<String>? integrity,
    Expression<String>? excerpt,
    Expression<String>? claimKind,
    Expression<String>? claimCounterparty,
    Expression<int>? claimByMillis,
    Expression<String>? claimSourceQuote,
    Expression<String>? producedById,
    Expression<String>? producedByVersion,
    Expression<double>? confidenceValue,
    Expression<String>? confidenceBasis,
    Expression<String>? confidenceMethodId,
    Expression<String>? confidenceMethodVersion,
    Expression<String>? confidenceUnder,
    Expression<int>? confidenceComputedAtMillis,
    Expression<String>? assertionKind,
    Expression<String>? aboutEvidenceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (capturedAtMillis != null) 'captured_at_millis': capturedAtMillis,
      if (sensitivity != null) 'sensitivity': sensitivity,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (sourceLocator != null) 'source_locator': sourceLocator,
      if (sourceAccountRef != null) 'source_account_ref': sourceAccountRef,
      if (integrity != null) 'integrity': integrity,
      if (excerpt != null) 'excerpt': excerpt,
      if (claimKind != null) 'claim_kind': claimKind,
      if (claimCounterparty != null) 'claim_counterparty': claimCounterparty,
      if (claimByMillis != null) 'claim_by_millis': claimByMillis,
      if (claimSourceQuote != null) 'claim_source_quote': claimSourceQuote,
      if (producedById != null) 'produced_by_id': producedById,
      if (producedByVersion != null) 'produced_by_version': producedByVersion,
      if (confidenceValue != null) 'confidence_value': confidenceValue,
      if (confidenceBasis != null) 'confidence_basis': confidenceBasis,
      if (confidenceMethodId != null)
        'confidence_method_id': confidenceMethodId,
      if (confidenceMethodVersion != null)
        'confidence_method_version': confidenceMethodVersion,
      if (confidenceUnder != null) 'confidence_under': confidenceUnder,
      if (confidenceComputedAtMillis != null)
        'confidence_computed_at_millis': confidenceComputedAtMillis,
      if (assertionKind != null) 'assertion_kind': assertionKind,
      if (aboutEvidenceId != null) 'about_evidence_id': aboutEvidenceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EvidenceEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<int>? capturedAtMillis,
      Value<String>? sensitivity,
      Value<String?>? sourceKind,
      Value<String?>? sourceLocator,
      Value<String?>? sourceAccountRef,
      Value<String?>? integrity,
      Value<String?>? excerpt,
      Value<String?>? claimKind,
      Value<String?>? claimCounterparty,
      Value<int?>? claimByMillis,
      Value<String?>? claimSourceQuote,
      Value<String?>? producedById,
      Value<String?>? producedByVersion,
      Value<double?>? confidenceValue,
      Value<String?>? confidenceBasis,
      Value<String?>? confidenceMethodId,
      Value<String?>? confidenceMethodVersion,
      Value<String?>? confidenceUnder,
      Value<int?>? confidenceComputedAtMillis,
      Value<String?>? assertionKind,
      Value<String?>? aboutEvidenceId,
      Value<int>? rowid}) {
    return EvidenceEntriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      capturedAtMillis: capturedAtMillis ?? this.capturedAtMillis,
      sensitivity: sensitivity ?? this.sensitivity,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceLocator: sourceLocator ?? this.sourceLocator,
      sourceAccountRef: sourceAccountRef ?? this.sourceAccountRef,
      integrity: integrity ?? this.integrity,
      excerpt: excerpt ?? this.excerpt,
      claimKind: claimKind ?? this.claimKind,
      claimCounterparty: claimCounterparty ?? this.claimCounterparty,
      claimByMillis: claimByMillis ?? this.claimByMillis,
      claimSourceQuote: claimSourceQuote ?? this.claimSourceQuote,
      producedById: producedById ?? this.producedById,
      producedByVersion: producedByVersion ?? this.producedByVersion,
      confidenceValue: confidenceValue ?? this.confidenceValue,
      confidenceBasis: confidenceBasis ?? this.confidenceBasis,
      confidenceMethodId: confidenceMethodId ?? this.confidenceMethodId,
      confidenceMethodVersion:
          confidenceMethodVersion ?? this.confidenceMethodVersion,
      confidenceUnder: confidenceUnder ?? this.confidenceUnder,
      confidenceComputedAtMillis:
          confidenceComputedAtMillis ?? this.confidenceComputedAtMillis,
      assertionKind: assertionKind ?? this.assertionKind,
      aboutEvidenceId: aboutEvidenceId ?? this.aboutEvidenceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (capturedAtMillis.present) {
      map['captured_at_millis'] = Variable<int>(capturedAtMillis.value);
    }
    if (sensitivity.present) {
      map['sensitivity'] = Variable<String>(sensitivity.value);
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(sourceKind.value);
    }
    if (sourceLocator.present) {
      map['source_locator'] = Variable<String>(sourceLocator.value);
    }
    if (sourceAccountRef.present) {
      map['source_account_ref'] = Variable<String>(sourceAccountRef.value);
    }
    if (integrity.present) {
      map['integrity'] = Variable<String>(integrity.value);
    }
    if (excerpt.present) {
      map['excerpt'] = Variable<String>(excerpt.value);
    }
    if (claimKind.present) {
      map['claim_kind'] = Variable<String>(claimKind.value);
    }
    if (claimCounterparty.present) {
      map['claim_counterparty'] = Variable<String>(claimCounterparty.value);
    }
    if (claimByMillis.present) {
      map['claim_by_millis'] = Variable<int>(claimByMillis.value);
    }
    if (claimSourceQuote.present) {
      map['claim_source_quote'] = Variable<String>(claimSourceQuote.value);
    }
    if (producedById.present) {
      map['produced_by_id'] = Variable<String>(producedById.value);
    }
    if (producedByVersion.present) {
      map['produced_by_version'] = Variable<String>(producedByVersion.value);
    }
    if (confidenceValue.present) {
      map['confidence_value'] = Variable<double>(confidenceValue.value);
    }
    if (confidenceBasis.present) {
      map['confidence_basis'] = Variable<String>(confidenceBasis.value);
    }
    if (confidenceMethodId.present) {
      map['confidence_method_id'] = Variable<String>(confidenceMethodId.value);
    }
    if (confidenceMethodVersion.present) {
      map['confidence_method_version'] =
          Variable<String>(confidenceMethodVersion.value);
    }
    if (confidenceUnder.present) {
      map['confidence_under'] = Variable<String>(confidenceUnder.value);
    }
    if (confidenceComputedAtMillis.present) {
      map['confidence_computed_at_millis'] =
          Variable<int>(confidenceComputedAtMillis.value);
    }
    if (assertionKind.present) {
      map['assertion_kind'] = Variable<String>(assertionKind.value);
    }
    if (aboutEvidenceId.present) {
      map['about_evidence_id'] = Variable<String>(aboutEvidenceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceEntriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('capturedAtMillis: $capturedAtMillis, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceLocator: $sourceLocator, ')
          ..write('sourceAccountRef: $sourceAccountRef, ')
          ..write('integrity: $integrity, ')
          ..write('excerpt: $excerpt, ')
          ..write('claimKind: $claimKind, ')
          ..write('claimCounterparty: $claimCounterparty, ')
          ..write('claimByMillis: $claimByMillis, ')
          ..write('claimSourceQuote: $claimSourceQuote, ')
          ..write('producedById: $producedById, ')
          ..write('producedByVersion: $producedByVersion, ')
          ..write('confidenceValue: $confidenceValue, ')
          ..write('confidenceBasis: $confidenceBasis, ')
          ..write('confidenceMethodId: $confidenceMethodId, ')
          ..write('confidenceMethodVersion: $confidenceMethodVersion, ')
          ..write('confidenceUnder: $confidenceUnder, ')
          ..write('confidenceComputedAtMillis: $confidenceComputedAtMillis, ')
          ..write('assertionKind: $assertionKind, ')
          ..write('aboutEvidenceId: $aboutEvidenceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoopRecordsTable extends LoopRecords
    with TableInfo<$LoopRecordsTable, LoopRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoopRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _basisEvidenceIdMeta =
      const VerificationMeta('basisEvidenceId');
  @override
  late final GeneratedColumn<String> basisEvidenceId = GeneratedColumn<String>(
      'basis_evidence_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES evidence_entries (id)'));
  static const VerificationMeta _commitmentIdMeta =
      const VerificationMeta('commitmentId');
  @override
  late final GeneratedColumn<String> commitmentId = GeneratedColumn<String>(
      'commitment_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _suggestionIdMeta =
      const VerificationMeta('suggestionId');
  @override
  late final GeneratedColumn<String> suggestionId = GeneratedColumn<String>(
      'suggestion_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _waitingOnMeta =
      const VerificationMeta('waitingOn');
  @override
  late final GeneratedColumn<String> waitingOn = GeneratedColumn<String>(
      'waiting_on', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _waitingSinceMillisMeta =
      const VerificationMeta('waitingSinceMillis');
  @override
  late final GeneratedColumn<int> waitingSinceMillis = GeneratedColumn<int>(
      'waiting_since_millis', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _resolvedAtMillisMeta =
      const VerificationMeta('resolvedAtMillis');
  @override
  late final GeneratedColumn<int> resolvedAtMillis = GeneratedColumn<int>(
      'resolved_at_millis', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _abandonReasonMeta =
      const VerificationMeta('abandonReason');
  @override
  late final GeneratedColumn<String> abandonReason = GeneratedColumn<String>(
      'abandon_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _suppressedUntilMillisMeta =
      const VerificationMeta('suppressedUntilMillis');
  @override
  late final GeneratedColumn<int> suppressedUntilMillis = GeneratedColumn<int>(
      'suppressed_until_millis', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
      'pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("pinned" IN (0, 1))'),
      defaultValue: const Constant<bool>(false));
  static const VerificationMeta _sensitivityMeta =
      const VerificationMeta('sensitivity');
  @override
  late final GeneratedColumn<String> sensitivity = GeneratedColumn<String>(
      'sensitivity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMillisMeta =
      const VerificationMeta('createdAtMillis');
  @override
  late final GeneratedColumn<int> createdAtMillis = GeneratedColumn<int>(
      'created_at_millis', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMillisMeta =
      const VerificationMeta('updatedAtMillis');
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
      'updated_at_millis', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stateChangedAtMillisMeta =
      const VerificationMeta('stateChangedAtMillis');
  @override
  late final GeneratedColumn<int> stateChangedAtMillis = GeneratedColumn<int>(
      'state_changed_at_millis', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _schemaVersionMeta =
      const VerificationMeta('schemaVersion');
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
      'schema_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant<int>(1));
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        state,
        basisEvidenceId,
        commitmentId,
        suggestionId,
        waitingOn,
        waitingSinceMillis,
        resolvedAtMillis,
        abandonReason,
        suppressedUntilMillis,
        pinned,
        sensitivity,
        createdAtMillis,
        updatedAtMillis,
        stateChangedAtMillis,
        schemaVersion,
        revision
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loop_records';
  @override
  VerificationContext validateIntegrity(Insertable<LoopRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('basis_evidence_id')) {
      context.handle(
          _basisEvidenceIdMeta,
          basisEvidenceId.isAcceptableOrUnknown(
              data['basis_evidence_id']!, _basisEvidenceIdMeta));
    } else if (isInserting) {
      context.missing(_basisEvidenceIdMeta);
    }
    if (data.containsKey('commitment_id')) {
      context.handle(
          _commitmentIdMeta,
          commitmentId.isAcceptableOrUnknown(
              data['commitment_id']!, _commitmentIdMeta));
    }
    if (data.containsKey('suggestion_id')) {
      context.handle(
          _suggestionIdMeta,
          suggestionId.isAcceptableOrUnknown(
              data['suggestion_id']!, _suggestionIdMeta));
    }
    if (data.containsKey('waiting_on')) {
      context.handle(_waitingOnMeta,
          waitingOn.isAcceptableOrUnknown(data['waiting_on']!, _waitingOnMeta));
    }
    if (data.containsKey('waiting_since_millis')) {
      context.handle(
          _waitingSinceMillisMeta,
          waitingSinceMillis.isAcceptableOrUnknown(
              data['waiting_since_millis']!, _waitingSinceMillisMeta));
    }
    if (data.containsKey('resolved_at_millis')) {
      context.handle(
          _resolvedAtMillisMeta,
          resolvedAtMillis.isAcceptableOrUnknown(
              data['resolved_at_millis']!, _resolvedAtMillisMeta));
    }
    if (data.containsKey('abandon_reason')) {
      context.handle(
          _abandonReasonMeta,
          abandonReason.isAcceptableOrUnknown(
              data['abandon_reason']!, _abandonReasonMeta));
    }
    if (data.containsKey('suppressed_until_millis')) {
      context.handle(
          _suppressedUntilMillisMeta,
          suppressedUntilMillis.isAcceptableOrUnknown(
              data['suppressed_until_millis']!, _suppressedUntilMillisMeta));
    }
    if (data.containsKey('pinned')) {
      context.handle(_pinnedMeta,
          pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta));
    }
    if (data.containsKey('sensitivity')) {
      context.handle(
          _sensitivityMeta,
          sensitivity.isAcceptableOrUnknown(
              data['sensitivity']!, _sensitivityMeta));
    } else if (isInserting) {
      context.missing(_sensitivityMeta);
    }
    if (data.containsKey('created_at_millis')) {
      context.handle(
          _createdAtMillisMeta,
          createdAtMillis.isAcceptableOrUnknown(
              data['created_at_millis']!, _createdAtMillisMeta));
    } else if (isInserting) {
      context.missing(_createdAtMillisMeta);
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
          _updatedAtMillisMeta,
          updatedAtMillis.isAcceptableOrUnknown(
              data['updated_at_millis']!, _updatedAtMillisMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    if (data.containsKey('state_changed_at_millis')) {
      context.handle(
          _stateChangedAtMillisMeta,
          stateChangedAtMillis.isAcceptableOrUnknown(
              data['state_changed_at_millis']!, _stateChangedAtMillisMeta));
    } else if (isInserting) {
      context.missing(_stateChangedAtMillisMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
          _schemaVersionMeta,
          schemaVersion.isAcceptableOrUnknown(
              data['schema_version']!, _schemaVersionMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoopRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoopRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      basisEvidenceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}basis_evidence_id'])!,
      commitmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commitment_id']),
      suggestionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}suggestion_id']),
      waitingOn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}waiting_on']),
      waitingSinceMillis: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}waiting_since_millis']),
      resolvedAtMillis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}resolved_at_millis']),
      abandonReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}abandon_reason']),
      suppressedUntilMillis: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}suppressed_until_millis']),
      pinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pinned'])!,
      sensitivity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sensitivity'])!,
      createdAtMillis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at_millis'])!,
      updatedAtMillis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_millis'])!,
      stateChangedAtMillis: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}state_changed_at_millis'])!,
      schemaVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schema_version'])!,
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
    );
  }

  @override
  $LoopRecordsTable createAlias(String alias) {
    return $LoopRecordsTable(attachedDatabase, alias);
  }
}

class LoopRecord extends DataClass implements Insertable<LoopRecord> {
  /// The `LoopId.value`.
  final String id;
  final String title;

  /// `LoopState`, by name.
  final String state;

  /// The evidence this loop exists because of. The domain's own invariant
  /// requires it to also appear in [LoopEvidenceLinks] for this loop; that is
  /// enforced by the aggregate's constructor, not restated as a database
  /// constraint SQLite has no direct way to express.
  final String basisEvidenceId;
  final String? commitmentId;
  final String? suggestionId;
  final String? waitingOn;
  final int? waitingSinceMillis;
  final int? resolvedAtMillis;

  /// `AbandonReason`, by name.
  final String? abandonReason;
  final int? suppressedUntilMillis;
  final bool pinned;

  /// `DataSensitivity`, by name.
  final String sensitivity;
  final int createdAtMillis;
  final int updatedAtMillis;
  final int stateChangedAtMillis;
  final int schemaVersion;
  final int revision;
  const LoopRecord(
      {required this.id,
      required this.title,
      required this.state,
      required this.basisEvidenceId,
      this.commitmentId,
      this.suggestionId,
      this.waitingOn,
      this.waitingSinceMillis,
      this.resolvedAtMillis,
      this.abandonReason,
      this.suppressedUntilMillis,
      required this.pinned,
      required this.sensitivity,
      required this.createdAtMillis,
      required this.updatedAtMillis,
      required this.stateChangedAtMillis,
      required this.schemaVersion,
      required this.revision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['state'] = Variable<String>(state);
    map['basis_evidence_id'] = Variable<String>(basisEvidenceId);
    if (!nullToAbsent || commitmentId != null) {
      map['commitment_id'] = Variable<String>(commitmentId);
    }
    if (!nullToAbsent || suggestionId != null) {
      map['suggestion_id'] = Variable<String>(suggestionId);
    }
    if (!nullToAbsent || waitingOn != null) {
      map['waiting_on'] = Variable<String>(waitingOn);
    }
    if (!nullToAbsent || waitingSinceMillis != null) {
      map['waiting_since_millis'] = Variable<int>(waitingSinceMillis);
    }
    if (!nullToAbsent || resolvedAtMillis != null) {
      map['resolved_at_millis'] = Variable<int>(resolvedAtMillis);
    }
    if (!nullToAbsent || abandonReason != null) {
      map['abandon_reason'] = Variable<String>(abandonReason);
    }
    if (!nullToAbsent || suppressedUntilMillis != null) {
      map['suppressed_until_millis'] = Variable<int>(suppressedUntilMillis);
    }
    map['pinned'] = Variable<bool>(pinned);
    map['sensitivity'] = Variable<String>(sensitivity);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    map['state_changed_at_millis'] = Variable<int>(stateChangedAtMillis);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  LoopRecordsCompanion toCompanion(bool nullToAbsent) {
    return LoopRecordsCompanion(
      id: Value(id),
      title: Value(title),
      state: Value(state),
      basisEvidenceId: Value(basisEvidenceId),
      commitmentId: commitmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(commitmentId),
      suggestionId: suggestionId == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestionId),
      waitingOn: waitingOn == null && nullToAbsent
          ? const Value.absent()
          : Value(waitingOn),
      waitingSinceMillis: waitingSinceMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(waitingSinceMillis),
      resolvedAtMillis: resolvedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAtMillis),
      abandonReason: abandonReason == null && nullToAbsent
          ? const Value.absent()
          : Value(abandonReason),
      suppressedUntilMillis: suppressedUntilMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(suppressedUntilMillis),
      pinned: Value(pinned),
      sensitivity: Value(sensitivity),
      createdAtMillis: Value(createdAtMillis),
      updatedAtMillis: Value(updatedAtMillis),
      stateChangedAtMillis: Value(stateChangedAtMillis),
      schemaVersion: Value(schemaVersion),
      revision: Value(revision),
    );
  }

  factory LoopRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoopRecord(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      state: serializer.fromJson<String>(json['state']),
      basisEvidenceId: serializer.fromJson<String>(json['basisEvidenceId']),
      commitmentId: serializer.fromJson<String?>(json['commitmentId']),
      suggestionId: serializer.fromJson<String?>(json['suggestionId']),
      waitingOn: serializer.fromJson<String?>(json['waitingOn']),
      waitingSinceMillis: serializer.fromJson<int?>(json['waitingSinceMillis']),
      resolvedAtMillis: serializer.fromJson<int?>(json['resolvedAtMillis']),
      abandonReason: serializer.fromJson<String?>(json['abandonReason']),
      suppressedUntilMillis:
          serializer.fromJson<int?>(json['suppressedUntilMillis']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      sensitivity: serializer.fromJson<String>(json['sensitivity']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
      stateChangedAtMillis:
          serializer.fromJson<int>(json['stateChangedAtMillis']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'state': serializer.toJson<String>(state),
      'basisEvidenceId': serializer.toJson<String>(basisEvidenceId),
      'commitmentId': serializer.toJson<String?>(commitmentId),
      'suggestionId': serializer.toJson<String?>(suggestionId),
      'waitingOn': serializer.toJson<String?>(waitingOn),
      'waitingSinceMillis': serializer.toJson<int?>(waitingSinceMillis),
      'resolvedAtMillis': serializer.toJson<int?>(resolvedAtMillis),
      'abandonReason': serializer.toJson<String?>(abandonReason),
      'suppressedUntilMillis': serializer.toJson<int?>(suppressedUntilMillis),
      'pinned': serializer.toJson<bool>(pinned),
      'sensitivity': serializer.toJson<String>(sensitivity),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
      'stateChangedAtMillis': serializer.toJson<int>(stateChangedAtMillis),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'revision': serializer.toJson<int>(revision),
    };
  }

  LoopRecord copyWith(
          {String? id,
          String? title,
          String? state,
          String? basisEvidenceId,
          Value<String?> commitmentId = const Value.absent(),
          Value<String?> suggestionId = const Value.absent(),
          Value<String?> waitingOn = const Value.absent(),
          Value<int?> waitingSinceMillis = const Value.absent(),
          Value<int?> resolvedAtMillis = const Value.absent(),
          Value<String?> abandonReason = const Value.absent(),
          Value<int?> suppressedUntilMillis = const Value.absent(),
          bool? pinned,
          String? sensitivity,
          int? createdAtMillis,
          int? updatedAtMillis,
          int? stateChangedAtMillis,
          int? schemaVersion,
          int? revision}) =>
      LoopRecord(
        id: id ?? this.id,
        title: title ?? this.title,
        state: state ?? this.state,
        basisEvidenceId: basisEvidenceId ?? this.basisEvidenceId,
        commitmentId:
            commitmentId.present ? commitmentId.value : this.commitmentId,
        suggestionId:
            suggestionId.present ? suggestionId.value : this.suggestionId,
        waitingOn: waitingOn.present ? waitingOn.value : this.waitingOn,
        waitingSinceMillis: waitingSinceMillis.present
            ? waitingSinceMillis.value
            : this.waitingSinceMillis,
        resolvedAtMillis: resolvedAtMillis.present
            ? resolvedAtMillis.value
            : this.resolvedAtMillis,
        abandonReason:
            abandonReason.present ? abandonReason.value : this.abandonReason,
        suppressedUntilMillis: suppressedUntilMillis.present
            ? suppressedUntilMillis.value
            : this.suppressedUntilMillis,
        pinned: pinned ?? this.pinned,
        sensitivity: sensitivity ?? this.sensitivity,
        createdAtMillis: createdAtMillis ?? this.createdAtMillis,
        updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
        stateChangedAtMillis: stateChangedAtMillis ?? this.stateChangedAtMillis,
        schemaVersion: schemaVersion ?? this.schemaVersion,
        revision: revision ?? this.revision,
      );
  LoopRecord copyWithCompanion(LoopRecordsCompanion data) {
    return LoopRecord(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      state: data.state.present ? data.state.value : this.state,
      basisEvidenceId: data.basisEvidenceId.present
          ? data.basisEvidenceId.value
          : this.basisEvidenceId,
      commitmentId: data.commitmentId.present
          ? data.commitmentId.value
          : this.commitmentId,
      suggestionId: data.suggestionId.present
          ? data.suggestionId.value
          : this.suggestionId,
      waitingOn: data.waitingOn.present ? data.waitingOn.value : this.waitingOn,
      waitingSinceMillis: data.waitingSinceMillis.present
          ? data.waitingSinceMillis.value
          : this.waitingSinceMillis,
      resolvedAtMillis: data.resolvedAtMillis.present
          ? data.resolvedAtMillis.value
          : this.resolvedAtMillis,
      abandonReason: data.abandonReason.present
          ? data.abandonReason.value
          : this.abandonReason,
      suppressedUntilMillis: data.suppressedUntilMillis.present
          ? data.suppressedUntilMillis.value
          : this.suppressedUntilMillis,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      sensitivity:
          data.sensitivity.present ? data.sensitivity.value : this.sensitivity,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
      stateChangedAtMillis: data.stateChangedAtMillis.present
          ? data.stateChangedAtMillis.value
          : this.stateChangedAtMillis,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoopRecord(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('state: $state, ')
          ..write('basisEvidenceId: $basisEvidenceId, ')
          ..write('commitmentId: $commitmentId, ')
          ..write('suggestionId: $suggestionId, ')
          ..write('waitingOn: $waitingOn, ')
          ..write('waitingSinceMillis: $waitingSinceMillis, ')
          ..write('resolvedAtMillis: $resolvedAtMillis, ')
          ..write('abandonReason: $abandonReason, ')
          ..write('suppressedUntilMillis: $suppressedUntilMillis, ')
          ..write('pinned: $pinned, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('stateChangedAtMillis: $stateChangedAtMillis, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      state,
      basisEvidenceId,
      commitmentId,
      suggestionId,
      waitingOn,
      waitingSinceMillis,
      resolvedAtMillis,
      abandonReason,
      suppressedUntilMillis,
      pinned,
      sensitivity,
      createdAtMillis,
      updatedAtMillis,
      stateChangedAtMillis,
      schemaVersion,
      revision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoopRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.state == this.state &&
          other.basisEvidenceId == this.basisEvidenceId &&
          other.commitmentId == this.commitmentId &&
          other.suggestionId == this.suggestionId &&
          other.waitingOn == this.waitingOn &&
          other.waitingSinceMillis == this.waitingSinceMillis &&
          other.resolvedAtMillis == this.resolvedAtMillis &&
          other.abandonReason == this.abandonReason &&
          other.suppressedUntilMillis == this.suppressedUntilMillis &&
          other.pinned == this.pinned &&
          other.sensitivity == this.sensitivity &&
          other.createdAtMillis == this.createdAtMillis &&
          other.updatedAtMillis == this.updatedAtMillis &&
          other.stateChangedAtMillis == this.stateChangedAtMillis &&
          other.schemaVersion == this.schemaVersion &&
          other.revision == this.revision);
}

class LoopRecordsCompanion extends UpdateCompanion<LoopRecord> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> state;
  final Value<String> basisEvidenceId;
  final Value<String?> commitmentId;
  final Value<String?> suggestionId;
  final Value<String?> waitingOn;
  final Value<int?> waitingSinceMillis;
  final Value<int?> resolvedAtMillis;
  final Value<String?> abandonReason;
  final Value<int?> suppressedUntilMillis;
  final Value<bool> pinned;
  final Value<String> sensitivity;
  final Value<int> createdAtMillis;
  final Value<int> updatedAtMillis;
  final Value<int> stateChangedAtMillis;
  final Value<int> schemaVersion;
  final Value<int> revision;
  final Value<int> rowid;
  const LoopRecordsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.state = const Value.absent(),
    this.basisEvidenceId = const Value.absent(),
    this.commitmentId = const Value.absent(),
    this.suggestionId = const Value.absent(),
    this.waitingOn = const Value.absent(),
    this.waitingSinceMillis = const Value.absent(),
    this.resolvedAtMillis = const Value.absent(),
    this.abandonReason = const Value.absent(),
    this.suppressedUntilMillis = const Value.absent(),
    this.pinned = const Value.absent(),
    this.sensitivity = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.stateChangedAtMillis = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoopRecordsCompanion.insert({
    required String id,
    required String title,
    required String state,
    required String basisEvidenceId,
    this.commitmentId = const Value.absent(),
    this.suggestionId = const Value.absent(),
    this.waitingOn = const Value.absent(),
    this.waitingSinceMillis = const Value.absent(),
    this.resolvedAtMillis = const Value.absent(),
    this.abandonReason = const Value.absent(),
    this.suppressedUntilMillis = const Value.absent(),
    this.pinned = const Value.absent(),
    required String sensitivity,
    required int createdAtMillis,
    required int updatedAtMillis,
    required int stateChangedAtMillis,
    this.schemaVersion = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        state = Value(state),
        basisEvidenceId = Value(basisEvidenceId),
        sensitivity = Value(sensitivity),
        createdAtMillis = Value(createdAtMillis),
        updatedAtMillis = Value(updatedAtMillis),
        stateChangedAtMillis = Value(stateChangedAtMillis),
        revision = Value(revision);
  static Insertable<LoopRecord> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? state,
    Expression<String>? basisEvidenceId,
    Expression<String>? commitmentId,
    Expression<String>? suggestionId,
    Expression<String>? waitingOn,
    Expression<int>? waitingSinceMillis,
    Expression<int>? resolvedAtMillis,
    Expression<String>? abandonReason,
    Expression<int>? suppressedUntilMillis,
    Expression<bool>? pinned,
    Expression<String>? sensitivity,
    Expression<int>? createdAtMillis,
    Expression<int>? updatedAtMillis,
    Expression<int>? stateChangedAtMillis,
    Expression<int>? schemaVersion,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (state != null) 'state': state,
      if (basisEvidenceId != null) 'basis_evidence_id': basisEvidenceId,
      if (commitmentId != null) 'commitment_id': commitmentId,
      if (suggestionId != null) 'suggestion_id': suggestionId,
      if (waitingOn != null) 'waiting_on': waitingOn,
      if (waitingSinceMillis != null)
        'waiting_since_millis': waitingSinceMillis,
      if (resolvedAtMillis != null) 'resolved_at_millis': resolvedAtMillis,
      if (abandonReason != null) 'abandon_reason': abandonReason,
      if (suppressedUntilMillis != null)
        'suppressed_until_millis': suppressedUntilMillis,
      if (pinned != null) 'pinned': pinned,
      if (sensitivity != null) 'sensitivity': sensitivity,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (stateChangedAtMillis != null)
        'state_changed_at_millis': stateChangedAtMillis,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoopRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? state,
      Value<String>? basisEvidenceId,
      Value<String?>? commitmentId,
      Value<String?>? suggestionId,
      Value<String?>? waitingOn,
      Value<int?>? waitingSinceMillis,
      Value<int?>? resolvedAtMillis,
      Value<String?>? abandonReason,
      Value<int?>? suppressedUntilMillis,
      Value<bool>? pinned,
      Value<String>? sensitivity,
      Value<int>? createdAtMillis,
      Value<int>? updatedAtMillis,
      Value<int>? stateChangedAtMillis,
      Value<int>? schemaVersion,
      Value<int>? revision,
      Value<int>? rowid}) {
    return LoopRecordsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      state: state ?? this.state,
      basisEvidenceId: basisEvidenceId ?? this.basisEvidenceId,
      commitmentId: commitmentId ?? this.commitmentId,
      suggestionId: suggestionId ?? this.suggestionId,
      waitingOn: waitingOn ?? this.waitingOn,
      waitingSinceMillis: waitingSinceMillis ?? this.waitingSinceMillis,
      resolvedAtMillis: resolvedAtMillis ?? this.resolvedAtMillis,
      abandonReason: abandonReason ?? this.abandonReason,
      suppressedUntilMillis:
          suppressedUntilMillis ?? this.suppressedUntilMillis,
      pinned: pinned ?? this.pinned,
      sensitivity: sensitivity ?? this.sensitivity,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      stateChangedAtMillis: stateChangedAtMillis ?? this.stateChangedAtMillis,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (basisEvidenceId.present) {
      map['basis_evidence_id'] = Variable<String>(basisEvidenceId.value);
    }
    if (commitmentId.present) {
      map['commitment_id'] = Variable<String>(commitmentId.value);
    }
    if (suggestionId.present) {
      map['suggestion_id'] = Variable<String>(suggestionId.value);
    }
    if (waitingOn.present) {
      map['waiting_on'] = Variable<String>(waitingOn.value);
    }
    if (waitingSinceMillis.present) {
      map['waiting_since_millis'] = Variable<int>(waitingSinceMillis.value);
    }
    if (resolvedAtMillis.present) {
      map['resolved_at_millis'] = Variable<int>(resolvedAtMillis.value);
    }
    if (abandonReason.present) {
      map['abandon_reason'] = Variable<String>(abandonReason.value);
    }
    if (suppressedUntilMillis.present) {
      map['suppressed_until_millis'] =
          Variable<int>(suppressedUntilMillis.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (sensitivity.present) {
      map['sensitivity'] = Variable<String>(sensitivity.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (stateChangedAtMillis.present) {
      map['state_changed_at_millis'] =
          Variable<int>(stateChangedAtMillis.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoopRecordsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('state: $state, ')
          ..write('basisEvidenceId: $basisEvidenceId, ')
          ..write('commitmentId: $commitmentId, ')
          ..write('suggestionId: $suggestionId, ')
          ..write('waitingOn: $waitingOn, ')
          ..write('waitingSinceMillis: $waitingSinceMillis, ')
          ..write('resolvedAtMillis: $resolvedAtMillis, ')
          ..write('abandonReason: $abandonReason, ')
          ..write('suppressedUntilMillis: $suppressedUntilMillis, ')
          ..write('pinned: $pinned, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('stateChangedAtMillis: $stateChangedAtMillis, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoopEventRecordsTable extends LoopEventRecords
    with TableInfo<$LoopEventRecordsTable, LoopEventRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoopEventRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _loopIdMeta = const VerificationMeta('loopId');
  @override
  late final GeneratedColumn<String> loopId = GeneratedColumn<String>(
      'loop_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES loop_records (id)'));
  static const VerificationMeta _sequenceMeta =
      const VerificationMeta('sequence');
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
      'sequence', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actorMeta = const VerificationMeta('actor');
  @override
  late final GeneratedColumn<String> actor = GeneratedColumn<String>(
      'actor', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _atMillisMeta =
      const VerificationMeta('atMillis');
  @override
  late final GeneratedColumn<int> atMillis = GeneratedColumn<int>(
      'at_millis', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fromStateMeta =
      const VerificationMeta('fromState');
  @override
  late final GeneratedColumn<String> fromState = GeneratedColumn<String>(
      'from_state', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _toStateMeta =
      const VerificationMeta('toState');
  @override
  late final GeneratedColumn<String> toState = GeneratedColumn<String>(
      'to_state', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _abandonReasonMeta =
      const VerificationMeta('abandonReason');
  @override
  late final GeneratedColumn<String> abandonReason = GeneratedColumn<String>(
      'abandon_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _evidenceIdMeta =
      const VerificationMeta('evidenceId');
  @override
  late final GeneratedColumn<String> evidenceId = GeneratedColumn<String>(
      'evidence_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES evidence_entries (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        loopId,
        sequence,
        kind,
        actor,
        atMillis,
        fromState,
        toState,
        abandonReason,
        evidenceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loop_event_records';
  @override
  VerificationContext validateIntegrity(Insertable<LoopEventRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('loop_id')) {
      context.handle(_loopIdMeta,
          loopId.isAcceptableOrUnknown(data['loop_id']!, _loopIdMeta));
    } else if (isInserting) {
      context.missing(_loopIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(_sequenceMeta,
          sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta));
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('actor')) {
      context.handle(
          _actorMeta, actor.isAcceptableOrUnknown(data['actor']!, _actorMeta));
    } else if (isInserting) {
      context.missing(_actorMeta);
    }
    if (data.containsKey('at_millis')) {
      context.handle(_atMillisMeta,
          atMillis.isAcceptableOrUnknown(data['at_millis']!, _atMillisMeta));
    } else if (isInserting) {
      context.missing(_atMillisMeta);
    }
    if (data.containsKey('from_state')) {
      context.handle(_fromStateMeta,
          fromState.isAcceptableOrUnknown(data['from_state']!, _fromStateMeta));
    }
    if (data.containsKey('to_state')) {
      context.handle(_toStateMeta,
          toState.isAcceptableOrUnknown(data['to_state']!, _toStateMeta));
    }
    if (data.containsKey('abandon_reason')) {
      context.handle(
          _abandonReasonMeta,
          abandonReason.isAcceptableOrUnknown(
              data['abandon_reason']!, _abandonReasonMeta));
    }
    if (data.containsKey('evidence_id')) {
      context.handle(
          _evidenceIdMeta,
          evidenceId.isAcceptableOrUnknown(
              data['evidence_id']!, _evidenceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {loopId, sequence};
  @override
  LoopEventRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoopEventRecord(
      loopId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loop_id'])!,
      sequence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      actor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actor'])!,
      atMillis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}at_millis'])!,
      fromState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_state']),
      toState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_state']),
      abandonReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}abandon_reason']),
      evidenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}evidence_id']),
    );
  }

  @override
  $LoopEventRecordsTable createAlias(String alias) {
    return $LoopEventRecordsTable(attachedDatabase, alias);
  }
}

class LoopEventRecord extends DataClass implements Insertable<LoopEventRecord> {
  final String loopId;

  /// Equals the loop's `revision` after this event. Monotonic per loop; see
  /// [primaryKey] for how uniqueness of the pair is enforced.
  final int sequence;

  /// `LoopEventKind`, by name.
  final String kind;

  /// `TransitionActor`, by name.
  final String actor;
  final int atMillis;

  /// `LoopState`, by name. Null unless [kind] is `stateChanged`.
  final String? fromState;
  final String? toState;

  /// `AbandonReason`, by name. Set only when this event abandoned the loop.
  final String? abandonReason;

  /// Set when this event is about a specific piece of evidence.
  final String? evidenceId;
  const LoopEventRecord(
      {required this.loopId,
      required this.sequence,
      required this.kind,
      required this.actor,
      required this.atMillis,
      this.fromState,
      this.toState,
      this.abandonReason,
      this.evidenceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['loop_id'] = Variable<String>(loopId);
    map['sequence'] = Variable<int>(sequence);
    map['kind'] = Variable<String>(kind);
    map['actor'] = Variable<String>(actor);
    map['at_millis'] = Variable<int>(atMillis);
    if (!nullToAbsent || fromState != null) {
      map['from_state'] = Variable<String>(fromState);
    }
    if (!nullToAbsent || toState != null) {
      map['to_state'] = Variable<String>(toState);
    }
    if (!nullToAbsent || abandonReason != null) {
      map['abandon_reason'] = Variable<String>(abandonReason);
    }
    if (!nullToAbsent || evidenceId != null) {
      map['evidence_id'] = Variable<String>(evidenceId);
    }
    return map;
  }

  LoopEventRecordsCompanion toCompanion(bool nullToAbsent) {
    return LoopEventRecordsCompanion(
      loopId: Value(loopId),
      sequence: Value(sequence),
      kind: Value(kind),
      actor: Value(actor),
      atMillis: Value(atMillis),
      fromState: fromState == null && nullToAbsent
          ? const Value.absent()
          : Value(fromState),
      toState: toState == null && nullToAbsent
          ? const Value.absent()
          : Value(toState),
      abandonReason: abandonReason == null && nullToAbsent
          ? const Value.absent()
          : Value(abandonReason),
      evidenceId: evidenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(evidenceId),
    );
  }

  factory LoopEventRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoopEventRecord(
      loopId: serializer.fromJson<String>(json['loopId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      kind: serializer.fromJson<String>(json['kind']),
      actor: serializer.fromJson<String>(json['actor']),
      atMillis: serializer.fromJson<int>(json['atMillis']),
      fromState: serializer.fromJson<String?>(json['fromState']),
      toState: serializer.fromJson<String?>(json['toState']),
      abandonReason: serializer.fromJson<String?>(json['abandonReason']),
      evidenceId: serializer.fromJson<String?>(json['evidenceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'loopId': serializer.toJson<String>(loopId),
      'sequence': serializer.toJson<int>(sequence),
      'kind': serializer.toJson<String>(kind),
      'actor': serializer.toJson<String>(actor),
      'atMillis': serializer.toJson<int>(atMillis),
      'fromState': serializer.toJson<String?>(fromState),
      'toState': serializer.toJson<String?>(toState),
      'abandonReason': serializer.toJson<String?>(abandonReason),
      'evidenceId': serializer.toJson<String?>(evidenceId),
    };
  }

  LoopEventRecord copyWith(
          {String? loopId,
          int? sequence,
          String? kind,
          String? actor,
          int? atMillis,
          Value<String?> fromState = const Value.absent(),
          Value<String?> toState = const Value.absent(),
          Value<String?> abandonReason = const Value.absent(),
          Value<String?> evidenceId = const Value.absent()}) =>
      LoopEventRecord(
        loopId: loopId ?? this.loopId,
        sequence: sequence ?? this.sequence,
        kind: kind ?? this.kind,
        actor: actor ?? this.actor,
        atMillis: atMillis ?? this.atMillis,
        fromState: fromState.present ? fromState.value : this.fromState,
        toState: toState.present ? toState.value : this.toState,
        abandonReason:
            abandonReason.present ? abandonReason.value : this.abandonReason,
        evidenceId: evidenceId.present ? evidenceId.value : this.evidenceId,
      );
  LoopEventRecord copyWithCompanion(LoopEventRecordsCompanion data) {
    return LoopEventRecord(
      loopId: data.loopId.present ? data.loopId.value : this.loopId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      kind: data.kind.present ? data.kind.value : this.kind,
      actor: data.actor.present ? data.actor.value : this.actor,
      atMillis: data.atMillis.present ? data.atMillis.value : this.atMillis,
      fromState: data.fromState.present ? data.fromState.value : this.fromState,
      toState: data.toState.present ? data.toState.value : this.toState,
      abandonReason: data.abandonReason.present
          ? data.abandonReason.value
          : this.abandonReason,
      evidenceId:
          data.evidenceId.present ? data.evidenceId.value : this.evidenceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoopEventRecord(')
          ..write('loopId: $loopId, ')
          ..write('sequence: $sequence, ')
          ..write('kind: $kind, ')
          ..write('actor: $actor, ')
          ..write('atMillis: $atMillis, ')
          ..write('fromState: $fromState, ')
          ..write('toState: $toState, ')
          ..write('abandonReason: $abandonReason, ')
          ..write('evidenceId: $evidenceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(loopId, sequence, kind, actor, atMillis,
      fromState, toState, abandonReason, evidenceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoopEventRecord &&
          other.loopId == this.loopId &&
          other.sequence == this.sequence &&
          other.kind == this.kind &&
          other.actor == this.actor &&
          other.atMillis == this.atMillis &&
          other.fromState == this.fromState &&
          other.toState == this.toState &&
          other.abandonReason == this.abandonReason &&
          other.evidenceId == this.evidenceId);
}

class LoopEventRecordsCompanion extends UpdateCompanion<LoopEventRecord> {
  final Value<String> loopId;
  final Value<int> sequence;
  final Value<String> kind;
  final Value<String> actor;
  final Value<int> atMillis;
  final Value<String?> fromState;
  final Value<String?> toState;
  final Value<String?> abandonReason;
  final Value<String?> evidenceId;
  final Value<int> rowid;
  const LoopEventRecordsCompanion({
    this.loopId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.kind = const Value.absent(),
    this.actor = const Value.absent(),
    this.atMillis = const Value.absent(),
    this.fromState = const Value.absent(),
    this.toState = const Value.absent(),
    this.abandonReason = const Value.absent(),
    this.evidenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoopEventRecordsCompanion.insert({
    required String loopId,
    required int sequence,
    required String kind,
    required String actor,
    required int atMillis,
    this.fromState = const Value.absent(),
    this.toState = const Value.absent(),
    this.abandonReason = const Value.absent(),
    this.evidenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : loopId = Value(loopId),
        sequence = Value(sequence),
        kind = Value(kind),
        actor = Value(actor),
        atMillis = Value(atMillis);
  static Insertable<LoopEventRecord> custom({
    Expression<String>? loopId,
    Expression<int>? sequence,
    Expression<String>? kind,
    Expression<String>? actor,
    Expression<int>? atMillis,
    Expression<String>? fromState,
    Expression<String>? toState,
    Expression<String>? abandonReason,
    Expression<String>? evidenceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (loopId != null) 'loop_id': loopId,
      if (sequence != null) 'sequence': sequence,
      if (kind != null) 'kind': kind,
      if (actor != null) 'actor': actor,
      if (atMillis != null) 'at_millis': atMillis,
      if (fromState != null) 'from_state': fromState,
      if (toState != null) 'to_state': toState,
      if (abandonReason != null) 'abandon_reason': abandonReason,
      if (evidenceId != null) 'evidence_id': evidenceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoopEventRecordsCompanion copyWith(
      {Value<String>? loopId,
      Value<int>? sequence,
      Value<String>? kind,
      Value<String>? actor,
      Value<int>? atMillis,
      Value<String?>? fromState,
      Value<String?>? toState,
      Value<String?>? abandonReason,
      Value<String?>? evidenceId,
      Value<int>? rowid}) {
    return LoopEventRecordsCompanion(
      loopId: loopId ?? this.loopId,
      sequence: sequence ?? this.sequence,
      kind: kind ?? this.kind,
      actor: actor ?? this.actor,
      atMillis: atMillis ?? this.atMillis,
      fromState: fromState ?? this.fromState,
      toState: toState ?? this.toState,
      abandonReason: abandonReason ?? this.abandonReason,
      evidenceId: evidenceId ?? this.evidenceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (loopId.present) {
      map['loop_id'] = Variable<String>(loopId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (actor.present) {
      map['actor'] = Variable<String>(actor.value);
    }
    if (atMillis.present) {
      map['at_millis'] = Variable<int>(atMillis.value);
    }
    if (fromState.present) {
      map['from_state'] = Variable<String>(fromState.value);
    }
    if (toState.present) {
      map['to_state'] = Variable<String>(toState.value);
    }
    if (abandonReason.present) {
      map['abandon_reason'] = Variable<String>(abandonReason.value);
    }
    if (evidenceId.present) {
      map['evidence_id'] = Variable<String>(evidenceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoopEventRecordsCompanion(')
          ..write('loopId: $loopId, ')
          ..write('sequence: $sequence, ')
          ..write('kind: $kind, ')
          ..write('actor: $actor, ')
          ..write('atMillis: $atMillis, ')
          ..write('fromState: $fromState, ')
          ..write('toState: $toState, ')
          ..write('abandonReason: $abandonReason, ')
          ..write('evidenceId: $evidenceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoopEvidenceLinksTable extends LoopEvidenceLinks
    with TableInfo<$LoopEvidenceLinksTable, LoopEvidenceLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoopEvidenceLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _loopIdMeta = const VerificationMeta('loopId');
  @override
  late final GeneratedColumn<String> loopId = GeneratedColumn<String>(
      'loop_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES loop_records (id)'));
  static const VerificationMeta _evidenceIdMeta =
      const VerificationMeta('evidenceId');
  @override
  late final GeneratedColumn<String> evidenceId = GeneratedColumn<String>(
      'evidence_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES evidence_entries (id)'));
  @override
  List<GeneratedColumn> get $columns => [loopId, evidenceId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loop_evidence_links';
  @override
  VerificationContext validateIntegrity(Insertable<LoopEvidenceLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('loop_id')) {
      context.handle(_loopIdMeta,
          loopId.isAcceptableOrUnknown(data['loop_id']!, _loopIdMeta));
    } else if (isInserting) {
      context.missing(_loopIdMeta);
    }
    if (data.containsKey('evidence_id')) {
      context.handle(
          _evidenceIdMeta,
          evidenceId.isAcceptableOrUnknown(
              data['evidence_id']!, _evidenceIdMeta));
    } else if (isInserting) {
      context.missing(_evidenceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {loopId, evidenceId};
  @override
  LoopEvidenceLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoopEvidenceLink(
      loopId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loop_id'])!,
      evidenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}evidence_id'])!,
    );
  }

  @override
  $LoopEvidenceLinksTable createAlias(String alias) {
    return $LoopEvidenceLinksTable(attachedDatabase, alias);
  }
}

class LoopEvidenceLink extends DataClass
    implements Insertable<LoopEvidenceLink> {
  final String loopId;
  final String evidenceId;
  const LoopEvidenceLink({required this.loopId, required this.evidenceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['loop_id'] = Variable<String>(loopId);
    map['evidence_id'] = Variable<String>(evidenceId);
    return map;
  }

  LoopEvidenceLinksCompanion toCompanion(bool nullToAbsent) {
    return LoopEvidenceLinksCompanion(
      loopId: Value(loopId),
      evidenceId: Value(evidenceId),
    );
  }

  factory LoopEvidenceLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoopEvidenceLink(
      loopId: serializer.fromJson<String>(json['loopId']),
      evidenceId: serializer.fromJson<String>(json['evidenceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'loopId': serializer.toJson<String>(loopId),
      'evidenceId': serializer.toJson<String>(evidenceId),
    };
  }

  LoopEvidenceLink copyWith({String? loopId, String? evidenceId}) =>
      LoopEvidenceLink(
        loopId: loopId ?? this.loopId,
        evidenceId: evidenceId ?? this.evidenceId,
      );
  LoopEvidenceLink copyWithCompanion(LoopEvidenceLinksCompanion data) {
    return LoopEvidenceLink(
      loopId: data.loopId.present ? data.loopId.value : this.loopId,
      evidenceId:
          data.evidenceId.present ? data.evidenceId.value : this.evidenceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoopEvidenceLink(')
          ..write('loopId: $loopId, ')
          ..write('evidenceId: $evidenceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(loopId, evidenceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoopEvidenceLink &&
          other.loopId == this.loopId &&
          other.evidenceId == this.evidenceId);
}

class LoopEvidenceLinksCompanion extends UpdateCompanion<LoopEvidenceLink> {
  final Value<String> loopId;
  final Value<String> evidenceId;
  final Value<int> rowid;
  const LoopEvidenceLinksCompanion({
    this.loopId = const Value.absent(),
    this.evidenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoopEvidenceLinksCompanion.insert({
    required String loopId,
    required String evidenceId,
    this.rowid = const Value.absent(),
  })  : loopId = Value(loopId),
        evidenceId = Value(evidenceId);
  static Insertable<LoopEvidenceLink> custom({
    Expression<String>? loopId,
    Expression<String>? evidenceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (loopId != null) 'loop_id': loopId,
      if (evidenceId != null) 'evidence_id': evidenceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoopEvidenceLinksCompanion copyWith(
      {Value<String>? loopId, Value<String>? evidenceId, Value<int>? rowid}) {
    return LoopEvidenceLinksCompanion(
      loopId: loopId ?? this.loopId,
      evidenceId: evidenceId ?? this.evidenceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (loopId.present) {
      map['loop_id'] = Variable<String>(loopId.value);
    }
    if (evidenceId.present) {
      map['evidence_id'] = Variable<String>(evidenceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoopEvidenceLinksCompanion(')
          ..write('loopId: $loopId, ')
          ..write('evidenceId: $evidenceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InferenceDerivationsTable extends InferenceDerivations
    with TableInfo<$InferenceDerivationsTable, InferenceDerivation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InferenceDerivationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _inferenceIdMeta =
      const VerificationMeta('inferenceId');
  @override
  late final GeneratedColumn<String> inferenceId = GeneratedColumn<String>(
      'inference_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES evidence_entries (id)'));
  static const VerificationMeta _sourceEvidenceIdMeta =
      const VerificationMeta('sourceEvidenceId');
  @override
  late final GeneratedColumn<String> sourceEvidenceId = GeneratedColumn<String>(
      'source_evidence_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES evidence_entries (id)'));
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [inferenceId, sourceEvidenceId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inference_derivations';
  @override
  VerificationContext validateIntegrity(
      Insertable<InferenceDerivation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('inference_id')) {
      context.handle(
          _inferenceIdMeta,
          inferenceId.isAcceptableOrUnknown(
              data['inference_id']!, _inferenceIdMeta));
    } else if (isInserting) {
      context.missing(_inferenceIdMeta);
    }
    if (data.containsKey('source_evidence_id')) {
      context.handle(
          _sourceEvidenceIdMeta,
          sourceEvidenceId.isAcceptableOrUnknown(
              data['source_evidence_id']!, _sourceEvidenceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceEvidenceIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {inferenceId, sourceEvidenceId};
  @override
  InferenceDerivation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InferenceDerivation(
      inferenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}inference_id'])!,
      sourceEvidenceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_evidence_id'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $InferenceDerivationsTable createAlias(String alias) {
    return $InferenceDerivationsTable(attachedDatabase, alias);
  }
}

class InferenceDerivation extends DataClass
    implements Insertable<InferenceDerivation> {
  /// The `Inference` row this derivation belongs to.
  final String inferenceId;

  /// One piece of evidence the inference above was derived from.
  final String sourceEvidenceId;
  final int position;
  const InferenceDerivation(
      {required this.inferenceId,
      required this.sourceEvidenceId,
      required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['inference_id'] = Variable<String>(inferenceId);
    map['source_evidence_id'] = Variable<String>(sourceEvidenceId);
    map['position'] = Variable<int>(position);
    return map;
  }

  InferenceDerivationsCompanion toCompanion(bool nullToAbsent) {
    return InferenceDerivationsCompanion(
      inferenceId: Value(inferenceId),
      sourceEvidenceId: Value(sourceEvidenceId),
      position: Value(position),
    );
  }

  factory InferenceDerivation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InferenceDerivation(
      inferenceId: serializer.fromJson<String>(json['inferenceId']),
      sourceEvidenceId: serializer.fromJson<String>(json['sourceEvidenceId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'inferenceId': serializer.toJson<String>(inferenceId),
      'sourceEvidenceId': serializer.toJson<String>(sourceEvidenceId),
      'position': serializer.toJson<int>(position),
    };
  }

  InferenceDerivation copyWith(
          {String? inferenceId, String? sourceEvidenceId, int? position}) =>
      InferenceDerivation(
        inferenceId: inferenceId ?? this.inferenceId,
        sourceEvidenceId: sourceEvidenceId ?? this.sourceEvidenceId,
        position: position ?? this.position,
      );
  InferenceDerivation copyWithCompanion(InferenceDerivationsCompanion data) {
    return InferenceDerivation(
      inferenceId:
          data.inferenceId.present ? data.inferenceId.value : this.inferenceId,
      sourceEvidenceId: data.sourceEvidenceId.present
          ? data.sourceEvidenceId.value
          : this.sourceEvidenceId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InferenceDerivation(')
          ..write('inferenceId: $inferenceId, ')
          ..write('sourceEvidenceId: $sourceEvidenceId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(inferenceId, sourceEvidenceId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InferenceDerivation &&
          other.inferenceId == this.inferenceId &&
          other.sourceEvidenceId == this.sourceEvidenceId &&
          other.position == this.position);
}

class InferenceDerivationsCompanion
    extends UpdateCompanion<InferenceDerivation> {
  final Value<String> inferenceId;
  final Value<String> sourceEvidenceId;
  final Value<int> position;
  final Value<int> rowid;
  const InferenceDerivationsCompanion({
    this.inferenceId = const Value.absent(),
    this.sourceEvidenceId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InferenceDerivationsCompanion.insert({
    required String inferenceId,
    required String sourceEvidenceId,
    required int position,
    this.rowid = const Value.absent(),
  })  : inferenceId = Value(inferenceId),
        sourceEvidenceId = Value(sourceEvidenceId),
        position = Value(position);
  static Insertable<InferenceDerivation> custom({
    Expression<String>? inferenceId,
    Expression<String>? sourceEvidenceId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (inferenceId != null) 'inference_id': inferenceId,
      if (sourceEvidenceId != null) 'source_evidence_id': sourceEvidenceId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InferenceDerivationsCompanion copyWith(
      {Value<String>? inferenceId,
      Value<String>? sourceEvidenceId,
      Value<int>? position,
      Value<int>? rowid}) {
    return InferenceDerivationsCompanion(
      inferenceId: inferenceId ?? this.inferenceId,
      sourceEvidenceId: sourceEvidenceId ?? this.sourceEvidenceId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (inferenceId.present) {
      map['inference_id'] = Variable<String>(inferenceId.value);
    }
    if (sourceEvidenceId.present) {
      map['source_evidence_id'] = Variable<String>(sourceEvidenceId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InferenceDerivationsCompanion(')
          ..write('inferenceId: $inferenceId, ')
          ..write('sourceEvidenceId: $sourceEvidenceId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LoopDatabase extends GeneratedDatabase {
  _$LoopDatabase(QueryExecutor e) : super(e);
  $LoopDatabaseManager get managers => $LoopDatabaseManager(this);
  late final $EvidenceEntriesTable evidenceEntries =
      $EvidenceEntriesTable(this);
  late final $LoopRecordsTable loopRecords = $LoopRecordsTable(this);
  late final $LoopEventRecordsTable loopEventRecords =
      $LoopEventRecordsTable(this);
  late final $LoopEvidenceLinksTable loopEvidenceLinks =
      $LoopEvidenceLinksTable(this);
  late final $InferenceDerivationsTable inferenceDerivations =
      $InferenceDerivationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        evidenceEntries,
        loopRecords,
        loopEventRecords,
        loopEvidenceLinks,
        inferenceDerivations
      ];
}

typedef $$EvidenceEntriesTableCreateCompanionBuilder = EvidenceEntriesCompanion
    Function({
  required String id,
  required String type,
  required int capturedAtMillis,
  required String sensitivity,
  Value<String?> sourceKind,
  Value<String?> sourceLocator,
  Value<String?> sourceAccountRef,
  Value<String?> integrity,
  Value<String?> excerpt,
  Value<String?> claimKind,
  Value<String?> claimCounterparty,
  Value<int?> claimByMillis,
  Value<String?> claimSourceQuote,
  Value<String?> producedById,
  Value<String?> producedByVersion,
  Value<double?> confidenceValue,
  Value<String?> confidenceBasis,
  Value<String?> confidenceMethodId,
  Value<String?> confidenceMethodVersion,
  Value<String?> confidenceUnder,
  Value<int?> confidenceComputedAtMillis,
  Value<String?> assertionKind,
  Value<String?> aboutEvidenceId,
  Value<int> rowid,
});
typedef $$EvidenceEntriesTableUpdateCompanionBuilder = EvidenceEntriesCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<int> capturedAtMillis,
  Value<String> sensitivity,
  Value<String?> sourceKind,
  Value<String?> sourceLocator,
  Value<String?> sourceAccountRef,
  Value<String?> integrity,
  Value<String?> excerpt,
  Value<String?> claimKind,
  Value<String?> claimCounterparty,
  Value<int?> claimByMillis,
  Value<String?> claimSourceQuote,
  Value<String?> producedById,
  Value<String?> producedByVersion,
  Value<double?> confidenceValue,
  Value<String?> confidenceBasis,
  Value<String?> confidenceMethodId,
  Value<String?> confidenceMethodVersion,
  Value<String?> confidenceUnder,
  Value<int?> confidenceComputedAtMillis,
  Value<String?> assertionKind,
  Value<String?> aboutEvidenceId,
  Value<int> rowid,
});

final class $$EvidenceEntriesTableReferences extends BaseReferences<
    _$LoopDatabase, $EvidenceEntriesTable, EvidenceEntry> {
  $$EvidenceEntriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $EvidenceEntriesTable _aboutEvidenceIdTable(_$LoopDatabase db) => db
      .evidenceEntries
      .createAlias('evidence_entries__about_evidence_id__evidence_entries__id');

  $$EvidenceEntriesTableProcessedTableManager? get aboutEvidenceId {
    final $_column = $_itemColumn<String>('about_evidence_id');
    if ($_column == null) return null;
    final manager =
        $$EvidenceEntriesTableTableManager($_db, $_db.evidenceEntries)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_aboutEvidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$LoopRecordsTable, List<LoopRecord>>
      _loopRecordsRefsTable(_$LoopDatabase db) => MultiTypedResultKey.fromTable(
          db.loopRecords,
          aliasName: 'evidence_entries__id__loop_records__basis_evidence_id');

  $$LoopRecordsTableProcessedTableManager get loopRecordsRefs {
    final manager = $$LoopRecordsTableTableManager($_db, $_db.loopRecords)
        .filter(
            (f) => f.basisEvidenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_loopRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LoopEventRecordsTable, List<LoopEventRecord>>
      _loopEventRecordsRefsTable(_$LoopDatabase db) =>
          MultiTypedResultKey.fromTable(db.loopEventRecords,
              aliasName:
                  'evidence_entries__id__loop_event_records__evidence_id');

  $$LoopEventRecordsTableProcessedTableManager get loopEventRecordsRefs {
    final manager = $$LoopEventRecordsTableTableManager(
            $_db, $_db.loopEventRecords)
        .filter((f) => f.evidenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_loopEventRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LoopEvidenceLinksTable, List<LoopEvidenceLink>>
      _loopEvidenceLinksRefsTable(_$LoopDatabase db) =>
          MultiTypedResultKey.fromTable(db.loopEvidenceLinks,
              aliasName:
                  'evidence_entries__id__loop_evidence_links__evidence_id');

  $$LoopEvidenceLinksTableProcessedTableManager get loopEvidenceLinksRefs {
    final manager = $$LoopEvidenceLinksTableTableManager(
            $_db, $_db.loopEvidenceLinks)
        .filter((f) => f.evidenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_loopEvidenceLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$EvidenceEntriesTableFilterComposer
    extends Composer<_$LoopDatabase, $EvidenceEntriesTable> {
  $$EvidenceEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get capturedAtMillis => $composableBuilder(
      column: $table.capturedAtMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sensitivity => $composableBuilder(
      column: $table.sensitivity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceKind => $composableBuilder(
      column: $table.sourceKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceLocator => $composableBuilder(
      column: $table.sourceLocator, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceAccountRef => $composableBuilder(
      column: $table.sourceAccountRef,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get integrity => $composableBuilder(
      column: $table.integrity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get excerpt => $composableBuilder(
      column: $table.excerpt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get claimKind => $composableBuilder(
      column: $table.claimKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get claimCounterparty => $composableBuilder(
      column: $table.claimCounterparty,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get claimByMillis => $composableBuilder(
      column: $table.claimByMillis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get claimSourceQuote => $composableBuilder(
      column: $table.claimSourceQuote,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get producedById => $composableBuilder(
      column: $table.producedById, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get producedByVersion => $composableBuilder(
      column: $table.producedByVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidenceValue => $composableBuilder(
      column: $table.confidenceValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confidenceBasis => $composableBuilder(
      column: $table.confidenceBasis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confidenceMethodId => $composableBuilder(
      column: $table.confidenceMethodId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confidenceMethodVersion => $composableBuilder(
      column: $table.confidenceMethodVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confidenceUnder => $composableBuilder(
      column: $table.confidenceUnder,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get confidenceComputedAtMillis => $composableBuilder(
      column: $table.confidenceComputedAtMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assertionKind => $composableBuilder(
      column: $table.assertionKind, builder: (column) => ColumnFilters(column));

  $$EvidenceEntriesTableFilterComposer get aboutEvidenceId {
    final $$EvidenceEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.aboutEvidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableFilterComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> loopRecordsRefs(
      Expression<bool> Function($$LoopRecordsTableFilterComposer f) f) {
    final $$LoopRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loopRecords,
        getReferencedColumn: (t) => t.basisEvidenceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopRecordsTableFilterComposer(
              $db: $db,
              $table: $db.loopRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> loopEventRecordsRefs(
      Expression<bool> Function($$LoopEventRecordsTableFilterComposer f) f) {
    final $$LoopEventRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loopEventRecords,
        getReferencedColumn: (t) => t.evidenceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopEventRecordsTableFilterComposer(
              $db: $db,
              $table: $db.loopEventRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> loopEvidenceLinksRefs(
      Expression<bool> Function($$LoopEvidenceLinksTableFilterComposer f) f) {
    final $$LoopEvidenceLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loopEvidenceLinks,
        getReferencedColumn: (t) => t.evidenceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopEvidenceLinksTableFilterComposer(
              $db: $db,
              $table: $db.loopEvidenceLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EvidenceEntriesTableOrderingComposer
    extends Composer<_$LoopDatabase, $EvidenceEntriesTable> {
  $$EvidenceEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get capturedAtMillis => $composableBuilder(
      column: $table.capturedAtMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sensitivity => $composableBuilder(
      column: $table.sensitivity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceKind => $composableBuilder(
      column: $table.sourceKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceLocator => $composableBuilder(
      column: $table.sourceLocator,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceAccountRef => $composableBuilder(
      column: $table.sourceAccountRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get integrity => $composableBuilder(
      column: $table.integrity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get excerpt => $composableBuilder(
      column: $table.excerpt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get claimKind => $composableBuilder(
      column: $table.claimKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get claimCounterparty => $composableBuilder(
      column: $table.claimCounterparty,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get claimByMillis => $composableBuilder(
      column: $table.claimByMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get claimSourceQuote => $composableBuilder(
      column: $table.claimSourceQuote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get producedById => $composableBuilder(
      column: $table.producedById,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get producedByVersion => $composableBuilder(
      column: $table.producedByVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidenceValue => $composableBuilder(
      column: $table.confidenceValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidenceBasis => $composableBuilder(
      column: $table.confidenceBasis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidenceMethodId => $composableBuilder(
      column: $table.confidenceMethodId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidenceMethodVersion => $composableBuilder(
      column: $table.confidenceMethodVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidenceUnder => $composableBuilder(
      column: $table.confidenceUnder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get confidenceComputedAtMillis => $composableBuilder(
      column: $table.confidenceComputedAtMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assertionKind => $composableBuilder(
      column: $table.assertionKind,
      builder: (column) => ColumnOrderings(column));

  $$EvidenceEntriesTableOrderingComposer get aboutEvidenceId {
    final $$EvidenceEntriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.aboutEvidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableOrderingComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EvidenceEntriesTableAnnotationComposer
    extends Composer<_$LoopDatabase, $EvidenceEntriesTable> {
  $$EvidenceEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get capturedAtMillis => $composableBuilder(
      column: $table.capturedAtMillis, builder: (column) => column);

  GeneratedColumn<String> get sensitivity => $composableBuilder(
      column: $table.sensitivity, builder: (column) => column);

  GeneratedColumn<String> get sourceKind => $composableBuilder(
      column: $table.sourceKind, builder: (column) => column);

  GeneratedColumn<String> get sourceLocator => $composableBuilder(
      column: $table.sourceLocator, builder: (column) => column);

  GeneratedColumn<String> get sourceAccountRef => $composableBuilder(
      column: $table.sourceAccountRef, builder: (column) => column);

  GeneratedColumn<String> get integrity =>
      $composableBuilder(column: $table.integrity, builder: (column) => column);

  GeneratedColumn<String> get excerpt =>
      $composableBuilder(column: $table.excerpt, builder: (column) => column);

  GeneratedColumn<String> get claimKind =>
      $composableBuilder(column: $table.claimKind, builder: (column) => column);

  GeneratedColumn<String> get claimCounterparty => $composableBuilder(
      column: $table.claimCounterparty, builder: (column) => column);

  GeneratedColumn<int> get claimByMillis => $composableBuilder(
      column: $table.claimByMillis, builder: (column) => column);

  GeneratedColumn<String> get claimSourceQuote => $composableBuilder(
      column: $table.claimSourceQuote, builder: (column) => column);

  GeneratedColumn<String> get producedById => $composableBuilder(
      column: $table.producedById, builder: (column) => column);

  GeneratedColumn<String> get producedByVersion => $composableBuilder(
      column: $table.producedByVersion, builder: (column) => column);

  GeneratedColumn<double> get confidenceValue => $composableBuilder(
      column: $table.confidenceValue, builder: (column) => column);

  GeneratedColumn<String> get confidenceBasis => $composableBuilder(
      column: $table.confidenceBasis, builder: (column) => column);

  GeneratedColumn<String> get confidenceMethodId => $composableBuilder(
      column: $table.confidenceMethodId, builder: (column) => column);

  GeneratedColumn<String> get confidenceMethodVersion => $composableBuilder(
      column: $table.confidenceMethodVersion, builder: (column) => column);

  GeneratedColumn<String> get confidenceUnder => $composableBuilder(
      column: $table.confidenceUnder, builder: (column) => column);

  GeneratedColumn<int> get confidenceComputedAtMillis => $composableBuilder(
      column: $table.confidenceComputedAtMillis, builder: (column) => column);

  GeneratedColumn<String> get assertionKind => $composableBuilder(
      column: $table.assertionKind, builder: (column) => column);

  $$EvidenceEntriesTableAnnotationComposer get aboutEvidenceId {
    final $$EvidenceEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.aboutEvidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> loopRecordsRefs<T extends Object>(
      Expression<T> Function($$LoopRecordsTableAnnotationComposer a) f) {
    final $$LoopRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loopRecords,
        getReferencedColumn: (t) => t.basisEvidenceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.loopRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> loopEventRecordsRefs<T extends Object>(
      Expression<T> Function($$LoopEventRecordsTableAnnotationComposer a) f) {
    final $$LoopEventRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loopEventRecords,
        getReferencedColumn: (t) => t.evidenceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopEventRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.loopEventRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> loopEvidenceLinksRefs<T extends Object>(
      Expression<T> Function($$LoopEvidenceLinksTableAnnotationComposer a) f) {
    final $$LoopEvidenceLinksTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.loopEvidenceLinks,
            getReferencedColumn: (t) => t.evidenceId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LoopEvidenceLinksTableAnnotationComposer(
                  $db: $db,
                  $table: $db.loopEvidenceLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$EvidenceEntriesTableTableManager extends RootTableManager<
    _$LoopDatabase,
    $EvidenceEntriesTable,
    EvidenceEntry,
    $$EvidenceEntriesTableFilterComposer,
    $$EvidenceEntriesTableOrderingComposer,
    $$EvidenceEntriesTableAnnotationComposer,
    $$EvidenceEntriesTableCreateCompanionBuilder,
    $$EvidenceEntriesTableUpdateCompanionBuilder,
    (EvidenceEntry, $$EvidenceEntriesTableReferences),
    EvidenceEntry,
    PrefetchHooks Function(
        {bool aboutEvidenceId,
        bool loopRecordsRefs,
        bool loopEventRecordsRefs,
        bool loopEvidenceLinksRefs})> {
  $$EvidenceEntriesTableTableManager(
      _$LoopDatabase db, $EvidenceEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidenceEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidenceEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidenceEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> capturedAtMillis = const Value.absent(),
            Value<String> sensitivity = const Value.absent(),
            Value<String?> sourceKind = const Value.absent(),
            Value<String?> sourceLocator = const Value.absent(),
            Value<String?> sourceAccountRef = const Value.absent(),
            Value<String?> integrity = const Value.absent(),
            Value<String?> excerpt = const Value.absent(),
            Value<String?> claimKind = const Value.absent(),
            Value<String?> claimCounterparty = const Value.absent(),
            Value<int?> claimByMillis = const Value.absent(),
            Value<String?> claimSourceQuote = const Value.absent(),
            Value<String?> producedById = const Value.absent(),
            Value<String?> producedByVersion = const Value.absent(),
            Value<double?> confidenceValue = const Value.absent(),
            Value<String?> confidenceBasis = const Value.absent(),
            Value<String?> confidenceMethodId = const Value.absent(),
            Value<String?> confidenceMethodVersion = const Value.absent(),
            Value<String?> confidenceUnder = const Value.absent(),
            Value<int?> confidenceComputedAtMillis = const Value.absent(),
            Value<String?> assertionKind = const Value.absent(),
            Value<String?> aboutEvidenceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EvidenceEntriesCompanion(
            id: id,
            type: type,
            capturedAtMillis: capturedAtMillis,
            sensitivity: sensitivity,
            sourceKind: sourceKind,
            sourceLocator: sourceLocator,
            sourceAccountRef: sourceAccountRef,
            integrity: integrity,
            excerpt: excerpt,
            claimKind: claimKind,
            claimCounterparty: claimCounterparty,
            claimByMillis: claimByMillis,
            claimSourceQuote: claimSourceQuote,
            producedById: producedById,
            producedByVersion: producedByVersion,
            confidenceValue: confidenceValue,
            confidenceBasis: confidenceBasis,
            confidenceMethodId: confidenceMethodId,
            confidenceMethodVersion: confidenceMethodVersion,
            confidenceUnder: confidenceUnder,
            confidenceComputedAtMillis: confidenceComputedAtMillis,
            assertionKind: assertionKind,
            aboutEvidenceId: aboutEvidenceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required int capturedAtMillis,
            required String sensitivity,
            Value<String?> sourceKind = const Value.absent(),
            Value<String?> sourceLocator = const Value.absent(),
            Value<String?> sourceAccountRef = const Value.absent(),
            Value<String?> integrity = const Value.absent(),
            Value<String?> excerpt = const Value.absent(),
            Value<String?> claimKind = const Value.absent(),
            Value<String?> claimCounterparty = const Value.absent(),
            Value<int?> claimByMillis = const Value.absent(),
            Value<String?> claimSourceQuote = const Value.absent(),
            Value<String?> producedById = const Value.absent(),
            Value<String?> producedByVersion = const Value.absent(),
            Value<double?> confidenceValue = const Value.absent(),
            Value<String?> confidenceBasis = const Value.absent(),
            Value<String?> confidenceMethodId = const Value.absent(),
            Value<String?> confidenceMethodVersion = const Value.absent(),
            Value<String?> confidenceUnder = const Value.absent(),
            Value<int?> confidenceComputedAtMillis = const Value.absent(),
            Value<String?> assertionKind = const Value.absent(),
            Value<String?> aboutEvidenceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EvidenceEntriesCompanion.insert(
            id: id,
            type: type,
            capturedAtMillis: capturedAtMillis,
            sensitivity: sensitivity,
            sourceKind: sourceKind,
            sourceLocator: sourceLocator,
            sourceAccountRef: sourceAccountRef,
            integrity: integrity,
            excerpt: excerpt,
            claimKind: claimKind,
            claimCounterparty: claimCounterparty,
            claimByMillis: claimByMillis,
            claimSourceQuote: claimSourceQuote,
            producedById: producedById,
            producedByVersion: producedByVersion,
            confidenceValue: confidenceValue,
            confidenceBasis: confidenceBasis,
            confidenceMethodId: confidenceMethodId,
            confidenceMethodVersion: confidenceMethodVersion,
            confidenceUnder: confidenceUnder,
            confidenceComputedAtMillis: confidenceComputedAtMillis,
            assertionKind: assertionKind,
            aboutEvidenceId: aboutEvidenceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$EvidenceEntriesTable, EvidenceEntry>(table),
                    $$EvidenceEntriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {aboutEvidenceId = false,
              loopRecordsRefs = false,
              loopEventRecordsRefs = false,
              loopEvidenceLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (loopRecordsRefs) db.loopRecords,
                if (loopEventRecordsRefs) db.loopEventRecords,
                if (loopEvidenceLinksRefs) db.loopEvidenceLinks
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (aboutEvidenceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.aboutEvidenceId,
                    referencedTable: $$EvidenceEntriesTableReferences
                        ._aboutEvidenceIdTable(db),
                    referencedColumn: $$EvidenceEntriesTableReferences
                        ._aboutEvidenceIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (loopRecordsRefs)
                    await $_getPrefetchedData<EvidenceEntry,
                            $EvidenceEntriesTable, LoopRecord>(
                        currentTable: table,
                        referencedTable: $$EvidenceEntriesTableReferences
                            ._loopRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EvidenceEntriesTableReferences(db, table, p0)
                                .loopRecordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.basisEvidenceId == item.id),
                        typedResults: items),
                  if (loopEventRecordsRefs)
                    await $_getPrefetchedData<EvidenceEntry,
                            $EvidenceEntriesTable, LoopEventRecord>(
                        currentTable: table,
                        referencedTable: $$EvidenceEntriesTableReferences
                            ._loopEventRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EvidenceEntriesTableReferences(db, table, p0)
                                .loopEventRecordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.evidenceId == item.id),
                        typedResults: items),
                  if (loopEvidenceLinksRefs)
                    await $_getPrefetchedData<EvidenceEntry,
                            $EvidenceEntriesTable, LoopEvidenceLink>(
                        currentTable: table,
                        referencedTable: $$EvidenceEntriesTableReferences
                            ._loopEvidenceLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EvidenceEntriesTableReferences(db, table, p0)
                                .loopEvidenceLinksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.evidenceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$EvidenceEntriesTableProcessedTableManager = ProcessedTableManager<
    _$LoopDatabase,
    $EvidenceEntriesTable,
    EvidenceEntry,
    $$EvidenceEntriesTableFilterComposer,
    $$EvidenceEntriesTableOrderingComposer,
    $$EvidenceEntriesTableAnnotationComposer,
    $$EvidenceEntriesTableCreateCompanionBuilder,
    $$EvidenceEntriesTableUpdateCompanionBuilder,
    (EvidenceEntry, $$EvidenceEntriesTableReferences),
    EvidenceEntry,
    PrefetchHooks Function(
        {bool aboutEvidenceId,
        bool loopRecordsRefs,
        bool loopEventRecordsRefs,
        bool loopEvidenceLinksRefs})>;
typedef $$LoopRecordsTableCreateCompanionBuilder = LoopRecordsCompanion
    Function({
  required String id,
  required String title,
  required String state,
  required String basisEvidenceId,
  Value<String?> commitmentId,
  Value<String?> suggestionId,
  Value<String?> waitingOn,
  Value<int?> waitingSinceMillis,
  Value<int?> resolvedAtMillis,
  Value<String?> abandonReason,
  Value<int?> suppressedUntilMillis,
  Value<bool> pinned,
  required String sensitivity,
  required int createdAtMillis,
  required int updatedAtMillis,
  required int stateChangedAtMillis,
  Value<int> schemaVersion,
  required int revision,
  Value<int> rowid,
});
typedef $$LoopRecordsTableUpdateCompanionBuilder = LoopRecordsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> state,
  Value<String> basisEvidenceId,
  Value<String?> commitmentId,
  Value<String?> suggestionId,
  Value<String?> waitingOn,
  Value<int?> waitingSinceMillis,
  Value<int?> resolvedAtMillis,
  Value<String?> abandonReason,
  Value<int?> suppressedUntilMillis,
  Value<bool> pinned,
  Value<String> sensitivity,
  Value<int> createdAtMillis,
  Value<int> updatedAtMillis,
  Value<int> stateChangedAtMillis,
  Value<int> schemaVersion,
  Value<int> revision,
  Value<int> rowid,
});

final class $$LoopRecordsTableReferences
    extends BaseReferences<_$LoopDatabase, $LoopRecordsTable, LoopRecord> {
  $$LoopRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EvidenceEntriesTable _basisEvidenceIdTable(_$LoopDatabase db) =>
      db.evidenceEntries
          .createAlias('loop_records__basis_evidence_id__evidence_entries__id');

  $$EvidenceEntriesTableProcessedTableManager get basisEvidenceId {
    final $_column = $_itemColumn<String>('basis_evidence_id')!;

    final manager =
        $$EvidenceEntriesTableTableManager($_db, $_db.evidenceEntries)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_basisEvidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$LoopEventRecordsTable, List<LoopEventRecord>>
      _loopEventRecordsRefsTable(_$LoopDatabase db) =>
          MultiTypedResultKey.fromTable(db.loopEventRecords,
              aliasName: 'loop_records__id__loop_event_records__loop_id');

  $$LoopEventRecordsTableProcessedTableManager get loopEventRecordsRefs {
    final manager =
        $$LoopEventRecordsTableTableManager($_db, $_db.loopEventRecords)
            .filter((f) => f.loopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_loopEventRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LoopEvidenceLinksTable, List<LoopEvidenceLink>>
      _loopEvidenceLinksRefsTable(_$LoopDatabase db) =>
          MultiTypedResultKey.fromTable(db.loopEvidenceLinks,
              aliasName: 'loop_records__id__loop_evidence_links__loop_id');

  $$LoopEvidenceLinksTableProcessedTableManager get loopEvidenceLinksRefs {
    final manager =
        $$LoopEvidenceLinksTableTableManager($_db, $_db.loopEvidenceLinks)
            .filter((f) => f.loopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_loopEvidenceLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LoopRecordsTableFilterComposer
    extends Composer<_$LoopDatabase, $LoopRecordsTable> {
  $$LoopRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commitmentId => $composableBuilder(
      column: $table.commitmentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestionId => $composableBuilder(
      column: $table.suggestionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get waitingOn => $composableBuilder(
      column: $table.waitingOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get waitingSinceMillis => $composableBuilder(
      column: $table.waitingSinceMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get resolvedAtMillis => $composableBuilder(
      column: $table.resolvedAtMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get abandonReason => $composableBuilder(
      column: $table.abandonReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get suppressedUntilMillis => $composableBuilder(
      column: $table.suppressedUntilMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pinned => $composableBuilder(
      column: $table.pinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sensitivity => $composableBuilder(
      column: $table.sensitivity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAtMillis => $composableBuilder(
      column: $table.createdAtMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
      column: $table.updatedAtMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stateChangedAtMillis => $composableBuilder(
      column: $table.stateChangedAtMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  $$EvidenceEntriesTableFilterComposer get basisEvidenceId {
    final $$EvidenceEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.basisEvidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableFilterComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> loopEventRecordsRefs(
      Expression<bool> Function($$LoopEventRecordsTableFilterComposer f) f) {
    final $$LoopEventRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loopEventRecords,
        getReferencedColumn: (t) => t.loopId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopEventRecordsTableFilterComposer(
              $db: $db,
              $table: $db.loopEventRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> loopEvidenceLinksRefs(
      Expression<bool> Function($$LoopEvidenceLinksTableFilterComposer f) f) {
    final $$LoopEvidenceLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loopEvidenceLinks,
        getReferencedColumn: (t) => t.loopId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopEvidenceLinksTableFilterComposer(
              $db: $db,
              $table: $db.loopEvidenceLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LoopRecordsTableOrderingComposer
    extends Composer<_$LoopDatabase, $LoopRecordsTable> {
  $$LoopRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commitmentId => $composableBuilder(
      column: $table.commitmentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestionId => $composableBuilder(
      column: $table.suggestionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get waitingOn => $composableBuilder(
      column: $table.waitingOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get waitingSinceMillis => $composableBuilder(
      column: $table.waitingSinceMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get resolvedAtMillis => $composableBuilder(
      column: $table.resolvedAtMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get abandonReason => $composableBuilder(
      column: $table.abandonReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get suppressedUntilMillis => $composableBuilder(
      column: $table.suppressedUntilMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pinned => $composableBuilder(
      column: $table.pinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sensitivity => $composableBuilder(
      column: $table.sensitivity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAtMillis => $composableBuilder(
      column: $table.createdAtMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
      column: $table.updatedAtMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stateChangedAtMillis => $composableBuilder(
      column: $table.stateChangedAtMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  $$EvidenceEntriesTableOrderingComposer get basisEvidenceId {
    final $$EvidenceEntriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.basisEvidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableOrderingComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoopRecordsTableAnnotationComposer
    extends Composer<_$LoopDatabase, $LoopRecordsTable> {
  $$LoopRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get commitmentId => $composableBuilder(
      column: $table.commitmentId, builder: (column) => column);

  GeneratedColumn<String> get suggestionId => $composableBuilder(
      column: $table.suggestionId, builder: (column) => column);

  GeneratedColumn<String> get waitingOn =>
      $composableBuilder(column: $table.waitingOn, builder: (column) => column);

  GeneratedColumn<int> get waitingSinceMillis => $composableBuilder(
      column: $table.waitingSinceMillis, builder: (column) => column);

  GeneratedColumn<int> get resolvedAtMillis => $composableBuilder(
      column: $table.resolvedAtMillis, builder: (column) => column);

  GeneratedColumn<String> get abandonReason => $composableBuilder(
      column: $table.abandonReason, builder: (column) => column);

  GeneratedColumn<int> get suppressedUntilMillis => $composableBuilder(
      column: $table.suppressedUntilMillis, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<String> get sensitivity => $composableBuilder(
      column: $table.sensitivity, builder: (column) => column);

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
      column: $table.createdAtMillis, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
      column: $table.updatedAtMillis, builder: (column) => column);

  GeneratedColumn<int> get stateChangedAtMillis => $composableBuilder(
      column: $table.stateChangedAtMillis, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  $$EvidenceEntriesTableAnnotationComposer get basisEvidenceId {
    final $$EvidenceEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.basisEvidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> loopEventRecordsRefs<T extends Object>(
      Expression<T> Function($$LoopEventRecordsTableAnnotationComposer a) f) {
    final $$LoopEventRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loopEventRecords,
        getReferencedColumn: (t) => t.loopId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopEventRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.loopEventRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> loopEvidenceLinksRefs<T extends Object>(
      Expression<T> Function($$LoopEvidenceLinksTableAnnotationComposer a) f) {
    final $$LoopEvidenceLinksTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.loopEvidenceLinks,
            getReferencedColumn: (t) => t.loopId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LoopEvidenceLinksTableAnnotationComposer(
                  $db: $db,
                  $table: $db.loopEvidenceLinks,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$LoopRecordsTableTableManager extends RootTableManager<
    _$LoopDatabase,
    $LoopRecordsTable,
    LoopRecord,
    $$LoopRecordsTableFilterComposer,
    $$LoopRecordsTableOrderingComposer,
    $$LoopRecordsTableAnnotationComposer,
    $$LoopRecordsTableCreateCompanionBuilder,
    $$LoopRecordsTableUpdateCompanionBuilder,
    (LoopRecord, $$LoopRecordsTableReferences),
    LoopRecord,
    PrefetchHooks Function(
        {bool basisEvidenceId,
        bool loopEventRecordsRefs,
        bool loopEvidenceLinksRefs})> {
  $$LoopRecordsTableTableManager(_$LoopDatabase db, $LoopRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoopRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoopRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoopRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<String> basisEvidenceId = const Value.absent(),
            Value<String?> commitmentId = const Value.absent(),
            Value<String?> suggestionId = const Value.absent(),
            Value<String?> waitingOn = const Value.absent(),
            Value<int?> waitingSinceMillis = const Value.absent(),
            Value<int?> resolvedAtMillis = const Value.absent(),
            Value<String?> abandonReason = const Value.absent(),
            Value<int?> suppressedUntilMillis = const Value.absent(),
            Value<bool> pinned = const Value.absent(),
            Value<String> sensitivity = const Value.absent(),
            Value<int> createdAtMillis = const Value.absent(),
            Value<int> updatedAtMillis = const Value.absent(),
            Value<int> stateChangedAtMillis = const Value.absent(),
            Value<int> schemaVersion = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoopRecordsCompanion(
            id: id,
            title: title,
            state: state,
            basisEvidenceId: basisEvidenceId,
            commitmentId: commitmentId,
            suggestionId: suggestionId,
            waitingOn: waitingOn,
            waitingSinceMillis: waitingSinceMillis,
            resolvedAtMillis: resolvedAtMillis,
            abandonReason: abandonReason,
            suppressedUntilMillis: suppressedUntilMillis,
            pinned: pinned,
            sensitivity: sensitivity,
            createdAtMillis: createdAtMillis,
            updatedAtMillis: updatedAtMillis,
            stateChangedAtMillis: stateChangedAtMillis,
            schemaVersion: schemaVersion,
            revision: revision,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String state,
            required String basisEvidenceId,
            Value<String?> commitmentId = const Value.absent(),
            Value<String?> suggestionId = const Value.absent(),
            Value<String?> waitingOn = const Value.absent(),
            Value<int?> waitingSinceMillis = const Value.absent(),
            Value<int?> resolvedAtMillis = const Value.absent(),
            Value<String?> abandonReason = const Value.absent(),
            Value<int?> suppressedUntilMillis = const Value.absent(),
            Value<bool> pinned = const Value.absent(),
            required String sensitivity,
            required int createdAtMillis,
            required int updatedAtMillis,
            required int stateChangedAtMillis,
            Value<int> schemaVersion = const Value.absent(),
            required int revision,
            Value<int> rowid = const Value.absent(),
          }) =>
              LoopRecordsCompanion.insert(
            id: id,
            title: title,
            state: state,
            basisEvidenceId: basisEvidenceId,
            commitmentId: commitmentId,
            suggestionId: suggestionId,
            waitingOn: waitingOn,
            waitingSinceMillis: waitingSinceMillis,
            resolvedAtMillis: resolvedAtMillis,
            abandonReason: abandonReason,
            suppressedUntilMillis: suppressedUntilMillis,
            pinned: pinned,
            sensitivity: sensitivity,
            createdAtMillis: createdAtMillis,
            updatedAtMillis: updatedAtMillis,
            stateChangedAtMillis: stateChangedAtMillis,
            schemaVersion: schemaVersion,
            revision: revision,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LoopRecordsTable, LoopRecord>(table),
                    $$LoopRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {basisEvidenceId = false,
              loopEventRecordsRefs = false,
              loopEvidenceLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (loopEventRecordsRefs) db.loopEventRecords,
                if (loopEvidenceLinksRefs) db.loopEvidenceLinks
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (basisEvidenceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.basisEvidenceId,
                    referencedTable:
                        $$LoopRecordsTableReferences._basisEvidenceIdTable(db),
                    referencedColumn: $$LoopRecordsTableReferences
                        ._basisEvidenceIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (loopEventRecordsRefs)
                    await $_getPrefetchedData<LoopRecord, $LoopRecordsTable,
                            LoopEventRecord>(
                        currentTable: table,
                        referencedTable: $$LoopRecordsTableReferences
                            ._loopEventRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LoopRecordsTableReferences(db, table, p0)
                                .loopEventRecordsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.loopId == item.id),
                        typedResults: items),
                  if (loopEvidenceLinksRefs)
                    await $_getPrefetchedData<LoopRecord, $LoopRecordsTable,
                            LoopEvidenceLink>(
                        currentTable: table,
                        referencedTable: $$LoopRecordsTableReferences
                            ._loopEvidenceLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LoopRecordsTableReferences(db, table, p0)
                                .loopEvidenceLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.loopId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LoopRecordsTableProcessedTableManager = ProcessedTableManager<
    _$LoopDatabase,
    $LoopRecordsTable,
    LoopRecord,
    $$LoopRecordsTableFilterComposer,
    $$LoopRecordsTableOrderingComposer,
    $$LoopRecordsTableAnnotationComposer,
    $$LoopRecordsTableCreateCompanionBuilder,
    $$LoopRecordsTableUpdateCompanionBuilder,
    (LoopRecord, $$LoopRecordsTableReferences),
    LoopRecord,
    PrefetchHooks Function(
        {bool basisEvidenceId,
        bool loopEventRecordsRefs,
        bool loopEvidenceLinksRefs})>;
typedef $$LoopEventRecordsTableCreateCompanionBuilder
    = LoopEventRecordsCompanion Function({
  required String loopId,
  required int sequence,
  required String kind,
  required String actor,
  required int atMillis,
  Value<String?> fromState,
  Value<String?> toState,
  Value<String?> abandonReason,
  Value<String?> evidenceId,
  Value<int> rowid,
});
typedef $$LoopEventRecordsTableUpdateCompanionBuilder
    = LoopEventRecordsCompanion Function({
  Value<String> loopId,
  Value<int> sequence,
  Value<String> kind,
  Value<String> actor,
  Value<int> atMillis,
  Value<String?> fromState,
  Value<String?> toState,
  Value<String?> abandonReason,
  Value<String?> evidenceId,
  Value<int> rowid,
});

final class $$LoopEventRecordsTableReferences extends BaseReferences<
    _$LoopDatabase, $LoopEventRecordsTable, LoopEventRecord> {
  $$LoopEventRecordsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $LoopRecordsTable _loopIdTable(_$LoopDatabase db) => db.loopRecords
      .createAlias('loop_event_records__loop_id__loop_records__id');

  $$LoopRecordsTableProcessedTableManager get loopId {
    final $_column = $_itemColumn<String>('loop_id')!;

    final manager = $$LoopRecordsTableTableManager($_db, $_db.loopRecords)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_loopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $EvidenceEntriesTable _evidenceIdTable(_$LoopDatabase db) =>
      db.evidenceEntries
          .createAlias('loop_event_records__evidence_id__evidence_entries__id');

  $$EvidenceEntriesTableProcessedTableManager? get evidenceId {
    final $_column = $_itemColumn<String>('evidence_id');
    if ($_column == null) return null;
    final manager =
        $$EvidenceEntriesTableTableManager($_db, $_db.evidenceEntries)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_evidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LoopEventRecordsTableFilterComposer
    extends Composer<_$LoopDatabase, $LoopEventRecordsTable> {
  $$LoopEventRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actor => $composableBuilder(
      column: $table.actor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get atMillis => $composableBuilder(
      column: $table.atMillis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromState => $composableBuilder(
      column: $table.fromState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toState => $composableBuilder(
      column: $table.toState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get abandonReason => $composableBuilder(
      column: $table.abandonReason, builder: (column) => ColumnFilters(column));

  $$LoopRecordsTableFilterComposer get loopId {
    final $$LoopRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loopId,
        referencedTable: $db.loopRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopRecordsTableFilterComposer(
              $db: $db,
              $table: $db.loopRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EvidenceEntriesTableFilterComposer get evidenceId {
    final $$EvidenceEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.evidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableFilterComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoopEventRecordsTableOrderingComposer
    extends Composer<_$LoopDatabase, $LoopEventRecordsTable> {
  $$LoopEventRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actor => $composableBuilder(
      column: $table.actor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get atMillis => $composableBuilder(
      column: $table.atMillis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromState => $composableBuilder(
      column: $table.fromState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toState => $composableBuilder(
      column: $table.toState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get abandonReason => $composableBuilder(
      column: $table.abandonReason,
      builder: (column) => ColumnOrderings(column));

  $$LoopRecordsTableOrderingComposer get loopId {
    final $$LoopRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loopId,
        referencedTable: $db.loopRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.loopRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EvidenceEntriesTableOrderingComposer get evidenceId {
    final $$EvidenceEntriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.evidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableOrderingComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoopEventRecordsTableAnnotationComposer
    extends Composer<_$LoopDatabase, $LoopEventRecordsTable> {
  $$LoopEventRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get actor =>
      $composableBuilder(column: $table.actor, builder: (column) => column);

  GeneratedColumn<int> get atMillis =>
      $composableBuilder(column: $table.atMillis, builder: (column) => column);

  GeneratedColumn<String> get fromState =>
      $composableBuilder(column: $table.fromState, builder: (column) => column);

  GeneratedColumn<String> get toState =>
      $composableBuilder(column: $table.toState, builder: (column) => column);

  GeneratedColumn<String> get abandonReason => $composableBuilder(
      column: $table.abandonReason, builder: (column) => column);

  $$LoopRecordsTableAnnotationComposer get loopId {
    final $$LoopRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loopId,
        referencedTable: $db.loopRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.loopRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EvidenceEntriesTableAnnotationComposer get evidenceId {
    final $$EvidenceEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.evidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoopEventRecordsTableTableManager extends RootTableManager<
    _$LoopDatabase,
    $LoopEventRecordsTable,
    LoopEventRecord,
    $$LoopEventRecordsTableFilterComposer,
    $$LoopEventRecordsTableOrderingComposer,
    $$LoopEventRecordsTableAnnotationComposer,
    $$LoopEventRecordsTableCreateCompanionBuilder,
    $$LoopEventRecordsTableUpdateCompanionBuilder,
    (LoopEventRecord, $$LoopEventRecordsTableReferences),
    LoopEventRecord,
    PrefetchHooks Function({bool loopId, bool evidenceId})> {
  $$LoopEventRecordsTableTableManager(
      _$LoopDatabase db, $LoopEventRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoopEventRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoopEventRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoopEventRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> loopId = const Value.absent(),
            Value<int> sequence = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> actor = const Value.absent(),
            Value<int> atMillis = const Value.absent(),
            Value<String?> fromState = const Value.absent(),
            Value<String?> toState = const Value.absent(),
            Value<String?> abandonReason = const Value.absent(),
            Value<String?> evidenceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoopEventRecordsCompanion(
            loopId: loopId,
            sequence: sequence,
            kind: kind,
            actor: actor,
            atMillis: atMillis,
            fromState: fromState,
            toState: toState,
            abandonReason: abandonReason,
            evidenceId: evidenceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String loopId,
            required int sequence,
            required String kind,
            required String actor,
            required int atMillis,
            Value<String?> fromState = const Value.absent(),
            Value<String?> toState = const Value.absent(),
            Value<String?> abandonReason = const Value.absent(),
            Value<String?> evidenceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoopEventRecordsCompanion.insert(
            loopId: loopId,
            sequence: sequence,
            kind: kind,
            actor: actor,
            atMillis: atMillis,
            fromState: fromState,
            toState: toState,
            abandonReason: abandonReason,
            evidenceId: evidenceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LoopEventRecordsTable, LoopEventRecord>(table),
                    $$LoopEventRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({loopId = false, evidenceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (loopId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.loopId,
                    referencedTable:
                        $$LoopEventRecordsTableReferences._loopIdTable(db),
                    referencedColumn:
                        $$LoopEventRecordsTableReferences._loopIdTable(db).id,
                  ) as T;
                }
                if (evidenceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.evidenceId,
                    referencedTable:
                        $$LoopEventRecordsTableReferences._evidenceIdTable(db),
                    referencedColumn: $$LoopEventRecordsTableReferences
                        ._evidenceIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LoopEventRecordsTableProcessedTableManager = ProcessedTableManager<
    _$LoopDatabase,
    $LoopEventRecordsTable,
    LoopEventRecord,
    $$LoopEventRecordsTableFilterComposer,
    $$LoopEventRecordsTableOrderingComposer,
    $$LoopEventRecordsTableAnnotationComposer,
    $$LoopEventRecordsTableCreateCompanionBuilder,
    $$LoopEventRecordsTableUpdateCompanionBuilder,
    (LoopEventRecord, $$LoopEventRecordsTableReferences),
    LoopEventRecord,
    PrefetchHooks Function({bool loopId, bool evidenceId})>;
typedef $$LoopEvidenceLinksTableCreateCompanionBuilder
    = LoopEvidenceLinksCompanion Function({
  required String loopId,
  required String evidenceId,
  Value<int> rowid,
});
typedef $$LoopEvidenceLinksTableUpdateCompanionBuilder
    = LoopEvidenceLinksCompanion Function({
  Value<String> loopId,
  Value<String> evidenceId,
  Value<int> rowid,
});

final class $$LoopEvidenceLinksTableReferences extends BaseReferences<
    _$LoopDatabase, $LoopEvidenceLinksTable, LoopEvidenceLink> {
  $$LoopEvidenceLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $LoopRecordsTable _loopIdTable(_$LoopDatabase db) => db.loopRecords
      .createAlias('loop_evidence_links__loop_id__loop_records__id');

  $$LoopRecordsTableProcessedTableManager get loopId {
    final $_column = $_itemColumn<String>('loop_id')!;

    final manager = $$LoopRecordsTableTableManager($_db, $_db.loopRecords)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_loopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $EvidenceEntriesTable _evidenceIdTable(_$LoopDatabase db) => db
      .evidenceEntries
      .createAlias('loop_evidence_links__evidence_id__evidence_entries__id');

  $$EvidenceEntriesTableProcessedTableManager get evidenceId {
    final $_column = $_itemColumn<String>('evidence_id')!;

    final manager =
        $$EvidenceEntriesTableTableManager($_db, $_db.evidenceEntries)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_evidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LoopEvidenceLinksTableFilterComposer
    extends Composer<_$LoopDatabase, $LoopEvidenceLinksTable> {
  $$LoopEvidenceLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$LoopRecordsTableFilterComposer get loopId {
    final $$LoopRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loopId,
        referencedTable: $db.loopRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopRecordsTableFilterComposer(
              $db: $db,
              $table: $db.loopRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EvidenceEntriesTableFilterComposer get evidenceId {
    final $$EvidenceEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.evidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableFilterComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoopEvidenceLinksTableOrderingComposer
    extends Composer<_$LoopDatabase, $LoopEvidenceLinksTable> {
  $$LoopEvidenceLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$LoopRecordsTableOrderingComposer get loopId {
    final $$LoopRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loopId,
        referencedTable: $db.loopRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.loopRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EvidenceEntriesTableOrderingComposer get evidenceId {
    final $$EvidenceEntriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.evidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableOrderingComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoopEvidenceLinksTableAnnotationComposer
    extends Composer<_$LoopDatabase, $LoopEvidenceLinksTable> {
  $$LoopEvidenceLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$LoopRecordsTableAnnotationComposer get loopId {
    final $$LoopRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.loopId,
        referencedTable: $db.loopRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoopRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.loopRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EvidenceEntriesTableAnnotationComposer get evidenceId {
    final $$EvidenceEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.evidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoopEvidenceLinksTableTableManager extends RootTableManager<
    _$LoopDatabase,
    $LoopEvidenceLinksTable,
    LoopEvidenceLink,
    $$LoopEvidenceLinksTableFilterComposer,
    $$LoopEvidenceLinksTableOrderingComposer,
    $$LoopEvidenceLinksTableAnnotationComposer,
    $$LoopEvidenceLinksTableCreateCompanionBuilder,
    $$LoopEvidenceLinksTableUpdateCompanionBuilder,
    (LoopEvidenceLink, $$LoopEvidenceLinksTableReferences),
    LoopEvidenceLink,
    PrefetchHooks Function({bool loopId, bool evidenceId})> {
  $$LoopEvidenceLinksTableTableManager(
      _$LoopDatabase db, $LoopEvidenceLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoopEvidenceLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoopEvidenceLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoopEvidenceLinksTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> loopId = const Value.absent(),
            Value<String> evidenceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoopEvidenceLinksCompanion(
            loopId: loopId,
            evidenceId: evidenceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String loopId,
            required String evidenceId,
            Value<int> rowid = const Value.absent(),
          }) =>
              LoopEvidenceLinksCompanion.insert(
            loopId: loopId,
            evidenceId: evidenceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LoopEvidenceLinksTable, LoopEvidenceLink>(
                        table),
                    $$LoopEvidenceLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({loopId = false, evidenceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (loopId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.loopId,
                    referencedTable:
                        $$LoopEvidenceLinksTableReferences._loopIdTable(db),
                    referencedColumn:
                        $$LoopEvidenceLinksTableReferences._loopIdTable(db).id,
                  ) as T;
                }
                if (evidenceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.evidenceId,
                    referencedTable:
                        $$LoopEvidenceLinksTableReferences._evidenceIdTable(db),
                    referencedColumn: $$LoopEvidenceLinksTableReferences
                        ._evidenceIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LoopEvidenceLinksTableProcessedTableManager = ProcessedTableManager<
    _$LoopDatabase,
    $LoopEvidenceLinksTable,
    LoopEvidenceLink,
    $$LoopEvidenceLinksTableFilterComposer,
    $$LoopEvidenceLinksTableOrderingComposer,
    $$LoopEvidenceLinksTableAnnotationComposer,
    $$LoopEvidenceLinksTableCreateCompanionBuilder,
    $$LoopEvidenceLinksTableUpdateCompanionBuilder,
    (LoopEvidenceLink, $$LoopEvidenceLinksTableReferences),
    LoopEvidenceLink,
    PrefetchHooks Function({bool loopId, bool evidenceId})>;
typedef $$InferenceDerivationsTableCreateCompanionBuilder
    = InferenceDerivationsCompanion Function({
  required String inferenceId,
  required String sourceEvidenceId,
  required int position,
  Value<int> rowid,
});
typedef $$InferenceDerivationsTableUpdateCompanionBuilder
    = InferenceDerivationsCompanion Function({
  Value<String> inferenceId,
  Value<String> sourceEvidenceId,
  Value<int> position,
  Value<int> rowid,
});

final class $$InferenceDerivationsTableReferences extends BaseReferences<
    _$LoopDatabase, $InferenceDerivationsTable, InferenceDerivation> {
  $$InferenceDerivationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $EvidenceEntriesTable _inferenceIdTable(_$LoopDatabase db) => db
      .evidenceEntries
      .createAlias('inference_derivations__inference_id__evidence_entries__id');

  $$EvidenceEntriesTableProcessedTableManager get inferenceId {
    final $_column = $_itemColumn<String>('inference_id')!;

    final manager =
        $$EvidenceEntriesTableTableManager($_db, $_db.evidenceEntries)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inferenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $EvidenceEntriesTable _sourceEvidenceIdTable(_$LoopDatabase db) =>
      db.evidenceEntries.createAlias(
          'inference_derivations__source_evidence_id__evidence_entries__id');

  $$EvidenceEntriesTableProcessedTableManager get sourceEvidenceId {
    final $_column = $_itemColumn<String>('source_evidence_id')!;

    final manager =
        $$EvidenceEntriesTableTableManager($_db, $_db.evidenceEntries)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceEvidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InferenceDerivationsTableFilterComposer
    extends Composer<_$LoopDatabase, $InferenceDerivationsTable> {
  $$InferenceDerivationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  $$EvidenceEntriesTableFilterComposer get inferenceId {
    final $$EvidenceEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.inferenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableFilterComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EvidenceEntriesTableFilterComposer get sourceEvidenceId {
    final $$EvidenceEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceEvidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableFilterComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InferenceDerivationsTableOrderingComposer
    extends Composer<_$LoopDatabase, $InferenceDerivationsTable> {
  $$InferenceDerivationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  $$EvidenceEntriesTableOrderingComposer get inferenceId {
    final $$EvidenceEntriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.inferenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableOrderingComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EvidenceEntriesTableOrderingComposer get sourceEvidenceId {
    final $$EvidenceEntriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceEvidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableOrderingComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InferenceDerivationsTableAnnotationComposer
    extends Composer<_$LoopDatabase, $InferenceDerivationsTable> {
  $$InferenceDerivationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$EvidenceEntriesTableAnnotationComposer get inferenceId {
    final $$EvidenceEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.inferenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EvidenceEntriesTableAnnotationComposer get sourceEvidenceId {
    final $$EvidenceEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceEvidenceId,
        referencedTable: $db.evidenceEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EvidenceEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.evidenceEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InferenceDerivationsTableTableManager extends RootTableManager<
    _$LoopDatabase,
    $InferenceDerivationsTable,
    InferenceDerivation,
    $$InferenceDerivationsTableFilterComposer,
    $$InferenceDerivationsTableOrderingComposer,
    $$InferenceDerivationsTableAnnotationComposer,
    $$InferenceDerivationsTableCreateCompanionBuilder,
    $$InferenceDerivationsTableUpdateCompanionBuilder,
    (InferenceDerivation, $$InferenceDerivationsTableReferences),
    InferenceDerivation,
    PrefetchHooks Function({bool inferenceId, bool sourceEvidenceId})> {
  $$InferenceDerivationsTableTableManager(
      _$LoopDatabase db, $InferenceDerivationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InferenceDerivationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InferenceDerivationsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InferenceDerivationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> inferenceId = const Value.absent(),
            Value<String> sourceEvidenceId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InferenceDerivationsCompanion(
            inferenceId: inferenceId,
            sourceEvidenceId: sourceEvidenceId,
            position: position,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String inferenceId,
            required String sourceEvidenceId,
            required int position,
            Value<int> rowid = const Value.absent(),
          }) =>
              InferenceDerivationsCompanion.insert(
            inferenceId: inferenceId,
            sourceEvidenceId: sourceEvidenceId,
            position: position,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$InferenceDerivationsTable,
                        InferenceDerivation>(table),
                    $$InferenceDerivationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {inferenceId = false, sourceEvidenceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (inferenceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.inferenceId,
                    referencedTable: $$InferenceDerivationsTableReferences
                        ._inferenceIdTable(db),
                    referencedColumn: $$InferenceDerivationsTableReferences
                        ._inferenceIdTable(db)
                        .id,
                  ) as T;
                }
                if (sourceEvidenceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceEvidenceId,
                    referencedTable: $$InferenceDerivationsTableReferences
                        ._sourceEvidenceIdTable(db),
                    referencedColumn: $$InferenceDerivationsTableReferences
                        ._sourceEvidenceIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InferenceDerivationsTableProcessedTableManager
    = ProcessedTableManager<
        _$LoopDatabase,
        $InferenceDerivationsTable,
        InferenceDerivation,
        $$InferenceDerivationsTableFilterComposer,
        $$InferenceDerivationsTableOrderingComposer,
        $$InferenceDerivationsTableAnnotationComposer,
        $$InferenceDerivationsTableCreateCompanionBuilder,
        $$InferenceDerivationsTableUpdateCompanionBuilder,
        (InferenceDerivation, $$InferenceDerivationsTableReferences),
        InferenceDerivation,
        PrefetchHooks Function({bool inferenceId, bool sourceEvidenceId})>;

class $LoopDatabaseManager {
  final _$LoopDatabase _db;
  $LoopDatabaseManager(this._db);
  $$EvidenceEntriesTableTableManager get evidenceEntries =>
      $$EvidenceEntriesTableTableManager(_db, _db.evidenceEntries);
  $$LoopRecordsTableTableManager get loopRecords =>
      $$LoopRecordsTableTableManager(_db, _db.loopRecords);
  $$LoopEventRecordsTableTableManager get loopEventRecords =>
      $$LoopEventRecordsTableTableManager(_db, _db.loopEventRecords);
  $$LoopEvidenceLinksTableTableManager get loopEvidenceLinks =>
      $$LoopEvidenceLinksTableTableManager(_db, _db.loopEvidenceLinks);
  $$InferenceDerivationsTableTableManager get inferenceDerivations =>
      $$InferenceDerivationsTableTableManager(_db, _db.inferenceDerivations);
}
