/# Component Catalog

## Base Components
- **BaseButton**
  Purpose:
  A customizable button component with support for multiple variants (primary, secondary, outline, text, danger), sizes (sm, md, lg), loading states, and icons. Includes dark mode support and full-width (block) option. Used for all button interactions throughout the application.
  
  Used in:
  - Project management components (PhotoUploadSection, ConvertToJobButton, AssessmentContent, etc.)
  - User management (UserManagement, UserSettings)
  - Client management (ClientSettings, ClientTable* components)
  - Authentication views (LoginView, RegisterView)
  - Settings views (AppearanceSettings, AccountSettings, etc.)
  - General UI components (App.vue, HomeView)

- **BaseIcon**
  Purpose:
  A flexible icon component that renders SVG icons from a predefined set. Supports various sizes (xs, sm, md, lg, xl) and colors, with full dark mode compatibility. Includes stroke customization options (width, linecap, linejoin). Contains 20+ common icons for navigation, UI elements, and project-specific needs.
  
  Used in:
  - Project components (PreviousStateCard, StateContentDisplay, PhotoGrid, PhotoUploadSection, TimelineStep, ProjectCard, AssessmentContent)
  - Project views (ProjectsView, ProjectDetail)
  - Settings components (ProjectSettings)

- **BaseDivider**
  Purpose:
  A component to visually separate content, supporting horizontal and vertical orientations, and optional text integration within the divider line. Provides configurable styling options including line type (solid, dashed, dotted), thickness (thin, normal, thick), and text positioning (left, center, right). Includes dark mode support and accessibility attributes.
  
  Used in:
  No current usage found in codebase (component available but not actively used)

- **BaseGridLayout**
  Purpose: Provides a flexible grid and layout system using Tailwind CSS utilities. Can function as a responsive container, a flex row, or a grid column with configurable columns, gaps, and ordering.
  Used in: Currently unused in the project (as of 2025-04-15)

## Data Display
- **BaseTable**
  Purpose: A versatile table component for displaying structured data with sorting, selection, pagination support, and responsive adaptation. Features include:
    - Configurable columns with sortable headers
    - Row selection capabilities
    - Customizable loading and empty states
    - Slot-based customization for headers, cells, and footer
    - Dark mode support
    - Events for sort changes, row clicks, and selection changes
  
  Used in:
    - User management interface (UserManagementView.vue, UserManagement.vue)

- **BaseCard**
  Purpose:
  Flexible container component with customizable header, body and footer sections. Supports multiple visual variants (default, bordered, elevated), hover effects, and clickable state. Fully compatible with dark mode.
  Used in:
  - UserManagement (admin)
  - UserSettings
  - ClientSettings
  - ProjectSettings

- **BaseBadge**
  Purpose:
  A versatile badge component for displaying status indicators, tags, and counts. Supports multiple color variants, sizes, and optional icons/counts. Features include:
  - Color variants: gray, red, yellow, green, blue, indigo, purple, pink
  - Size variants: sm, md, lg
  - Optional count numbers and dot indicators
  - Dark mode compatibility
  - Slot support for custom content and icons
  
  Used in:
  - ProjectCard.vue (project status indicators)
  - UserManagement.vue (user role badges)
  - ClientTableResponsive.vue (client type indicators)
  - ProjectTableResponsive.vue (project type/status badges)
  - UserTableResponsive.vue (user role badges)
  - ClientSettings.vue (client status/primary address indicators)
  - UserSettings.vue (user role/status indicators)
  - ProjectSettings.vue (project status indicators)

- **BaseMap**
  Purpose:
  An interactive map component for displaying geographical data (currently using placeholder text as Leaflet integration is temporarily disabled). Supports center coordinates, zoom level, markers with popups, and custom tile layers.
  Used in:
  Not currently used in any components/views (as of 2025-04-15)

