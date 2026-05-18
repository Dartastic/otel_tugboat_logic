// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_tugboat_logic_suppression.dart';

const _tracerName = 'dartastic_otel_libs_tugboat_logic';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class TugboatLogicResult {
  const TugboatLogicResult({
    this.organizationId,
    this.projectId,
    this.standard,
    this.controlId,
    this.requirementId,
    this.evidenceTaskId,
    this.controlStatus,
    this.evidenceStatus,
    this.ownerEmail,
    this.dueDateSec,
    this.attachmentCount,
    this.collectorSlug,
    this.statusCode,
  });

  /// OneTrust/Tugboat organization (tenant).
  final String? organizationId;

  /// Certification project (typically one per scope/framework).
  final String? projectId;

  /// `soc2` / `iso_27001` / `iso_27701` / `hipaa` / `pci_dss` /
  /// `gdpr` / `ccpa` / `nist_csf` / `nist_800_53` / `cmmc` /
  /// `sox_itgc` / `c5` / `irap` / `australia_essential_eight`.
  final String? standard;

  final String? controlId;

  /// Standard-specific requirement (e.g., `A.5.1`).
  final String? requirementId;

  /// Evidence task — the actual unit of work for a controller.
  final String? evidenceTaskId;

  /// `implemented` / `partially_implemented` / `not_implemented` /
  /// `not_applicable`.
  final String? controlStatus;

  /// `pending` / `in_progress` / `submitted` / `approved` / `rejected`
  /// / `expired`.
  final String? evidenceStatus;

  final String? ownerEmail;

  final int? dueDateSec;

  /// Number of file/screenshot attachments on the evidence task.
  final int? attachmentCount;

  /// `aws` / `azure` / `gcp` / `jira` / `github` / `okta` /
  /// `google_workspace` — automated collector source (vs human upload).
  final String? collectorSlug;

  final int? statusCode;
}

class TugboatLogicCallResult<T> {
  const TugboatLogicCallResult({required this.value, this.result});
  final T value;
  final TugboatLogicResult? result;
}

/// Wraps a Tugboat Logic / OneTrust Certification Automation API call
/// in a CLIENT span. [operation] is one of `projects.list`,
/// `controls.list`, `controls.update`, `evidence_tasks.list`,
/// `evidence_tasks.submit`, `evidence_tasks.attach`,
/// `audits.start`, `audits.complete`, `policies.list`,
/// `risks.list`.
Future<T> tracedTugboatLogic<T>({
  required String operation,
  required Future<TugboatLogicCallResult<T>> Function() invoke,
}) async {
  if (tugboatLogicInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'tugboat_logic',
    'rpc.method': operation,
    'tugboat_logic.operation': operation,
  };

  final span = _tracer().startSpan(
    'tugboat_logic $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.organizationId != null) {
        extras.add(OTel.attributeString(
          'tugboat_logic.organization.id',
          r.result!.organizationId!,
        ));
      }
      if (r.result!.projectId != null) {
        extras.add(OTel.attributeString(
          'tugboat_logic.project.id',
          r.result!.projectId!,
        ));
      }
      if (r.result!.standard != null) {
        extras.add(OTel.attributeString(
          'tugboat_logic.standard',
          r.result!.standard!,
        ));
      }
      if (r.result!.controlId != null) {
        extras.add(OTel.attributeString(
          'tugboat_logic.control.id',
          r.result!.controlId!,
        ));
      }
      if (r.result!.requirementId != null) {
        extras.add(OTel.attributeString(
          'tugboat_logic.requirement.id',
          r.result!.requirementId!,
        ));
      }
      if (r.result!.evidenceTaskId != null) {
        extras.add(OTel.attributeString(
          'tugboat_logic.evidence_task.id',
          r.result!.evidenceTaskId!,
        ));
      }
      if (r.result!.controlStatus != null) {
        extras.add(OTel.attributeString(
          'tugboat_logic.control.status',
          r.result!.controlStatus!,
        ));
        if (r.result!.controlStatus == 'not_implemented') {
          span.setStatus(
            SpanStatusCode.Error,
            'Tugboat control not_implemented',
          );
        }
      }
      if (r.result!.evidenceStatus != null) {
        extras.add(OTel.attributeString(
          'tugboat_logic.evidence.status',
          r.result!.evidenceStatus!,
        ));
        if (r.result!.evidenceStatus == 'rejected' ||
            r.result!.evidenceStatus == 'expired') {
          span.setStatus(
            SpanStatusCode.Error,
            'Tugboat evidence ${r.result!.evidenceStatus}',
          );
        }
      }
      if (r.result!.ownerEmail != null) {
        extras.add(OTel.attributeString(
          'tugboat_logic.owner.email',
          r.result!.ownerEmail!,
        ));
      }
      if (r.result!.dueDateSec != null) {
        extras.add(OTel.attributeInt(
          'tugboat_logic.due_date_sec',
          r.result!.dueDateSec!,
        ));
      }
      if (r.result!.attachmentCount != null) {
        extras.add(OTel.attributeInt(
          'tugboat_logic.attachment.count',
          r.result!.attachmentCount!,
        ));
      }
      if (r.result!.collectorSlug != null) {
        extras.add(OTel.attributeString(
          'tugboat_logic.collector.slug',
          r.result!.collectorSlug!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Tugboat HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
