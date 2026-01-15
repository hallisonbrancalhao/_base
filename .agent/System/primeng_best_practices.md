# PrimeNG Best Practices - Monorepo

**Last update**: 2026-01-03
**Version**: 1.2.0
**PrimeNG Version**: 20.0.0-rc.1

---

## 📌 Overview

This document outlines the best practices and conventions for using PrimeNG v20 in the Monorepo project. PrimeNG v20 has deprecated directive-based usage in favor of component-based usage.

---

## Core Rules

### ✅ Use `class` Attribute (NOT `styleClass`)

PrimeNG v20 deprecated the `styleClass` attribute in favor of the standard HTML `class` attribute for most components.

#### ❌ OLD (styleClass - DO NOT USE)

```html
<!-- DON'T use styleClass on most components -->
<p-inputtext styleClass="w-full" />
<p-select styleClass="w-full" />
<p-date-picker styleClass="w-full" />
<p-table styleClass="w-full" />
```

#### ✅ NEW (class - CORRECT)

```html
<!-- DO use class attribute -->
<p-inputtext class="w-full" />
<p-select class="w-full" />
<p-date-picker class="w-full" />
<p-table class="w-full" />
```

#### ⚠️ Exception: `p-button` Still Uses `styleClass`

```html
<!-- ✅ p-button STILL uses styleClass in v20 -->
<p-button styleClass="w-full" label="Save" />

<!-- ❌ Don't use class on p-button -->
<p-button class="w-full" label="Save" />
```

**Migration Tool**: Use `tools/scripts/migrate-styleclass.js` to automatically migrate `styleClass` to `class` across the codebase (preserves `p-button`).

---

### ✅ Use Components (NOT Directives)

PrimeNG v20 strongly encourages using component-based API instead of directive-based API.

#### ❌ OLD (Directive-based - DO NOT USE)

```html
<!-- DON'T use directives -->
<button pButton label="Click me"></button>
<input pInputText [(ngModel)]="value" />
<p-dropdown [options]="items"></p-dropdown>
<p-calendar [(ngModel)]="date"></p-calendar>
<table pTable [value]="data"></table>
```

#### ✅ NEW (Component-based - CORRECT)

```html
<!-- DO use components -->
<p-button label="Click me" />
<p-inputtext [(ngModel)]="value" />
<p-select [options]="items" />
<p-date-picker [(ngModel)]="date" />
<p-table [value]="data"></p-table>
```

---

## Component Migration Guide

### Buttons

**❌ Don't use `pButton` directive**:
```html
<button pButton type="button" label="Save"></button>
```

**✅ Use `p-button` component**:
```html
<p-button type="button" label="Save" />
```

---

### Text Inputs

**❌ Don't use `pInputText` directive**:
```html
<input type="text" pInputText [(ngModel)]="value" />
```

**✅ Use `p-inputtext` component**:
```html
<p-inputtext [(ngModel)]="value" />
```

---

### Textareas

**❌ Don't use `pInputTextarea` directive**:
```html
<textarea pInputTextarea [(ngModel)]="value"></textarea>
```

**✅ Use `p-inputtextarea` component**:
```html
<p-inputtextarea [(ngModel)]="value" />
```

---

### Dropdowns / Selects

**❌ Don't use `p-dropdown` (deprecated in v20)**:
```html
<p-dropdown [options]="items" [(ngModel)]="selectedItem"></p-dropdown>
```

**❌ Don't use `pDropdown` directive**:
```html
<select pDropdown [options]="items"></select>
```

**✅ Use `p-select` component (IMPORTANT!)**:
```html
<p-select [options]="items" [(ngModel)]="selectedItem" />
```

**Why?** PrimeNG v20 renamed `p-dropdown` to `p-select` for better semantic clarity.

---

### Date Pickers

**❌ Don't use `pCalendar` directive**:
```html
<input pCalendar [(ngModel)]="date" />
```

**✅ Use `p-date-picker` component**:
```html
<p-date-picker [(ngModel)]="date" />
```

---

### Tables

**❌ Don't use `pTable` directive**:
```html
<table pTable [value]="data"></table>
```

**✅ Use `p-table` component**:
```html
<p-table [value]="data">
  <ng-template #header>
    <tr>
      <th>Name</th>
      <th>Email</th>
    </tr>
  </ng-template>
  <ng-template #body let-item>
    <tr>
      <td>{{ item.name }}</td>
      <td>{{ item.email }}</td>
    </tr>
  </ng-template>
</p-table>
```

---

### Templates

**❌ Don't use `pTemplate` directive**:
```html
<ng-template pTemplate="header">
  <th>Name</th>
</ng-template>
```

**✅ Use `#template` reference**:
```html
<ng-template #header>
  <th>Name</th>
</ng-template>
```

---

## Complete Component Reference

### Form Components

