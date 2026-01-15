# Responsive Design Guide - GDP Monorepo

**Last update**: 2025-01-19
**Version**: 1.0.0
**Tailwind CSS Version**: 4.0
**PrimeNG Version**: 20.0.0-rc.1

---

## 📌 Overview

This document outlines responsive design best practices and conventions for the GDP Monorepo project. It covers Tailwind CSS utilities, PrimeNG responsive components, mobile-first approach, and layout patterns for tablets and mobile devices.

---

## Core Principles

### ✅ Mobile-First Approach

**ALWAYS** design for mobile first, then add complexity for larger screens using breakpoint prefixes.

```html
<!-- ✅ CORRECT: Mobile-first approach -->
<div class="p-4 md:p-6 lg:p-8">
  <!-- padding-4 on mobile, padding-6 on tablet, padding-8 on desktop -->
</div>

<!-- ❌ WRONG: Desktop-first -->
<div class="p-8 md:p-6 sm:p-4">
  <!-- backwards, harder to maintain -->
</div>
```

**Why?** Mobile-first ensures:
- ✅ Better performance on mobile devices
- ✅ Progressive enhancement
- ✅ Simpler CSS (add complexity up, not strip it down)
- ✅ Forces you to prioritize content

---

## Tailwind CSS Breakpoints

### Default Breakpoints

| Prefix | Min Width | Target Devices | Usage |
|--------|-----------|----------------|-------|
| (none) | 0px | Mobile (default) | Base styles |
| `sm:` | 640px | Large mobile / Small tablet | Phone landscape |
| `md:` | 768px | Tablet | iPad portrait |
| `lg:` | 1024px | Desktop | iPad landscape / Small desktop |
| `xl:` | 1280px | Large desktop | Standard desktop |
| `2xl:` | 1536px | Extra large desktop | Wide monitors |

### Breakpoint Usage Examples

```html
<!-- Text sizing -->
<h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl">
  Responsive heading
</h1>

<!-- Layout changes -->
<div class="
  flex flex-col        <!-- Mobile: vertical stack -->
  md:flex-row          <!-- Tablet+: horizontal -->
  gap-4 md:gap-6       <!-- Different gaps -->
">
  <div class="w-full md:w-1/2">Column 1</div>
  <div class="w-full md:w-1/2">Column 2</div>
</div>

<!-- Hide/show elements -->
<div class="hidden lg:block">
  <!-- Only visible on desktop -->
  Desktop sidebar
</div>

<button class="lg:hidden">
  <!-- Mobile menu button, hidden on desktop -->
  Menu
</button>
```

---

## Common Responsive Patterns

### 1. Responsive Grid Layout

```html
<!-- ✅ CORRECT: Responsive grid -->
<div class="
  grid
  grid-cols-1        <!-- 1 column on mobile -->
  sm:grid-cols-2     <!-- 2 columns on large mobile -->
  md:grid-cols-3     <!-- 3 columns on tablet -->
  lg:grid-cols-4     <!-- 4 columns on desktop -->
  gap-4              <!-- Consistent gap -->
">
  <div class="bg-surface-0 dark:bg-surface-900 p-4 rounded-lg">Card 1</div>
  <div class="bg-surface-0 dark:bg-surface-900 p-4 rounded-lg">Card 2</div>
  <div class="bg-surface-0 dark:bg-surface-900 p-4 rounded-lg">Card 3</div>
  <div class="bg-surface-0 dark:bg-surface-900 p-4 rounded-lg">Card 4</div>
</div>
```

---

### 2. Responsive Container Padding

```html
<!-- ✅ CORRECT: Progressive padding -->
<div class="
  px-4 py-6          <!-- Mobile: smaller padding -->
  md:px-6 md:py-8    <!-- Tablet: medium padding -->
  lg:px-8 lg:py-10   <!-- Desktop: larger padding -->
">
  Content
</div>

<!-- Common container pattern -->
<div class="container mx-auto px-4 md:px-6 lg:px-8">
  <!-- Responsive container with auto margins -->
</div>
```

---

### 3. Responsive Typography

```html
<!-- ✅ CORRECT: Responsive font sizes -->
<h1 class="
  text-2xl md:text-3xl lg:text-4xl xl:text-5xl
  font-bold
  leading-tight
">
  Main Heading
</h1>

<p class="
  text-sm md:text-base lg:text-lg
  text-surface-700 dark:text-surface-300
">
  Body text that scales appropriately
</p>
```

