import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import pinia from './store';
import PrimeVue from 'primevue/config';
import Aura from '@primeuix/themes/aura';
import Timeline from 'primevue/timeline';
import ColorPicker from 'primevue/colorpicker';
import Menubar from 'primevue/menubar';
import Select from 'primevue/select';
import Paginator from 'primevue/paginator';
import ToastService from 'primevue/toastservice';
import { setupCalendar } from 'v-calendar';
import clickOutsideDirective from './directives/click-outside';
import Toast from 'vue-toastification';

// PrimeVue core CSS
import 'primeicons/primeicons.css';
import 'v-calendar/style.css';
import 'vue-toastification/dist/index.css';
import './style.css';
// Theme variables and custom component styles
import './assets/css/theme-variables.css';
import './assets/css/custom-paginator.css';

const app = createApp(App);

// Ensure Pinia is installed before the router
app.use(pinia);
app.use(router);
app.use(PrimeVue, {
  theme: {
    preset: Aura
  }
});

// Register PrimeVue services
app.use(ToastService);

// Register PrimeVue components
app.component('Timeline', Timeline);
app.component('ColorPicker', ColorPicker);
app.component('Menubar', Menubar);
app.component('Select', Select);
app.component('Paginator', Paginator);

// Setup v-calendar
app.use(setupCalendar, {});

// Setup Toast
app.use(Toast, {
  position: "top-right",
  timeout: 3000,
  closeOnClick: true,
  pauseOnFocusLoss: true,
  pauseOnHover: true,
  draggable: true,
  hideProgressBar: false,
  closeButton: "button",
  icon: true,
  transition: "Vue-Toastification__bounce",
});

// Register custom directives
app.use(clickOutsideDirective);

app.mount('#app');
