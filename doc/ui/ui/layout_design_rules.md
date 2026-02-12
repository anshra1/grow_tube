# Layout Design Rules

> **Core Principle**: Layout controls space and structure. Components control content and visuals.

---

## Table of Contents

1. [Layout Responsibilities](#layout-responsibilities)
2. [Layout Architecture](#layout-architecture)
3. [Implementation Pattern](#implementation-pattern)
4. [Layout Design Principles](#layout-design-principles)
5. [Quick Reference](#quick-reference)

---

## Layout Responsibilities

### What a Layout SHOULD Define

- ✅ How wide a component is
- ✅ Whether it stretches
- ✅ Whether it is constrained
- ✅ How many items per row
- ✅ Alignment of components
- ✅ Spacing between components
- ✅ Vertical rhythm
- ✅ Section spacing
- ✅ Group spacing
- ✅ Content density
- ✅ Breathing room

### What a Layout MUST NOT Define

- ❌ Component internal styles
- ❌ Component states (hover, focus, etc.)
- ❌ Component typography
- ❌ Component internal padding
- ❌ Component visual appearance

---

## Layout Architecture

### High-Level Structure

Your mobile application should follow this pattern:

```
Page
 └── Layout
       ├── Section 1
       ├── Section 2
       └── Section 3
```

**Key principle**: Layout decides structure, components handle content.

### Why This Matters

- **Separation of concerns**: Layout decides structure, components handle content
- **Reusability**: Same components work across different layouts
- **Maintainability**: Change layout without touching components
- **Testability**: Test components independently of layout

---

## Implementation Pattern

### Step 1: Create Layout Widget

Layouts define **structure only**, not content:

```dart
class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          HeroSection(),
          Gap(24),
          ProjectsSection(),
          Gap(24),
          ContactSection(),
        ],
      ),
    );
  }
}
```

---

### Step 2: Use Layout in Pages

Your page delegates layout decisions to the layout widget:

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: HomeLayout(),
    );
  }
}
```

---

### Step 3: Keep Components Size-Neutral

Components must not know about their layout context:

```dart
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppRadius.roundedM,
        boxShadow: AppShadows.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Project Title"),
          Gap(AppSpacing.xs),
          Text("Description"),
          Gap(AppSpacing.m),
          PrimaryButton(),
        ],
      ),
    );
  }
}
```

**Notice**:
- ❌ No width defined
- ❌ No layout decisions
- ✅ Only internal padding and styling

---

## Layout Design Principles

### Principle 1: Layout Controls Space, Not Components

Layout must control:
- ✔ Vertical rhythm
- ✔ Section spacing
- ✔ Group spacing
- ✔ Content density
- ✔ Breathing room

Components must not:
- ❌ Define external margins
- ❌ Control spacing to siblings

---

### Principle 2: Layout Should Be Declarative

**❌ Bad mental model** (imperative):
> "Calculate spacing based on screen size"

```dart
// Bad: Manual calculations
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final spacing = screenHeight * 0.02;
  
  return Column(
    children: [
      Section1(),
      SizedBox(height: spacing),
      Section2(),
    ],
  );
}
```

**✅ Good mental model** (declarative):
> "This layout expresses a structure with consistent spacing"

```dart
// Good: Declarative layout
Widget build(BuildContext context) {
  return Column(
    children: [
      Section1(),
      Gap(16),
      Section2(),
    ],
  );
}
```

Think: **composition**, not conditions.

---

### Principle 3: Avoid Magical Behavior

**❌ Bad** (magical behavior):
> "This button becomes full width automatically"

```dart
// Bad: Component decides its width based on context
class MagicalButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Magic inside component
      child: ElevatedButton(...),
    );
  }
}
```

**✅ Good** (explicit layout):
> "This layout makes the button full width"

```dart
// Good: Layout decides button width
SizedBox(
  width: double.infinity,
  child: PrimaryButton(),
)
```

Magic causes confusion. Be explicit.

---

### Principle 4: Layout Must Allow Change

If changing layout requires editing many components, your system is broken.

**A correct system lets you:**
- ✔ Swap layouts without touching components
- ✔ Adjust spacing globally
- ✔ Rearrange sections easily

**Example**: Changing spacing between sections

```dart
// Before
Gap(16)

// After
Gap(24)

// Components don't change at all ✅
```

---

## Quick Reference

### Layout vs Component Responsibilities

| Concern | Layout | Component |
|---------|--------|-----------|
| Width/Height | ✅ | ❌ |
| Max-width | ✅ | ❌ |
| External margins | ✅ | ❌ |
| Gaps between items | ✅ | ❌ |
| Alignment in page | ✅ | ❌ |
| Vertical rhythm | ✅ | ❌ |
| Internal padding | ❌ | ✅ |
| Visual style | ❌ | ✅ |
| States (hover/focus) | ❌ | ✅ |
| Typography | ❌ | ✅ |
| Content rendering | ❌ | ✅ |

### Layout Pattern Checklist

When creating a new layout:

- [ ] Layout defines spacing, not components
- [ ] Layout defines component widths, not components
- [ ] Components work in any layout without modification
- [ ] Layout is declarative, not imperative
- [ ] No magical behavior (explicit sizing)
- [ ] Can swap layouts without breaking components

### Common Layout Patterns

#### Pattern 1: Simple Scrollable Layout

```dart
class HomeLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          HeroSection(),
          Gap(24),
          FeaturesSection(),
          Gap(24),
          FooterSection(),
        ],
      ),
    );
  }
}
```

#### Pattern 2: List Layout

```dart
class ProjectsLayout extends StatelessWidget {
  final List<Project> projects;
  
  const ProjectsLayout({required this.projects});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: projects.length,
      separatorBuilder: (_, __) => Gap(16),
      itemBuilder: (context, index) {
        return ProjectCard(project: projects[index]);
      },
    );
  }
}
```

#### Pattern 3: Grid Layout

```dart
class GalleryLayout extends StatelessWidget {
  final List<Item> items;
  
  const GalleryLayout({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ItemCard(item: items[index]);
      },
    );
  }
}
```

#### Pattern 4: Full-Width Button in Layout

```dart
class FormLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmailField(),
          Gap(16),
          PasswordField(),
          Gap(24),
          PrimaryButton(text: 'Submit'), // Stretches full width
        ],
      ),
    );
  }
}
```

---

**Remember**: Layout = Structure. Component = Content. Keep them separate.
