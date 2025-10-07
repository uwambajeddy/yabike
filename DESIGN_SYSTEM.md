# YaBike Design System

## 🎨 Overview

This design system provides a comprehensive set of guidelines, components, and standards for the YaBike personal finance management app. It ensures consistency, usability, and a modern, friendly aesthetic throughout the application.

## 📝 Typography

### Primary Font: Plus Jakarta Sans

**Font Family**: Plus Jakarta Sans
- Modern, clean sans-serif typeface
- Excellent readability across all sizes
- Available weights: Regular (400), Medium (500), Semi-bold (600), Bold (700)

### Typography Scale

#### Display Styles (Headers, Titles)
- **Display Large**: 32px, Bold, -0.5 letter spacing
- **Display Medium**: 28px, Bold, -0.5 letter spacing
- **Display Small**: 24px, Bold

#### Headline Styles (Section Headers)
- **Headline Large**: 22px, Semi-bold (600)
- **Headline Medium**: 20px, Semi-bold (600)
- **Headline Small**: 18px, Semi-bold (600)

#### Title Styles (Card Titles, Labels)
- **Title Large**: 16px, Semi-bold (600)
- **Title Medium**: 14px, Semi-bold (600)
- **Title Small**: 12px, Semi-bold (600)

#### Body Styles (Content Text)
- **Body Large**: 16px, Regular (400)
- **Body Medium**: 14px, Regular (400)
- **Body Small**: 12px, Regular (400)

#### Label Styles (Buttons, Tags)
- **Label Large**: 14px, Medium (500)
- **Label Medium**: 12px, Medium (500)
- **Label Small**: 10px, Medium (500)

### Usage in Code

```dart
import 'package:google_fonts/google_fonts.dart';

Text(
  'Hello World',
  style: GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
)

// Or use theme
Text(
  'Hello World',
  style: Theme.of(context).textTheme.headlineMedium,
)
```

## 🎨 Color Palette

### Primary Colors (Green)

Our brand color representing growth, prosperity, and financial health.

| Shade | Hex Code | Usage |
|-------|----------|-------|
| Primary 100 | `#E8F5E9` | Light backgrounds, hover states |
| Primary 200 | `#C8E6C9` | Secondary backgrounds |
| Primary 300 | `#A5D6A7` | Light accents |
| Primary 400 | `#81C784` | Medium accents |
| **Primary 500** | **`#66BB6A`** | **Main brand color** |
| Primary 600 | `#4CAF50` | Hover states, active elements |
| Primary 700 | `#43A047` | Dark accents |
| Primary 800 | `#388E3C` | Strong emphasis |
| Primary 900 | `#2E7D32` | Darkest shade |

### Danger/Error Colors (Red)

Used for errors, warnings, and destructive actions.

| Shade | Hex Code | Usage |
|-------|----------|-------|
| Danger 100 | `#FFEBEE` | Error backgrounds |
| Danger 200 | `#FFCDD2` | Light error states |
| Danger 300 | `#EF9A9A` | Medium error states |
| Danger 400 | `#E57373` | Error accents |
| **Danger 500** | **`#F44336`** | **Main error color** |
| Danger 600 | `#E53935` | Error hover |
| Danger 700 | `#D32F2F` | Strong error |
| Danger 800 | `#C62828` | Critical errors |
| Danger 900 | `#B71C1C` | Darkest error |

### Grayscale - White

| Name | Hex Code | Usage |
|------|----------|-------|
| White Primary | `#FFFFFF` | Main backgrounds, cards |
| White Secondary | `#FAFAFA` | Secondary backgrounds |
| White Tertiary | `#F5F5F5` | Tertiary backgrounds |
| White Quaternary | `#EEEEEE` | Disabled backgrounds |

### Grayscale - Gray

