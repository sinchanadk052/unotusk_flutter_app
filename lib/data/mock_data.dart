import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/models.dart';

class MockData {
  static List<NotificationItem> get initialNotifications => [
        NotificationItem(
          id: 'n1',
          type: 'success',
          title: 'Ingestion completed',
          body: 'Unotusk Core API — 847 new events indexed across 3 sources',
          time: '14 min ago',
          read: false,
        ),
        NotificationItem(
          id: 'n2',
          type: 'success',
          title: 'Signal Gate passed',
          body: 'Auth Service — 94 decision-events, 312 diff+commit pairs',
          time: '1h ago',
          read: false,
        ),
        NotificationItem(
          id: 'n3',
          type: 'info',
          title: 'Intelligence Report ready',
          body: 'Q2 summary emailed to authorizing CTO',
          time: '2h ago',
          read: false,
        ),
        NotificationItem(
          id: 'n4',
          type: 'warning',
          title: 'Ingestion stale',
          body: 'Payments Pipeline — last successful ingestion 72h ago',
          time: '3h ago',
          read: true,
        ),
        NotificationItem(
          id: 'n5',
          type: 'error',
          title: 'Signal Gate failed',
          body: 'Billing Service — 18 decision-events (threshold: 30)',
          time: 'Yesterday',
          read: true,
        ),
      ];

  static List<ProjectItem> get initialProjects => const [
        ProjectItem(
          id: 'p1',
          name: 'Unotusk Core API',
          upsStatus: 'active',
          ingestionStatus: 'live',
          lastIngestion: '14 min ago',
          fpr: 0.71,
          days: 67,
        ),
        ProjectItem(
          id: 'p2',
          name: 'Auth Service',
          upsStatus: 'active',
          ingestionStatus: 'live',
          lastIngestion: '1h ago',
          fpr: 0.64,
          days: 34,
        ),
        ProjectItem(
          id: 'p3',
          name: 'Payments Pipeline',
          upsStatus: 'offline',
          ingestionStatus: 'stale',
          lastIngestion: '72h ago',
          fpr: 0.51,
          days: 12,
        ),
        ProjectItem(
          id: 'p4',
          name: 'Billing Service',
          upsStatus: 'active',
          ingestionStatus: 'ingesting',
          lastIngestion: 'In progress…',
          fpr: 0.48,
          days: 8,
        ),
      ];

  static List<ActivityItem> get recentActivities => const [
        ActivityItem(
          id: 'a1',
          icon: '↑',
          text: '847 events indexed — GitHub + Jira + Confluence',
          time: '14 min ago',
          color: Color(0xFF6EC8B8),
        ),
        ActivityItem(
          id: 'a2',
          icon: '✓',
          text: 'Signal Gate passed — 94 decision-events, 312 pairs',
          time: '1h ago',
          color: Color(0xFFD4909A),
        ),
        ActivityItem(
          id: 'a3',
          icon: '↑',
          text: '312 events indexed — GitHub diff + commit lane',
          time: '25h ago',
          color: Color(0xFF6EC8B8),
        ),
        ActivityItem(
          id: 'a4',
          icon: '!',
          text: 'Payments Pipeline stale — last ingestion 72h ago',
          time: '3h ago',
          color: Color(0xFFD4725A),
        ),
        ActivityItem(
          id: 'a5',
          icon: '↑',
          text: '1,204 events — sprint completion trigger fired',
          time: '2d ago',
          color: Color(0xFF6EC8B8),
        ),
      ];

  static List<RecentChat> get recentChats => const [
        RecentChat(
          id: 1,
          title: 'Why did the auth refactor stall in review?',
          ago: '2d ago',
          time: '14:02',
        ),
        RecentChat(
          id: 2,
          title: 'Summarize decisions on the billing service',
          ago: '4d ago',
          time: '09:41',
        ),
        RecentChat(
          id: 3,
          title: 'Is the rate-limiter change still pending?',
          ago: '1w ago',
          time: '16:20',
        ),
      ];

