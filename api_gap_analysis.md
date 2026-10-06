# Nirvoor Learning — API Gap & Merge Analysis

**Prepared for:** Backend Team (ASP.NET Core API) + Flutter Client Team
**Prepared by:** Flutter Client Agent
**Date:** 2026-10-05
**Scope:** Student & Teacher panels only (Admin/Super-Admin deliberately excluded per master prompt).
**Evidence base:**
- Live OpenAPI document: `https://api.nirvoor.com/swagger/v1/swagger.json`
- Retrieved and parsed programmatically: **261 paths**, **65 schemas**, security scheme `Bearer` (JWT).
- Business rules: `SYSTEM_USER_MANUAL.md` (v1.0, Aug 2026), Rules 1–14.
- Existing client code under `lib/` (Clean Architecture skeleton).

> **Method note:** Nothing in this document is guessed. Every endpoint listed as "missing" was checked against the live spec's `paths` object; every endpoint referenced as "existing" was matched by exact route. Where a claim is an inference rather than a spec fact, it is labelled **(inference)**.

---

## 0. Executive Summary

The backend is **far more complete than the current Flutter client uses**. The spec exposes 261 routes covering almost every Student and Teacher workflow in the User Manual — including several areas the client currently does not touch at all (live-class exams, AI writing, refunds, payments/coupons, progress, practice files, free-live, teacher evaluation, pre-booking).

The real problems are **not primarily missing endpoints** — they are:

1. **Contract drift:** the Flutter client calls routes that do not exist in the spec (`register/login`, `register/register`, `register/profile`, `Enrollment/by-course` semantics, `quiz/*` casing, `LiveClass/*` response shapes). These are **client-side bugs**, not backend gaps, and they will 404 or mis-parse in production.
2. **Data-shape gaps:** DTOs are largely **untyped in the spec** (200 responses declare no schema), so the client cannot code-generate models and has been guessing field names (`durationMinutes` treated as months, `lessonCount`, `isEnrolled`, `isWishlisted`).
3. **Merge opportunities:** several screens require 3–5 sequential round-trips (course hub, progress, notifications) that should be composite endpoints for slow Bangladeshi mobile networks.
4. **A small set of genuine missing endpoints:** mostly around **live-class exam grading analytics**, **watch-history sync semantics**, **marketing vs. real counts**, and **teacher dashboard aggregates**.

Severity legend: 🔴 Blocker · 🟠 High · 🟡 Medium · 🟢 Nice-to-have

---

## 1. Client ↔ Spec Contract Drift (Client Bugs — fix in Flutter)

These are routes the current client code calls that **do not exist** at that path in the spec. They must be corrected client-side immediately.

| # | Client call (current code) | Correct spec route | Severity | Notes |
|---|---|---|---|---|
| 1 | `POST register/login` | `POST /api/Register/Login` **or** `POST /api/app/login` | 🔴 | Client omits `/api/` prefix (baseUrl is `.../api/`, so it becomes `/api/register/login` → wrong case → 404). Two login routes exist; `/api/app/login` appears to be the mobile-oriented one. **Backend: confirm which one mobile should use.** |
| 2 | `POST register/register` | `POST /api/Register/Register` | 🔴 | Same casing issue. |
| 3 | `GET register/profile` | `GET /api/Register/Profile` | 🔴 | Also `GET /api/Student/me` exists for student profile. **Backend: clarify which is canonical.** |
| 4 | `POST register/forgotpassword` | `POST /api/PasswordReset/request` | 🔴 | Route renamed entirely. |
| 5 | `POST register/verifyotp` | `POST /api/Register/verify-email` (`VerifyEmailDTO`) | 🔴 | Renamed + payload `{email, otp}` → verify DTO. |
| 6 | `POST register/resetpassword` | `PUT /api/PasswordReset/reset` (`ResetPasswordDTO`) | 🔴 | Method changed POST→PUT, renamed. |
| 7 | `GET quiz/getbylesson/{id}` (lowercase `quiz`) | `GET /api/quiz/getbylesson/{lessonId}` | 🟡 | Lowercase `quiz` is actually correct in spec; confirm case-insensitive routing on host. |
| 8 | `GET Enrollment/by-course/{courseId}` used as *student's own* enrollment status | `GET /api/Enrollment/by-course/{courseId}` returns **course-level** enrollment; student's own state comes from `GET /api/Enrollment/my-enrollments` or `GET /api/Student/me` | 🟠 | **(inference)** The client treats a course-scoped response as a per-user boolean. |
| 9 | `GET LiveClass/course/{courseId}` | exists, but free-live has a **separate namespace** `/api/LiveClass/free/...` | 🟠 | Client has no concept of free-live at all. |
| 10 | No client support | `POST /api/Payment/quote` | 🔴 | Rule 4 (largest discount wins) is **server-side**; client must call quote before checkout. |