| Old (Directive/Deprecated) | New (Component) | Purpose |
|----------------------------|-----------------|---------|
| `pInputText` | `p-inputtext` | Text input |
| `pInputTextarea` | `p-inputtextarea` | Textarea input |
| `pDropdown` / `p-dropdown` | `p-select` | Dropdown select |
| `pCalendar` | `p-date-picker` | Date picker |
| `pCheckbox` | `p-checkbox` | Checkbox |
| `pRadioButton` | `p-radio-button` | Radio button |
| `pInputNumber` | `p-inputnumber` | Number input |
| `pInputMask` | `p-inputmask` | Masked input |
| `pPassword` | `p-password` | Password input |

### Button Components

| Old (Directive) | New (Component) | Purpose |
|----------------|-----------------|---------|
| `pButton` | `p-button` | Standard button |
| `pToggleButton` | `p-togglebutton` | Toggle button |
| `pSplitButton` | `p-splitbutton` | Split button |

### Data Components

| Old (Directive) | New (Component) | Purpose |
|----------------|-----------------|---------|
| `pTable` | `p-table` | Data table |
| `pDataView` | `p-dataview` | Data view |
| `pTree` | `p-tree` | Tree structure |
| `pPickList` | `p-picklist` | Pick list |
| `pOrderList` | `p-orderlist` | Order list |

---

## Import Statements

When using PrimeNG components, import them in your standalone component:

```typescript
import { Component } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { SelectModule } from 'primeng/select';
import { DatePickerModule } from 'primeng/datepicker';
import { TableModule } from 'primeng/table';

@Component({
  selector: 'app-my-component',
  standalone: true,
  imports: [
    ButtonModule,
    InputTextModule,
    SelectModule,
    DatePickerModule,
    TableModule
  ],
  template: `
    <p-button label="Save" />
    <p-inputtext [(ngModel)]="name" />
    <p-select [options]="items" />
    <p-date-picker [(ngModel)]="date" />
    <p-table [value]="data"></p-table>
  `
})
export class MyComponent {
  // Component logic
}
```

---

## Common Patterns

### Form with PrimeNG Components

```typescript
@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [ReactiveFormsModule, InputTextModule, SelectModule, ButtonModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <div class="field">
        <label for="name">Name</label>
        <p-inputtext
          id="name"
          formControlName="name"
          placeholder="Enter name"
        />
      </div>

      <div class="field">
        <label for="role">Role</label>
        <p-select
          id="role"
          formControlName="role"
          [options]="roles"
          placeholder="Select role"
        />
      </div>

      <p-button type="submit" label="Save" [disabled]="form.invalid" />
    </form>
  `
})
export class UserFormComponent {
  form = new FormGroup({
    name: new FormControl('', Validators.required),
    role: new FormControl('', Validators.required)
  });

  roles = [
    { label: 'Admin', value: 'admin' },
    { label: 'User', value: 'user' }
  ];

  onSubmit() {
    if (this.form.valid) {
      console.log(this.form.value);
    }
  }
}
```

---

### Data Table with Template References

```typescript
@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [TableModule, ButtonModule],
  template: `
    <p-table [value]="users">
      <ng-template #header>
        <tr>
          <th>Name</th>
          <th>Email</th>
          <th>Actions</th>
        </tr>
      </ng-template>

      <ng-template #body let-user>
        <tr>
          <td>{{ user.name }}</td>
          <td>{{ user.email }}</td>
          <td>
            <p-button
              icon="pi pi-pencil"
              [text]="true"
              (onClick)="edit(user)"
            />
          </td>
        </tr>
      </ng-template>
    </p-table>
  `
})
export class UserListComponent {
  users = [
    { name: 'John Doe', email: 'john@example.com' },
    { name: 'Jane Smith', email: 'jane@example.com' }
  ];

  edit(user: any) {
    console.log('Edit', user);
  }
}
```

---

## Dark Mode Support

PrimeNG v20 has built-in dark mode support via surface colors. Use PrimeNG surface classes instead of Tailwind colors.

**See**: `.agent/System/dark_mode_reference.md` for complete dark mode guidelines.

### Quick Reference

```html
<!-- ✅ Correct: PrimeNG surface colors -->
<div class="surface-0 dark:surface-950">
  <p class="text-color">Content</p>
</div>

<!-- ❌ Wrong: Tailwind colors -->
<div class="bg-white dark:bg-gray-900">
  <p class="text-gray-900 dark:text-white">Content</p>
</div>
```

---

## Testing PrimeNG Components

When testing components that use PrimeNG, use schemas to avoid errors:

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NO_ERRORS_SCHEMA, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { MyComponent } from './my.component';

describe('MyComponent', () => {
  let component: MyComponent;
  let fixture: ComponentFixture<MyComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MyComponent],
      schemas: [NO_ERRORS_SCHEMA, CUSTOM_ELEMENTS_SCHEMA]
    }).compileComponents();

    fixture = TestBed.createComponent(MyComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
```

