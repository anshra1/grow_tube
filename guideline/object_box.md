# ObjectBox Dart — AI Reference

> **Package**: `objectbox: ^5.2.0`
> **Purpose**: Super-fast NoSQL ACID-compliant object database.
> **Key Concepts**: Pure Dart objects (Entities), Code Generation (Bindings), Box (Table), Store (Database).

---

## Setup

### Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  objectbox: ^5.2.0
  objectbox_flutter_libs: any # REQUIRED for Flutter apps (provides native binaries)
  path_provider: any          # Recommended for finding app documents directory

dev_dependencies:
  build_runner: ^2.4.11
  objectbox_generator: any
```

### Code Generation

ObjectBox relies on code generation. Run this command after any changes to `@Entity` classes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates `lib/objectbox.g.dart` which contains the `Store` bindings (like `openStore()`) and model definitions.

---

## Defining Entities

Annotate classes with `@Entity()`.

```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class User {
  @Id()
  int id = 0; // MUST be initialized to 0. ObjectBox assigns a real ID upon insertion.

  String name;

  @Property(type: PropertyType.date) // Optional: Specify type explicitly
  DateTime? dateJoined;

  @Transient() // Ignored by ObjectBox
  int? tempValue;

  // Relations
  final notes = ToMany<Note>();

  User({required this.name, this.dateJoined});
}
```

> **Rules**:
> *   **ID**: Must be `int id = 0;` (64-bit integer). 0 means "new object".
> *   **Constructor**: Must have a constructor that handles all persisted fields.

---

## Store Management

The `Store` is the database entry point. It's expensive to open, so **open it once** and keep it alive (e.g., using a Singleton, Provider, or GetIt).

```dart
import 'package:path_provider/path_provider.dart';
import 'objectbox.g.dart'; // Generated file

class ObjectBox {
  late final Store store;

  ObjectBox._create(this.store);

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "obx-demo"));
    return ObjectBox._create(store);
  }
}
```

---

## Basic Operations (CRUD)

Access the "box" for a specific entity type to perform operations.

```dart
final Box<User> userBox = store.box<User>();
```

### Create / Update (`put`)

```dart
final user = User(name: "Alice");
final id = userBox.put(user); // Returns the new ID.
// user.id is now updated to the new ID.

// Update:
user.name = "Alice Cooper";
userBox.put(user); // Overwrites existing object with same ID.
```

### Read (`get`)

```dart
final User? user = userBox.get(id);
final List<User> allUsers = userBox.getAll();
```

### Delete (`remove`)

```dart
final bool success = userBox.remove(id);
userBox.removeAll(); // Clear the box
```

---

## Queries

Queries use the generated `objectbox.g.dart` property definitions (e.g., `User_.name`).

```dart
// 1. Build Query
final Query<User> query = userBox
    .query(User_.name.startsWith("A") & User_.dateJoined.notNull())
    .order(User_.name)
    .build();

// 2. Execute
final List<User> results = query.find();
final User? first = query.findFirst();

// 3. Close (Reusing queries is efficient, close when done)
query.close();
```

### Property Queries

Extract specific field values directly without loading full objects.

```dart
final Query<User> query = userBox.query().build();
final PropertyQuery<int> idQuery = query.property(User_.id);
final List<int> allIds = idQuery.find();
```

---

## Relations

### ToOne

Link to a single object.

```dart
@Entity()
class Note {
  @Id() int id = 0;
  String text;

  final author = ToOne<User>(); // Define relation

  Note(this.text);
}

// Usage:
final note = Note("Hello world");
note.author.target = user; // Set relation
noteBox.put(note); // Saves relation automatically
```

### ToMany

Link to multiple objects.

```dart
// In User entity:
final notes = ToMany<Note>();

// Usage:
final user = User(name: "Bob");
user.notes.add(Note("Note 1"));
user.notes.add(Note("Note 2"));
userBox.put(user); // Saves user and the new notes automatically
```

> **Backlink**: ToMany relations are usually backed by a ToOne on the other side.
> *   `@Backlink('author')` on `ToMany<Note> notes` implies `Note` has `ToOne<User> author`.

---

## Advanced

### Transactions

Group operations for performance and consistency.

```dart
store.runInTransaction(TxMode.write, () {
  userBox.put(user1);
  userBox.put(user2);
});
```

### Async Operations

Use `putAsync`, `getAsync`, etc., or run operations in an isolate.

```dart
await userBox.putAsync(user);
```

---

## Common Pitfalls

1.  **Missing `objectbox-model.json`**: This file tracks your schema ID. commit it to version control!
2.  **`id` not initialized to 0**: If you set `id = null` or a random number, ObjectBox won't treat it as a new object insertion properly.
3.  **Forgot `build_runner`**: If `objectbox.g.dart` is missing or outdated, run the build command.