---

### 4. Responsive Flexbox

```html
<!-- ✅ CORRECT: Stack on mobile, row on desktop -->
<div class="
  flex
  flex-col md:flex-row     <!-- Direction changes -->
  items-stretch md:items-center
  gap-4 md:gap-6
">
  <div class="flex-1">Item 1</div>
  <div class="flex-1">Item 2</div>
  <div class="flex-1">Item 3</div>
</div>

<!-- Form layout example -->
<form class="flex flex-col gap-4">
  <div class="
    flex flex-col md:flex-row
    gap-4
  ">
    <div class="flex-1">
      <label>First Name</label>
      <p-inputtext class="w-full" />
    </div>
    <div class="flex-1">
      <label>Last Name</label>
      <p-inputtext class="w-full" />
    </div>
  </div>
</form>
```

---

### 5. Responsive Width & Max Width

```html
<!-- ✅ CORRECT: Responsive widths -->
<div class="
  w-full               <!-- Full width on mobile -->
  md:w-3/4             <!-- 75% on tablet -->
  lg:w-1/2             <!-- 50% on desktop -->
  mx-auto              <!-- Center horizontally -->
">
  Centered content
</div>

<!-- Max width container -->
<div class="
  w-full
  max-w-screen-sm      <!-- Max 640px -->
  md:max-w-screen-md   <!-- Max 768px on tablet -->
  lg:max-w-screen-lg   <!-- Max 1024px on desktop -->
  mx-auto
  px-4
">
  Responsive container with max width
</div>
```

---

## PrimeNG Responsive Components

### DataView (Responsive Cards/List)

```typescript
import { DataViewModule } from 'primeng/dataview';

@Component({
  selector: 'app-product-list',
  standalone: true,
  imports: [DataViewModule],
  template: `
    <p-dataview [value]="products" [layout]="layout">
      <ng-template #header>
        <div class="flex justify-end">
          <p-button
            icon="pi pi-th-large"
            (onClick)="layout = 'grid'"
            [outlined]="layout !== 'grid'"
          />
          <p-button
            icon="pi pi-bars"
            (onClick)="layout = 'list'"
            [outlined]="layout !== 'list'"
          />
        </div>
      </ng-template>

      <!-- List layout (better for mobile) -->
      <ng-template #listItem let-product>
        <div class="flex flex-col md:flex-row gap-4 p-4">
          <img
            [src]="product.image"
            [alt]="product.name"
            class="w-full md:w-32 h-32 object-cover rounded-lg"
          />
          <div class="flex-1">
            <h3 class="text-xl font-bold">{{ product.name }}</h3>
            <p class="text-surface-600 dark:text-surface-400">
              {{ product.description }}
            </p>
          </div>
        </div>
      </ng-template>

      <!-- Grid layout (better for tablet/desktop) -->
      <ng-template #gridItem let-product>
        <div class="p-4">
          <div class="bg-surface-0 dark:bg-surface-900 rounded-lg p-4">
            <img
              [src]="product.image"
              [alt]="product.name"
              class="w-full h-48 object-cover rounded-lg mb-4"
            />
            <h3 class="text-lg font-bold mb-2">{{ product.name }}</h3>
            <p class="text-sm text-surface-600 dark:text-surface-400">
              {{ product.description }}
            </p>
          </div>
        </div>
      </ng-template>
    </p-dataview>
  `
})
export class ProductListComponent {
  layout: 'list' | 'grid' = 'grid';
  products = [/* ... */];
}
```

---

### Responsive Table

```html
<!-- ✅ CORRECT: Responsive table with horizontal scroll -->
<div class="overflow-x-auto">
  <p-table [value]="items" [scrollable]="true">
    <ng-template #header>
      <tr>
        <th class="min-w-[200px]">Name</th>
        <th class="min-w-[150px]">Email</th>
        <th class="min-w-[120px]">Phone</th>
        <th class="min-w-[100px]">Actions</th>
      </tr>
    </ng-template>
    <ng-template #body let-item>
      <tr>
        <td>{{ item.name }}</td>
        <td>{{ item.email }}</td>
        <td>{{ item.phone }}</td>
        <td>
          <p-button icon="pi pi-pencil" [text]="true" />
        </td>
      </tr>
    </ng-template>
  </p-table>
</div>

<!-- Alternative: Card layout for mobile -->
<div class="lg:hidden">
  <!-- Card view on mobile/tablet -->
  @for (item of items; track item.id) {
    <div class="bg-surface-0 dark:bg-surface-900 p-4 rounded-lg mb-4">
      <h3 class="font-bold mb-2">{{ item.name }}</h3>
      <p class="text-sm mb-1">{{ item.email }}</p>
      <p class="text-sm mb-2">{{ item.phone }}</p>
      <p-button label="Edit" size="small" />
    </div>
  }
</div>

<div class="hidden lg:block">
  <!-- Table view on desktop -->
  <p-table [value]="items">
    <!-- ... -->
  </p-table>
</div>
```

