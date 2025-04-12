# Component Change Management

This document outlines the process for modifying existing components to ensure consistency throughout the application.

## Pre-Change Assessment

Before altering any component, follow these steps:

1. **Identify Usages**
   - Check `component-usage.md` to identify all pages/features using the component
   - Run a project-wide search for component imports: `grep -r "import Base<ComponentName>" src/`

2. **Document Current API**
   - Review the component's current props, events, and slots
   - Understand default behaviors and edge cases

3. **Determine Change Type**
   - **Non-breaking changes**: Adding optional props, enhancing styling, improving performance
   - **Breaking changes**: Modifying required props, changing event payloads, removing features

4. **Impact Analysis**
   - Document which pages/components will be affected
   - Estimate effort required to implement and test changes

## Implementation Guidelines

### Non-Breaking Changes

- Add new props with appropriate defaults so existing usage continues working
- Extend functionality without changing core behavior
- Enhance styling while maintaining design consistency
- Document new features in component comments

Example:
```javascript
// Before
const props = defineProps({
  variant: {
    type: String,
    default: 'primary'
  }
});

// After - Non-breaking addition
const props = defineProps({
  variant: {
    type: String,
    default: 'primary'
  },
  // New prop with default to maintain backward compatibility
  size: {
    type: String,
    default: 'medium'
  }
});
```

### Breaking Changes

- Create a migration plan before implementing
- Update all instances of the component across the project
- Consider implementing a temporary compatibility layer
- Document breaking changes prominently in the component

Example for deprecation approach:
```javascript
// Deprecation approach
const props = defineProps({
  // Original prop (deprecated)
  outline: {
    type: Boolean,
    default: false
  },
  // New replacement prop
  variant: {
    type: String,
    default: 'primary'
  }
});

// In setup, handle both patterns
const finalVariant = computed(() => {
  // Support deprecated API while warning developers
  if (props.outline) {
    console.warn('BaseButton: "outline" prop is deprecated, use variant="outline" instead');
    return 'outline';
  }
  return props.variant;
});
```

### Style Changes

- Always maintain both light and dark mode variants
- Follow the color system defined in `component-guidelines.md`
- Ensure new styles are consistent with existing design patterns
- Test changes across all breakpoints (mobile, tablet, desktop)

## Testing Changes

1. **Component Testing**
   - Test all component states (normal, hover, active, disabled)
   - Verify in both light and dark themes
   - Check responsive behavior across all breakpoints
   - Validate accessibility (keyboard navigation, ARIA, etc.)

2. **Integration Testing**
   - Test the component in all contexts where it's used
   - Verify interactions with other components still work
   - Check for edge cases particular to specific implementations

3. **Visual Regression**
   - Compare before/after appearance to ensure consistency
   - Check alignment, spacing, and proportions
   - Verify animations and transitions

## Documentation Updates

After implementing changes:

1. Update component inline documentation
2. Update example pages to demonstrate new/changed behavior
3. Update `component-checklist.md` with new features
4. Update `component-usage.md` if new usages are discovered
5. Add entry to `.clinerules` if changes involve patterns other developers should follow

## Change Rollout

For significant changes:

1. Implement changes in a separate branch
2. Create example showing before/after behavior
3. Get feedback from team before finalizing
4. Roll out changes systematically, updating usages across the project
5. Monitor for unexpected issues after deployment
