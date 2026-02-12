# Bloc Library: Technical Operating Manual

## Part 1: Philosophy & Mental Model

### The Analogy: The Industrial Assembly Line
The Bloc library acts as a **reactive assembly line** coupled with a **flight recorder**.
*   **The Assembly Line**: Raw materials (**Events**) enter the factory floor. The **Bloc** (processing unit) transforms these materials through a serialized event loop. The finished products (**States**) are shipped to the loading dock (**UI**).
*   **Layered Architecture**:
    1.  **Data Layer** (Repositories): Abstraction over API/DB. *Never knows about Blocs.*
    2.  **Business Logic Layer** (Bloc): Bridges Data and UI. Receives Events, emits States.
    3.  **Presentation Layer** (UI): Renders State, sends Events.

### Data Flow
*   **Unidirectional**: UI → Event → Bloc → State → UI.
*   **Ownership**: The Bloc instance owns the state absolutely.
*   **Immutability**: States are immutable. Updates involve emitting a new instance.

---

## Part 2: Authoring Standards (Defining Logic)

### 1. Naming Conventions (Usage-Based)
Adhere to these rules to maintain codebase consistency.

#### Events: UI → Bloc (The "What Happened" Layer)
*   **Tense**: Must be **Past Tense**.
*   **Suffix**: Must strictly end with `Event`.
*   **Syntax**: `[Subject] + [Action (Verb)] + [Context] + Event`
*   **Examples**:
    *   ✅ `CounterIncrementPressedEvent` (User pressed it)
    *   ✅ `OrderSubmittedEvent` (System event)
    *   ❌ `IncrementCounter` (Missing suffix/Imperative)

#### States: Bloc → UI (The "Snapshot" Layer)
*   **Structure**: Use a **Sealed Class Hierarchy** (Separate classes).
*   **Suffix**: Must strictly end with `State`.
*   **Syntax**: `[Subject] + [Status] + State`
*   **Examples**:
    *   ✅ `CounterLoadSuccessState`
    *   ✅ `AuthFailureState`
    *   ❌ `CounterLoaded` (Missing suffix)

### 2. Equatable: The Foundation of State Comparison

All States and Events **must** extend `Equatable` and override `props`. This is critical for Bloc to detect state changes.

```dart
import 'package:equatable/equatable.dart';

sealed class CounterState extends Equatable {
  const CounterState();
  
  @override
  List<Object?> get props => [];
}

final class CounterSuccessState extends CounterState {
  final int value;
  const CounterSuccessState(this.value);
  
  @override
  List<Object?> get props => [value]; // Include ALL fields!
}
```

> [!CAUTION]
> Forgetting to include a property in `props` will cause `stateA == stateB` to return `true`, and the UI will never update.

### 3. The Sealed Class Hierarchy Pattern

Use **separate state classes** for each distinct application state. This approach:
- Ensures each state holds only its relevant data
- Enables exhaustive `switch` expressions for type safety
- Eliminates the need for `copyWith` — you emit entirely new state instances

```dart
// ✅ CORRECT: Sealed Hierarchy - Each state is self-contained
sealed class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object?> get props => [];
}

final class TaskInitialState extends TaskState {}

final class TaskLoadingState extends TaskState {}

final class TaskSuccessState extends TaskState {
  final List<Task> tasks;  // Only exists in success state
  const TaskSuccessState(this.tasks);
  
  @override
  List<Object?> get props => [tasks];
}

final class TaskFailureState extends TaskState {
  final String message;  // Only exists in failure state
  const TaskFailureState(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

> [!IMPORTANT]
> With sealed hierarchies, state transitions are **replacements**, not modifications. You emit a completely new state class instance.

```dart
// Transition examples - no copyWith needed
emit(TaskLoadingState());                    // Replace with loading
emit(TaskSuccessState(fetchedTasks));        // Replace with success
emit(TaskFailureState('Network error'));     // Replace with failure
```

### 4. The Golden Path: Bloc
Use `Bloc` when you need event traceability or advanced event transformation (debounce, throttle).

```dart
// Event
sealed class CounterEvent extends Equatable {
  const CounterEvent();
  @override
  List<Object?> get props => [];
}

