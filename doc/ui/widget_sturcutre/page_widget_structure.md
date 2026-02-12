# Page-Based Widget Structure

This document defines how widgets are organized **within a page**. We follow a **"Local First"** approach — widgets live as close as possible to where they are used.

---

## Core Principle

> Every page folder is a **self-contained universe**. Its widgets are private to that page unless explicitly promoted.

---

## Folder Structure

```text
lib/features/shop/presentation/
 │
 ├── shared_widgets/                     <-- FEATURE-LEVEL SHARED
 │    ├── shop_product_card.dart         <-- Promoted! Used by Search & Details
 │    └── shop_sale_badge.dart           <-- Promoted! Used by Card & Details
 │
 └── pages/
      ├── search/
      │    ├── search_page.dart
      │    └── widgets/                  <-- Local (Private to this page)
      │         ├── search_input_bar.dart
      │         └── search_result_grid.dart (Imports ShopProductCard)
      │
      ├── product_details/
      │    ├── product_details_page.dart
      │    └── widgets/                  <-- Local (Private to this page)
      │         ├── product_image_carousel.dart
      │         ├── product_info_card.dart (Imports ShopSaleBadge)
      │         └── similar_products_list.dart (Imports ShopProductCard)
      │
      └── profile/
           ├── profile_page.dart
           └── widgets/                  <-- Local (Private to this page)
                └── profile_header_card.dart
```

---

## Widget Placement Rules

```text
Widget used by 1 page only          →  pages/<page_name>/widgets/
Widget used by 2+ pages in feature  →  shared_widgets/ (feature-level)
Widget used by 2+ features          →  lib/src/core/widgets/ (see global_widget_structure.md)
```

---

## Widget Tree Examples

### A. Search Page
*Context:* Even though `SearchInputBar` looks like a basic text field, it has specific logic (debounce, auto-focus) that only this page needs.

```text
SearchPage (Scaffold)
 └── Column
     ├── SearchInputBar           <-- (1) The text field area
     ├── SearchFilterChips        <-- (2) Row: [Price] [Color] [Brand]
     └── Expanded
          └── Stack
               ├── SearchEmptyState     <-- (3) "No results found" image
               ├── ListView
               │    ├── SearchPromoBanner    <-- (4) "50% Off Nike"
               │    ├── SearchRecentHistory  <-- (5) "Last searched: Puma"
               │    └── SearchResultGrid     <-- (6) The actual products
```

### B. Profile Page
*Context:* Completely different visual style from the rest of the app.

```text
ProfilePage (Scaffold)
 └── SingleChildScrollView
      └── Column
           ├── ProfileHeaderCard        <-- (1) User Photo & Name
           ├── ProfileWalletBadge       <-- (2) "Balance: $50.00"
           ├── ProfileOrderSummary      <-- (3) "Last order: Arriving Today"
           ├── Padding (Divider)
           ├── ProfileMenuOptions       <-- (4) "Account", "Privacy", "Help"
           ├── Row
           │    ├── Text("Dark Mode")
           │    └── ProfileDarkModeSwitch <-- (5) Toggle Switch
           └── ProfileLogoutButton      <-- (6) Red button at bottom
```

---

## Naming Convention

All page-level widgets should be **prefixed with the page name** for clarity.

| Page         | Widget Name              | ❌ Bad Name       |
|--------------|--------------------------|-------------------|
| Search       | `SearchInputBar`         | `InputBar`        |
| Search       | `SearchFilterChips`      | `FilterChips`     |
| Profile      | `ProfileHeaderCard`      | `HeaderCard`      |
| Profile      | `ProfileWalletBadge`     | `WalletBadge`     |

**Why?** Prefixing prevents accidental reuse across pages and makes file search instant.

---

## Why This Is Better

1. **No "God Classes":** Multiple developers can work on different widgets without merge conflicts.
2. **Context in Names:** `ProfileWalletBadge` tells you exactly what it is and where it belongs.
3. **Specific Logic:** `SearchInputBar` handles debounced API calls. `ProfileDarkModeSwitch` saves to local storage. Separate files = separate concerns.

---

## AI Instructions

When creating widgets for a page:
1. **Always place widgets inside `pages/<page_name>/widgets/`** unless they are shared.
2. **Always prefix the widget name with the page name** (e.g., `SearchInputBar`, not `InputBar`).
3. If a widget starts being used by a second page within the same feature, **promote it** to `shared_widgets/`.
4. For complex pages with many widgets, consider using the **Section-Based Structure** (see `section_widget_structure.md`).