**See**: `.agent/System/angular_unit_testing_guide.md` for complete testing guide.

---

## Migration Checklist

When migrating old code to PrimeNG v20:

- [ ] Replace `styleClass` with `class` on all components EXCEPT `p-button` (**IMPORTANT**)
- [ ] Keep `styleClass` on `<p-button>` components (exception in v20)
- [ ] Replace `pButton` directive with `<p-button>` component
- [ ] Replace `pInputText` directive with `<p-inputtext>` component
- [ ] Replace `pInputTextarea` directive with `<p-inputtextarea>` component
- [ ] Replace `p-dropdown` with `<p-select>` component (**IMPORTANT**)
- [ ] Replace `pCalendar` directive with `<p-date-picker>` component
- [ ] Replace `pTable` directive with `<p-table>` component
- [ ] Replace `pTemplate` directive with `#template` reference
- [ ] Replace `p-input-icon-left` with `p-iconfield` + `p-inputicon` (**IMPORTANT**)
- [ ] Update imports to use new component modules
- [ ] Add `IconFieldModule` and `InputIconModule` for search inputs
- [ ] Test all forms and data tables
- [ ] Verify dark mode styling with surface colors
- [ ] Run `node tools/scripts/migrate-styleclass.js` for automated migration

---

## Search Input Pattern

### Correct Search Input Pattern (p-iconfield)

PrimeNG v20 deprecated `p-input-icon-left` and `p-input-icon-right` in favor of `p-iconfield` + `p-inputicon`.

**Required Imports:**
```typescript
import { IconFieldModule } from 'primeng/iconfield';
import { InputIconModule } from 'primeng/inputicon';
import { InputTextModule } from 'primeng/inputtext';
```

**Correct Pattern:**
```html
<p-iconfield class="w-full">
  <p-inputicon styleClass="pi pi-search" />
  <input pInputText type="text" class="w-full" placeholder="Pesquisar..." />
</p-iconfield>
```

**With Clear Button:**
```html
<p-iconfield class="w-full">
  <p-inputicon styleClass="pi pi-search" />
  <input
    pInputText
    type="text"
    class="w-full"
    placeholder="Pesquisar..."
    [ngModel]="searchValue()"
    (ngModelChange)="onSearch($event)"
  />
  @if (searchValue()) {
    <p-inputicon
      styleClass="pi pi-times cursor-pointer"
      (click)="clearSearch()"
    />
  }
</p-iconfield>
```

### Anti-Pattern Warning

**DO NOT USE (Obsolete):**
```html
<!-- BROKEN - p-input-icon-left is obsolete -->
<span class="p-input-icon-left">
  <i class="pi pi-search"></i>
  <input pInputText type="text" placeholder="Search...">
</span>
```

This pattern causes visual issues - icons don't display correctly and inputs are misaligned.

**See**: `.agent/Tasks/PRD-SEARCH-FILTER-REFACTORING.md` for migration details.

---

## Common Errors and Solutions

### Error: "styleClass is deprecated" or styling not applying

**Cause**: Using deprecated `styleClass` attribute instead of standard `class`

**Solution**: Use `class` attribute (except on `p-button`)

```html
<!-- ❌ Old -->
<p-inputtext styleClass="w-full" />
<p-select styleClass="w-full" />

<!-- ✅ New -->
<p-inputtext class="w-full" />
<p-select class="w-full" />

<!-- ✅ Exception: p-button still uses styleClass -->
<p-button styleClass="w-full" label="Save" />
```

**Migration**: Run `node tools/scripts/migrate-styleclass.js` to automatically fix all files

---

### Error: "Can't bind to 'pButton' since it isn't a known property"

**Cause**: Using directive-based API in PrimeNG v20

**Solution**: Use component-based API

```html
<!-- ❌ Old -->
<button pButton label="Click me"></button>

<!-- ✅ New -->
<p-button label="Click me" />
```

---

### Error: "p-dropdown is deprecated"

**Cause**: Using old `p-dropdown` component

**Solution**: Use `p-select` instead

```html
<!-- ❌ Old -->
<p-dropdown [options]="items" />

<!-- ✅ New -->
<p-select [options]="items" />
```

---

## 📚 References

### Official Documentation

- **PrimeNG**: https://primeng.org
- **PrimeNG Theming**: https://primeng.org/theming
- **Migration Guide**: https://primeng.org/migration

### Internal Documentation

- **[dark_mode_reference.md](./dark_mode_reference.md)**: Dark mode with PrimeNG surface colors
- **[angular_best_practices.md](./angular_best_practices.md)**: Angular coding standards
- **[angular_unit_testing_guide.md](./angular_unit_testing_guide.md)**: Testing guide

---

**Last update**: 2026-01-03
**Version**: 1.2.0
**PrimeNG Version**: 20.0.0-rc.1
**Changes**: Added `styleClass` vs `class` migration guide with `p-button` exception