---

### Responsive Dialog

```typescript
import { DialogService, DynamicDialogRef } from 'primeng/dynamicdialog';

@Component({
  selector: 'app-parent',
  standalone: true,
  imports: [DialogService]
})
export class ParentComponent {
  #dialogService = inject(DialogService);
  ref: DynamicDialogRef | undefined;

  openDialog() {
    this.ref = this.#dialogService.open(EditFormComponent, {
      header: 'Edit User',
      // Responsive width
      width: '90vw',          // 90% on mobile
      breakpoints: {
        '960px': '75vw',      // 75% on tablet
        '640px': '90vw'       // 90% on mobile
      },
      // Responsive position
      position: 'top',        // Top on mobile (easier to reach)
      contentStyle: {
        'max-height': '80vh', // Prevent overflow
        'overflow': 'auto'
      }
    });
  }
}
```

---

### Responsive Menu / Sidebar

```typescript
import { SidebarModule } from 'primeng/sidebar';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [SidebarModule],
  template: `
    <!-- Mobile sidebar (overlay) -->
    <p-sidebar
      [(visible)]="sidebarVisible"
      [baseZIndex]="10000"
      styleClass="lg:hidden"
    >
      <nav>
        <!-- Mobile menu items -->
      </nav>
    </p-sidebar>

    <!-- Desktop sidebar (static) -->
    <aside class="hidden lg:block w-64 bg-surface-0 dark:bg-surface-900">
      <nav>
        <!-- Desktop menu items -->
      </nav>
    </aside>

    <!-- Mobile menu button -->
    <button
      class="lg:hidden"
      (click)="sidebarVisible = true"
    >
      <i class="pi pi-bars"></i>
    </button>
  `
})
export class LayoutComponent {
  sidebarVisible = false;
}
```

---

## Responsive Layout Patterns

### 1. Dashboard Layout

```html
<div class="min-h-screen bg-surface-50 dark:bg-surface-950">
  <!-- Header -->
  <header class="
    bg-surface-0 dark:bg-surface-900
    border-b border-surface-200 dark:border-surface-700
    px-4 md:px-6 lg:px-8
    py-4
  ">
    <div class="flex items-center justify-between">
      <h1 class="text-xl md:text-2xl font-bold">Dashboard</h1>
      <button class="lg:hidden">
        <i class="pi pi-bars text-xl"></i>
      </button>
    </div>
  </header>

  <!-- Main Content -->
  <div class="flex flex-col lg:flex-row">
    <!-- Sidebar (hidden on mobile) -->
    <aside class="
      hidden lg:block
      w-64
      bg-surface-0 dark:bg-surface-900
      border-r border-surface-200 dark:border-surface-700
      p-4
    ">
      <!-- Navigation -->
    </aside>

    <!-- Main -->
    <main class="flex-1 p-4 md:p-6 lg:p-8">
      <!-- Responsive grid of cards -->
      <div class="
        grid
        grid-cols-1
        md:grid-cols-2
        lg:grid-cols-3
        gap-4 md:gap-6
      ">
        <!-- Cards -->
      </div>
    </main>
  </div>
</div>
```

---

### 2. Form Layout

```html
<form class="max-w-4xl mx-auto p-4 md:p-6 lg:p-8">
  <!-- Single column on mobile, two columns on tablet+ -->
  <div class="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
    <div class="flex flex-col gap-2">
      <label class="font-medium">First Name</label>
      <p-inputtext class="w-full" />
    </div>

    <div class="flex flex-col gap-2">
      <label class="font-medium">Last Name</label>
      <p-inputtext class="w-full" />
    </div>
  </div>

  <!-- Full width field -->
  <div class="flex flex-col gap-2 mt-4">
    <label class="font-medium">Email</label>
    <p-inputtext type="email" class="w-full" />
  </div>

  <!-- Button group: stack on mobile, row on tablet+ -->
  <div class="
    flex flex-col md:flex-row
    gap-3
    mt-6
    justify-end
  ">
    <p-button
      label="Cancel"
      severity="secondary"
      styleClass="w-full md:w-auto"
    />
    <p-button
      label="Save"
      styleClass="w-full md:w-auto"
    />
  </div>
</form>
```