> **Action (Client):** Introduce a single `ApiRoutes` constants class and stop hard-coding strings in data sources. This one change eliminates items 1–7 permanently.

---

## 2. Missing Endpoints

"Missing" here means: **required by a Student/Teacher UI flow in the User Manual, but absent from the live spec.** Genuine backend gaps are few; the rest are covered.

### 2.1 🔴 Genuine missing endpoints

| # | Needed for (Manual ref) | Endpoint that should exist | Why it's needed |
|---|---|---|---|
| M1 | Live-class exam analytics for teacher (§5.2 "See live-exam answers", Rule 10) | `GET /api/LiveExam/{examId}/analytics` | Teacher can fetch submissions (`GET /api/LiveExam/{examId}/submissions`) but there is **no aggregate**: class average, per-question difficulty, pass rate. Google-Forms-style builders always show this. |
| M2 | Watch history "sync" semantics (§4.3; the prompt explicitly lists *student watch history sync*) | `POST /api/VideoProgress/history/sync` (batch upsert) | Spec has per-item `save` and per-item `restore`, plus `DELETE .../{lessonId}`. There is **no batch sync** for a device that watched offline / resumed from multiple devices. (inference: needed because playback progress is written on a timer.) |
| M3 | Marketing vs. real enrollment counts (Rule 5) | `GET /api/Course/{courseId}/counts` returning `{ realEnrollments, marketingEnrollments, marketingVideoCount, marketingPracticeCount }` | `GET /api/Course/{courseId}/stats` exists but its response schema is **untyped in the spec**, so it is unknown whether it separates real from inflated. **If `/stats` already does this, this gap collapses — backend to confirm.** |
| M4 | Course "disappears after start date" verification (Rule 2) | Server must expose the rule; client needs `enrollmentDeadline` / `isEnrollable` flag on course DTO | Rule 2 is enforced server-side for the *list*, but a deep-linked course (`/course-details/<id>`) needs an explicit `isEnrollable` boolean so the client can render "enrollment closed" vs. 404. **(inference from Rule 2 + deep-link requirement.)** |
| M5 | Teacher dashboard aggregate (§5) | `GET /api/Teacher/dashboard` | Teacher panel home needs "my courses, upcoming classes today, pending submissions to mark". Currently requires N+1 calls (`GetByTeacher` + per-course exams + per-course live classes). |

### 2.2 🟡 Endpoints that exist but are **undocumented at the response level**

The spec declares **200 responses with no `content`/`schema`** for essentially every GET (verified: `/api/Course/GetAll`, `/api/Course/GetById/{id}`, `/api/Enrollment/my-enrollments`, `/api/Progress/my`, `/api/Exam/course/{courseId}`, `/api/LiveExam/{examId}/take`, `/api/Payment/quote`, `/api/Coupon/validate`, `/api/CorporateCoupon/validate`, `/api/Refund/eligibility/{courseId}`, `/api/LiveClass/free/active`, etc.).

**Impact:** the Flutter client cannot auto-generate models; every model is hand-written and error-prone. This is the single biggest developer-velocity problem in the project.

**Ask:** add `[ProducesResponseType(typeof(XxxResponseDto), 200)]` to controllers so Swagger emits response schemas. This is a documentation-only change with no runtime behaviour impact.