  static List<ArchivedChat> get initialArchivedChats => [
        const ArchivedChat(
          id: 101,
          title: 'GraphQL vs REST API specification audit',
          date: '2026-08-14',
          messages: 14,
        ),
        const ArchivedChat(
          id: 102,
          title: 'Auth service FPR anomaly investigation',
          date: '2026-08-10',
          messages: 8,
        ),
        const ArchivedChat(
          id: 103,
          title: 'Postgres migration ADR #7 benchmarks',
          date: '2026-07-28',
          messages: 22,
        ),
        const ArchivedChat(
          id: 104,
          title: 'Rate limiter BDD contract generation',
          date: '2026-07-15',
          messages: 6,
        ),
      ];

  static List<SpecHistoryItem> get specHistoryList => const [
        SpecHistoryItem(
          id: 'sh-001',
          query: 'Generate a BDD spec for the rate-limiter change',
          timestamp: 'Jul 22 · 14:02',
          ago: 'Today',
          isoDate: '2026-07-22',
          queryType: 'cold',
          confidence: 'confirmed',
          score: 0.84,
          fprDelta: null,
          hasBDD: true,
        ),
        SpecHistoryItem(
          id: 'sh-002',
          query: 'Why did the auth refactor stall in review?',
          timestamp: 'Jul 20 · 14:02',
          ago: '2d ago',
          isoDate: '2026-07-20',
          queryType: 'warm',
          confidence: 'confirmed',
          score: 0.76,
          fprDelta: 0.04,
          hasBDD: false,
        ),
        SpecHistoryItem(
          id: 'sh-003',
          query: 'What is the FPR trend on the auth service this month?',
          timestamp: 'Jul 20 · 09:41',
          ago: '2d ago',
          isoDate: '2026-07-20',
          queryType: 'hot',
          confidence: 'confirmed',
          score: 0.71,
          fprDelta: 0.02,
          hasBDD: false,
        ),
        SpecHistoryItem(
          id: 'sh-004',
          query: 'Which team owns the payments service after the Q2 reorg?',
          timestamp: 'Jul 15 · 16:20',
          ago: '7d ago',
          isoDate: '2026-07-15',
          queryType: 'cold',
          confidence: 'uncertain',
          score: 0.63,
          fprDelta: null,
          hasBDD: false,
        ),
        SpecHistoryItem(
          id: 'sh-005',
          query: 'Summarize decisions on the billing service since January',
          timestamp: 'Jul 10 · 11:30',
          ago: '12d ago',
          isoDate: '2026-07-10',
          queryType: 'warm',
          confidence: 'confirmed',
          score: 0.81,
          fprDelta: 0.06,
          hasBDD: false,
        ),
        SpecHistoryItem(
          id: 'sh-006',
          query: 'Who approved the OIDC federation architecture?',
          timestamp: 'Jul 3 · 10:15',
          ago: '19d ago',
          isoDate: '2026-07-03',
          queryType: 'cold',
          confidence: 'confirmed',
          score: 0.88,
          fprDelta: null,
          hasBDD: false,
        ),
      ];