| Name | Hex Code | Usage |
|------|----------|-------|
| Gray Primary | `#E0E0E0` | Borders, dividers |
| Gray Secondary | `#BDBDBD` | Secondary text, disabled |
| Gray Tertiary | `#9E9E9E` | Hint text |
| Gray Quaternary | `#757575` | Secondary text |
| Gray Quinary | `#616161` | Body text (dark) |
| Gray Senary | `#424242` | Dark surfaces |
| Gray Septenary | `#303030` | Darker surfaces |

### Grayscale - Black

| Name | Hex Code | Usage |
|------|----------|-------|
| Black Primary | `#424242` | Primary text |
| Black Secondary | `#303030` | Dark backgrounds |
| Black Tertiary | `#212121` | Darkest background |
| Black Quaternary | `#1C1C1C` | Near black |
| Black Quinary | `#000000` | Pure black, shadows |

### Other Colors

| Color | Hex Code | Usage |
|-------|----------|-------|
| Blue | `#42A5F5` | Informational elements, links |
| Light Green | `#C5E1A5` | Success states, positive feedback |
| Yellow | `#FFEB3B` | Warnings, highlights, attention |

### Semantic Colors

```dart
// Success
AppColors.success = AppColors.primary500
AppColors.successLight = AppColors.lightGreen

// Warning
AppColors.warning = AppColors.yellow

// Error
AppColors.error = AppColors.danger500

// Info
AppColors.info = AppColors.blue

// Income (positive transactions)
AppColors.income = AppColors.primary500

// Expense (negative transactions)
AppColors.expense = AppColors.danger500
```

### Usage Guidelines

✅ **DO:**
- Use Primary green for positive actions, success states, and brand elements
- Use Danger red for errors, warnings, and destructive actions
- Use Grayscale for text, backgrounds, borders, and neutral elements
- Maintain sufficient contrast for accessibility (WCAG AA minimum)
- Use semantic color names for better code readability

❌ **DON'T:**
- Don't use colors inconsistently across the app
- Don't use too many colors at once
- Don't ignore accessibility contrast ratios
- Don't use colors as the only way to convey information

## 🎯 Icons

### Icon Style

**Style**: Outlined (not filled)
- Consistent stroke width across all icons
- Clean, modern appearance
- Better visibility at small sizes

### Icon Sizes

| Size | Value | Usage |
|------|-------|-------|
| Small | 16px | Small UI elements, inline icons |
| Medium | 20px | List items, action bars |
| Large | 24px | Buttons, navigation |
| X-Large | 32px | Avatars, feature highlights |
| XX-Large | 48px | Large feature icons |

### Common Icons

**Navigation**
- Home, Wallet, Chart/Analytics, Settings, Profile

**Actions**
- Add, Edit, Delete, Search, Filter, Share, More

**Status**
- Check, Close, Error, Warning, Info

**Finance**
- Money, Credit Card, Receipt, Transaction, Income, Expense

**Categories**
- Food, Transport, Shopping, Entertainment, Utilities, Health, Education

### Usage in Code

```dart
import 'package:flutter/material.dart';
import 'package:yabike/core/constants/app_icons.dart';

Icon(
  Icons.home_outlined,
  size: AppIcons.iconSizeLarge, // 24px
  color: AppColors.primary,
)

// Or use predefined size contexts
Icon(
  Icons.add,
  size: AppIcons.getSizeForContext('button'),
)
```

## 📐 Spacing System

### Base Unit: 4px

All spacing follows a 4px base unit for consistency.

| Name | Value | Usage |
|------|-------|-------|
| xs | 4px | Minimal spacing |
| sm | 8px | Small spacing |
| md | 12px | Medium spacing |
| lg | 16px | Large spacing |
| xl | 24px | Extra large spacing |
| 2xl | 32px | Double extra large |
| 3xl | 48px | Triple extra large |

## 🔘 Buttons

### Button Variants

**Elevated Button** (Primary actions)
- Background: Primary 500
- Text: White
- Padding: 24px horizontal, 16px vertical
- Border radius: 12px
- Elevation: 2px

