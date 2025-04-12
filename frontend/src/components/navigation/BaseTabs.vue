<!--
  BaseTabs
  
  A flexible tabs component supporting horizontal and vertical orientations with icon support.
  Provides accessible keyboard navigation and ARIA attributes.
  
  @props {Object[]} tabList - Array of tab objects with id, title, and optional icon
  @props {String} orientation - Tab orientation ('horizontal' or 'vertical')
  @props {String} defaultTab - ID of the initially active tab
  @props {String} iconPosition - Position of icons relative to text ('left' or 'right')
  
  @slots default - Content panel container
  @slots {tabId} - Individual tab panel content (dynamic named slots using tab IDs)
  @slots tab-title - Custom tab title template
  @slots tab-icon - Custom tab icon template
  
  @events tab-change - Emitted when active tab changes
  @events tab-click - Emitted when a tab is clicked
  
  @example
  <BaseTabs
    :tab-list="[
      { id: 'tab1', title: 'Profile', icon: 'user' },
      { id: 'tab2', title: 'Settings', icon: 'cog' }
    ]"
    orientation="horizontal"
    @tab-change="handleTabChange"
  >
    <template #tab1>Profile content</template>
    <template #tab2>Settings content</template>
  </BaseTabs>
-->
<template>
  <div 
    :class="[
      'tabs-container',
      orientation === 'vertical' ? 'flex space-x-4' : 'space-y-2'
    ]"
  >
    <!-- Tab List -->
    <div 
      role="tablist"
      :aria-orientation="orientation"
      :class="[
        'flex',
        orientation === 'vertical' 
          ? 'flex-col space-y-1' 
          : 'space-x-1',
        'border rounded-lg',
        'bg-white dark:bg-gray-800',
        'border-gray-200 dark:border-gray-700'
      ]"
      @keydown="handleKeyDown"
    >
      <button
        v-for="tab in tabList"
        :key="tab.id"
        role="tab"
        :id="`tab-${tab.id}`"
        :aria-controls="`panel-${tab.id}`"
        :aria-selected="activeTab === tab.id"
        :tabindex="activeTab === tab.id ? 0 : -1"
        :class="[
          'group relative min-w-[100px] px-4 py-2',
          'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800',
          'rounded-md transition-colors',
          activeTab === tab.id 
            ? 'bg-blue-50 text-blue-700 dark:bg-blue-900/50 dark:text-blue-300'
            : 'text-gray-500 hover:text-gray-700 hover:bg-gray-50 dark:text-gray-400 dark:hover:text-gray-300 dark:hover:bg-gray-700/50',
        ]"
        @click="handleTabClick(tab.id)"
      >
        <div class="flex items-center justify-center space-x-2">
          <!-- Icon slot with fallback -->
          <slot 
            name="tab-icon" 
            v-bind="{ tab, active: activeTab === tab.id }"
          >
            <span v-if="tab.icon && iconPosition === 'left'" class="h-5 w-5">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <!-- User icon -->
                <path v-if="tab.icon === 'user'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                
                <!-- Users (multiple users) icon -->
                <path v-else-if="tab.icon === 'users'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                
                <!-- Cog/Settings icon -->
                <path v-else-if="tab.icon === 'cog'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                
                <!-- Bell icon -->
                <path v-else-if="tab.icon === 'bell'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                
                <!-- Eye icon -->
                <g v-else-if="tab.icon === 'eye'">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                </g>
                
                <!-- Lock icon -->
                <path v-else-if="tab.icon === 'lock'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                
                <!-- Clock icon -->
                <path v-else-if="tab.icon === 'clock'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                
                <!-- Default icon -->
                <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </span>
          </slot>
          
          <!-- Title slot with fallback -->
          <slot 
            name="tab-title" 
            v-bind="{ tab, active: activeTab === tab.id }"
          >
            <span>{{ tab.title }}</span>
          </slot>
          
          <!-- Right-positioned icon -->
          <slot 
            name="tab-icon" 
            v-bind="{ tab, active: activeTab === tab.id }"
          >
            <span v-if="tab.icon && iconPosition === 'right'" class="h-5 w-5">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <!-- User icon -->
                <path v-if="tab.icon === 'user'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                
                <!-- Users (multiple users) icon -->
                <path v-else-if="tab.icon === 'users'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                
                <!-- Cog/Settings icon -->
                <path v-else-if="tab.icon === 'cog'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                
                <!-- Bell icon -->
                <path v-else-if="tab.icon === 'bell'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                
                <!-- Eye icon -->
                <g v-else-if="tab.icon === 'eye'">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                </g>
                
                <!-- Lock icon -->
                <path v-else-if="tab.icon === 'lock'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                
                <!-- Clock icon -->
                <path v-else-if="tab.icon === 'clock'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                
                <!-- Default icon -->
                <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </span>
          </slot>
        </div>
      </button>
    </div>

    <!-- Tab Panels -->
    <div class="flex-1">
      <div
        v-for="tab in tabList"
        :key="tab.id"
        :id="`panel-${tab.id}`"
        role="tabpanel"
        :aria-labelledby="`tab-${tab.id}`"
        :class="[
          'focus:outline-none',
          { 'hidden': activeTab !== tab.id }
        ]"
        tabindex="0"
      >
        <slot :name="tab.id"></slot>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const props = defineProps({
  tabList: {
    type: Array,
    required: true,
    validator: (value) => {
      return value.every(tab => 
        typeof tab === 'object' && 
        'id' in tab && 
        'title' in tab
      );
    }
  },
  orientation: {
    type: String,
    default: 'horizontal',
    validator: (value) => ['horizontal', 'vertical'].includes(value)
  },
  defaultTab: {
    type: String,
    default: null
  },
  iconPosition: {
    type: String,
    default: 'left',
    validator: (value) => ['left', 'right'].includes(value)
  }
});

const emit = defineEmits(['tab-change', 'tab-click']);

// State
const activeTab = ref(props.defaultTab || (props.tabList[0]?.id ?? null));

// Event Handlers
const handleTabClick = (tabId) => {
  activeTab.value = tabId;
  emit('tab-click', tabId);
  emit('tab-change', tabId);
};

// Keyboard Navigation
const handleKeyDown = (event) => {
  const currentIndex = props.tabList.findIndex(tab => tab.id === activeTab.value);
  let nextIndex;

  switch (event.key) {
    case 'ArrowRight':
    case 'ArrowDown':
      event.preventDefault();
      nextIndex = (currentIndex + 1) % props.tabList.length;
      break;
    case 'ArrowLeft':
    case 'ArrowUp':
      event.preventDefault();
      nextIndex = (currentIndex - 1 + props.tabList.length) % props.tabList.length;
      break;
    case 'Home':
      event.preventDefault();
      nextIndex = 0;
      break;
    case 'End':
      event.preventDefault();
      nextIndex = props.tabList.length - 1;
      break;
    default:
      return;
  }

  const nextTab = props.tabList[nextIndex];
  if (nextTab) {
    handleTabClick(nextTab.id);
    // Focus the newly activated tab
    document.getElementById(`tab-${nextTab.id}`)?.focus();
  }
};
</script>