---

## 3. Endpoints Needing Merging / Payload Optimization

Target: reduce round-trips on **slow/intermittent networks** (the stated concern). Each row shows the current number of sequential calls the UI must make vs. a recommended composite.

### 3.1 🔴 Course Hub (biggest win)

**Screen:** `enrolled-course/<id>` — the five hub cards + lessons + progress (Manual §4.3).

**Current design forces:**

| Call | Endpoint |
|---|---|
| 1 | `GET /api/Course/GetById/{courseId}` |
| 2 | `GET /api/Lesson/GetByCourse/{courseId}` |
| 3 | `GET /api/LiveClass/course/{courseId}` |
| 4 | `GET /api/LiveClass/course/{courseId}/recordings` |
| 5 | `GET /api/Exam/course/{courseId}` |
| 6 | `GET /api/Practice/course/{courseId}` |
| 7 | `GET /api/AiWriting/course/{courseId}` |
| 8 | `GET /api/Progress/my` (then filter client-side) |

**Recommendation:** `GET /api/Course/{courseId}/hub`
Returns a single composite DTO:
```json
{
  "course": { ... },
  "lessons": [ ... ],
  "liveClasses": { "upcoming": [...], "recordings": [...] },
  "exams": [ { "slot": 1, "status": "Open|Locked|Closed", "deadline": "..." } ],
  "practiceFiles": [ ... ],
  "aiWritingTasks": [ ... ],
  "suggestions": [ ... ],
  "progress": { "overall": 62, "video": 40, "quiz": 15, "exam": 15, "liveExam": 20, "attendance": 10 }
}
```
**Impact:** 8 round-trips → 1. On a 3G connection at ~300 ms RTT this is roughly **2.1 s saved per hub open**, and the hub is opened on every course visit.

### 3.2 🟠 Progress breakdown (Manual §4.3 — the weighted formula)

The manual defines progress as **video 40% + quiz 15% + exam 15% + live exam 20% + attendance 10%**. The spec has `GET /api/Progress/my`, `GET /api/Progress/performance`, and `GET /api/Progress/course/{courseId}/students` — but the client would still need quiz progress (`/api/quiz/overall-progress/{userId}`) separately.

**Recommendation:** ensure `GET /api/Progress/my` returns the **five weighted components** directly (not just a single number), so the dashboard renders the breakdown without a second call.

### 3.3 🟠 Notification polling (Manual §4.5 — "refreshes every 30 seconds")

Client polls `GET /api/Notification/my` + `GET /api/Notification/unread-count` **every 30 s** = **~5,760 requests/user/day**.

**Recommendation (pick one):**
- (a) Merge: `/api/Notification/my?includeUnreadCount=true`, **or**
- (b) Add lightweight `GET /api/Notification/poll?since={iso8601}` returning only changes + count. **This is the preferred fix** — it also fixes the "no push notifications" limitation (Rule/§8: notifications are in-app only).

### 3.4 🟡 Checkout pricing (Rule 4)

Current: client must call `POST /api/Coupon/validate` **and** `POST /api/CorporateCoupon/validate` **and** `GET /api/CorporateCoupon/course/{courseId}` to show the greyed-out losing offer.

**Recommendation:** `POST /api/Payment/quote` already exists — make it the **single source of truth** returning:
```json
{
  "originalPrice": 1000,
  "appliedDiscount": { "source": "Coupon|Campaign|Corporate", "amount": 200 },
  "losingOffers": [ { "source": "Corporate", "amount": 150, "applied": false } ],
  "payableAmount": 800
}
```
This directly encodes **Rule 4** ("the losing corporate offer is still listed, greyed out and marked as not applied"). Client should never compute discounts itself.

### 3.5 🟡 Wishlist badge counts

`GET /api/Wishlist/counts` exists — good. Ensure it is used instead of fetching the full wishlist to show a badge.

### 3.6 🟢 Course catalogue filtering