- **BaseSkeletonLoader**
  Purpose: Displays placeholder previews of content before it finishes loading. Supports various shapes (text, image, card, table, avatar, button) with configurable dimensions and animations. Used to improve perceived performance during data fetching.
  Used in:
    - Admin/UserManagement.vue (table loading state)
    - Settings/ClientTableResponsive.vue (table loading state)

- **BaseTagChip**
  Purpose:
  A small piece of information component used for categorization or labeling. Supports different colors, sizes, optional icons, and a removable state. Features include:
    - Color variants: gray, blue, green, yellow, red, purple
    - Size variants: sm, md
    - Optional icon integration
    - Removable state with remove event
    - Dark mode support
    - Slot support for custom content
  
  Used in:
  Not currently used in production (as of 2025-04-15)

- **Base*(Timeline)***
  Purpose:
  A timeline component for displaying a sequence of events or milestones. Supports both vertical and horizontal layouts with customizable markers (dot, number, icon) and descriptions. Features include:
    - Alternating content position option
    - Slots for customizing content, markers, and connectors
    - Dark mode support
    - Responsive design
  
  Used in:
  Not currently used in production (as of 2025-04-15)

- **BaseAvatar**
  Purpose:
  Displays user avatars with image URLs or initials as fallback. Supports multiple sizes (xs, sm, md, lg, xl), shapes (circle, rounded), and status indicators (online, offline, away, busy). Includes dark mode support and emits error events when image loading fails.
  
  Used in:
  - UserManagementView.vue (user list and detail views)
  - UserManagement.vue (admin interface)
  - UserTableCompact.vue (compact user listings)
  - UserSettings.vue (user profile and settings)

## Form Components
- **BaseInput**
  Purpose:
  A customizable input field component with support for different types (text, email, password, number, etc.), validation states (success, error, warning), icons (left/right), and helper text. Fully supports dark mode styling and v-model integration. Features include:
    - Configurable input types
    - Validation state styling
    - Icon integration (left/right)
    - Helper/error text display
    - Dark mode support
    - Required/disabled states
    - Full-width (block) option
  
  Used in:
  - AssessmentContent.vue (project assessments)
  - UserManagement.vue (admin interface)
  - RegisterView.vue (user registration)
  - UserManagementView.vue (user management)
  - LoginView.vue (authentication)
  - AccountSettings.vue (user settings)
  - SystemSettings.vue (system configuration)
  - UserSettings.vue (user profile)
  - ProjectSettings.vue (project configuration)
  - ClientSettings.vue (client management)

- **BaseSelect**
  Purpose:
  A customizable select/dropdown component with search functionality, grouped options, and single/multiple selection support. Features include:
    - Dark mode compatibility
    - Keyboard navigation
    - Accessibility attributes (ARIA)
    - Search filtering
    - Option grouping
    - Customizable placeholder text
    - Slot-based option rendering
    - Disabled state handling
    - Custom label/value keys
    - Blur/click outside handling
  
  Used in:
  - Settings views (SecuritySettings.vue, AppearanceSettings.vue, AccountSettings.vue, SystemSettings.vue)
  - Administration (UserManagementView.vue, UserManagement.vue)
  - Project components (AssessmentContent.vue)
  - Settings components (ClientTableResponsive.vue, ProjectTableResponsive.vue, UserTableResponsive.vue)
  - Client/User/Project settings (ClientSettings.vue, UserSettings.vue, ProjectSettings.vue)

- **BaseCheckboxRadio**
  Purpose:
  A versatile component for rendering single checkboxes, groups of checkboxes, or radio button groups. Supports custom styling, indeterminate state for checkboxes, and disabled states. Integrates with v-model for easy form handling. Features include:
    - Configurable input types (checkbox/radio)
    - Support for single/multiple selection via v-model
    - Indeterminate state handling for checkboxes
    - Customizable styling with dark mode support
    - Label slots for custom content
    - Disabled state handling
    - Full accessibility support
  
  Used in:
  Currently unused in production (as of 2025-04-15)

