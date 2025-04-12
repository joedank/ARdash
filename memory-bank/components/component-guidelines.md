# Component Library Guidelines

This document provides comprehensive guidelines for implementing UI components in our Vue.js and Node.js project with consistent styling, behavior, and accessibility.

## Component Organization

### Folder Structure
```
/src
  /components
    /base            # Base components (Button, Input, etc.)
    /form            # Form-specific components
    /layout          # Layout components
    /navigation      # Navigation components 
    /data-display    # Components for displaying data
    /feedback        # Notifications, alerts, etc.
    /overlays        # Modals, dialogs, etc.
```

### Component Hierarchy
1. **Base Components**: Fundamental building blocks (Button, Input, etc.)
2. **Composite Components**: Combinations of base components (FormGroup, etc.)
3. **Page-Level Components**: Full sections of pages (UserTable, DashboardWidget, etc.)

### Naming Conventions
- Component files use PascalCase with "Base" prefix for base components
- Props use camelCase
- Events use kebab-case with emit prefixes like `@click`, `@update:modelValue`
- CSS classes use kebab-case

## Theme System

### Color System
- **Primary Actions**: blue-600/blue-500 (light/dark)
- **Success States**: green-600/green-500 (light/dark)
- **Warning States**: yellow-600/yellow-500 (light/dark)
- **Error States**: red-600/red-500 (light/dark)
- **Neutral/UI**: gray-800/gray-200 (light/dark)

### Background Colors
- **Light Mode**: 
  - Primary: white
  - Secondary: gray-50/gray-100
  - Elevated: gray-50 with shadow
- **Dark Mode**:
  - Primary: gray-900
  - Secondary: gray-800
  - Elevated: gray-800 with shadow-gray-900/30

### Text Colors
- **Light Mode**:
  - Primary: gray-900
  - Secondary: gray-700
  - Muted: gray-500
- **Dark Mode**:
  - Primary: white
  - Secondary: gray-300
  - Muted: gray-400

### Border Colors
- **Light Mode**: gray-200/gray-300
- **Dark Mode**: gray-700/gray-600

## Dark Mode Implementation

### Configuration
- Our project uses `@custom-variant dark (&:where(html, html *))` in base.css
- Dark mode is set as the default theme
- All components must support both light and dark modes

### Implementation Pattern
```html
<!-- Example dark mode pattern -->
<div 
  :class="[
    // Base styles (shared)
    'rounded-lg transition-colors',
    
    // Light mode styles
    'bg-white text-gray-900 border-gray-200',
    
    // Dark mode styles (using variants)
    'dark:bg-gray-900 dark:text-white dark:border-gray-700'
  ]"
>
  <!-- Component content -->
</div>
```

### Best Practices
- Always include both light and dark variants for color-related classes
- Maintain sufficient contrast in both modes (4.5:1 minimum ratio)
- Test components in both light and dark modes
- Group related styles together (base, light, dark) for readability

## Accessibility Guidelines

### Focus Management
- All interactive elements must be keyboard accessible
- Use proper focus trapping for modals/dialogs
- Include visible focus styles (usually using `focus:ring` utilities)
- Maintain focus order that matches visual layout

### ARIA Attributes
- Include appropriate `role` attributes for non-semantic elements
- Use `aria-label` for elements without visible text
- Include `aria-expanded`, `aria-pressed`, `aria-selected` for interactive elements
- Ensure form fields have associated labels

### Color and Contrast
- Maintain minimum contrast ratio of 4.5:1 for normal text
- Don't rely solely on color to convey information
- Include additional indicators (icons, patterns) alongside colors

### Keyboard Navigation
- Ensure all interactive elements can be accessed via keyboard
- Use appropriate keyboard shortcuts where needed
- Test tab order for logical flow
- Support Escape key for dismissing modals/popovers

## Component Development Process

### Planning
1. Check component-checklist.md for existing components
2. Review similar components for styling patterns
3. Plan component API (props, events, slots)
4. Consider all required states (normal, hover, active, disabled)
5. Create example implementation in /views/examples folder

### Example Implementation
1. Create example file in `/views/examples/{ComponentName}Example.vue`
2. Demonstrate all main features and variations
3. Show common use cases and patterns
4. Include responsive behavior examples
5. Document with clear comments explaining each example
6. Add route to example in router configuration

### Implementation
1. Create component file in appropriate folder
2. Start with component documentation in comments
3. Build the template with Tailwind classes
4. Implement the script with props validation
5. Add event handlers and emitters
6. Test in both light and dark modes

### Documentation
Each component should include comprehensive documentation:

```javascript
/**
 * ComponentName
 *
 * Description of the component and its purpose
 *
 * @props {Type} propName - Description of the prop
 * @slots default - Description of the default slot
 * @slots named - Description of any named slots
 * @events event-name - Description of emitted events
 *
 * @example
 * <!-- Important: Use HTML entities for tags in examples -->
 * &lt;ComponentName
 *   :prop-name="value"
 *   @event-name="handler"
 * &gt;
 *   Slot content
 * &lt;/ComponentName&gt;
 *
 * <!-- HTML entities to use: -->
 * <!-- < = &lt; -->
 * <!-- > = &gt; -->
 */
```

Note: Always use HTML entities (&lt; and &gt;) for angle brackets in JSDoc @example sections to prevent Vue template parsing errors.

## Component Integration

When integrating components into pages:

1. Import base components with consistent naming:
```javascript
import BaseButton from '@/components/base/BaseButton.vue';
import BaseInput from '@/components/form/BaseInput.vue';
import BaseCard from '@/components/data-display/BaseCard.vue';
```

2. Register them in the component setup:
```javascript
// In <script setup>
import BaseButton from '@/components/base/BaseButton.vue';
import BaseInput from '@/components/form/BaseInput.vue';
// Components are auto-registered in <script setup>
```

3. Use consistent event handling patterns:
```html
<BaseButton @click="handleClick">Submit</BaseButton>

<BaseInput 
  v-model="formData.email"
  @update:modelValue="handleInput"
  @blur="validateField"
/>
```

## Example Structure
```vue
<!--
  ComponentExample
  
  Demonstrates the usage and features of Component.
  Shows various configurations and implementations.
  
  Examples include:
  - Basic usage
  - Different variations (size, color, etc.)
  - Common use cases
  - Advanced features
  - Responsive behavior
-->
<template>
  <div class="max-w-4xl mx-auto p-6 space-y-12">
    <h1 class="text-3xl font-bold mb-8 text-gray-900 dark:text-white">
      Component Examples
    </h1>

    <!-- Basic Example Section -->
    <section class="space-y-4">
      <h2 class="text-xl font-semibold text-gray-800 dark:text-gray-200">
        Basic Usage
      </h2>
      <!-- Basic implementation example -->
    </section>

    <!-- Additional Sections for Different Features -->
    <section class="space-y-4">
      <h2 class="text-xl font-semibold text-gray-800 dark:text-gray-200">
        Feature Variation
      </h2>
      <!-- Feature-specific implementation -->
    </section>
  </div>
</template>
```

## Common Component Patterns

### Form Handling
- Use v-model with component for two-way binding
- Emit validation state changes to parent
- Handle form submission at form level, not in components
- Clearly indicate required fields

### Loading States
- Show loading indicators during async operations
- Disable interactive elements during loading
- Maintain layout stability when switching states
- Provide feedback for long operations

### Error Handling
- Display clear error messages
- Use consistent error styling (color, icons)
- Provide recovery options when possible
- Avoid blocking UI during non-critical errors

### Responsive Design
- Test components at all breakpoints (mobile, tablet, desktop)
- Use Tailwind responsive prefixes consistently
- Consider touch vs mouse interactions
- Ensure text remains readable at all sizes

## Code Style Guidelines

### Vue Component Structure
Follow this order in Vue component files:
1. Documentation comment
2. Template
3. Script
4. CSS (if needed)

### Props Validation
Always validate props with proper types and defaults:

```javascript
const props = defineProps({
  variant: {
    type: String,
    default: 'primary',
    validator: (value) => ['primary', 'secondary', 'outline', 'text'].includes(value)
  },
  disabled: {
    type: Boolean,
    default: false
  }
});
```

### Using Computed Properties
Use computed properties for derived values:

```javascript
// Good
const buttonClasses = computed(() => {
  return [
    'base-classes',
    props.variant === 'primary' ? 'primary-classes' : 'secondary-classes',
    props.disabled ? 'disabled-classes' : ''
  ].join(' ');
});

// Avoid inline complex logic in templates
```

### Event Handling
Use consistent event handling patterns:

```javascript
// Define emits
const emit = defineEmits(['click', 'update:modelValue']);

// Handler functions
const handleClick = (event) => {
  if (props.disabled) return;
  emit('click', event);
};
```

## Testing Components

### What to Test
- Props correctly affect rendering
- Events are properly emitted
- Slots render correctly
- Conditional rendering works as expected
- Component behaves correctly in different states

### Test Setup
- Import the component
- Mount with necessary props
- Trigger events or state changes
- Assert expected behavior

### Testing Interactions
- Click events trigger correct behavior
- Form inputs emit update events
- Conditional elements show/hide properly
- Accessibility features function correctly

## Updating the Checklist

After implementing a component:
1. Update component-checklist.md with ✅ for completed features
2. Add the file path to the component in the checklist
3. Ensure all sub-features are marked appropriately
4. Update implementation priority if needed