Manual §4.2 says *"Sorting and paging are done by the server"*, but `GET /api/Course/GetAll` has **no documented query parameters** (category/level/price/rating/availability/sort/page). Either they exist undocumented, or this is a real gap.

**Ask:** document `GET /api/Course/GetAll?category=&level=&minPrice=&maxPrice=&minRating=&available=&sort=&page=&pageSize=` and return `{ items: [], totalCount, page, pageSize }`.

---

## 4. Data Gaps (DTO field-level)

### 4.1 🔴 `durationMinutes` — the Rule 6 trap

`CreateCourseDTO.durationMinutes` is `integer(int32)`.

Per **Rule 6**, *"the field is stored with a name that says minutes, but every screen treats it as months."* The name is actively misleading and has already leaked into the Flutter client (`CourseModel.durationMinutes`).

**Ask:** rename to `durationMonths` (or add `durationUnit: "months"`). If a rename breaks existing rows, add `durationMonths` as the documented field and mark `durationMinutes` `deprecated: true` in the spec. **This prevents every future agent/developer from re-introducing the bug.**

### 4.2 🔴 Marketing vs. real counts (Rule 5)

The spec's `CreateCourseDTO` has **no field for the fixed marketing baseline** (Rule 5: *"a fixed baseline between 25 and 55, different per course but always the same for that course"*). It is presumably seeded in the DB.

