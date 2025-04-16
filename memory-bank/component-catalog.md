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
  An off-canvas panel that slides in from the side, used for navigation menus, filters, or supplementary content. Supports left/right positions, custom width, backdrop, and accessibility features.

  Used in:
  - (Usage not explicitly found; available for navigation/filter overlays)

- **BaseModal**
  Purpose:
  A customizable modal dialog with header, body, and footer sections. Includes backdrop, focus trap, keyboard accessibility, and multiple sizing options.

  Used in:
  - User management (UserManagementView.vue)
  - (Likely used in other dialogs and confirmation flows)

- **BasePopover**
  Purpose:
  Displays rich content in a floating portal, triggered by hover or click. Useful for showing additional info, actions, or interactive UI without cluttering the main interface.

  Used in:
  - (Usage not explicitly found; available for contextual overlays)

- **BaseTooltip**
  Purpose:
  Shows a small informational box on hover or focus. Supports multiple positions, custom delays, and rich content via slots. Used for inline help and explanations.

  Used in:
  - (Usage not explicitly found; available for tooltips on buttons, icons, etc.)


## Feedback
- **BaseAlert**
  Purpose:
  A customizable alert for displaying feedback messages. Supports info, success, warning, error variants, can be dismissible, and works with dark mode.

  Used in:
  - Authentication (LoginView.vue, RegisterView.vue)
  - Home view (HomeView.vue)
  - User management (UserManagementView.vue)
  - Project detail (ProjectDetail.vue)
  - Settings (SecuritySettings.vue, NotificationsSettings.vue, AccountSettings.vue, AppearanceSettings.vue)

- **BaseLoader**
  Purpose:
  A spinner/loader for indicating loading states. Supports different sizes and color themes. Used in lists, forms, and anywhere async data is loaded.

  Used in:
  - Projects view (ProjectsView.vue)
  - Project detail (ProjectDetail.vue)
  - Create project (CreateProject.vue)

- **BaseProgressBarSpinner**
  Purpose:
  Displays progress as a determinate bar or indeterminate spinner. Supports different sizes, colors, and optional percentage display.

  Used in:
  - (Usage not explicitly found; available for upload/progress feedback)

- **BaseToastNotification**
  Purpose:
  Toast notification for transient feedback. Supports multiple types, auto-dismiss, actions, and custom content. Appears in the corner of the screen.

  Used in:
  - User management (UserManagementView.vue)
  - (Available for global notification needs)


## Project Components

- **ProjectCard**
  Purpose:
  Displays a summary card for a project, including client info, status, type, address, and estimate reference. Clickable for navigation. Integrates with badges and icons for visual status.

  Used in:
  - Projects view (ProjectsView.vue)

- **PhotoUploadSection**
  Purpose:
  A section for uploading project photos. Supports drag-and-drop, image preview, notes input, and upload/cancel actions. Integrates with BaseTextarea for notes and BaseButton for controls.

  Used in:
  - Project detail (ProjectDetail.vue)

- **ActiveJobContent**
  Purpose:
  Displays details and actions for active jobs, including photo uploads (before, after, receipts), additional work, and job-specific notes. Integrates PhotoUploadSection and PhotoGrid for managing job-related images.

  Used in:
  - StateContentDisplay (when viewing an active job)

- **AssessmentContent**
  Purpose:
  Shows the assessment details for a project, such as items, measurements, and notes. Used for both editing and readonly display of assessment data.

  Used in:
  - StateContentDisplay (when viewing an assessment)
  - PreviousStateCard (for assessment history)

- **ConvertToJobButton**
  Purpose:
  Button and modal to convert an assessment project into an active job. Handles confirmation, estimate requirements, and triggers conversion logic.

  Used in:
  - Project detail (ProjectDetail.vue)

- **EstimateItemPhotos**
  Purpose:
  Manages photos associated with estimate items, including upload, preview, deletion, and additional work notes. Handles camera integration and photo categorization.

  Used in:
  - Estimate item management (estimate-related views/components)

- **PhotoGrid**
  Purpose:
  Displays a grid of photos for a project or estimate, with support for preview modal, navigation, error handling, and notes badges. Integrates with PhotoUploadSection.

  Used in:
  - ActiveJobContent
  - Project detail (ProjectDetail.vue)
  - PhotoUploadSection

- **PreviousStateCard**
  Purpose:
  Expandable card showing previous assessment history for a project. Displays assessment data in a collapsible format for review.

  Used in:
  - Project detail (ProjectDetail.vue)

- **ProjectTimeline**
  Purpose:
  Visual timeline of project states (assessment, active, completed), with icons, dates, and navigation between steps. Indicates current progress and status.

  Used in:
  - Project detail (ProjectDetail.vue)

- **StateContentDisplay**
  Purpose:
  Displays either assessment or active job details for a project, switching based on project type. Integrates ActiveJobContent and AssessmentContent for unified display.

  Used in:
  - Project detail (ProjectDetail.vue)

- **TimelineStep**
  Purpose:
  Represents a single step in the project timeline, with icon, label, completion state, and navigation. Used within ProjectTimeline.

  Used in:
  - ProjectTimeline


## Settings Components

- **ClientSettings**
  Purpose:
  Provides a comprehensive interface for managing client records, including creation, editing, address management, billing, and preferences. Handles validation, error reporting, and integrates with forms and tables.

  Used in:
  - Settings views (Client management)

- **PdfSettings**
  Purpose:
  Allows administrators to configure PDF output settings for invoices and estimates, including company info, colors, margins, watermarks, and logo uploads. Integrates with backend for persistence.

  Used in:
  - Settings views (PDF configuration)

- **LLMPromptManager**
  Purpose:
  Enables management of prompts for large language model (LLM) integrations. Supports viewing, editing, and saving prompt templates used throughout the application.

  Used in:
  - Settings views (AI/LLM prompt management)

- **ProductCatalogManager**
  Purpose:
  Interface for managing the product and service catalog, including creation, editing, filtering, and deletion. Supports search, type filtering, and integrates with backend services.

  Used in:
  - Settings views (Product catalog management)

- **ProjectSettings**
  Purpose:
  Provides configuration and management for project-related settings, including project types, statuses, and pagination. Supports editing and filtering of project records.

  Used in:
  - Settings views (Project management)

- **SettingsMenubar**
  Purpose:
  Navigation component for settings sections. Displays a menubar or dropdown for navigating between user, client, project, system, and PDF settings. Supports both desktop and mobile layouts.

  Used in:
  - All settings views (as the main navigation for settings)

- **UserSettings**
  Purpose:
  Interface for managing user account settings, including profile info, password, notifications, and preferences. Handles validation, error reporting, and integrates with user management features.

  Used in:
  - Settings views (User account management)


## Enterprise Components
- **BaseAdvancedTable**
  Purpose:
  An advanced, highly-configurable table for displaying and manipulating structured data. Features include column freezing, row grouping, excel-like editing, row selection, and CSV/Excel export. Supports custom slots for headers, cells, and footers.

  Used in:
  - Enterprise data views (project, client, or product tables)

## Estimates Components

- **AssessmentMarkdownPanel**
  Purpose:
  Renders assessment data as interactive, styled markdown. Supports clickable sections, highlights, and linking between assessment items and estimate items for enhanced navigation and editing.

  Used in:
  - Estimate creation/editing (as part of EstimateFromAssessment)

- **EstimateControls**
  Purpose:
  Provides UI controls for adjusting estimate generation parameters, such as aggressiveness and estimation mode. Emits events for settings changes and regeneration requests.

  Used in:
  - EstimateFromAssessment (estimate parameter controls)

- **EstimateFromAssessment**
  Purpose:
  Main workflow container for generating estimates from assessment data. Integrates the markdown panel, item editor, and controls, managing the process of transforming assessments into actionable estimates.

  Used in:
  - Estimate creation from assessments

- **EstimateItemEditor**
  Purpose:
  Editor for individual estimate line items, allowing users to add, edit, or remove items, set quantities, units, and prices. Supports validation and integrates with the overall estimate workflow.

  Used in:
  - EstimateFromAssessment (estimate item editing)

- **ExternalLLMInput**
  Purpose:
  Enables users to paste responses from external LLMs for estimate generation. Validates, parses, and processes the LLM output, integrating assessment data and supporting product matching workflows.

  Used in:
  - Estimate generation (external LLM integration)

- **LLMEstimateInput**
  Purpose:
  Provides a guided interface for generating estimates using an integrated LLM, handling project selection and description input.

  Used in:
  - `EstimatesList.vue`, `EstimatesList.updated.vue` (invoicing views)

- **ProductMatchReview**
  Purpose:
  Displays and manages the review of matched products or services after LLM-based estimate generation, allowing edits before finalizing.

  Used in:
  - `ExternalLLMInput.vue`, `LLMEstimateInput.vue` (LLM-driven estimate input components)

- **BaseAccordion**  
  Purpose:  
  Provides a vertically stacked set of interactive headings that reveal content sections, supporting single or multiple open sections.

  Used in:  
  **Not currently used in any parent component or view (orphaned).**

- **BaseContextMenu**  
  Purpose:  
  Displays a context menu triggered by right-click events, allowing users to perform actions related to the element it's attached to.

  Used in:  
  **Not currently used in any parent component or view (orphaned).**

- **ClientSelector**  
  Purpose:  
  Allows users to select a client, providing options to add new clients and managing client data loading and selection.

  Used in:  
  `EditEstimate.vue`, `EditInvoice.vue`, `CreateInvoice.vue`, `CreateEstimate.vue` (invoicing views), and `ProjectSettings.vue` (project management).

- **EstimateSelector**  
  Purpose:  
  Manages the selection of estimates based on the selected client, loading estimates when a client is selected.

  Used in:  
  `CreateProject.vue` (project creation), and `ProjectSettings.vue` (project management).

- **FixedClientSelector**  
  Purpose:  
  A specialized client selector component that displays a pre-selected client, preventing changes. Used to lock the client context in workflows where changing the client is not permitted, ensuring data consistency during invoice or estimate creation.

  Used in:  
  **Not currently used in any parent component or view (orphaned).**

- **LineItemsEditor**  
  Purpose:  
  Provides an interactive interface for adding, editing, and removing line items (such as products or services) on invoices or estimates. Supports quantity, unit, price, and description fields, with validation and dynamic total calculation.

  Used in:  
  `CreateInvoice.vue`, `EditEstimate.vue`, `EditInvoice.vue`, `CreateEstimate.vue` (invoicing views).

## Interactive
- **BaseAccordion**  
  Purpose:  
  Provides a vertically stacked set of interactive headings that reveal content sections, supporting single or multiple open sections.

  Used in:  
  **Not currently used in any parent component or view (orphaned).**

- **BaseContextMenu**  
  Purpose:  
  Displays a context menu triggered by right-click events, allowing users to perform actions related to the element it's attached to.

  Used in:  
  **Not currently used in any parent component or view (orphaned).**

## Invoicing
- **ClientSelector**  
  Purpose:  
  Allows users to select a client, providing options to add new clients and managing client data loading and selection.

  Used in:  
  `EditEstimate.vue`, `EditInvoice.vue`, `CreateInvoice.vue`, `CreateEstimate.vue` (invoicing views), and `ProjectSettings.vue` (project management).

- **EstimateSelector**  
  Purpose:  
  Manages the selection of estimates based on the selected client, loading estimates when a client is selected.

  Used in:  
  `CreateProject.vue` (project creation), and `ProjectSettings.vue` (project management).

- **FixedClientSelector**  
  Purpose:  
  A specialized client selector component that displays a pre-selected client, preventing changes. Used to lock the client context in workflows where changing the client is not permitted, ensuring data consistency during invoice or estimate creation.

  Used in:  
  **Not currently used in any parent component or view (orphaned).**

- **LineItemsEditor**  
  Purpose:  
  Provides an interactive interface for adding, editing, and removing line items (such as products or services) on invoices or estimates. Supports quantity, unit, price, and description fields, with validation and dynamic total calculation.

  Used in:  
  `CreateInvoice.vue`, `EditEstimate.vue`, `EditInvoice.vue`, `CreateEstimate.vue` (invoicing views).

## Layout
- **BaseSidebar**  
  Purpose:  
  Provides a collapsible sidebar navigation component for the application's main layout. Supports nested menu items, icons, section headers, and active state highlighting. Allows for dynamic menu configuration and responsive behavior.

  Used in:  
  **Not currently used in any parent component or view (orphaned).**

- **BaseSplitPanel**  
  Purpose:  
  A layout component that divides its container into two resizable panels, either vertically or horizontally. Enables users to adjust the space allocation between panels via drag handle.

  Used in:  
  `EstimateFromAssessment.vue` (estimate generation workflow).

## Utility
- **BaseStepperWizard**  
  Purpose:  
  Guides users through multi-step processes with a visual stepper interface. Supports step validation, navigation, and progress indication. Can be configured for linear or non-linear flows.

  Used in:  
  **Not currently used in any parent component or view (orphaned).**

## Tables
- **ClientTableCompact**  
  Purpose:  
  Displays client data in a compact, space-efficient table format. Optimized for quick scanning and selection, with minimal visual clutter and optional row actions.

  Used in:  
  `ClientSettings.vue` (client management).

- **ClientTableResponsive**  
  Purpose:  
  Shows client data in a table that adapts to different screen sizes, hiding or stacking columns as needed for mobile or desktop.

  Used in:  
  `ClientSettings.vue` (client management).

- **ProjectTableCompact**  
  Purpose:  
  Presents project data in a condensed table format for easy browsing and quick actions. Prioritizes essential fields and supports row selection.

  Used in:  
  `ProjectSettings.vue` (project management).

- **ProjectTableResponsive**  
  Purpose:  
  Displays project data in a responsive table layout, ensuring usability across devices. Adjusts columns and layout for optimal viewing on small or large screens.

  Used in:  
  `ProjectSettings.vue` (project management).

- **UserTableCompact**  
  Purpose:  
  Shows user data in a minimal, high-density table for quick reference and management. Supports row selection, sorting, and basic actions.

  Used in:  
  `UserSettings.vue` (user management).

- **UserTableResponsive**  
  Purpose:  
  Renders user data in a table that automatically adapts to screen size, optimizing for both desktop and mobile use cases.

  Used in:  
  `UserSettings.vue` (user management).