# Component Usage Tracker

This document tracks where components are used throughout the application to facilitate impact analysis when making changes. Keep this document updated when adding new component implementations or discovering new usages.

## Base Components

### BaseButton
- **Used in**:
  - Login form (`/src/views/auth/LoginView.vue`)
  - Registration form (`/src/views/auth/RegisterView.vue`)
  - Dashboard actions (`/src/views/dashboard/DashboardView.vue`)
  - Profile page forms (`/src/views/profile/ProfileView.vue`)
  - Settings forms (`/src/views/settings/SettingsView.vue`)
  - All modal confirmations (global usage)
  - Password change modal in dashboard

### BaseInput
- **Used in**:
  - Login form (`/src/views/auth/LoginView.vue`)
  - Registration form (`/src/views/auth/RegisterView.vue`)
  - Profile forms (`/src/views/profile/ProfileView.vue`)
  - Settings forms (`/src/views/settings/SettingsView.vue`)
  - Search components (global usage)

### BaseCard
- **Used in**:
  - Dashboard statistics (`/src/views/dashboard/DashboardView.vue`)
  - Profile information (`/src/views/profile/ProfileView.vue`)
  - Settings sections (`/src/views/settings/SettingsView.vue`)
  - Home view content sections (`/src/views/HomeView.vue`)
  - Login and register forms (`/src/views/auth/LoginView.vue`, `/src/views/auth/RegisterView.vue`)

### BaseAlert
- **Used in**:
  - Login/register form validation (`/src/views/auth/LoginView.vue`, `/src/views/auth/RegisterView.vue`)
  - Dashboard notifications (`/src/views/dashboard/DashboardView.vue`)
  - Form submission feedback (multiple views)
  - Error state handling (global usage)

### BaseModal
- **Used in**:
  - Password change form (`/src/views/dashboard/DashboardView.vue`)
  - Confirmation dialogs (global usage)
  - Settings page for sensitive actions (`/src/views/settings/SettingsView.vue`)

## Form Components

### BaseSelect
- **Used in**:
  - Settings form selectors (`/src/views/settings/SettingsView.vue`)
  - Profile form dropdowns (`/src/views/profile/ProfileView.vue`)
  - Dashboard filters (`/src/views/dashboard/DashboardView.vue`)

### BaseCheckboxRadio
- **Used in**:
  - Settings preferences (`/src/views/settings/SettingsView.vue`)
  - Registration form agreements (`/src/views/auth/RegisterView.vue`)
  - Dashboard filters (`/src/views/dashboard/DashboardView.vue`)

### BaseToggleSwitch
- **Used in**:
  - Context switching between personal/admin settings (`/src/views/settings/SettingsView.vue`)
  - Settings toggles for boolean options (`/src/views/settings/SettingsView.vue`)
  - Dashboard quick actions (`/src/views/dashboard/DashboardView.vue`)
  - Feature toggles throughout the application
  - User status toggling in User Management view

### BaseFormGroup
- **Used in**:
  - All forms throughout the application (wraps input controls)
  - Login and registration forms
  - Profile settings
  - User preferences

### BaseDateTimePicker
- **Used in**:
  - Settings page for schedule preferences (`/src/views/settings/SettingsView.vue`)
  - Dashboard for date filtering (`/src/views/dashboard/DashboardView.vue`)

### BaseRangeSlider
- **Used in**:
  - Settings page for numeric preferences (`/src/views/settings/SettingsView.vue`)

## Navigation Components

### BaseTabs
- **Used in**:
  - Dashboard tabbed interface (`/src/views/dashboard/DashboardView.vue`)
  - Settings categories with contextual tab sets (`/src/views/settings/SettingsView.vue`)
  - Profile page sections (`/src/views/profile/ProfileView.vue`)

### BaseBreadcrumb
- **Used in**:
  - Dashboard navigation (`/src/views/dashboard/DashboardView.vue`)
  - Nested settings pages (`/src/views/settings/SettingsView.vue`)

### BasePagination
- **Used in**:
  - Dashboard activity logs (`/src/views/dashboard/DashboardView.vue`)
  - Data tables throughout the application

## Data Display Components

### BaseTable
- **Used in**:
  - Dashboard data tables (`/src/views/dashboard/DashboardView.vue`)
  - User Management tab in Settings (`/src/views/settings/SettingsView.vue`)
  - Settings history section (`/src/views/settings/SettingsView.vue`)

### BaseBadge
- **Used in**:
  - Admin access indicator in Settings context switcher (`/src/views/settings/SettingsView.vue`)
  - User role indicators in profile dropdown (`/src/App.vue`)
  - Status indicators throughout application
  - Notification counters in navigation

### BaseAvatar
- **Used in**:
  - Profile dropdown menu (`/src/App.vue`)
  - User profile page (`/src/views/profile/ProfileView.vue`)
  - Dashboard user section (`/src/views/dashboard/DashboardView.vue`)

### BaseSkeletonLoader
- **Used in**:
  - Dashboard during data loading (`/src/views/dashboard/DashboardView.vue`)
  - Profile page during data fetch (`/src/views/profile/ProfileView.vue`)
  - Settings page during loading states (`/src/views/settings/SettingsView.vue`)

### BaseTagChip
- **Used in**:
  - Dashboard activity filtering (`/src/views/dashboard/DashboardView.vue`)
  - Settings category tags (`/src/views/settings/SettingsView.vue`)

## Layout Components

### BaseGridLayout
- **Used in**:
  - Dashboard layout (`/src/views/dashboard/DashboardView.vue`)
  - Home view responsive grid (`/src/views/HomeView.vue`)
  - Settings page layout (`/src/views/settings/SettingsView.vue`)

### BaseSidebar
- **Used in**:
  - App layout for main navigation (`/src/App.vue`)
  - Dashboard sidebar (`/src/views/dashboard/DashboardView.vue`)

### BaseDivider
- **Used in**:
  - Multiple forms to separate sections
  - Dashboard content dividers
  - Settings page section dividers

## Feedback Components

### BaseToastNotification
- **Used in**:
  - Global notifications (implemented at app level)
  - Form submission feedback
  - Error handling notifications

### BaseProgressBarSpinner
- **Used in**:
  - Loading indicators throughout the application
  - Form submission states
  - Data fetching indicators

## Common Component Combinations

- **Form Patterns**:
  - BaseFormGroup + BaseInput + BaseButton for standard forms
  - BaseCard + BaseTabs + form components for settings sections
  - BaseAlert for validation feedback

- **Dashboard Patterns**:
  - BaseCard + BaseSkeletonLoader for dashboard widgets
  - BaseTabs + BaseTable + BasePagination for data sections
  - BaseTagChip for filtering options

- **Navigation Patterns**:
  - BaseBreadcrumb + page title for navigation context
  - Profile dropdown uses BaseAvatar + BaseBadge + dropdown menu
  - Main navigation uses BaseSidebar with active state indicators

- **Admin Context Pattern**:
  - BaseToggleSwitch + BaseBadge for context switching with role indication
  - Computed TabList property to dynamically change available tabs
  - URL query parameters to maintain state across page reloads
  - Centralized admin experience with consistent layout

## Implementation Notes

When implementing components in new areas:
1. Follow established patterns from similar views
2. Maintain consistent layout structures
3. Use BaseSkeleton for loading states
4. Show BaseAlert messages for feedback
5. Update this document with new usage patterns

Keep this document updated to facilitate component changes and ensure consistency across the application.
