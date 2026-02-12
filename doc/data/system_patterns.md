# System Patterns: Flutter Clean Architecture & BLoC

This document defines the architectural DNA of the project. **AI agents MUST adhere to these patterns.**

---

## 1. Core Architecture

| Aspect | Standard |
|--------|----------|
| Pattern | Strict Clean Architecture (Presentation → Domain → Data) |
| Dependency Rule | Dependencies **only point inwards** |
| Structure | Feature-first (`lib/features/[feature]/[layer]`) |
| State Management | `flutter_bloc` |
| Imports | Absolute package imports |

### Decision Framework: "Who Says No?"

| Authority | Layer | Example |
|-----------|-------|---------|
| OS / Device | UI / Presentation | "Screen too small", "Double tap ignored" |
| Infrastructure | Data Layer | "No internet", "Server 500" |
| Product Rules | Domain Layer | "User not admin", "Balance insufficient" |

---

## 2. Domain Layer (Pure Dart)

### Entities
- Use `@freezed` annotation (immutable with `copyWith`)
- Pure Dart classes (no Flutter imports)
- No JSON/serialization logic (that belongs in Models)

### Repository Interfaces
- Abstract classes (contracts only)
- Return domain entities
- Use `ResultFuture<T>` types

### Use Cases

| Rule | Guideline |
|------|-----------|
| Responsibility | Wraps exactly **one** repository method |
| Base Class | Extend `FutureUseCaseWithParams`, `FutureUseCaseWithoutParams`, etc. |
| Entry Point | Use `call()` method pattern |
| Return Type | Must return `ResultFuture<T>` or `ResultStream<T>` |

**File Organization:**
- Simple CRUD use cases → Group in `[feature]_usecases.dart`
- Complex use cases (validation, 15+ lines) → Own file `[action]_usecase.dart`
- If grouped file exceeds ~200 lines → Split it

### Domain Logic Categories (The "9 Rules")

1. **Validity** — "Task title cannot be empty"
2. **Permission** — "Only owner can delete"
3. **Quantity/Limits** — "Free tier max 5 projects"
4. **State Transitions** — "Cannot move from Delivered to Shipped"
5. **Field Dependencies** — "Urgent tasks must have due date"
6. **Monetary/Pricing** — "Refunds only within 30 days"
7. **Time-based** — "Login bonus once per day"
8. **Data Invariants** — "Email must be unique"
9. **Workflow Sequence** — "Payment before Order Confirmation"

---

## 3. Data Layer

### Models (DTOs)
- Use `@freezed` annotation
- Include `fromJson`/`toJson` via `json_serializable`
- Implement `toEntity()` method

### Data Sources ("Dumb Executor")

| Allowed | Forbidden |
|---------|-----------|
| Raw I/O (HTTP, DB query) | Business logic |
| JSON ↔ DTO serialization | Branching decisions |
| Throw `AppException` | Return `Result` types |

### Repository Implementation ("Decision Maker")

**Smart Repo Protocol — Allowed Logic:**

| Category | Example |
|----------|---------|
| Routing | Remote vs Local source selection |
| Policy | Business rules application |
| Error Mapping | `ServerException` → `ServerFailure` |
| Aggregation | Combining multiple sources |
| Transformation | In-memory processing |
| Cross-Cutting | Analytics, crash reporting |

> If none apply → Pure delegation only

---

## 4. Presentation Layer

### BLoC/Cubit Responsibilities

| Task | Example |
|------|---------|
| Screen States | Loading, Success, Error, Empty |
| UX Guards | Debouncing, disable button while saving |
| UI Transformation | `User` → `UserUiModel` |
| Visual Filtering | "Show only completed tasks" |

### Widget Responsibilities
- Pure rendering based on state
- Trivial formatting (colors, icons, padding)
- Wiring actions to Cubit methods

---

## 5. Error Handling

| Aspect | Rule |
|--------|------|
| Return Type | `Future<Either<Failure, T>>` |
| Left | `Failure` class hierarchy |
| Right | Success data |
| Handling | Use `.fold()` in BLoC |

> [!CAUTION]
> No `try-catch` in Domain or Presentation layers. Failures must be explicit via `Either`.

---

## 6. Dependency Injection

| Lifecycle | Use For |
|-----------|---------|
| `registerFactory` | BLoCs (new instance per screen) |
| `registerLazySingleton` | Use Cases, Repositories, Data Sources |

---

## 7. Naming Conventions

| Component | Pattern | Example |
|-----------|---------|---------|
| Use Cases | `VerbNoun` | `GetUserProfile` |
| Repositories | `FeatureRepository` | `TaskRepository` |
| Data Sources | `Remote/LocalFeatureDataSource` | `RemoteTaskDataSource` |