**Ask:** expose explicitly so the client never shows a marketing number where a real on /api/Course/{courseId}/stats` → `{ realEnrollmentCount, marketingEnrollmentCount, marketingVideoText, marketingPracticeText }`
- `GET /api/Course/GetAll` items → include `isUpcoming` so the card can render "Coming soon" (Rule 3).

### 4.3 🟠 Upcoming / coming-soon state (Rule 3)

`CreateCourseDTO` **does** include `isUpcoming` and `enrollmentOpensAt` — good. **But the client model (`CourseEntity`/`CourseModel`) has neither.**

**Ask (Client):** add `isUpcoming`, `enrollmentOpensAt`, `startDate`, `endDate` to `CourseEntity` so the UI can:
- hide the price and the word "Free" when `isUpcoming == true` (Rule 3),
- hide the Buy button,
- exclude from "Most popular".

**Ask (Backend):** confirm `GET /api/Course/GetAll` returns these three fields per item.

### 4.4 🟠 Refund status flags (Rule 9)

The prompt explicitly lists *"refund status flags"* as a data gap. Spec has a full refund lifecycle:
`GET /api/Refund/eligibility/{courseId}`, `POST /api/Refund/request`, `GET /api/Refund/my`, `POST /api/Refund/my/{id}/cancel`, `POST /api/Refund/admin/{id}/approve|reject|reverse`, `POST /api/Refund/admin/unenroll`.

**Gap:** the **student's** view needs a per-course refund state. `GET /api/Refund/my` exists but there is no documented `refundStatus` on the enrollment/course DTO.

**Ask:** add to the enrollment DTO: `refundStatus: "None|Requested|Approved|Rejected|Reversed"` and `refundRequestedAt`. Otherwise the client must cross-join `/api/Refund/my` with `/api/Enrollment/my-enrollments`.

### 4.5 🟠 Exam state machine

Manual §4.4: *"The exam window **opens when the teacher uploads the question file**, and everyone gets the same clock."*

`GET /api/Exam/course/{courseId}` exists, and there are `POST /api/Exam/upload-question/{examId}`, `GET /api/Exam/question/{examId}`, `POST /api/Exam/submit/{examId}`.

**Gap:** no documented **status** field. Client needs per-exam: `status: "Locked|Open|Closed"`, `opensAt`, `deadline`, `questionFileUrl`, `mySubmissionStatus`. Without it, the hub's Exam card cannot show which of the four slots (1st/2nd/3rd/Final) is live.

**Also:** `slot` is `integer(int32)` in `CreateExamDTO` — ambiguous (1..4?). **Ask:** document the enum mapping (1=1st, 2=2nd, 3=3rd, 4=Final) or switch to a string enum.

### 4.6 🟡 Live-class exam answer shapes

`SaveLiveExamQuestionDTO` supports `type`, `options`, `fileUrl`, `points` — good, matches "Google-Forms style". `GradeLiveExamDTO` has `{feedback, marks[]}`.

**Gap:** no documented field for **auto-marked vs. manual** on a submission (`GET /api/LiveExam/submission/{submissionId}`). Manual §5.2: *"auto-marked where possible, manual marks where needed."*

**Ask:** add `autoMarks`, `manualMarks`, `finalMarks`, `gradedBy`, `gradedAt` to the submission response.

### 4.7 🟡 AI writing "last attempt counts"

Manual §4.4: *"Multiple attempts allowed — the last one counts."* and *"Admin can overwrite the mark afterwards."*

Spec: `POST /api/AiWriting/submit`, `PUT /api/AiWriting/grade/{submissionId}`, `OverrideMarkDto.finalMarks`.

**Gap:** no documented `attemptNumber` / `isLatest` on submissions, and no `aiMark` vs `finalMark` split.

**Ask:** submission response → `{ attemptNumber, isLatest, aiMark, finalMark, overriddenBy, feedback }`.

### 4.8 🟡 Live-class "join" response shape

`GET /api/LiveClass/join/{id}` — the client's `joinLiveClass` does `response.data as Map<String,dynamic>`. Since the spec declares no response schema, the Jitsi room payload (`roomUrl`? `jitsiToken`? `domain`?) is **unknown**.

**Ask:** document the join response. Jitsi integration cannot be completed reliably without it.

### 4.9 🟡 Free-live namespace (Rule 12)

`/api/LiveClass/free/*` exists and is **public** (should have no `security` requirement). The client has **zero** free-live support, and the router has no `/free-live` route.

**Ask (Backend):** confirm which `/api/LiveClass/free/*` routes are anonymous, so the client's Dio interceptor does not attach/refresh a token for them.
**Ask (Client):** add a public `/free-live` route (no auth guard).

### 4.10 🟡 Attendance contribution

Manual §5.2: attendance *"feeds 10% of their progress score"*. No dedicated attendance endpoint exists.

**Ask:** confirm attendance is folded into `GET /api/Progress/my` (component 5). If it is separate, expose `GET /api/Progress/attendance/{courseId}`.

### 4.11 🟢 Teacher invite flow

`GET /api/Register/invite/{token}` + `POST /api/Admin/teacher-invites` exist. `RegisterDTO.inviteToken` supports instant approval (Rule/§5.1). Client has no invite-registration screen.

### 4.12 🟢 Pre-booking (upcoming courses)

`/api/PreBooking` (POST/GET), `/api/PreBooking/export`, `PUT /api/PreBooking/{id}/contacted`. This is the natural companion to **Rule 3** (Upcoming courses are visible but not buyable) — a "notify me / pre-book" CTA. **Client does not use it.** Recommend wiring it to the "Coming soon" card.

### 4.13 🟢 Store purchase flow

Spec has a **full parallel payment flow** for the store (`/api/store/purchase/initiate|ipn|success|fail|cancel|status|held|release`) plus `GET /api/store/purchase/my`. Client's `StoreRepository` only lists items. If the Store is meant to be buyable (Manual §4.5 "Books and other items admin has listed"), this whole flow is unimplemented client-side.

---

## 5. Endpoints Present in Spec but Unused by the Client (Feature Backlog)

These are **not gaps** — they are **unimplemented client features**. Listed so the Flutter work is scoped correctly.

| Feature (Manual ref) | Spec endpoints available | Client status |
|---|---|---|
| Course exams (§4.4) | `/api/Exam/*` (9 routes) | ❌ none |
| Live-class exams (§4.4, §5.2) | `/api/LiveExam/*` (15 routes) | ❌ none |
| AI writing (§4.4) | `/api/AiWriting/*` (8 routes) | ❌ none |
| Refunds (§4.2, Rule 9) | `/api/Refund/*` (9 routes) | ❌ none |
| Payments / SSLCommerz (§4.2) | `/api/Payment/*` (8 routes) | ❌ none |
| Coupons + Corporate (Rule 4) | `/api/Coupon/*`, `/api/CorporateCoupon/*` (11 routes) | ❌ none |
| Progress (§4.3) | `/api/Progress/*` (4 routes) | ❌ none (client shows a stub) |
| Practice files (§4.3) | `/api/Practice/*` (4 routes) | ❌ none |
| Free live (Rule 12) | `/api/LiveClass/free/*` (18 routes) | ❌ none |
| Live recordings | `/api/LiveClass/recording/{id}`, `/course/{id}/recordings` | ⚠️ partial |
| Watch history | `/api/VideoProgress/history/{userId}` (+restore) | ⚠️ partial (no restore) |
| Teacher evaluation (§4.4) | `/api/TeacherEvaluation/submit`, `/mine/{courseId}` | ❌ none |
| Support ticket (§4.5) | `POST /api/Support/ticket` | ❌ none |
| Announcements (§4.5) | `/api/Announcement/active` | ⚠️ partial |
| Notifications (§4.5) | `/api/Notification/*` | ⚠️ partial |
| Leaderboard (§4.4) | `/api/quiz/leaderboard`, `/course/{courseId}` | ⚠️ partial |
| Certificates (§4.4) | `/api/Certificate/*` | ⚠️ partial |
| Student onboarding (§4.1) | `/api/Student/complete-onboarding` | ❌ none (client has no profile form) |
| Pre-booking (Rule 3) | `/api/PreBooking` | ❌ none |
| Store purchase (§4.5) | `/api/store/purchase/*` | ❌ none |
| Account deletion | `/api/Register/account/delete-impact`, `/delete` | ❌ none |
| Course reorder (teacher) | `PUT /api/Course/Reorder` | ❌ none |
| Course complete | `PUT /api/Course/Complete/{courseId}` | ❌ none |

---

## 6. Rule-by-Rule Traceability

| Rule (Manual) | Server support | Client support | Verdict |
|---|---|---|---|
| R1 Roles (student vs teacher split) | ✅ role enum on login | ⚠️ router has no role guard on teacher routes | **Client fix needed** |
| R2 Course vanishes after start date | ✅ (server list filtering) | ❌ no `isEnrollable` handling | **Needs flag** |
| R3 Upcoming = visible, not buyable | ✅ `isUpcoming`, `enrollmentOpensAt` | ❌ fields not in model | **Client fix needed** |
| R4 Discounts never stack, largest wins | ✅ `/api/Payment/quote` + validate routes | ❌ no checkout | **Client fix needed** |
| R5 Inflated marketing counts | ⚠️ baseline not exposed | ❌ shows raw count | **Needs `/stats` clarity** |
| R6 Duration is MONTHS | ❌ field named `durationMinutes` | ❌ same misnomer | **Backend rename needed** |
| R9 Refund removes enrollment | ✅ full refund lifecycle | ❌ none | **Client fix needed** |
| R10 Teacher-only live exam | ✅ `LiveExam/manage` vs `submissions` | ❌ none | Client fix needed |
| R11 Browser-side recording upload | ⚠️ `LiveClass/recording/{id}` | ❌ none | Client fix needed |
| R12 `/free-live` public, no login | ✅ `LiveClass/free/*` | ❌ no route | **Client fix needed** |
| R13 Rate limit 8/min | ⚠️ server-side, no `Retry-After` documented | ❌ no backoff | **Ask: return 429 + Retry-After** |
| R14 Email in spam | n/a | ⚠️ OTP screen should warn | Client copy fix |
| Timezone = BD local, no conversion | ✅ (implied) | ⚠️ uses `DateTime.parse` (assumes local) | **Client: treat as wall-clock** |

### 6.1 🔴 Rate limiting (Rule 13) — request a machine-readable signal

Manual: *"8 login/signup/password attempts per minute... Wait 60 seconds and it clears by itself."*

**Ask:** return HTTP **429** with a `Retry-After` header (seconds) and body `{ "message": "...", "retryAfterSeconds": 60 }`. Currently the client cannot distinguish a lockout from a wrong password, so it will show "incorrect password" — exactly the confusing behaviour the manual warns about.

---

## 7. Prioritised Action List

### Backend (ordered by client unblocking value)
1. 🔴 **Rename `durationMinutes` → `durationMonths`** (Rule 6). Add `deprecated: true` if rename is unsafe.
2. 🔴 **Publish response schemas** (`[ProducesResponseType]`) for all GET endpoints — unblocks client model generation.
3. 🔴 **Return 429 + `Retry-After`** on the auth rate limiter (Rule 13).
4. 🔴 **Confirm canonical auth routes** (`/api/Register/Login` vs `/api/app/login`; `/api/Register/Profile` vs `/api/Student/me`).
5. 🟠 **Add `GET /api/Course/{courseId}/hub`** composite (8 calls → 1).
6. 🟠 **Add `isEnrollable` / `enrollmentDeadline`** to course DTO (Rule 2 deep links).
7. 🟠 **Expose real vs. marketing counts** in `/api/Course/{courseId}/stats` (Rule 5).
8. 🟠 **Add `refundStatus`** to enrollment DTO (Rule 9).
9. 🟠 **Add exam `status` + `opensAt` + `deadline`** (Manual §4.4).
10. 🟠 **Document `LiveClass/join` response** (Jitsi payload).
11. 🟡 **Document `GetAll` filter/sort/paging params** (Manual §4.2).
12. 🟡 **Add `attemptNumber`/`isLatest`/`aiMark`** to AI writing submissions.
13. 🟡 **Add notification `poll?since=`** to kill 30-second polling.
14. 🟡 **Add `GET /api/LiveExam/{examId}/analytics`** (M1).
15. 🟡 **Add `POST /api/VideoProgress/history/sync`** (M2).
16. 🟢 **Confirm anonymous routes** under `/api/LiveClass/free/*`.

### Client (ordered)
1. 🔴 Central `ApiRoutes` constants class — remove all hard-coded path strings.
2. 🔴 Fix auth routes + payloads (`Register/Login`, `verify-email`, `PasswordReset/*`).
3. 🔴 Extend `CourseEntity` with `isUpcoming`, `enrollmentOpensAt`, `startDate`, `endDate`, `isEnrollable`.
4. 🔴 Rename `durationMinutes` → `durationMonths` in client models.
5. 🟠 Implement `Payment/quote`-driven checkout (Rule 4) — never compute discounts client-side.
6. 🟠 Implement Exam, LiveExam, AI Writing, Refund, Progress modules.
7. 🟠 Add `/free-live` public route with no auth guard (Rule 12).
8. 🟠 Add role guard for `/teacher/*` routes (Rule 1).
9. 🟡 Implement student onboarding form (`complete-onboarding`).
10. 🟡 Implement watch-history restore + delete.
11. 🟢 Wire PreBooking into "Coming soon" cards (Rule 3).

---

## 8. Verification Log

Commands used to produce this document (reproducible):

```powershell
# 1. Fetch the live spec
Invoke-WebRequest -Uri "https://api.nirvoor.com/swagger/v1/swagger.json" -OutFile swagger_spec.json

# 2. Enumerate all paths + methods  -> 261 paths
$j = Get-Content swagger_spec.json -Raw | ConvertFrom-Json
$j.paths.PSObject.Properties | % { $_.Name }

# 3. Enumerate schemas  -> 65 schemas
$j.components.schemas.PSObject.Properties | % { $_.Name }
```

Confirmed facts:
- Spec title `LearningAPi`, version `1.0`, **261 paths**, **65 schemas**.
- Auth: single `Bearer` JWT security scheme.
- `CreateCourseDTO` contains `durationMinutes`, `isUpcoming`, `enrollmentOpensAt`, `startDate`, `endDate`, `discountType`, `discountPercent`, `discountAmount`.
- `InitiatePaymentRequest` contains `courseId`, `couponCode`, `corporateCouponId`, `phone`.
- `GET` 200 responses carry **no schema** for all sampled endpoints.

---

*End of report.*