---

### 3. Card Grid Layout

```html
<!-- Responsive product/service cards -->
<div class="
  grid
  grid-cols-1           <!-- 1 column on mobile -->
  sm:grid-cols-2        <!-- 2 columns on large mobile -->
  lg:grid-cols-3        <!-- 3 columns on desktop -->
  xl:grid-cols-4        <!-- 4 columns on large desktop -->
  gap-4 md:gap-6
  p-4 md:p-6
">
  @for (item of items; track item.id) {
    <div class="
      bg-surface-0 dark:bg-surface-900
      rounded-lg
      overflow-hidden
      shadow-sm
      hover:shadow-md
      transition-shadow
    ">
      <!-- Image -->
      <img
        [src]="item.image"
        [alt]="item.name"
        class="w-full h-48 md:h-56 object-cover"
      />

      <!-- Content -->
      <div class="p-4 md:p-5">
        <h3 class="
          text-lg md:text-xl
          font-bold
          mb-2
          text-surface-900 dark:text-surface-0
        ">
          {{ item.name }}
        </h3>

        <p class="
          text-sm md:text-base
          text-surface-600 dark:text-surface-400
          mb-4
          line-clamp-2
        ">
          {{ item.description }}
        </p>

        <!-- Actions -->
        <div class="flex flex-col sm:flex-row gap-2">
          <p-button
            label="View"
            [outlined]="true"
            styleClass="flex-1"
          />
          <p-button
            label="Buy"
            styleClass="flex-1"
          />
        </div>
      </div>
    </div>
  }
</div>
```

---

## Best Practices

### ✅ DO

- ✅ Use mobile-first approach (base styles for mobile, add breakpoints upwards)
- ✅ Test on real devices (not just browser devtools)
- ✅ Use PrimeNG surface colors for dark mode compatibility
- ✅ Use `container mx-auto` for centered, responsive containers
- ✅ Add horizontal overflow (`overflow-x-auto`) to tables on mobile
- ✅ Use `hidden`/`block` classes to show/hide elements at breakpoints
- ✅ Provide adequate touch targets (min 44x44px) on mobile
- ✅ Use responsive images with `NgOptimizedImage`
- ✅ Test keyboard navigation on all screen sizes
- ✅ Use semantic HTML (`<nav>`, `<main>`, `<aside>`)
- ✅ Provide alternative layouts for mobile (e.g., cards instead of tables)

### ❌ DON'T

- ❌ Use fixed pixel widths without breakpoint variants
- ❌ Forget to test touch interactions on mobile
- ❌ Use small text sizes on mobile (min 16px to prevent zoom on iOS)
- ❌ Use hover-only interactions (not accessible on touch devices)
- ❌ Create horizontal scroll unless intentional (e.g., carousel)
- ❌ Use too many breakpoint variants (keep it simple)
- ❌ Forget about landscape orientation on mobile
- ❌ Use `vw`/`vh` units without fallbacks (viewport units can be buggy)
- ❌ Test only on one device size

---

## Touch-Friendly Interactions

### Minimum Touch Target Size

```html
<!-- ✅ CORRECT: Adequate touch targets -->
<button class="
  min-h-[44px]        <!-- Min 44px height -->
  min-w-[44px]        <!-- Min 44px width -->
  px-4 py-2
">
  Click me
</button>

<!-- PrimeNG buttons are touch-friendly by default -->
<p-button label="Touch-friendly" />

<!-- ❌ WRONG: Too small for touch -->
<button class="p-1 text-xs">
  Too small
</button>
```

---

### Spacing for Touch

```html
<!-- ✅ CORRECT: Adequate spacing between touch targets -->
<div class="flex gap-3 md:gap-2">
  <!-- Larger gaps on mobile for easier tapping -->
  <p-button icon="pi pi-pencil" />
  <p-button icon="pi pi-trash" />
  <p-button icon="pi pi-eye" />
</div>
```

---

## Responsive Images

### Using Angular NgOptimizedImage

