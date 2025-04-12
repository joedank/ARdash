/** @type {import('tailwindcss').Config} */
export default {
  // Content paths are automatically detected in Tailwind v4
  // but we can still specify paths for clarity
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  // darkMode: 'class' is no longer needed in Tailwind v4 (using @custom-variant instead)
  theme: {
    extend: {
      zIndex: {
        'primevue-overlay': 9999
      }
    },
  },
  safelist: [
    // Card styles
    'bg-white', 'dark:bg-gray-900', 
    'border', 'border-gray-200', 'dark:border-gray-700',
    'bg-gray-50', 'dark:bg-gray-800',
    'shadow-sm', 'shadow-md', 'dark:shadow-gray-800/50',
    'hover:shadow-lg', 'rounded-lg',
    'px-4', 'py-3', 'p-4', 'p-2', 'p-3',
    
    // Text styles
    'text-gray-900', 'dark:text-white',
    'text-gray-800', 'dark:text-white',
    'text-gray-700', 'dark:text-gray-300',
    'text-gray-600', 'dark:text-gray-400',
    'text-gray-500', 'dark:text-gray-400',
    'text-sm', 'text-base', 'text-lg', 'text-xl', 'text-2xl', 'text-3xl',
    'font-medium', 'font-semibold', 'font-bold',
    
    // Spacing/Padding utilities
    'px-1', 'px-2', 'px-3', 'px-4', 'px-5', 'px-6',
    'py-1', 'py-2', 'py-3', 'py-4', 'py-5', 'py-6',
    'pt-1', 'pb-1', 'pl-1', 'pr-1',
    'mt-1', 'mt-2', 'ml-1', 'ml-2', 'ml-6', 'mr-1',
    
    // Flex/Grid layouts
    'flex', 'items-center', 'items-start', 'justify-between',
    'flex-shrink-0', 'flex-1', 'flex-col', 'space-y-4',
    'grid', 'grid-cols-1', 'md:grid-cols-3', 'lg:grid-cols-3', 'gap-6',
    
    // Common utilities
    'transition-all', 'duration-200', 'rounded-full',
    'divide-y', 'divide-gray-200', 'dark:divide-gray-700',
    'overflow-hidden',
    
    // Color utilities for icons and indicators
    'bg-blue-100', 'dark:bg-blue-900', 'text-blue-600', 'dark:text-blue-300',
    'bg-green-100', 'dark:bg-green-900', 'text-green-600', 'dark:text-green-300',
    'bg-purple-100', 'dark:bg-purple-900', 'text-purple-600', 'dark:text-purple-300',
    'bg-red-100', 'dark:bg-red-900', 'text-red-600', 'dark:text-red-300',
    'bg-yellow-100', 'dark:bg-yellow-900', 'text-yellow-600', 'dark:text-yellow-300',
  ],
  corePlugins: {
    preflight: false,
  },
  plugins: [],
}