  static Map<String, List<Map<String, String>>> get specChatThreads => {
        'sh-001': [
          {
            'role': 'user',
            'text': 'Generate a BDD spec for the rate-limiter change'
          },
          {
            'role': 'ai',
            'text':
                '[CONFIRMED · score 0.84] The rate-limiter change (PR #441, merged Jul 21) modifies the token-bucket implementation to support per-tenant burst limits.\n\nFeature: Per-tenant rate limiting\n  Scenario: Burst requests within allowed quota\n    Given the tenant "acme" has a burst limit of 200 req/s\n    When 180 requests arrive within a 1-second window\n    Then all 180 requests are processed without throttling\n\n  Scenario: Burst requests exceeding quota\n    Given the tenant "acme" has a burst limit of 200 req/s\n    When 250 requests arrive within a 1-second window\n    Then 200 requests are processed\n    And 50 requests receive a 429 response with retry-after header\n\n  Scenario: Quota reset after window\n    Given the tenant "acme" was throttled at t=0\n    When 1 second has elapsed\n    Then the burst counter resets to 0\n    And new requests are processed normally'
          },
          {
            'role': 'user',
            'text': 'Add a scenario for unauthenticated requests'
          },
          {
            'role': 'ai',
            'text':
                '[CONFIRMED · score 0.84]\n\n  Scenario: Unauthenticated requests bypass tenant limits\n    Given a request arrives with no Authorization header\n    When the rate-limiter evaluates the request\n    Then the global anonymous limit of 50 req/s applies\n    And the per-tenant quota is not consumed\n\nThis aligns with the anonymous-traffic isolation decision recorded Jul 18 (Decision #D-0091).'
          }
        ],
        'sh-002': [
          {
            'role': 'user',
            'text': 'Why did the auth refactor stall in review?'
          },
          {
            'role': 'ai',
            'text':
                '[CONFIRMED · score 0.76] The auth refactor (PR #388) has been open for 11 days. Three blocking reviews remain from Security (@priya) pending verification of PKCE code-verifier entropy. Last comment recorded 48h ago on Slack #security-review.'
          }
        ],
        'sh-003': [
          {
            'role': 'user',
            'text': 'What is the FPR trend on the auth service this month?'
          },
          {
            'role': 'ai',
            'text':
                '[CONFIRMED · score 0.71] False Positive Ratio (FPR) increased from 0.62 to 0.64 (+0.02) over the last 30 days. Primary driver: 34 new spec changes indexed following the Okta SSO integration migration.'
          }
        ],
        'sh-004': [
          {
            'role': 'user',
            'text': 'Which team owns the payments service after the Q2 reorg?'
          },
          {
            'role': 'ai',
            'text':
                '[UNCERTAIN · score 0.63] Team ownership transition to Core Banking is documented in ENG-1902, but on-call rotation in PagerDuty still references the legacy Checkout squad. No reconciliation ticket found.'
          }
        ],
        'sh-005': [
          {
            'role': 'user',
            'text': 'Summarize decisions on the billing service since January'
          },
          {
            'role': 'ai',
            'text':
                '[CONFIRMED · score 0.81] Four architectural decisions indexed:\n1. Stripe webhook idempotency key enforcement (ADR #12, Jan 14)\n2. Postgres partition strategy by billing_cycle (Feb 2)\n3. Deprecation of legacy invoice PDF engine (ADR #15, Mar 20)\n4. Automated retry backoff ceiling set to 5 attempts (Apr 11).'
          }
        ],
        'sh-006': [
          {
            'role': 'user',
            'text': 'Who approved the OIDC federation architecture?'
          },
          {
            'role': 'ai',
            'text':
                '[CONFIRMED · score 0.88] Architecture approval was granted unanimously by @elena (VP Eng), @sam (Principal Arch), and @chen (Head of Security) in ADR #19 on Jul 3.'
          }
        ],
      };

  static List<OntologyNode> get ontologyNodes => const [
        OntologyNode(
            id: 0, cx: 120, cy: 200, label: 'Auth Service', type: 'Service'),
        OntologyNode(
            id: 1, cx: 320, cy: 100, label: 'OIDC Decision', type: 'Decision'),
        OntologyNode(
            id: 2,
            cx: 320,
            cy: 300,
            label: 'Postgres Decision',
            type: 'Decision'),
        OntologyNode(
            id: 3, cx: 520, cy: 80, label: 'GH #7210', type: 'Commit'),
        OntologyNode(
            id: 4, cx: 520, cy: 180, label: 'ENG-1042', type: 'Ticket'),
        OntologyNode(id: 5, cx: 520, cy: 300, label: 'ADR #7', type: 'Commit'),
        OntologyNode(
            id: 6, cx: 520, cy: 380, label: '#arch-decisions', type: 'Thread'),
        OntologyNode(id: 7, cx: 720, cy: 140, label: '@sam', type: 'Person'),
        OntologyNode(
            id: 8, cx: 720, cy: 300, label: 'Billing Service', type: 'Service'),
      ];

  static List<List<int>> get ontologyEdges => const [
        [0, 1],
        [0, 2],
        [1, 3],
        [1, 4],
        [2, 5],
        [2, 6],
        [3, 7],
        [5, 7],
        [5, 8],
        [6, 8],
        [4, 8],
      ];