```typescript
import { NgOptimizedImage } from '@angular/common';

@Component({
  selector: 'app-image-card',
  standalone: true,
  imports: [NgOptimizedImage],
  template: `
    <!-- ✅ CORRECT: Responsive optimized image -->
    <img
      [ngSrc]="imageUrl"
      alt="Product image"
      width="400"
      height="300"
      class="w-full h-auto"
      priority
    />
  `
})
export class ImageCardComponent {
  imageUrl = '/assets/images/product.jpg';
}
```

---

### Background Images (Responsive)

```html
<!-- ✅ CORRECT: Responsive background -->
<div class="
  h-64 md:h-96 lg:h-[500px]
  bg-cover bg-center
  rounded-lg
"
  [style.background-image]="'url(' + backgroundUrl + ')'"
>
  <div class="
    h-full
    bg-gradient-to-t from-black/60 to-transparent
    flex items-end
    p-6 md:p-8
  ">
    <h2 class="text-white text-2xl md:text-3xl lg:text-4xl font-bold">
      Hero Title
    </h2>
  </div>
</div>
```

---

## Testing Responsive Design

### Browser DevTools

```bash
# Common device sizes to test:
# Mobile:
  - iPhone SE: 375x667
  - iPhone 12/13/14: 390x844
  - Samsung Galaxy S21: 360x800

# Tablet:
  - iPad: 768x1024
  - iPad Pro 11": 834x1194
  - iPad Pro 12.9": 1024x1366

# Desktop:
  - Laptop: 1366x768
  - Desktop: 1920x1080
  - Wide: 2560x1440
```

---

### Manual Testing Checklist

- [ ] Test all breakpoints (sm, md, lg, xl, 2xl)
- [ ] Test portrait and landscape orientations
- [ ] Test touch interactions (tap, swipe, scroll)
- [ ] Verify text is readable (min 16px on mobile)
- [ ] Check button sizes (min 44x44px)
- [ ] Test navigation on mobile (hamburger menu works)
- [ ] Verify images load and scale properly
- [ ] Check table behavior (scroll or card view)
- [ ] Test forms on mobile (input focus, keyboard)
- [ ] Verify dark mode on all screen sizes

---

## Common Responsive Utilities

### Display

```html
<!-- Hide/show at breakpoints -->
<div class="block md:hidden">Mobile only</div>
<div class="hidden md:block">Tablet and up</div>
<div class="hidden lg:block">Desktop only</div>
```

---

### Flexbox

```html
<!-- Responsive flex direction -->
<div class="flex flex-col md:flex-row">
  <!-- Stack on mobile, row on tablet+ -->
</div>

<!-- Responsive justify -->
<div class="flex justify-start md:justify-center lg:justify-end">
  <!-- Different alignment at each breakpoint -->
</div>

<!-- Responsive items alignment -->
<div class="flex items-start md:items-center">
  <!-- Top align on mobile, center on tablet+ -->
</div>
```

---

### Grid

```html
<!-- Responsive grid columns -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
  <!-- Automatically responsive -->
</div>

<!-- Responsive grid gap -->
<div class="grid grid-cols-2 gap-2 md:gap-4 lg:gap-6">
  <!-- Larger gaps on larger screens -->
</div>
```

---

### Spacing

```html
<!-- Responsive padding -->
<div class="p-4 md:p-6 lg:p-8">
  <!-- Progressive padding -->
</div>

<!-- Responsive margin -->
<div class="mt-4 md:mt-6 lg:mt-8">
  <!-- Progressive margin -->
</div>
```

---

### Typography

```html
<!-- Responsive text size -->
<h1 class="text-2xl md:text-4xl lg:text-6xl">
  <!-- Scales with screen size -->
</h1>

<!-- Responsive text alignment -->
<p class="text-center md:text-left">
  <!-- Center on mobile, left on tablet+ -->
</p>
```

---

## Accessibility Considerations

### ✅ Accessible Responsive Design

- ✅ Use semantic HTML elements
- ✅ Ensure keyboard navigation works on all screen sizes
- ✅ Provide skip links for mobile navigation
- ✅ Use ARIA labels for icon-only buttons
- ✅ Maintain adequate color contrast (WCAG AA minimum)
- ✅ Test with screen readers on mobile devices
- ✅ Ensure form inputs are properly labeled
- ✅ Provide focus indicators visible on all devices

