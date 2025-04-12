import { useAuthStore } from '../store/auth';

// Settings Layout
import SettingsLayout from '../views/settings/SettingsLayout.vue';

// User Settings Components
import AccountSettings from '../views/settings/AccountSettings.vue';
import NotificationsSettings from '../views/settings/NotificationsSettings.vue';
import AppearanceSettings from '../views/settings/AppearanceSettings.vue';
import SecuritySettings from '../views/settings/SecuritySettings.vue';

// Admin Settings Components
import UsersSettings from '../views/settings/UsersSettings.vue';
import RolesSettings from '../views/settings/RolesSettings.vue';
import ClientsSettings from '../views/settings/ClientsSettings.vue';
import ProjectsSettings from '../views/settings/ProjectsSettings.vue';
import ProductsSettings from '../views/settings/ProductsSettings.vue';
import PdfSettings from '../views/settings/PdfSettings.vue';
import SystemSettings from '../views/settings/SystemSettings.vue';
import LLMPromptsSettings from '../views/settings/LLMPromptsSettings.vue';

// Settings Routes
export default {
  path: '/settings',
  component: SettingsLayout,
  meta: { requiresAuth: true },
  children: [
    {
      path: '',
      redirect: '/settings/account'
    },
    {
      path: 'account',
      name: 'settings-account',
      component: AccountSettings
    },
    {
      path: 'notifications',
      name: 'settings-notifications',
      component: NotificationsSettings
    },
    {
      path: 'appearance',
      name: 'settings-appearance',
      component: AppearanceSettings
    },
    {
      path: 'security',
      name: 'settings-security',
      component: SecuritySettings
    },
    {
      path: 'products',
      name: 'settings-products',
      component: ProductsSettings
    },
    // Admin settings routes with access control
    {
      path: 'users',
      name: 'settings-users',
      component: UsersSettings,
      meta: { requiresAdmin: true },
      beforeEnter: (to, from, next) => {
        const authStore = useAuthStore();
        if (authStore.user?.role === 'admin') {
          next();
        } else {
          next({ name: 'settings-account' });
        }
      }
    },
    {
      path: 'roles',
      name: 'settings-roles',
      component: RolesSettings,
      meta: { requiresAdmin: true },
      beforeEnter: (to, from, next) => {
        const authStore = useAuthStore();
        if (authStore.user?.role === 'admin') {
          next();
        } else {
          next({ name: 'settings-account' });
        }
      }
    },
    {
      path: 'clients',
      name: 'settings-clients',
      component: ClientsSettings,
      meta: { requiresAdmin: true },
      beforeEnter: (to, from, next) => {
        const authStore = useAuthStore();
        if (authStore.user?.role === 'admin') {
          next();
        } else {
          next({ name: 'settings-account' });
        }
      }
    },
    {
      path: 'projects',
      name: 'settings-projects',
      component: ProjectsSettings,
      meta: { requiresAdmin: true },
      beforeEnter: (to, from, next) => {
        const authStore = useAuthStore();
        if (authStore.user?.role === 'admin') {
          next();
        } else {
          next({ name: 'settings-account' });
        }
      }
    },
    {
      path: 'pdf',
      name: 'settings-pdf',
      component: PdfSettings,
      meta: { requiresAdmin: true },
      beforeEnter: (to, from, next) => {
        const authStore = useAuthStore();
        if (authStore.user?.role === 'admin') {
          next();
        } else {
          next({ name: 'settings-account' });
        }
      }
    },
    {
      path: 'system',
      name: 'settings-system',
      component: SystemSettings,
      meta: { requiresAdmin: true },
      beforeEnter: (to, from, next) => {
        const authStore = useAuthStore();
        if (authStore.user?.role === 'admin') {
          next();
        } else {
          next({ name: 'settings-account' });
        }
      }
    },
    {
      path: 'llm-prompts',
      name: 'settings-llm-prompts',
      component: LLMPromptsSettings,
      meta: { requiresAdmin: true },
      beforeEnter: (to, from, next) => {
        const authStore = useAuthStore();
        if (authStore.user?.role === 'admin') {
          next();
        } else {
          next({ name: 'settings-account' });
        }
      }
    }
  ]
};