- **BaseDateTimePicker**
  Purpose:
  A comprehensive date/time picker component with single date, date range, and date+time selection modes. Features include:
    - Dark mode support
    - Form integration via BaseFormGroup
    - Validation and error handling
    - Custom styling matching project design system
    - Time selection integration
    - Range selection support
    - Accessibility attributes
  
  Used in:
  - Project management components (date selection)
  - User management (account expiration dates)
  - Client management (contract dates)
  - Settings views (date-related configurations)

- **BaseFileUpload**
  Purpose:
  A file upload component with drag & drop support, file previews (especially images), upload progress simulation, and file validation (type, size). Supports multiple file selection and customizable via slots. Features include:
    - Drag & drop interface with visual feedback
    - Image preview generation
    - File type validation (MIME types)
    - File size validation
    - Multiple file support with max files limit
    - Customizable dropzone content via slots
    - Progress indicators during upload
    - Dark mode support
    - Accessible file input
  
  Used in:
  Currently no usage found in production (component available but not actively used)

- **BaseFormGroup**
  Purpose:
  A wrapper component for form fields that standardizes the layout of labels, helper text, and error messages. Ensures consistent spacing and accessibility for form elements. Used to group inputs with their associated metadata.

  Used in:
  - User registration (RegisterView.vue)
  - Appearance settings (AppearanceSettings.vue)
  - Account settings (AccountSettings.vue)
  - System settings (SystemSettings.vue)
  - User management (UserManagementView.vue)
  - Other forms throughout the application


- **BaseRangeSlider**
  Purpose:
  A customizable range slider for selecting a numeric value or a range of values. Supports min/max, step increments, single or dual-thumb (range), and accessibility features. Used for settings that require numeric input within a range.

  Used in:
  - Appearance settings (AppearanceSettings.vue)


- **BaseTextarea**
  Purpose:
  A flexible textarea component for multi-line text input. Supports validation states, helper text, required/disabled states, and dark mode. Integrates with v-model for reactive forms.

  Used in:
  - Project detail (ProjectDetail.vue)
  - Assessment content (AssessmentContent.vue)
  - Active job content (ActiveJobContent.vue)
  - Photo upload section (PhotoUploadSection.vue)


- **BaseToggleSwitch**
  Purpose:
  A toggle switch component for boolean input. Supports v-model, disabled state, and custom labeling. Used for enabling/disabling features and settings.

  Used in:
  - Home view (HomeView.vue)
  - User management (UserManagementView.vue, UserManagement.vue)
  - Security settings (SecuritySettings.vue)
  - System settings (SystemSettings.vue)
  - Notifications settings (NotificationsSettings.vue)
  - Client/User/Project settings (ClientSettings.vue, UserSettings.vue, ClientTableResponsive.vue, UserTableResponsive.vue, etc.)


## Navigation
- **BaseBreadcrumb**
  Purpose:
  Displays a navigation trail showing the user's location within the app hierarchy. Supports custom separators, accessibility, and slot customization for items and separators.

  Used in:
  - (Usage not explicitly found; likely available for navigation in multi-level views)


- **BaseDropdownMenu**
  Purpose:
  A dropdown menu component supporting nested menus, icons, dividers, and keyboard navigation. Can be triggered by click or hover. Highly customizable for various menu and action lists.

  Used in:
  - (Usage not explicitly found; available for general dropdown menu needs)


- **BasePagination**
  Purpose:
  A pagination component for navigating paginated data sets. Displays page numbers, previous/next/first controls, and item ranges. Supports dark mode and accessibility.

  Used in:
  - User management (UserManagementView.vue, UserManagement.vue)
  - Invoicing (EstimatesList.vue, InvoicesList.vue)
  - Client/project/user table responsive and compact views (ClientTableResponsive.vue, ProjectTableResponsive.vue, UserTableResponsive.vue, etc.)


