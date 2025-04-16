import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '../store/auth';
import HomeView from '../views/HomeView.vue';
import LoginView from '../views/LoginView.vue';
import RegisterView from '../views/RegisterView.vue';

// Invoicing Views
import InvoicesList from '../views/invoicing/InvoicesList.vue';
import CreateInvoice from '../views/invoicing/CreateInvoice.vue';
import InvoiceDetail from '../views/invoicing/InvoiceDetail.vue';
import EditInvoice from '../views/invoicing/EditInvoice.vue';

// Estimate Views
import EstimatesList from '../views/invoicing/EstimatesList.vue';
import CreateEstimate from '../views/invoicing/CreateEstimate.vue';
import EstimateDetail from '../views/invoicing/EstimateDetail.vue';
import EditEstimate from '../views/invoicing/EditEstimate.vue';
import AssessmentToEstimateView from '../views/invoicing/AssessmentToEstimateView.vue';

// Project Management Views
import ProjectDetail from '../views/projects/ProjectDetail.vue';
import ProjectsView from '../views/projects/ProjectsView.vue';
// ProjectLineItemPhotos was removed and integrated into ProjectDetail

// Community Management Views
import CommunitiesListView from '../views/communities/CommunitiesListView.vue';
import CommunityDetailView from '../views/communities/CommunityDetailView.vue';

// Import Settings Routes
import settingsRoutes from './settings.routes';

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView,
    meta: { requiresAuth: true }
  },
  {
    path: '/about',
    name: 'about',
    component: () => import('../views/AboutView.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/login',
    name: 'login',
    component: LoginView,
    meta: { requiresGuest: true }
  },
  {
    path: '/register',
    name: 'register',
    component: RegisterView,
    meta: { requiresGuest: true }
  },

  // Settings routes
  settingsRoutes,
  {
    // Project management routes
    path: '/projects',
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'projects-list',
        component: ProjectsView
      },
      {
        path: ':id',
        name: 'project-detail',
        component: ProjectDetail
      },
      // Line item photos route removed - integrated directly into project detail
      {
        path: 'create',
        name: 'create-project',
        component: () => import('../views/projects/CreateProject.vue')
      }
    ]
  },
  {
    // Community management routes
    path: '/communities',
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'communities-list',
        component: CommunitiesListView
      },
      {
        path: ':id',
        name: 'community-detail',
        component: CommunityDetailView
      }
    ]
  },
  {
    // Invoicing module routes
    path: '/invoicing',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'invoices',
        name: 'invoices-list',
        component: InvoicesList
      },
      {
        path: 'create-invoice',
        name: 'create-invoice',
        component: CreateInvoice
      },
      {
        path: 'invoice/:id',
        name: 'invoice-detail',
        component: InvoiceDetail
      },
      {
        path: 'edit-invoice/:id',
        name: 'edit-invoice',
        component: EditInvoice
      },
      // Estimate routes
      {
        path: 'estimates',
        name: 'estimates-list',
        component: EstimatesList
      },
      {
        path: 'create-estimate',
        name: 'create-estimate',
        component: CreateEstimate
      },
      {
        path: 'estimate/:id',
        name: 'estimate-detail',
        component: EstimateDetail
      },
      {
        path: 'edit-estimate/:id',
        name: 'edit-estimate',
        component: EditEstimate
      },
      // Assessment to Estimate route
      {
        path: 'assessment-to-estimate',
        name: 'assessment-to-estimate',
        component: AssessmentToEstimateView
      },
      // Estimate Finalization route
      {
        path: 'estimate/:id/finalize',
        name: 'estimate-finalization',
        component: () => import('../views/invoicing/EstimateFinalization.vue'),
        meta: {
          requiresAuth: true,
          title: 'Finalize Estimate'
        }
      }
    ]
  },
  {
    path: '/administration',
    meta: { requiresAuth: true, requiresAdmin: true },
    beforeEnter: (to, from, next) => {
      const authStore = useAuthStore();
      if (authStore.user?.role === 'admin') {
        next();
      } else {
        next({ name: 'home' });
      }
    },
    children: [
      {
        path: 'users',
        name: 'user-management',
        redirect: { path: '/settings/users' }
      }
    ]
  },
  {
    // Catch all undefined routes
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    redirect: to => {
      const authStore = useAuthStore();
      return authStore.isAuthenticated ? '/' : '/login';
    }
  }
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
});

// Navigation guards
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore();

  if (!authStore.authChecked) {
    await authStore.checkAuth();
  }

  const isAuthenticated = authStore.isAuthenticated;

  if (to.meta.requiresAuth && !isAuthenticated) {
    next({ name: 'login' });
  } else if (to.meta.requiresAdmin && authStore.user?.role !== 'admin') {
    next({ name: 'home' });
  } else if (to.meta.requiresGuest && isAuthenticated) {
    next('/');
  } else {
    next();
  }
});

export default router;