**Text Button** (Secondary actions)
- No background
- Text: Primary 500
- Padding: 16px horizontal, 12px vertical

**Outlined Button** (Tertiary actions)
- Border: Primary 500, 1.5px
- Text: Primary 500
- Padding: 24px horizontal, 16px vertical
- Border radius: 12px

### Button Usage

```dart
// Primary action
ElevatedButton(
  onPressed: () {},
  child: Text('Save'),
)

// Secondary action
TextButton(
  onPressed: () {},
  child: Text('Cancel'),
)

// Tertiary action
OutlinedButton(
  onPressed: () {},
  child: Text('Learn More'),
)
```

## 📱 Cards

### Card Style

- Border radius: 16px
- Elevation: 2px
- Background: White (light), Gray Senary (dark)
- Padding: 16px

### Card Usage

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        // Card content
      ],
    ),
  ),
)
```

## 📝 Input Fields

### Text Field Style

- Border radius: 12px
- Border: Gray Primary, 1px
- Focused border: Primary 500, 2px
- Error border: Danger 500
- Padding: 16px horizontal, 16px vertical
- Fill: White (light), Surface Dark (dark)

### Usage

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Amount',
    hintText: 'Enter amount',
  ),
  validator: Validators.amount,
)
```

## 🎭 Design Principles

### 1. Clarity
- Clear visual hierarchy
- Readable typography
- Sufficient spacing
- High contrast

### 2. Consistency
- Unified color palette
- Consistent spacing
- Standard components
- Predictable patterns

### 3. Simplicity
- Minimal UI
- Focus on content
- Remove unnecessary elements
- Clean layouts

### 4. Accessibility
- WCAG AA compliance
- Sufficient color contrast
- Touch target sizes (minimum 44x44)
- Screen reader support

### 5. Modern & Friendly
- Rounded corners
- Soft shadows
- Pleasant color palette
- Approachable design

## 📊 Component Patterns

### Transaction Cards

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: AppColors.surface,
  ),
  child: ListTile(
    leading: CircleAvatar(
      backgroundColor: AppColors.primary100,
      child: Icon(
        Icons.shopping_bag_outlined,
        color: AppColors.primary,
      ),
    ),
    title: Text('Shopping'),
    subtitle: Text('Today, 2:30 PM'),
    trailing: Text(
      '-1,000 RWF',
      style: TextStyle(
        color: AppColors.expense,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)
```

### Budget Progress

```dart
LinearProgressIndicator(
  value: 0.65, // 65%
  backgroundColor: AppColors.primary100,
  valueColor: AlwaysStoppedAnimation(AppColors.primary),
  borderRadius: BorderRadius.circular(4),
  minHeight: 8,
)
```

## 🌓 Dark Mode

The app supports both light and dark themes with appropriate color adaptations:

**Light Mode**
- Backgrounds: White shades
- Text: Black/Gray shades
- Primary: Green 500

**Dark Mode**
- Backgrounds: Black/Dark Gray shades
- Text: White/Light Gray shades
- Primary: Green 300 (lighter for better contrast)

## 📚 Resources

- **Font**: [Plus Jakarta Sans on Google Fonts](https://fonts.google.com/specimen/Plus+Jakarta+Sans)
- **Icons**: [Material Icons](https://fonts.google.com/icons)
- **Color Tool**: [Material Color Tool](https://material.io/resources/color/)

## ✅ Checklist for New Components

When creating new components, ensure:

- [ ] Uses Plus Jakarta Sans font
- [ ] Follows color palette (Primary Green, Danger Red, Grayscale)
- [ ] Uses outlined icons
- [ ] Follows spacing system (4px base unit)
- [ ] Supports both light and dark modes
- [ ] Has proper contrast ratios
- [ ] Uses semantic color names
- [ ] Follows component patterns
- [ ] Is accessible (touch targets, screen readers)
- [ ] Is responsive

---

**Last Updated**: October 7, 2025
**Version**: 1.0.0
