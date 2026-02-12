# AI Code Generation Guidelines - Clean Architecture & Project Standards

> **This document is the source of truth for code structure, responsibility, and architectural standards.**

---

## 1. The Core Philosophy & Constraints

### 🧠 The Mental Model: "Who says 'No'?"

To decide where logic belongs, ask: **"Who has the authority to stop this action?"**

| Authority | Layer | Example |
|-----------|-------|---------|
| OS / Device says 'No' | UI / Presentation | "Screen too small", "Double tap ignored" |
| Infrastructure says 'No' | Data Layer | "No internet", "Disk full", "Server 500" |
| Product Rules say 'No' | Domain Layer | "User not admin", "Balance insufficient" |

### 🛡️ The Dependency Rule (Strict Imports)

Dependencies must point **INWARDS** towards the Domain.

- ✅ **Presentation** depends on **Domain**
- ✅ **Data** depends on **Domain**
- ❌ **Domain** depends on **NOTHING** (Standard Library only)
- ❌ **Domain** NEVER imports `package:flutter`, `package:dio`, `package:firebase`

### 📦 The Data Flow Contract

- **DTOs (Data Transfer Objects):** exist **ONLY** in the Data Layer. They **NEVER** cross to Domain or UI.
- **Entities:** are the **ONLY** objects allowed to cross boundaries.

```
Datasource (returns DTO) → Repository (maps DTO → Entity) → UseCase → Bloc
```

---

## 2. Domain Layer (The "Product Truth")

**Path:** `lib/src/features/<feature>/domain/`

**Role:** The guardian of product correctness. Logic here is **unconditional** and **technology-agnostic**.

### ✅ The 9 Domain Rule Types

| # | Rule Type | Example |
|---|-----------|---------|
| 1 | **Validity** | "Task title cannot be empty" |
| 2 | **Permission** | "Only owner can delete" |
| 3 | **Quantity/Limits** | "Free tier max 5 projects" |
| 4 | **State Transitions** | "Cannot move from 'Delivered' to 'Shipped'" |
| 5 | **Field Dependencies** | "Urgent tasks must have a due date" |
| 6 | **Monetary/Pricing** | "Refunds only within 30 days" |
| 7 | **Time-based** | "Login bonus once per day" |
| 8 | **Data Invariants** | "Email must be unique" |
| 9 | **Workflow Sequence** | "Payment before Order Confirmation" |

### ❌ What MUST NOT be here

- **Flutter Code:** No `BuildContext`, Widgets, or UI logic
- **Infrastructure:** No HTTP, JSON, Database, or Firebase
- **User Messages:** Domain errors are technical (`InvalidTitle`), not user strings

---

## 3. Data Layer (The "Infrastructure")

**Path:** `lib/src/features/<feature>/data/`

### A. Repositories (The "Decision Maker")

**Implements:** Domain Repository Interface

| Responsibility | Example |
|----------------|---------|
| Decide Strategy | Local vs. Remote, Offline-first |
| Orchestrate | Fetch remote → Save local → Return |
| Map Errors | `DioException` → `ServerFailure` |
| Map Data | `UserDto` → `UserEntity` |
| Cross-Cutting | Analytics, Crash Reporting |

> **Rule:** Decides WHAT, WHEN, and WHY data is accessed.

### B. Datasources (The "Dumb Executor")

| Responsibility | Example |
|----------------|---------|
| Raw I/O | HTTP GET, Database Query |
| Serialization | JSON ↔ DTO |
| Throw Technical Errors | `Http500`, `SocketException` |

> **Rule:** Stateless execution only. No business logic. No decisions.

---

## 4. Presentation Layer (The "UI")

**Path:** `lib/src/features/<feature>/presentation/`

### A. State Management (Bloc/Cubit)

| Responsibility | Example |
|----------------|---------|
| Screen States | Loading, Success, Error, Empty |
| UX Guards | Debouncing, disable button while saving |
| UI Transformation | `User` → `UserUiModel` (format dates) |
| Visual Filtering | "Show only completed tasks" |

> **Rule:** Interprets system results for the UI.

### B. UI Widgets (The "Renderer")

| Responsibility | Example |
|----------------|---------|
| Pure Rendering | `if (state is Loading) return Spinner()` |
| Trivial Formatting | Colors, Icons, Padding |
| Wiring Actions | `onTap: () => cubit.submit()` |

> **Rule:** Dumb, minimal, and visual-only.

---

## 5. Quick Reference: Where Does It Go?

| Scenario | Layer | Common Mistake |
|----------|-------|----------------|
| "Email format is invalid" | **Domain** | Putting in UI validation |
| "Show error text in red" | **UI** | N/A |
| "Retry HTTP request 3 times" | **Repository** | Putting in Datasource |
| "JSON parsing" | **Datasource** | N/A |
| "User cannot save while loading" | **State Manager** | Putting in Domain |
| "Free users can't upload video" | **Domain** | Putting in UI |
| "Log 'purchase_failed' event" | **Repository** | Putting in UI |
| "Format date as 'Mon, Dec 22'" | **State Manager** | Putting in Domain |

---

## 6. Testing Strategy

| Layer | Coverage | Approach |
|-------|----------|----------|
| **Domain** | 100% | Pure Dart, no mocks needed |
| **Repository** | High | Mock Datasources |
| **State Management** | High | Mock Use Cases |

---

## 7. Related Documentation

- [Error Protocol](../data/error_protocol.md) - Exception & Failure handling
- [System Patterns](../data/system_patterns.md) - Detailed architecture patterns
- [Gold Standard Patterns](../examples/gold_standard_patterns.md) - Code templates
