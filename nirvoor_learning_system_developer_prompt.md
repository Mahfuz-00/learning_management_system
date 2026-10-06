# Nirvoor Learning System — Comprehensive Master Prompt & Agent Instructions

> **Target Audience for this Prompt:** AI Coding Agent / Full-Stack Flutter Developer  
> **Tech Stack:** Flutter, Clean Architecture, BLoC, Dependency Injection (`get_it` / `injectable`), `dio` (Network client), `hive` (Local caching/storage), `go_router` (Routing)  
> **System Scope:** Student & Teacher Panels Only (Strictly ignore Admin/Super Admin functions as outlined in the System User Manual).  
> **API Reference:** `https://api.nirvoor.com/swagger/index.html`  
> **Reference Document:** Attached `SYSTEM_USER_MANUAL.pdf` (Version 1.0, August 2026).

---

## Part 1: Context & Introduction for the Agent

You are working on the **Nirvoor Learning System** Flutter mobile/web client. This platform caters exclusively to **Students** and **Teachers** in Bangladesh (bilingual support: English & Bangla, though primary localization/state management must handle data models seamlessly). 

Before writing or completing any code, you must thoroughly understand the business rules, user workflows, and constraints documented in the `SYSTEM_USER_MANUAL.pdf`. 

### Key Business Rules & Behavioral Constraints (Must be enforced in UI & Domain Logic):
1. **Rule 1 (Roles):** Teachers handle live classes, recordings, and course exams. Students consume courses, take quizzes, view videos, join live classes, and sit for exams. Ignore all admin/super-admin capabilities.
2. **Rule 2 (Course Visibility):** A course disappears from the catalogue once its start date passes (except for enrolled students, teachers, and admins). 
3. **Rule 3 (Upcoming Courses):** Visible but not buyable ("Coming soon" state; no price or "Free" label shown).
4. **Rule 4 (Discounts):** Discounts never add up. The single largest saving (campaign, coupon, corporate) wins in Taka.
5. **Rule 5 & 6:** Course card counts are inflated marketing numbers; course duration is stored and treated in **MONTHS**, not minutes.
6. **Rule 11 & 12:** Live classes are recorded via the teacher's browser (upload progress managed via background state), and `/free-live` is fully public without login.
7. **Timezones:** All times are strictly Bangladesh local time ($UTC +6$). No timezone conversions on client-side.

---

## Part 2: Task 1 — API Gap & Merge Analysis Document (For Backend Team)

*Instructions for Agent:* Do not perform the API analysis yourself based on guesses. Programmatically or systematically review the Swagger documentation at `https://api.nirvoor.com/swagger/index.html` against the UI requirements defined in the User Manual for **Students and Teachers**. Then, generate a structured markdown report (`api_gap_analysis.md`) highlighting:
1. **Missing Endpoints:** Endpoints required by Flutter UI flows (e.g., student watch history sync, specific teacher live-exam grading routes, corporate discount payload validations) that are absent in Swagger.
2. **Endpoints Needing Merging / Payload Optimization:** Instances where multiple round-trips are required by the current API design (e.g., fetching course hub cards separately) and recommendations for composite DTOs or merged endpoints to improve mobile performance over slow networks.
3. **Data Gaps:** Missing fields in existing DTOs (e.g., duration unit clarity, real vs. marketing enrollment counts, refund status flags).

---

## Part 3: Task 2 — Code Completion & Architecture Guidelines

You are provided with an existing skeleton codebase. Your task is to complete all missing features, repositories, use cases, BLoCs, and UI screens following strict **Clean Architecture** principles.

### Architecture Structure:
```text
lib/
│
├── core/
│   ├── error/          # Failures and Exceptions (Proper Error Handling)
│   ├── network/        # Dio client setup, interceptors, token refresh
│   ├── router/         # GoRouter configuration & guards
│   └── storage/        # Hive local boxes & caching strategies
│
├── features/
│   ├── auth/           # Login, Register, OTP Verification, Profile setup
│   ├── courses/        # Catalogue, Course Details, Wishlist, My Courses
│   ├── learning_hub/   # Video streaming, Quizzes, Practice files, Suggestions
│   ├── live_classes/   # Jitsi integration, Attendance tracking, Recordings
│   ├── exams/          # Course exams & Live-class exams (Google-Forms style)
│   └── teacher_panel/  # Scheduling live classes, exam management, grading submissions
│
└── main.dart
```

### Coding Rules & Best Practices:
1. **Clean Architecture Separation:**
   - **Data Layer:** Models, Remote Data Sources (Dio), Local Data Sources (Hive), Repository Implementations.
   - **Domain Layer:** Entities, Value Objects, Use Cases (Interactors), Repository Interfaces (Abstract contracts).
   - **Presentation Layer:** BLoC / Cubit, States, Events, UI Screens & Widgets.
2. **Dependency Injection:** Use `get_it` and `injectable`. Annotate dependencies properly so code generation (`build_runner`) builds the DI graph seamlessly.
3. **Robust Error Handling:**
   - Catch all Dio exceptions (`DioException`), network timeouts, and local Hive read/write errors.
   - Map exceptions to descriptive domain `Failure` classes (`ServerFailure`, `CacheFailure`, `NetworkFailure`).
   - Display user-friendly error states in BLoCs and show snackbars/dialogs in UI without crashing the app.
4. **Commenting Standard (Crucial for Future Agents):**
   - Write clear, descriptive `/// Doc comments` above every class, method, BLoC event/state, and repository contract.
   - Add inline comments explaining *why* specific business rules are implemented (referencing User Manual rules where applicable, e.g., `// Rule 4: Ensure only the largest discount in Taka is applied`).

---

## Part 4: Task 3 — Code Documentation Generation

After completing the codebase, generate a comprehensive code documentation file (`code_documentation.md`) detailing:
1. Overview of the Clean Architecture layers implemented.
2. Directory structure mapping.
3. State management flow using BLoC (Events $\rightarrow$ States $\rightarrow$ UI).
4. Local caching implementation details using Hive.
5. Routing logic and guards implemented with GoRouter.
6. Instructions on how to run, test, and build the application.

---

## Step-by-Step Execution Instructions for the Agent

1. **Step 1:** Read and ingest the attached `SYSTEM_USER_MANUAL.pdf` to memorize student and teacher workflows and rules 1 through 14.
2. **Step 2:** Inspect `https://api.nirvoor.com/swagger/index.html` and generate the `api_gap_analysis.md` report for the backend team.
3. **Step 3:** Analyze the existing codebase structure, identify incomplete modules, missing repositories, and unhandled UI states.
4. **Step 4:** Implement missing features following Clean Architecture, Dio network configuration, Hive caching, GoRouter routing, and BLoC state management. Ensure comprehensive comment coverage over all code sections.
5. **Step 5:** Write robust error handling across all data and domain layers.
6. **Step 6:** Generate the `code_documentation.md` file summarizing the entire architecture and codebase implementation.