---
description: How to safely modify a Domain Use Case and handle the ripple effect across all layers in Clean Architecture
---

# A Guide for AI Assistants: How to Safely Modify a Domain code

When you are asked to change a component in the **Domain Layer** (such as a Use Case or a Repository interface) of a Clean Architecture project, you are modifying its core business rules. Such a change is **never isolated**. You must assume it will have a ripple effect on all dependent layers.

**Do not consider the task complete until you have analyzed and, if necessary, modified the files in the following checklist.**

---

## Checklist for Analyzing the Ripple Effect of a Domain Layer Change

When you modify a **Use Case** or its parameters/return values:

### 1. Verify the Domain Layer First

| Component | Path Pattern | Action |
|-----------|-------------|--------|
| **Repository Interface** | `lib/src/features/<feature>/domain/repositories/<feature>_repository.dart` | Does the repository method that your use case calls need to change its signature (parameters or return type)? |
| **Entities** | `lib/src/features/<feature>/domain/entities/*.dart` | Does your change affect the structure of a core business entity? (e.g., making a field nullable). **Changing an entity has the widest possible impact.** |

---

### 2. Implement Changes in the Data Layer

| Component | Path Pattern | Action |
|-----------|-------------|--------|
| **Repository Implementation** | `lib/src/features/<feature>/data/repositories/<feature>_repository_impl.dart` | Update the concrete implementation to match the new interface signature. |
| **DTOs (Request/Response Models)** | `lib/src/features/<feature>/data/models/*.dart` | Add, remove, or make fields nullable. Check if serialization rules like `@JsonKey(includeIfNull: false)` are needed. |
| **DataSources** | `lib/src/features/<feature>/data/datasources/<feature>_remote_datasource.dart` | Update the abstract datasource (e.g., Retrofit interface) to reflect DTO changes. |
| **Generated Files** | `*.g.dart` files | Run `build_runner` to regenerate code after DTO or datasource changes. |

---

### 3. Implement Changes in the Presentation Layer

| Component | Path Pattern | Action |
|-----------|-------------|--------|
| **BLoC / Cubit** | `lib/src/features/<feature>/presentation/bloc/<feature>_bloc.dart` | Update the event handler that calls your use case. Handle new parameters or return values. |
| **BLoC State** | `lib/src/features/<feature>/presentation/bloc/<feature>_state.dart` | Does the new data from the use case require a state class change? |
| **BLoC Event** | `lib/src/features/<feature>/presentation/bloc/<feature>_event.dart` | Does the event need to carry different data? |
| **UI Pages/Widgets** | `lib/src/features/<feature>/presentation/pages/*.dart` | Update how the UI creates events and consumes state. |
| **App Router** | `lib/src/core/router/app_router.dart` | If the page receives data via navigation, update the route's builder to provide the correct data structure. |

---

### 4. Final Check: Update the Dependency Injection Container

| Component | Path Pattern | Action |
|-----------|-------------|--------|
| **DI Container** | `lib/src/core/di/injection_container.dart` | If you changed the constructor of any class (BLoC, Use Case, Repository), update its registration here. |

---

## Quick Reference: Dependency Flow

```
Domain Layer (Core Business Rules)
    │
    ├── Use Cases ────────► calls ────────► Repository Interface
    │                                              │
    └── Entities ◄─────────────────────────────────┘
                                                   │
                                                   ▼
Data Layer (External Interfaces)
    │
    ├── Repository Implementation ◄── implements ── Repository Interface
    │         │
    │         └── calls ──► DataSources ──► DTOs/Models
    │
    ▼
Presentation Layer (UI & State Management)
    │
    ├── BLoC/Cubit ◄── calls ── Use Cases
    │     │
    │     ├── Events (input)
    │     └── States (output)
    │              │
    │              ▼
    └── UI Pages/Widgets
              │
              ▼
        App Router (navigation data)
              │
              ▼
        DI Container (wires everything together)
```

---

## Summary

By following this comprehensive checklist, you will ensure that any change to a core business rule is implemented safely and completely across the entire feature stack, preventing both **compile-time** and **runtime errors**.

> [!TIP]
> After making changes, always run:
> 1. `dart run build_runner build --delete-conflicting-outputs` for generated files
> 2. `flutter analyze` to catch type errors
> 3. `flutter test` to verify nothing is broken