```html
<!-- ✅ CORRECT: Accessible mobile menu -->
<button
  aria-label="Open menu"
  aria-expanded="false"
  class="lg:hidden"
  (click)="toggleMenu()"
>
  <i class="pi pi-bars" aria-hidden="true"></i>
</button>

<!-- ✅ CORRECT: Skip link for mobile -->
<a
  href="#main-content"
  class="
    sr-only
    focus:not-sr-only
    focus:absolute
    focus:top-0
    focus:left-0
    focus:z-50
    focus:p-4
    focus:bg-primary
    focus:text-white
  "
>
  Skip to main content
</a>
```

---

## Performance Optimization

### Lazy Loading Images

```typescript
import { NgOptimizedImage } from '@angular/common';

@Component({
  selector: 'app-gallery',
  standalone: true,
  imports: [NgOptimizedImage],
  template: `
    <!-- Above the fold: priority -->
    <img
      ngSrc="/hero.jpg"
      width="1200"
      height="600"
      priority
      alt="Hero image"
    />

    <!-- Below the fold: lazy load -->
    @for (image of images; track image.id) {
      <img
        [ngSrc]="image.url"
        width="400"
        height="300"
        loading="lazy"
        [alt]="image.alt"
      />
    }
  `
})
export class GalleryComponent {
  images = [/* ... */];
}
```

---

### Responsive Loading

```typescript
// Load different components based on screen size
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';

@Component({
  selector: 'app-adaptive',
  standalone: true,
  template: `
    @if (isMobile()) {
      <app-mobile-view />
    } @else {
      <app-desktop-view />
    }
  `
})
export class AdaptiveComponent {
  #breakpointObserver = inject(BreakpointObserver);

  isMobile = signal(false);

  constructor() {
    this.#breakpointObserver
      .observe([Breakpoints.Handset])
      .pipe(takeUntilDestroyed())
      .subscribe(result => {
        this.isMobile.set(result.matches);
      });
  }
}
```

---

## Quick Reference Cheat Sheet

### Layout Patterns

| Pattern | Mobile | Tablet | Desktop |
|---------|--------|--------|---------|
| Stack → Row | `flex flex-col` | `md:flex-row` | - |
| Full → Half | `w-full` | `md:w-1/2` | - |
| 1 → 2 → 4 cols | `grid-cols-1` | `md:grid-cols-2` | `lg:grid-cols-4` |
| Hide on mobile | `hidden` | `md:block` | - |
| Show on mobile | `block` | `md:hidden` | - |

### Spacing Scale

| Size | Mobile | Tablet | Desktop |
|------|--------|--------|---------|
| Small | `p-4` | `md:p-6` | `lg:p-8` |
| Medium | `p-6` | `md:p-8` | `lg:p-10` |
| Large | `p-8` | `md:p-10` | `lg:p-12` |

### Typography Scale

| Element | Mobile | Tablet | Desktop |
|---------|--------|--------|---------|
| H1 | `text-2xl` | `md:text-3xl` | `lg:text-4xl` |
| H2 | `text-xl` | `md:text-2xl` | `lg:text-3xl` |
| H3 | `text-lg` | `md:text-xl` | `lg:text-2xl` |
| Body | `text-sm` | `md:text-base` | - |

---

## 📚 References

### Official Documentation

- **Tailwind CSS Responsive Design**: https://tailwindcss.com/docs/responsive-design
- **PrimeNG Responsive**: https://primeng.org/layout
- **Angular CDK Layout**: https://material.angular.io/cdk/layout/overview

### Internal Documentation

- **[dark_mode_reference.md](./dark_mode_reference.md)**: Dark mode with surface colors
- **[primeng_best_practices.md](./primeng_best_practices.md)**: PrimeNG components
- **[angular_best_practices.md](./angular_best_practices.md)**: Angular standards

---

## Migration Checklist

When making components responsive:

- [ ] Identify mobile-first base styles
- [ ] Add tablet breakpoint (`md:`) for medium screens
- [ ] Add desktop breakpoint (`lg:`) for large screens
- [ ] Test on real devices (iOS, Android, tablet)
- [ ] Verify touch targets are min 44x44px
- [ ] Check text readability (min 16px on mobile)
- [ ] Test landscape and portrait orientations
- [ ] Verify images are optimized and responsive
- [ ] Test navigation and menus on mobile
- [ ] Verify dark mode on all screen sizes
- [ ] Test keyboard navigation
- [ ] Run accessibility audit (WCAG AA)

---

**Last update**: 2025-01-19
**Version**: 1.0.0
**Tailwind CSS Version**: 4.0
**PrimeNG Version**: 20.0.0-rc.1