final class CounterIncrementPressedEvent extends CounterEvent {}

// State (Sealed Hierarchy)
sealed class CounterState extends Equatable {
  const CounterState();
  @override
  List<Object?> get props => [];
}

final class CounterInitialState extends CounterState {}

final class CounterSuccessState extends CounterState {
  final int value;
  const CounterSuccessState(this.value);
  
  @override
  List<Object?> get props => [value];
}

// Logic
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitialState()) {
    on<CounterIncrementPressedEvent>(_onIncrementPressed);
  }
  
  void _onIncrementPressed(
    CounterIncrementPressedEvent event,
    Emitter<CounterState> emit,
  ) {
    final currentValue = switch (state) {
      CounterSuccessState(:final value) => value,
      _ => 0,
    };
    emit(CounterSuccessState(currentValue + 1));
  }
}
```

### 5. The Simpler Path: Cubit
Use `Cubit` for simple state management where event tracking is unnecessary.

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}
```

---

## Part 3: Dependency Management (Wiring)

### 1. The Provider Pattern
Use `BlocProvider` to create and close Blocs. It manages the lifecycle of the business logic.

```dart
BlocProvider(
  create: (context) => CounterBloc(),
  child: const CounterPage(),
)
```

### 2. Multi-Provider
Use `MultiBlocProvider` to avoid the "Pyramid of Doom" when providing multiple dependencies.

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => BlocA()),
    BlocProvider(create: (context) => BlocB()),
  ],
  child: const App(),
)
```

---

## Part 4: UI Interaction (Consumption Layer)

### 1. Rebuild Extensions: read, watch, select
These extensions are the primary way to interact with Blocs from the UI.

| Method | Usage | Rebuilds Widget? | Recommended Location |
| :--- | :--- | :--- | :--- |
| `context.read<T>()` | To add events/call methods | **No** | Callbacks (`onPressed`) |
| `context.watch<T>()` | To listen to full state | **Yes** | `build` method (Small widgets) |
| `context.select<T, R>()` | To listen to part of state | **Yes** (Only on change) | `build` method (Optimization) |

### 2. BlocBuilder vs BlocListener vs BlocConsumer

| Widget | Purpose | Use Case |
| :--- | :--- | :--- |
| `BlocBuilder` | Rebuild UI based on state | Displaying data, forms, lists |
| `BlocListener` | Side-effects (no rebuild) | Navigation, Snackbars, Dialogs |
| `BlocConsumer` | Both builder + listener | When you need both in one widget |

```dart
// BlocListener: For side-effects only
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthFailureState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
    if (state is AuthUnauthenticatedState) {
      context.go('/login');
    }
  },
  child: const HomeScreen(),
)

// BlocConsumer: When you need both
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthFailureState) {
      showErrorDialog(context, state.message);
    }
  },
  builder: (context, state) {
    return switch (state) {
      AuthLoadingState() => const LoadingSpinner(),
      AuthSuccessState(:final user) => UserProfile(user: user),
      _ => const LoginPrompt(),
    };
  },
)
```

### 3. Filtering Rebuilds: `buildWhen`
`buildWhen` is an **optional** callback on `BlocBuilder` and `BlocConsumer`. It receives the `previous` and `current` state and returns a `bool`. If it returns `false`, the `builder` is **not** called — the widget keeps its old UI.

**Mental Model**: Think of `buildWhen` as a **bouncer at the door** of the `builder`. It decides which state changes are "allowed in" to trigger a rebuild.

#### When to Use
| Scenario | Example |
| :--- | :--- |
| Widget only cares about **one specific state subtype** | A form card that should only rebuild for `AuthSuccessState`, not `AuthLoadingState` |
| Prevent **unnecessary rebuilds** from unrelated state changes | A counter display that shouldn't flicker during a reset animation state |
| **Multiple Blocs** influence a screen, and each widget should react to its own slice | A dashboard where the stats panel ignores notification-related states |

#### Syntax & Rules

```dart
BlocBuilder<AuthBloc, AuthState>(
  buildWhen: (previous, current) {
    // Return true  → builder runs (widget rebuilds)
    // Return false → builder skipped (widget keeps old UI)
    return current is AuthSuccessState || current is AuthFailureState;
  },
  builder: (context, state) {
    return switch (state) {
      AuthSuccessState(:final user) => UserProfile(user: user),
      AuthFailureState(:final error) => ErrorBanner(message: error),
      _ => const SizedBox.shrink(), // Fallback for initial render
    };
  },
)
```

> [!IMPORTANT]
> `buildWhen` is checked on **every state change after the first build**. The very first time the widget is built, the `builder` always runs regardless of `buildWhen`.

#### Real-World Example: Auth Screen

```dart
// Only rebuild the form when loading starts or finishes — 
// ignore navigation-related states handled by the listener.
BlocBuilder<AuthBloc, AuthState>(
  buildWhen: (previous, current) =>
      current is AuthLoadingState ||
      current is AuthSuccessState ||
      current is AuthFailureState,
  builder: (context, state) {
    final isLoading = state is AuthLoadingState;
    return Column(
      children: [
        EmailField(enabled: !isLoading),
        PasswordField(enabled: !isLoading),
        SubmitButton(isLoading: isLoading),
        if (state is AuthFailureState)
          ErrorText(state.message),
      ],
    );
  },
)
```

### 4. Filtering Side-Effects: `listenWhen`
`listenWhen` is an **optional** callback on `BlocListener` and `BlocConsumer`. Same signature as `buildWhen` — receives `previous` and `current`, returns a `bool`. If it returns `false`, the `listener` is **not** called.

**Mental Model**: Think of `listenWhen` as a **filter on the event stream** before side-effects fire. It prevents snackbars, navigation, and dialogs from triggering on irrelevant state changes.

#### When to Use
| Scenario | Example |
| :--- | :--- |
| Only show error feedback for **specific failure states** | Show a snackbar only for `AuthFailureState`, not for `DataFailureState` |
| Navigate **only on a specific transition** | Push to home only when state transitions from loading → authenticated |
| Prevent **duplicate side-effects** | Avoid showing the same dialog twice when state re-emits |

#### Syntax & Rules

```dart
BlocListener<AuthBloc, AuthState>(
  listenWhen: (previous, current) {
    // Return true  → listener fires
    // Return false → listener skipped
    return current is AuthFailureState || current is AuthSuccessState;
  },
  listener: (context, state) {
    if (state is AuthFailureState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
    if (state is AuthSuccessState) {
      context.go('/home');
    }
  },
  child: const AuthForm(),
)
```

#### Real-World Example: Transition-Based Navigation

```dart
// Navigate to home ONLY when transitioning from loading → success.
// This prevents re-navigation if another event re-emits AuthSuccessState.
BlocListener<AuthBloc, AuthState>(
  listenWhen: (previous, current) =>
      previous is AuthLoadingState && current is AuthSuccessState,
  listener: (context, state) {
    context.go('/home');
  },
  child: const AuthForm(),
)
```

### 5. Combined: `buildWhen` + `listenWhen` in `BlocConsumer`
`BlocConsumer` accepts **both** callbacks, giving you independent control over rebuilds and side-effects.

```dart
BlocConsumer<AuthBloc, AuthState>(
  // Only rebuild the form for loading/failure states
  buildWhen: (previous, current) =>
      current is AuthLoadingState || current is AuthFailureState,

  // Only fire side-effects for success/failure states
  listenWhen: (previous, current) =>
      current is AuthSuccessState || current is AuthFailureState,

  listener: (context, state) {
    if (state is AuthSuccessState) {
      context.go('/home');
    }
    if (state is AuthFailureState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    final isLoading = state is AuthLoadingState;
    return AuthForm(
      isLoading: isLoading,
      errorMessage: state is AuthFailureState ? state.message : null,
    );
  },
)
```

> [!CAUTION]
> **Anti-Pattern: Over-filtering.** Don't use `buildWhen` / `listenWhen` to filter out the **initial** state. The first build always runs regardless, and filtering the initial state in `listenWhen` can mask bugs where the listener never fires.
>
> ```dart
> // ❌ WRONG: Filtering too aggressively — will miss edge cases
> buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
>
> // ✅ CORRECT: Be explicit about which states you care about
> buildWhen: (prev, curr) => curr is AuthLoadingState || curr is AuthFailureState,
> ```

### 6. Optimized Selection: `BlocSelector`
**Best Practice**: Use this to stop rebuilding the entire widget when only one field changes. It acts like a filter/mapper.

```dart
// Only rebuilds if 'value' changes in SuccessState.
BlocSelector<CounterBloc, CounterState, int>(
  selector: (state) => state is CounterSuccessState ? state.value : 0,
  builder: (context, value) {
    return Text('Count: $value');
  },
)
```

### 7. Navigation: `BlocProvider.value`
To share an *existing* instance with a new route:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: context.read<CounterBloc>(),
      child: const NextScreen(),
    ),
  ),
);
```

---

## Part 5: Advanced Engineering (Guardrails)

### 1. Error Handling Pattern
Always handle errors gracefully within event handlers.

```dart
on<DataFetchRequestedEvent>((event, emit) async {
  emit(DataLoadingState());
  
  final result = await repository.fetchData();
  
  result.fold(
    (failure) => emit(DataFailureState(failure.message)),
    (data) => emit(DataSuccessState(data)),
  );
});
```

### 2. Reactivity: `emit.forEach` and `emit.onEach`
Bridge Data Layer Streams to the Bloc safely. Handles subscription/unsubscription automatically.

```dart
// emit.forEach: Replace state on each emission
on<SubscriptionRequestedEvent>((event, emit) async {
  await emit.forEach<int>(
    repository.intStream(),
    onData: (value) => DataSuccessState(value),
    onError: (error, stackTrace) => DataFailureState(error.toString()),
  );
});

// emit.onEach: Side-effects per emission (doesn't replace state)
on<NotificationSubscribedEvent>((event, emit) async {
  await emit.onEach<Notification>(
    repository.notificationStream(),
    onData: (notification) {
      // Trigger side-effect, then emit
      _showLocalNotification(notification);
      emit(NotificationReceivedState(notification));
    },
  );
});
```

### 3. Concurrency: Transformers
Control how events are processed (e.g., `restartable()`, `droppable()`).

```dart
import 'package:bloc_concurrency/bloc_concurrency.dart';

on<SearchTextChangedEvent>(
  (event, emit) async { ... },
  transformer: restartable(), // Cancels previous search if typing continues
);
```

| Transformer | Behavior |
| :--- | :--- |
| `concurrent()` | Process all events concurrently (default) |
| `sequential()` | Process events one at a time in order |
| `droppable()` | Ignore new events while processing current |
| `restartable()` | Cancel current and start new on each event |

### 4. Safety: Exhaustive Switching
Use Dart 3 `sealed` classes to ensure the UI handles every possible state.

```dart
return switch (state) {
  AuthInitialState() => const LoginScreen(),
  AuthLoadingState() => const LoadingSpinner(),
  AuthAuthenticatedState(:final user) => HomeScreen(user: user),
  AuthFailureState(:final error) => ErrorScreen(message: error),
};
```

### 5. Critical Rules (The "Musts")

*   **Bloc-to-Bloc Communication**:
    *   ❌ **Forbidden**: Blocs listening to other Blocs' streams directly.
    *   ✅ **Allowed**: UI Orchestration (UI listens to A, adds event to B) or Repo Sync (Both listen to Repo).

*   **Single-Path Mutation**: Enforce exactly one way to change a specific state. No back-door methods or public setters.

### 6. Anti-Patterns (The "Foot-Guns")

#### The "Same Context" Trap
*   **Anti-Pattern**: Trying to `context.read<MyBloc>()` in the *same* widget that created the `BlocProvider`.
*   **Fix**: Wrap the child in a `Builder` or extract it to a separate widget class.

```dart
// ❌ WRONG
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyBloc(),
      child: ElevatedButton(
        onPressed: () => context.read<MyBloc>().add(MyEvent()), // CRASH!
        child: const Text('Press'),
      ),
    );
  }
}

// ✅ CORRECT
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyBloc(),
      child: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => context.read<MyBloc>().add(MyEvent()), // Works!
          child: const Text('Press'),
        ),
      ),
    );
  }
}
```

#### Broken Equatable
*   **Anti-Pattern**: Forgetting to include a property in `props` or modifying a List/Map in place.
*   **Result**: `stateA == stateB` returns true, so the UI never updates.

#### In-Place Mutation
*   **Anti-Pattern**: `state.list.add(item); emit(state);`
*   **Result**: Bloc compares objects by reference (same instance), so no update triggers.
*   **Fix**: Emit a **new state class instance** with the updated data:

```dart
// ❌ WRONG: Mutating existing state
if (state is TaskSuccessState) {
  state.tasks.add(newTask);  // Mutating in place!
  emit(state);               // Same reference, no update
}

// ✅ CORRECT: Emit new state with new list
if (state is TaskSuccessState) {
  emit(TaskSuccessState([...state.tasks, newTask]));  // New instance
}
```

---

## Part 6: Observability: The BlocObserver Flight Recorder

### 1. Global Monitoring: `BlocObserver`
The "Flight Recorder" that logs every transition and error in the system.

```dart
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('onCreate: ${bloc.runtimeType}');
  }
  
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('onEvent: ${bloc.runtimeType} -> $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('onTransition: ${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('onError: ${bloc.runtimeType} $error');
    super.onError(bloc, error, stackTrace);
  }
  
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('onClose: ${bloc.runtimeType}');
  }
}

// Register in main.dart
void main() {
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}
```

### 2. Verification: Testing Strategy
Use `bloc_test` for declarative `build` → `act` → `expect` verification.

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  
  setUp(() {
    mockRepository = MockRepository();
  });

  blocTest<CounterBloc, CounterState>(
    'emits [CounterSuccessState(1)] when CounterIncrementPressedEvent is added',
    build: () => CounterBloc(),
    act: (bloc) => bloc.add(CounterIncrementPressedEvent()),
    expect: () => [const CounterSuccessState(1)],
  );
  
  blocTest<DataBloc, DataState>(
    'emits [Loading, Success] when fetch succeeds',
    setUp: () {
      when(() => mockRepository.fetchData())
          .thenAnswer((_) async => Right(mockData));
    },
    build: () => DataBloc(repository: mockRepository),
    act: (bloc) => bloc.add(DataFetchRequestedEvent()),
    expect: () => [
      DataLoadingState(),
      DataSuccessState(mockData),
    ],
    verify: (_) {
      verify(() => mockRepository.fetchData()).called(1);
    },
  );
}
```

**Testing Rules**:
*   ✅ Test outputs (States), not internals.
*   ✅ Mock all Repositories.
*   ✅ Use `seed` for initial state setup.
*   ✅ Use `verify` to ensure repository methods were called.

---

## Quick Reference

| Concept | When to Use |
| :--- | :--- |
| `Bloc` | Complex logic, event traceability, transformers needed |
| `Cubit` | Simple state, no event tracking needed |
| `BlocBuilder` | Rebuild UI based on state |
| `BlocListener` | Side-effects (navigation, snackbars) |
| `BlocConsumer` | Need both builder and listener |
| `buildWhen` | Filter which state changes trigger a rebuild |
| `listenWhen` | Filter which state changes trigger side-effects |
| `BlocSelector` | Optimize rebuilds for specific state fields |
| `context.read()` | In callbacks, to dispatch events |
| `context.watch()` | In build, to rebuild on any state change |
| `context.select()` | In build, to rebuild on specific field change |
