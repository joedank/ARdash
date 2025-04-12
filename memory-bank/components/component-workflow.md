# Component Development Workflow

This document outlines the step-by-step process for developing, documenting, and integrating new components into our Vue.js component library.

## 1. Implementation

1. Create component file in appropriate folder:
   ```
   /src/components/{category}/{ComponentName}.vue
   ```

2. Start with component documentation in comments:
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
    */
   ```

3. Build the template with Tailwind classes:
   - Follow dark mode pattern with both light/dark variants
   - Ensure proper accessibility attributes
   - Use consistent spacing and sizing

4. Implement the script with props validation:
   ```javascript
   const props = defineProps({
     propName: {
       type: Type,
       default: defaultValue,
       required: boolean,
       validator: (value) => boolean
     }
   });
   ```

5. Add event handlers and emitters:
   ```javascript
   const emit = defineEmits(['event-name']);
   
   const handleEvent = () => {
     emit('event-name', data);
   };
   ```

6. Test in both light and dark modes

## 2. Example Implementation

1. Create example file in `/views/examples/{component-category}/{ComponentName}Example.vue`:
   ```
   /views/examples/form/InputExample.vue
   /views/examples/navigation/TabsExample.vue
   ```

2. Use the ExampleLayout component:
   ```vue
   <template>
     <ExampleLayout>
       <div class="p-6 space-y-12">
         <!-- Example content -->
       </div>
     </ExampleLayout>
   </template>
   ```

3. Demonstrate all main features and variations:
   - Basic usage
   - Different states (normal, hover, active, disabled)
   - Size variations
   - Color/variant options
   - With/without icons
   - Custom content via slots

4. Show common use cases and patterns:
   - Form integration
   - Data display
   - User interaction patterns

5. Include responsive behavior examples:
   - Mobile-friendly configurations
   - Adaptive layouts

6. Document with clear comments explaining each example:
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
   ```

## 3. Route Configuration

1. Add lazy-loaded route in `router/index.js`:
   ```javascript
   {
     path: 'component-name',
     name: 'component-name-example',
     component: () => import('../views/examples/component-category/ComponentNameExample.vue')
   }
   ```

2. Ensure the route is nested under the admin examples path:
   ```javascript
   {
     path: '/admin/examples',
     meta: { requiresAuth: true },
     children: [
       // Your new component route here
     ]
   }
   ```

## 4. Component List Update

1. Add the component to `ComponentExamplesList.vue` in the appropriate category:
   ```vue
   <li>
     <router-link 
       to="/admin/examples/component-name"
       class="group flex items-center justify-between p-2 rounded-lg
              text-gray-700 dark:text-gray-300
              hover:bg-gray-50 dark:hover:bg-gray-800"
     >
       <span class="flex items-center space-x-2">
         <span class="text-green-500 dark:text-green-400">✓</span>
         <span>Component Name</span>
       </span>
       <span class="text-gray-400 group-hover:text-gray-600 dark:text-gray-500 dark:group-hover:text-gray-400">
         →
       </span>
     </router-link>
   </li>
   ```

2. For components without examples yet, use non-clickable entry with "Coming Soon":
   ```vue
   <li>
     <div 
       class="group flex items-center justify-between p-2 rounded-lg
              text-gray-700 dark:text-gray-300"
     >
       <span class="flex items-center space-x-2">
         <span class="text-green-500 dark:text-green-400">✓</span>
         <span>Component Name</span>
         <span class="text-xs bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 px-2 py-0.5 rounded">
           Coming Soon
         </span>
       </span>
     </div>
   </li>
   ```

3. For planned components, use appropriate status tags:
   - "Next" tag for the next priority component (yellow background)
   - "Planned" tag for future components (gray background)

## 5. Documentation Updates

1. Update `component-checklist.md`:
   - Mark completed features with ✅
   - Add the file path to the component
   - Ensure all sub-features are marked appropriately
   - Update implementation priority if needed

2. Update `progress.md` with implementation details:
   - Document key decisions made during implementation
   - Note any challenges or solutions discovered
   - Record any technical debt or future improvements

3. Update `.clinerules` if any project-specific patterns were discovered

## Example Workflow

For a new "Badge" component:

1. Create `frontend/src/components/display/BaseBadge.vue`
2. Implement the component with proper documentation
3. Create `frontend/src/views/examples/display/BadgeExample.vue`
4. Add route to `router/index.js`
5. Update `ComponentExamplesList.vue` to include a link to the example
6. Update documentation in `component-checklist.md` and `progress.md`

This workflow ensures consistent development, documentation, and integration of all components in our library.