  static List<HeroCardItem> get heroCards => const [
        HeroCardItem(
          title: 'Why choose Postgres over Mongo in March?',
          tag: 'ADR #7 Decision',
          icon: LucideIcons.gitBranch,
        ),
        HeroCardItem(
          title: 'Which team owns the auth service?',
          tag: 'ENG-2847 Ownership',
          icon: LucideIcons.users,
        ),
        HeroCardItem(
          title: 'Generate a BDD spec for rate-limiter',
          tag: 'BDD Contract',
          icon: LucideIcons.clipboardList,
        ),
        HeroCardItem(
          title: 'FPR trend on auth service this month',
          tag: 'Precision Metric',
          icon: LucideIcons.trendingUp,
        ),
      ];

  static List<String> get querySuggestions => const [
        'Why did we choose Postgres over Mongo in March?',
        'Which team owns the auth service after the Figma handoff?',
        'Generate a BDD spec for the rate-limiter change',
        'What is the FPR trend on the auth service this month?',
      ];

  static QueryResponseData get fallbackResponse => cannedResponses[
          'Why did we choose Postgres over Mongo in March?'] ??
      const QueryResponseData(
        segments: [
          ResponseSegment(
            text:
                'On March 14, the team voted 4–1 to proceed with Postgres. The primary driver was the existing RDS infrastructure and the billing schema\'s requirement for strong relational integrity.',
            tag: 'CONFIRMED',
          ),
          ResponseSegment(
            text:
                'MongoDB was eliminated after a schema-migration audit flagged 23 inconsistencies requiring manual reconciliation. No recount was requested.',
            tag: 'CONFIRMED',
          ),
          ResponseSegment(
            text:
                'ADR #7, merged by @sam on March 16 and cross-linked in ENG-1042, formally closed the decision. No alternative was raised in any indexed thread after that merge.',
            tag: 'CONFIRMED',
          ),
        ],
        meta:
            'Query resolved · 847ms · 3 sources · ADR #7 · Slack #arch-decisions · ENG-1042',
        queryType: 'warm',
        confidence: 'confirmed',
      );

  static Map<String, QueryResponseData> get cannedResponses => {
        'Why did we choose Postgres over Mongo in March?':
            const QueryResponseData(
          segments: [
            ResponseSegment(
              text:
                  'On March 14, the team voted 4–1 to proceed with Postgres. The primary driver was the existing RDS infrastructure and the billing schema\'s requirement for strong relational integrity.',
              tag: 'CONFIRMED',
            ),
            ResponseSegment(
              text:
                  'MongoDB was eliminated after a schema-migration audit flagged 23 inconsistencies requiring manual reconciliation. No recount was requested.',
              tag: 'CONFIRMED',
            ),
            ResponseSegment(
              text:
                  'ADR #7, merged by @sam on March 16 and cross-linked in ENG-1042, formally closed the decision. No alternative was raised in any indexed thread after that merge.',
              tag: 'CONFIRMED',
            ),
          ],
          meta:
              'Query resolved · 847ms · 3 sources · ADR #7 · Slack #arch-decisions · ENG-1042',
          queryType: 'warm',
          confidence: 'confirmed',
          reasoning: ReasoningModel(
            compositeScore: 0.89,
            components: [
              ScoreComponent(label: 'P_class', score: 0.93),
              ScoreComponent(label: 'S_auth', score: 0.86),
              ScoreComponent(label: 'T_match', score: 0.91),
              ScoreComponent(label: 'D_atom', score: 0.88),
              ScoreComponent(label: 'R_ragas', score: 0.87),
            ],
            routingPath: [
              'Warm query',
              'Delta write-back (20 candidates)',
              'Confirmed gate (≥0.80)',
              'Output'
            ],
            ontologyEdges: [
              'authored_by',
              'references',
              'supersedes',
              'resolves'
            ],
            citations: [
              'ADR #7',
              'ENG-1042',
              'Slack #arch-decisions',
              'GH PR #7210'
            ],
          ),
        ),
        'Why choose Postgres over Mongo in March?': const QueryResponseData(
          segments: [
            ResponseSegment(
              text:
                  'On March 14, the team voted 4–1 to proceed with Postgres. The primary driver was the existing RDS infrastructure and the billing schema\'s requirement for strong relational integrity.',
              tag: 'CONFIRMED',
            ),
            ResponseSegment(
              text:
                  'MongoDB was eliminated after a schema-migration audit flagged 23 inconsistencies requiring manual reconciliation. No recount was requested.',
              tag: 'CONFIRMED',
            ),
            ResponseSegment(
              text:
                  'ADR #7, merged by @sam on March 16 and cross-linked in ENG-1042, formally closed the decision. No alternative was raised in any indexed thread after that merge.',
              tag: 'CONFIRMED',
            ),
          ],
          meta:
              'Query resolved · 847ms · 3 sources · ADR #7 · Slack #arch-decisions · ENG-1042',
          queryType: 'warm',
          confidence: 'confirmed',
          reasoning: ReasoningModel(
            compositeScore: 0.89,
            components: [
              ScoreComponent(label: 'P_class', score: 0.93),
              ScoreComponent(label: 'S_auth', score: 0.86),
              ScoreComponent(label: 'T_match', score: 0.91),
              ScoreComponent(label: 'D_atom', score: 0.88),
              ScoreComponent(label: 'R_ragas', score: 0.87),
            ],
            routingPath: [
              'Warm query',
              'Delta write-back (20 candidates)',
              'Confirmed gate (≥0.80)',
              'Output'
            ],
            ontologyEdges: [
              'authored_by',
              'references',
              'supersedes',
              'resolves'
            ],
            citations: [
              'ADR #7',
              'ENG-1042',
              'Slack #arch-decisions',
              'GH PR #7210'
            ],
          ),
        ),
        'Which team owns the auth service after the Figma handoff?':
            const QueryResponseData(
          segments: [
            ResponseSegment(
              text:
                  'Ownership transferred to the Platform team on June 3, documented in the handoff sheet attached to ENG-2847 and countersigned by both team leads on June 1.',
              tag: 'CONFIRMED',
            ),
            ResponseSegment(
              text:
                  'PagerDuty on-call rotation was updated June 4. The Runbook link in the internal wiki still points to the Frontend team Slack channel — no ticket tracking that correction was found in any indexed source.',
              tag: 'INFERRED',
              note: 'no ticket confirming wiki update',
            ),
          ],
          meta:
              'Query resolved · 1.2s · 4 sources · ENG-2847 · PagerDuty · Confluence wiki',
          queryType: 'cold',
          confidence: 'uncertain',
          reasoning: ReasoningModel(
            compositeScore: 0.67,
            components: [
              ScoreComponent(label: 'P_class', score: 0.74),
              ScoreComponent(label: 'S_auth', score: 0.61),
              ScoreComponent(label: 'T_match', score: 0.72),
              ScoreComponent(label: 'D_atom', score: 0.60),
              ScoreComponent(label: 'R_ragas', score: 0.68),
            ],
            routingPath: [
              'Cold query',
              'Full re-rank (40 candidates)',
              'Uncertain gate (0.50–0.80)',
              'Output with caveats'
            ],
            ontologyEdges: ['authored_by', 'maintains', 'references'],
            citations: [
              'ENG-2847',
              'PagerDuty roster Jun-4',
              'Confluence wiki',
              'Slack #handoffs'
            ],
          ),
        ),
        'Which team owns the auth service?': const QueryResponseData(
          segments: [
            ResponseSegment(
              text:
                  'Ownership transferred to the Platform team on June 3, documented in the handoff sheet attached to ENG-2847 and countersigned by both team leads on June 1.',
              tag: 'CONFIRMED',
            ),
            ResponseSegment(
              text:
                  'PagerDuty on-call rotation was updated June 4. The Runbook link in the internal wiki still points to the Frontend team Slack channel — no ticket tracking that correction was found in any indexed source.',
              tag: 'INFERRED',
              note: 'no ticket confirming wiki update',
            ),
          ],
          meta:
              'Query resolved · 1.2s · 4 sources · ENG-2847 · PagerDuty · Confluence wiki',
          queryType: 'cold',
          confidence: 'uncertain',
          reasoning: ReasoningModel(
            compositeScore: 0.67,
            components: [
              ScoreComponent(label: 'P_class', score: 0.74),
              ScoreComponent(label: 'S_auth', score: 0.61),
              ScoreComponent(label: 'T_match', score: 0.72),
              ScoreComponent(label: 'D_atom', score: 0.60),
              ScoreComponent(label: 'R_ragas', score: 0.68),
            ],
            routingPath: [
              'Cold query',
              'Full re-rank (40 candidates)',
              'Uncertain gate (0.50–0.80)',
              'Output with caveats'
            ],
            ontologyEdges: ['authored_by', 'maintains', 'references'],
            citations: [
              'ENG-2847',
              'PagerDuty roster Jun-4',
              'Confluence wiki',
              'Slack #handoffs'
            ],
          ),
        ),
        'Generate a BDD spec for the rate-limiter change':
            const QueryResponseData(
          segments: [
            ResponseSegment(
              text:
                  'Verified BDD contract generated from PR #441 and ADR #12 decisions.',
              tag: 'CONFIRMED',
            ),
          ],
          meta:
              'Query resolved · 1.4s · PR #441 · ADR #12 · 6 test assertions',
          queryType: 'cold',
          confidence: 'confirmed',
          bdd: BddSpec(
            given:
                'A multi-tenant API gateway handling authenticated traffic and anonymous tiers.',
            when:
                'A request arrives exceeding the per-tenant burst threshold of 200 req/s.',
            then:
                'The token bucket throttles excess requests with HTTP 429 and Retry-After header while recording audit metrics.',
            kpi: 'Sub-millisecond token lookup latency (<0.8ms p99)',
            kpiTag: 'INFERRED',
            kpiNote: 'derived from RDS cache SLA',
            testCases: [
              TestCase(
                  id: 1,
                  desc:
                      'Tenant within allowed 200 req/s quota receives uninterrupted HTTP 200 responses.'),
              TestCase(
                  id: 2,
                  desc:
                      'Tenant bursting beyond 200 req/s receives HTTP 429 with calculated Retry-After header.'),
              TestCase(
                  id: 3,
                  desc:
                      'Anonymous endpoints fall back to global 50 req/s bucket without consuming tenant allocation.'),
            ],
            risks: [
              RiskItem(
                  tag: 'CONFIRMED',
                  text:
                      'Redis failover state causes rate-limiter to fail-open under emergency conditions (ADR #12).'),
              RiskItem(
                  tag: 'INFERRED',
                  text:
                      'High burst traffic on unauthenticated endpoints may exhaust ingress socket pool before token check.'),
            ],
          ),
          reasoning: ReasoningModel(
            compositeScore: 0.84,
            components: [
              ScoreComponent(label: 'P_class', score: 0.89),
              ScoreComponent(label: 'S_auth', score: 0.82),
              ScoreComponent(label: 'T_match', score: 0.88),
              ScoreComponent(label: 'D_atom', score: 0.83),
              ScoreComponent(label: 'R_ragas', score: 0.85),
            ],
            routingPath: [
              'Cold query',
              'Spec extraction (PR #441)',
              'BDD contract synthesis',
              'Confirmed gate'
            ],
            ontologyEdges: ['specifies', 'verifies', 'tests', 'implements'],
            citations: ['PR #441', 'ADR #12', 'ENG-1804', 'Jest integration'],
          ),
        ),
        'Generate a BDD spec for rate-limiter': const QueryResponseData(
          segments: [
            ResponseSegment(
              text:
                  'Verified BDD contract generated from PR #441 and ADR #12 decisions.',
              tag: 'CONFIRMED',
            ),
          ],
          meta:
              'Query resolved · 1.4s · PR #441 · ADR #12 · 6 test assertions',
          queryType: 'cold',
          confidence: 'confirmed',
          bdd: BddSpec(
            given:
                'A multi-tenant API gateway handling authenticated traffic and anonymous tiers.',
            when:
                'A request arrives exceeding the per-tenant burst threshold of 200 req/s.',
            then:
                'The token bucket throttles excess requests with HTTP 429 and Retry-After header while recording audit metrics.',
            kpi: 'Sub-millisecond token lookup latency (<0.8ms p99)',
            kpiTag: 'INFERRED',
            kpiNote: 'derived from RDS cache SLA',
            testCases: [
              TestCase(
                  id: 1,
                  desc:
                      'Tenant within allowed 200 req/s quota receives uninterrupted HTTP 200 responses.'),
              TestCase(
                  id: 2,
                  desc:
                      'Tenant bursting beyond 200 req/s receives HTTP 429 with calculated Retry-After header.'),
              TestCase(
                  id: 3,
                  desc:
                      'Anonymous endpoints fall back to global 50 req/s bucket without consuming tenant allocation.'),
            ],
            risks: [
              RiskItem(
                  tag: 'CONFIRMED',
                  text:
                      'Redis failover state causes rate-limiter to fail-open under emergency conditions (ADR #12).'),
              RiskItem(
                  tag: 'INFERRED',
                  text:
                      'High burst traffic on unauthenticated endpoints may exhaust ingress socket pool before token check.'),
            ],
          ),
        ),
        'FPR trend on auth service this month': const QueryResponseData(
          segments: [
            ResponseSegment(
              text:
                  'Auth Service False Positive Rate (FPR) currently sits at 0.64, up +0.02 from the 30-day baseline of 0.62.',
              tag: 'CONFIRMED',
            ),
            ResponseSegment(
              text:
                  'The uptick occurred following PR #388 (OIDC federation rework) which introduced 34 new decision events awaiting historical reconciliation.',
              tag: 'CONFIRMED',
            ),
            ResponseSegment(
              text:
                  'Projected to drop back to 0.61 once the Okta credential migration PR merges next Tuesday.',
              tag: 'INFERRED',
              note: 'derived from sprint commit velocity',
            ),
          ],
          meta:
              'Query resolved · 710ms · Datadog FPR telemetry · GH #388 · 34 events',
          queryType: 'hot',
          confidence: 'confirmed',
          reasoning: ReasoningModel(
            compositeScore: 0.71,
            components: [
              ScoreComponent(label: 'P_class', score: 0.78),
              ScoreComponent(label: 'S_auth', score: 0.69),
              ScoreComponent(label: 'T_match', score: 0.74),
              ScoreComponent(label: 'D_atom', score: 0.65),
              ScoreComponent(label: 'R_ragas', score: 0.70),
            ],
            routingPath: [
              'Hot query',
              'Telemetry lookup',
              'FPR delta calculation',
              'Output'
            ],
            ontologyEdges: ['tracks', 'measures', 'alerts_on'],
            citations: ['Datadog FPR-01', 'Auth Service telemetry', 'GH #388'],
          ),
        ),
      };

  static const Set<String> blockedDomains = {
    'gmail.com',
    'yahoo.com',
    'hotmail.com',
    'outlook.com',
    'icloud.com',
    'proton.me',
    'me.com',
    'live.com',
    'aol.com',
    'ymail.com',
  };

  static const Map<String, Map<String, String>> knownOrganizations = {
    'acme.com': {
      'name': 'Acme Corp',
      'provider': 'Google Workspace OIDC',
      'issuer': 'https://accounts.google.com',
      'type': 'google',
    },
    'meta.com': {
      'name': 'Meta Platforms',
      'provider': 'Okta Workforce Identity OIDC',
      'issuer': 'https://auth.meta.com',
      'type': 'okta',
    },
    'microsoft.com': {
      'name': 'Microsoft Enterprise',
      'provider': 'Microsoft Entra ID (Azure AD)',
      'issuer': 'https://login.microsoftonline.com',
      'type': 'microsoft',
    },
    'unotusk.com': {
      'name': 'Unotusk Internal',
      'provider': 'Google Workspace OIDC',
      'issuer': 'https://accounts.google.com',
      'type': 'google',
    },
  };
}
