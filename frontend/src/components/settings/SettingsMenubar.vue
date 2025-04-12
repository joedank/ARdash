<template>
  <div class="settings-menubar">
    <!-- Desktop Menubar -->
    <div class="hidden md:block">
      <Menubar :model="visibleMenuItems" class="mb-4">
        <template #start>
          <div class="font-semibold mr-4">Settings</div>
        </template>
        <template #item="{ item }">
          <router-link v-if="item.to" :to="item.to" custom v-slot="{ navigate, href }">
            <a :href="href" @click="navigate" class="p-menuitem-link">
              <span :class="item.icon" class="p-menuitem-icon"></span>
              <span class="p-menuitem-text">{{ item.label }}</span>
            </a>
          </router-link>
          <a v-else class="p-menuitem-link" @click="item.command && item.command($event)">
            <span :class="item.icon" class="p-menuitem-icon"></span>
            <span class="p-menuitem-text">{{ item.label }}</span>
            <span v-if="item.items" class="p-submenu-icon pi pi-angle-down"></span>
          </a>
        </template>
      </Menubar>
    </div>
    
    <!-- Mobile Select (replacing Dropdown) -->
    <div class="block md:hidden mb-4">
      <Select
        v-model="selectedMenuItem"
        :options="flattenedMenuItems"
        optionLabel="label"
        class="w-full"
        placeholder="Select Setting"
        @change="navigateToSetting"
      />
    </div>
    
    <router-view v-slot="{ Component }">
      <transition name="fade" mode="out-in">
        <component :is="Component" />
      </transition>
    </router-view>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, watch } from 'vue';
import Menubar from 'primevue/menubar';
import Select from 'primevue/select';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '../../store/auth';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();
const selectedMenuItem = ref(null);

// Check if user is admin
const isAdmin = computed(() => {
  return authStore.user?.role === 'admin';
});

// Define menu items
const menuItems = [
  {
    label: 'User Settings',
    icon: 'pi pi-user',
    items: [
      { label: 'Account', icon: 'pi pi-id-card', to: '/settings/account' },
      { label: 'Notifications', icon: 'pi pi-bell', to: '/settings/notifications' },
      { label: 'Appearance', icon: 'pi pi-eye', to: '/settings/appearance' },
      { label: 'Security', icon: 'pi pi-lock', to: '/settings/security' }
    ]
  },
  {
    label: 'Component Management',
    icon: 'pi pi-th-large',
    items: [
      { label: 'Product Catalog', icon: 'pi pi-list', to: '/settings/products' },
      { label: 'LLM Prompts', icon: 'pi pi-comments', to: '/settings/llm-prompts', visible: () => isAdmin.value }
    ]
  },
  {
    label: 'Site Settings',
    icon: 'pi pi-desktop',
    visible: () => isAdmin.value,
    items: [
      { 
        label: 'User Management', 
        icon: 'pi pi-users',
        to: '/settings/users'
      },
      { 
        label: 'Roles & Permissions', 
        icon: 'pi pi-lock',
        to: '/settings/roles'
      },
      { 
        label: 'Client Management', 
        icon: 'pi pi-users',
        to: '/settings/clients'
      },
      { 
        label: 'Project Management', 
        icon: 'pi pi-clipboard',
        to: '/settings/projects'
      },
      { 
        label: 'PDF Settings', 
        icon: 'pi pi-file-pdf',
        to: '/settings/pdf'
      },
      { 
        label: 'System Settings', 
        icon: 'pi pi-cog',
        to: '/settings/system'
      }
    ]
  }
];

// Create menu items with command functions for navigation
const processMenuItems = (items) => {
  return items.map(item => {
    const processed = { ...item };
    
    // Add command function for navigation
    if (item.to) {
      processed.command = () => router.push(item.to);
    }
    
    // Process nested items
    if (item.items) {
      processed.items = processMenuItems(item.items);
    }
    
    return processed;
  });
};

// Filter menu items based on visibility function
const visibleMenuItems = computed(() => {
  const filteredItems = menuItems
    .filter(item => !item.visible || item.visible())
    .map(item => {
      // Handle top-level items
      if (item.visible && !item.visible()) {
        return null;
      }
      
      // Handle nested items
      if (item.items) {
        return {
          ...item,
          items: item.items.filter(subItem => 
            !subItem.visible || subItem.visible()
          )
        };
      }
      
      return item;
    })
    .filter(Boolean);
    
  // Process items to add command functions
  return processMenuItems(filteredItems);
});

// Flatten menu items for mobile select
const flattenedMenuItems = computed(() => {
  const flattened = [];
  
  visibleMenuItems.value.forEach(item => {
    if (item.items) {
      item.items.forEach(subItem => {
        flattened.push({
          label: `${item.label} - ${subItem.label}`,
          to: subItem.to,
          icon: subItem.icon
        });
      });
    } else if (item.to) {
      flattened.push(item);
    }
  });
  
  return flattened;
});

// Handle navigation from dropdown
const navigateToSetting = () => {
  if (selectedMenuItem.value && selectedMenuItem.value.to) {
    router.push(selectedMenuItem.value.to);
  }
};

// Initialize component based on current route
onMounted(() => {
  // Get current path
  const currentPath = route.path;
  
  // Find matching menu item
  visibleMenuItems.value.forEach(category => {
    if (category.items) {
      category.items.forEach(item => {
        if (item.to === currentPath) {
          selectedMenuItem.value = {
            label: `${category.label} - ${item.label}`,
            to: item.to,
            icon: item.icon
          };
        }
      });
    }
  });
});

// Watch for route changes
watch(
  () => route.path,
  (newPath) => {
    // Update selected menu item
    visibleMenuItems.value.forEach(category => {
      if (category.items) {
        category.items.forEach(item => {
          if (item.to === newPath) {
            selectedMenuItem.value = {
              label: `${category.label} - ${item.label}`,
              to: item.to,
              icon: item.icon
            };
          }
        });
      }
    });
  }
);
</script>

<style scoped>
.settings-menubar :deep(.p-menubar) {
  background-color: var(--p-surface-card);
  border: 1px solid var(--p-surface-border);
  border-radius: 0.375rem;
}

.settings-menubar :deep(.p-menuitem-link) {
  color: var(--p-text-color);
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 0.75rem 1rem;
  transition: background-color 0.2s, color 0.2s;
  text-decoration: none;
}

.settings-menubar :deep(.p-menuitem-link:hover) {
  background-color: var(--p-surface-hover);
}

.settings-menubar :deep(.p-menuitem-icon) {
  margin-right: 0.5rem;
}

.settings-menubar :deep(.p-menuitem-text) {
  line-height: 1;
}

.settings-menubar :deep(.p-submenu-icon) {
  margin-left: 0.5rem;
}

/* Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
