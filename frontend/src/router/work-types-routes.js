/**
 * Work types routes configuration
 */

// Import the WorkTypesList component (lazy-loaded)
const WorkTypesList = () => import('../components/work-types/WorkTypesList.vue');

// Define the routes
const routes = [
  {
    path: '/work-types',
    name: 'work-types',
    component: WorkTypesList,
    meta: { 
      requiresAuth: true,
      title: 'Work Types'
    }
  }
];

export default routes;
