# Section-Based Widget Structure

This document defines how to break down **complex pages** into **Sections**. Use this when a page has too many widgets for a flat `widgets/` folder.

---

## When to Use Sections

Use sections when a page has **5+ distinct visual areas** or when the page file itself exceeds **100 lines**. Sections isolate each area's layout and logic into its own folder.

---

## Folder Structure

```text
lib/features/shop/presentation/pages/product_details/
 │
 ├── product_details_page.dart          <-- Main page file (coordinator, < 100 lines)
 │
 ├── sections/
 │    │
 │    ├── header_section/               <-- FOLDER per section
 │    │    ├── product_header_section.dart    <-- The Section widget
 │    │    └── widgets/                      <-- LOCKED to this section only
 │    │         ├── gallery_thumbnail.dart
 │    │         ├── flash_sale_timer.dart
 │    │         └── color_variant_picker.dart
 │    │
 │    └── feedback_section/             <-- FOLDER per section
 │         ├── product_feedback_section.dart
 │         └── widgets/                      <-- LOCKED to this section only
 │              ├── rating_bar.dart
 │              └── user_comment_bubble.dart
 │
 └── widgets/                           <-- Page-Level Widgets (shared across sections)
      ├── product_sticky_bottom_bar.dart
```

### Key Rules
- **Section widgets are LOCKED** — a section's `widgets/` folder is private to that section.
- **Page-level `widgets/`** — for widgets used by multiple sections or placed outside any section (e.g., sticky bars).
- **Main page file** — acts as a coordinator that assembles sections. Keep it under 100 lines.

---

## Widget Tree (Runtime View)

```text
ProductDetailsPage
 └── Column
      │
      ├── ProductHeaderSection          <-- The Section
      │    ├── ImageGallery
      │    │    └── GalleryThumbnail    <-- Section-Level Widget (Deepest)
      │    │
      │    ├── FlashSaleTimer           <-- Section-Level Widget (Deepest)
      │    └── ColorVariantPicker       <-- Section-Level Widget (Deepest)
      │
      ├── ProductFeedbackSection
      │    ├── RatingBar                <-- Section-Level Widget (Deepest)
      │    └── UserCommentBubble        <-- Section-Level Widget (Deepest)
      │
      └── ProductStickyBottomBar        <-- Page-Level Widget (Sibling to Sections)
```

---

## Code Examples

### A. The Main Page File (`product_details_page.dart`)
The page file coordinates sections. It should be clean and under 100 lines.

```dart
class ProductDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProductHeaderSection(),      // <--- Clean!
            Divider(),
            ProductContentSection(),     // <--- Clean!
            Divider(),
            ProductFeedbackSection(),    // <--- Clean!
          ],
        ),
      ),
      bottomNavigationBar: AddToCartStickyBar(), // Keep sticky elements on page level
    );
  }
}
```

### B. A Section File (`sections/feedback_section/product_feedback_section.dart`)
Handles the layout for a specific area of the page.

```dart
class ProductFeedbackSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Customer Reviews", style: Styles.h2),
          SizedBox(height: 16),
          ReviewHistogram(),           // <--- Uses Local Widget
          SizedBox(height: 24),
          ReviewListTile(user: "User A", stars: 5),
          ReviewListTile(user: "User B", stars: 4),
          Center(
            child: TextButton(onPressed: () {}, child: Text("View All")),
          )
        ],
      ),
    );
  }
}
```

---

## Widget Placement Decision

```text
Widget used by 1 section only            →  sections/<section_name>/widgets/
Widget used by 2+ sections on same page  →  pages/<page_name>/widgets/ (page-level)
Widget used by 2+ pages in feature       →  shared_widgets/ (feature-level)
Widget used by 2+ features               →  lib/src/core/widgets/ (global)
```

---

## AI Instructions

When working on a complex page:
1. **Check the line count** of the main page file. If it exceeds 100 lines, suggest splitting into sections.
2. **Create a `sections/` folder** inside the page folder.
3. **Each section gets its own folder** with a section widget and a local `widgets/` subfolder.
4. **Never import a section's private widget** from outside that section. If sharing is needed, promote the widget up one level.
5. **Name sections descriptively**: `header_section/`, `feedback_section/`, `pricing_section/`.