- **BaseTabs**
  Purpose:
  A flexible tab navigation component supporting horizontal/vertical orientation, icons, keyboard navigation, and ARIA accessibility. Allows custom tab content via slots.

  Used in:
  - (Usage not explicitly found; available for tabbed interfaces throughout the app)


- **MainNavigation**  
  Purpose:  
  Used in:  

{{ ... }}
## Overlays
- **BaseDrawer**  
  Purpose:  
  Used in:  

- **BaseModal**  
  Purpose:  
  Used in:  

- **BasePopover**  
  Purpose:  
  Used in:  

- **BaseTooltip**  
  Purpose:  
  Used in:  

## Feedback
- **BaseAlert**  
  Purpose:  
  Used in:  

- **BaseLoader**  
  Purpose:  
  Used in:  

- **BaseProgressBarSpinner**  
  Purpose:  
  Used in:  

- **BaseToastNotification**  
  Purpose:  
  Used in:  

## Project Components
- **ProjectCard**  
  Purpose:  
  Used in:  

- **PhotoUploadSection**  
  Purpose:  
  Used in:  

- **ActiveJobContent**  
  Purpose:  
  Used in:  

- **AssessmentContent**  
  Purpose:  
  Used in:  

- **ConvertToJobButton**  
  Purpose:  
  Used in:  

- **EstimateItemPhotos**  
  Purpose:  
  Used in:  

- **PhotoGrid**  
  Purpose:  
  Used in:  

- **PreviousStateCard**  
  Purpose:  
  Used in:  

- **ProjectTimeline**  
  Purpose:  
  Used in:  

- **StateContentDisplay**  
  Purpose:  
  Used in:  

- **TimelineStep**  
  Purpose:  
  Used in:  

## Settings Components
- **ClientSettings**  
  Purpose:  
  Used in:  

- **PdfSettings**  
  Purpose:  
  Used in:  

- **LLMPromptManager**  
  Purpose:  
  Used in:  

- **ProductCatalogManager**  
  Purpose:  
  Used in:  

- **ProjectSettings**  
  Purpose:  
  Used in:  

- **SettingsMenubar**  
  Purpose:  
  Used in:  

- **UserSettings**  
  Purpose:  
  Used in:  

## Enterprise Components
- **BaseAdvancedTable**  
  Purpose:  
  Used in:  

## Estimates Components
- **AssessmentMarkdownPanel**  
  Purpose:  
  Used in:  

- **EstimateControls**  
  Purpose:  
  Used in:  

- **EstimateFromAssessment**  
  Purpose:  
  Used in:  

- **EstimateItemEditor**  
  Purpose:  
  Used in:  

- **ExternalLLMInput**  
  Purpose:  
  Used in:  

- **LLMEstimateInput**  
  Purpose:  
  Used in:  

- **ProductMatchReview**  
  Purpose:  
  Used in:  

## Interactive
- **BaseAccordion**  
  Purpose:  
  Used in:  

- **BaseContextMenu**  
  Purpose:  
  Used in:  

## Invoicing
- **ClientSelector**  
  Purpose:  
  Used in:  

- **EstimateSelector**  
  Purpose:  
  Used in:  

- **FixedClientSelector**  
  Purpose:  
  Used in:  

- **LineItemsEditor**  
  Purpose:  
  Used in:  

## Layout
- **BaseSidebar**  
  Purpose:  
  Used in:  

- **BaseSplitPanel**  
  Purpose:  
  Used in:  

## Utility
- **BaseStepperWizard**  
  Purpose:  
  Used in:  

## Tables
- **ClientTableCompact**  
  Purpose:  
  Used in:  

- **ClientTableResponsive**  
  Purpose:  
  Used in:  

- **ProjectTableCompact**  
  Purpose:  
  Used in:  

- **ProjectTableResponsive**  
  Purpose:  
  Used in:  

- **UserTableCompact**  
  Purpose:  
  Used in:  

- **UserTableResponsive**  
  Purpose:  
  Used in: