# Component Catalog

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
  Used in:  

- **BaseMap**  
  Purpose:  
  Used in:  

- **BaseSkeletonLoader**  
  Purpose:  
  Used in:  

- **BaseTagChip**  
  Purpose:  
  Used in:  

- **BaseTimeline**  
  Purpose:  
  Used in:  

- **BaseAvatar**  
  Purpose:  
  Used in:  

## Form Components
- **BaseInput**  
  Purpose:  
  Used in:  

- **BaseSelect**  
  Purpose:  
  Used in:  

- **BaseCheckboxRadio**  
  Purpose:  
  Used in:  

- **BaseDateTimePicker**  
  Purpose:  
  Used in:  

- **BaseFileUpload**  
  Purpose:  
  Used in:  

- **BaseFormGroup**  
  Purpose:  
  Used in:  

- **BaseRangeSlider**  
  Purpose:  
  Used in:  

- **BaseTextarea**  
  Purpose:  
  Used in:  

- **BaseToggleSwitch**  
  Purpose:  
  Used in:  

## Navigation
- **BaseBreadcrumb**  
  Purpose:  
  Used in:  

- **BaseDropdownMenu**  
  Purpose:  
  Used in:  

- **BasePagination**  
  Purpose:  
  Used in:  

- **BaseTabs**  
  Purpose:  
  Used in:  

- **MainNavigation**  
  Purpose:  
  Used in:  

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