/// <reference types="next" />
/// <reference types="next/image-types/global" />
import "./.next/types/routes.d.ts";

// NOTE: This file should not be edited
// see https://nextjs.org/docs/app/api-reference/config/typescript for more information.
# Notification System — Task Breakdown

Goal: finish the TPA notification feature end-to-end — not just the settings
screens (already shipped for Principal, Teacher, Admin), but real delivery
that actually respects those saved preferences, with the exact per-notification
copy the doc specifies.

Source docs:
- `docs/business/product/Notifications/18-notification-preferences.md` (canonical spec, taxonomy, phasing)
- `docs/business/product/Notifications/18b-notification-copy-principal.md` (31 notifications, exact copy)
- `docs/business/product/Notifications/18c-notification-copy-teacher.md` (16 New Teacher + 18 Experienced Teacher, exact copy)
- `docs/business/product/Notifications/18d-notification-copy-admin.md` (16 board-level, exact copy)
- Reference architecture: `ClassTrack-BOS` (sibling project) — outbox table + one central preference gate + cron-hit dispatch job + polling in-app inbox. No queue/websockets there; don't invent one here either.

## Coverage audit (the important finding)

Checked every existing `src/lib/email.ts` sender against its real call sites
before writing this list — the gap is bigger than "wire preferences into
existing sends." Roughly half the documented notifications **don't exist in
any form today**, not just unmigrated:

| Area | Status |
|---|---|
| **ALP (Category E — P-C02, ET-E01–E04)** | **Zero code.** `alp/route.ts` has no send/notify call anywhere. |
| **Delegation (P-A06/P-A07)** | **Zero code.** Delegating/revoking an appraisal notifies no one. |
| **Conference/observation "scheduled" events** (NT-A02/A04/A06, ET-A03/A05/A07) | **Zero code.** Only `sendStepCompletedNotification` exists, firing on step *completion* — not when a principal enters a date/time. |
| **Day-before reminders** (NT-A03/A05/A07, ET-A04/A06/A08) | **Zero code.** No cron/job produces these. |
| **Meeting request confirmation** (NT-A09/ET-A10) | **Half-wired.** `sendMeetingRequestedNotification` only emails the principal (P-A05); the teacher never gets a confirmation. |
| **Admin ops** (AD-G02–G05, G08: user provisioned/deactivated, import, export, config changed) | Zero code, but doc scopes these Phase 2/3 — expected, not urgent. |
| P-B*/AD-B* deadlines, D01–D03 plans, F01–F03 NTIP, termination alerts | Real trigger call sites exist (`scheduler.ts`, `ticket-engine.ts`) using **generic** copy, not the exact per-ID subject/body from `18b`/`18d`. |

So this is two phases: **infrastructure** (gate/helper/inbox/digest — mostly
already scoped) and **content + trigger authoring** (the actual bulk of the
remaining work), organized by the doc's own A–G categories.

Work one task at a time, small steps, `/simplify` + commit after each
meaningful chunk (same cadence as the settings screens).

---

## Phase 1 — Infrastructure

### 1. Add `Notification` model + migration
Prisma model for an in-app inbox: `recipientUserId`, `boardId`, `screen`,
`rowId`, `title`, `body`, `link`, `channel` (IN_APP/EMAIL/CALENDAR), `status`,
`readAt`, `createdAt`. Shape informed by ClassTrack's `Notification` table.
Additive migration only — no producer/UI wiring yet.

### 2. Build central `resolveNotificationChannels()` gate
`src/lib/notifications/resolve-channels.ts` — one function,
`resolveNotificationChannels(userId, screen, rowId, catalog)`, reading the
existing `NotificationPreference`/`User.settings` data plus the row's
mandatory/phase2/channels metadata. **Single call site for every producer** —
ClassTrack only wired its equivalent gate into 1 of 4 producers, which is
exactly the inconsistency to avoid here.

### 3. Build `sendNotification()` helper (bilingual from the start)
`src/lib/notifications/send-notification.ts` —
`sendNotification({ userId, boardId, screen, rowId, templateKey, data })`.
Calls the gate, writes an in-app `Notification` row if IN_APP resolves, calls
a template renderer + the existing `src/lib/email.ts` transport if EMAIL
resolves. Must render subject/body in the recipient's saved FR/EN preference
from day one — `email.ts` currently has **zero** i18n awareness (verified: no
`getTranslations`/`locale` usage anywhere in the file), and retrofitting that
after templates are authored is more work than building it in now.

### 4. Build the in-app notification bell/inbox UI
Wire the existing (currently non-functional) bell icon stubs in `header.tsx` /
`admin-header.tsx` to a list endpoint over `Notification`: unread badge,
dropdown list, mark-as-read. Follow ClassTrack's simple pattern — React Query
polling (~60s), no websockets/SSE. One shared component reused across all 3
portal headers, not three separate builds.

### 5. Pilot: migrate one existing send through the gate
Route `sendStepCompletedNotification` (or `sendCycleCompletedNotification`)
through `sendNotification()` end-to-end. Verify: toggle the matching row off
in Principal preferences → nothing sent; toggle back on → sent; FR renders
correctly. First real proof the wiring works before scaling to ~80 IDs.

---

## Phase 2 — Content + trigger authoring (per doc category)

Each task below: build any missing trigger call sites, author the exact
subject/body/CTA copy from `18b`/`18c`/`18d` as templates, wire through
`sendNotification()`. Do these one category at a time — each is independently
shippable and testable.

### 6. Category A — Appraisal Lifecycle (Principal + New Teacher + Exp. Teacher)
The biggest gap. Build: delegation notify (P-A06/P-A07, currently zero code),
conference/observation "scheduled" triggers (NT-A02/A04/A06, ET-A03/A05/A07 —
fire when the principal sets a date, not on step completion), day-before
reminder job (NT-A03/A05/A07, ET-A04/A06/A08 — needs a new scheduler sweep),
the missing teacher-side meeting-request confirmation (NT-A09/ET-A10, doc gap
8.4's notification half — the "add a button" half of gap 8.4 stays out of
scope, see below). Replace `sendStepCompletedNotification`'s generic body with
the exact per-ID copy for P-A02–A04/NT-A08/ET-A09.

### 7. Category B — Deadlines & Compliance (Principal + Admin)
Reconcile `scheduler.ts`'s generic `sendDeadlineAlert`/`sendComplianceDeadlineAlert`
against the ~19 distinct per-ID subjects/bodies (P-B01–B12, AD-B01–B07) —
needs a `templateKey` param instead of one shared generic body. Fold in doc
gap 8.1 here: verify a Deputy Principal only receives these for teachers
actually delegated to them.

### 8. Category C — Documents & Signatures
Verify/build: teacher-side form-ready notifications (NT-C01/C02 — these fire
when the principal *submits* a form, not on step completion, so likely also
missing) and P-C02 (ALP ready for co-signature — zero code, ties into #9).

### 9. Category E — Annual Learning Plan (net-new, zero code today)
Full build: trigger points for ALP submit → principal co-sign → teacher final
sign, in `alp/route.ts` (currently has no send/notify call at all). Covers
P-C02, ET-E01–E04.

### 10. Category D — Plans (Enrichment/Improvement)
Mostly covered by `sendEnrichmentPlanRequired`/`sendImprovementPlanRequired` —
verify P-D03/NT-D02 (teacher signed the plan → notify principal) actually
fires, replace generic bodies with exact per-ID copy.

### 11. Category F — NTIP Progress
Mostly covered by `sendNtipCompletionNotice`/scheduler OCT alerts — verify
NT-F01 (progress updated, Phase 2, low priority) and replace generic bodies
with exact per-ID copy for F02/F03/AD-F01–F03.

### 12. Category G — Board & System (Admin, lower priority)
Doc scopes these Phase 2/3, so do this last: build AD-G02–G05 (new
user/deactivated/import/export — configurable, zero code today) and AD-G08
(board config changed, Phase 3). AD-G01/G06/G07 already have real triggers
(termination alert, scheduler).

### 13. Teacher-side termination notification (doc gap 8.5)
No screen or notification exists for a teacher's receipt/acknowledgement of
termination documents — a legally required one per the doc. Needs a new
screen/state, not just a template.

---

## Phase 3 — Polish

### 14. Add Daily Digest toggle
Digest mode is Principal + Admin only (not Teacher) per the doc — one
consolidated daily email of low-priority configurable notifications from the
prior 24h. Add the toggle to those two catalogs/UI/i18n, then a nightly job
reusing the existing `/api/internal/scheduler/run` cron pattern.

### 15. Wire Calendar channel delivery
For rows whose catalog entry includes "calendar" and the user has it enabled
+ connected, have `sendNotification()` also create the event — reuse the
existing OAuth calendar sync code in `src/lib/calendar/`, don't build new.

### 16. School-day-aware reminder timing (doc gap 8.6)
Reminder lead times must count school days, not calendar days. Wire the
reminder-timing selectors to the existing `addSchoolDays()`/`schoolDays()`
helpers in `src/lib/format.ts` instead of naive day math.

### 17. Full verification + final `/simplify` + commit
End-to-end Playwright pass (toggle off → nothing sent; toggle on → sent;
digest batches correctly; bell UI works, FR/EN both correct), typecheck,
`/simplify`, commit the whole notification-delivery milestone.

---

## Explicitly out of scope (not in this list)

- **Doc gap 8.4, the UI half — "Request Post-Delivery Discussion" button.**
  Task 6 covers the missing teacher-confirmation *notification*, but the doc
  also recommends a net-new button on the Documents screens to trigger the
  request in the first place. That's a product feature, not notification
  plumbing — would need its own task if wanted.
- **Phase 3 governance items** — configurable compliance-alert thresholds per
  board, notification history/audit for board oversight. The doc itself
  scopes these to Phase 3 beyond what's listed above.
