// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_tugboat_logic/otel_tugboat_logic.dart';

/// Traces Tugboat Logic calls with OpenTelemetry.
///
/// `otel_tugboat_logic` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Tugboat Logic call in
/// [tracedTugboatLogic]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'tugboat-logic-example');

  // Wraps a Tugboat Logic / OneTrust Certification Automation API call in a CLIENT span.
  final tugboatLogicId = await tracedTugboatLogic<String>(
    operation: 'projects.list',
    invoke: () async {
      // Make the Tugboat Logic call here, then report what it returned.
      const id = 'tugboat_logic_8f3a2c';
      return const TugboatLogicCallResult(
          value: id,
          result: TugboatLogicResult(
              organizationId: 'organization_8f3a2c',
              projectId: 'project_8f3a2c',
              standard: 'soc2',
              controlId: 'control_8f3a2c',
              requirementId: 'A.5.1',
              evidenceTaskId: 'evidencetask_8f3a2c',
              controlStatus: 'implemented',
              evidenceStatus: 'pending',
              ownerEmail: 'ada@example.com',
              dueDateSec: 1,
              attachmentCount: 3,
              collectorSlug: 'aws',
              statusCode: 200));
    },
  );
  OTelLog.info('tracedTugboatLogic projects.list returned $tugboatLogicId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutTugboatLogicInstrumentationAsync.
  await runWithoutTugboatLogicInstrumentationAsync(
    () => tracedTugboatLogic<String>(
      operation: 'projects.list',
      invoke: () async {
        const id = 'tugboat_logic_8f3a2c';
        return const TugboatLogicCallResult(
            value: id,
            result: TugboatLogicResult(
                organizationId: 'organization_8f3a2c',
                projectId: 'project_8f3a2c',
                standard: 'soc2',
                controlId: 'control_8f3a2c',
                requirementId: 'A.5.1',
                evidenceTaskId: 'evidencetask_8f3a2c',
                controlStatus: 'implemented',
                evidenceStatus: 'pending',
                ownerEmail: 'ada@example.com',
                dueDateSec: 1,
                attachmentCount: 3,
                collectorSlug: 'aws',
                statusCode: 200));
      },
    ),
  );

  await OTel.shutdown();
}
