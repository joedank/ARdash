<template>
  <div class="space-y-8">
    <!-- Welcome Message -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold mb-2 text-gray-900 dark:text-white">Welcome, {{ user?.firstName || user?.username }}!</h1>
      <p class="text-gray-600 dark:text-gray-400">Your authenticated dashboard</p>
    </div>
    
    <!-- Stats Overview -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <BaseCard
        v-for="(stat, index) in statCards"
        :key="index"
        variant="elevated"
        hover
      >
        <div class="flex items-start">
          <div class="flex-shrink-0">
            <div :class="[
              'p-3 rounded-full',
              stat.bgColor,
              stat.textColor
            ]">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="stat.icon"></path>
              </svg>
            </div>
          </div>
          <div class="ml-4">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">{{ stat.label }}</h3>
            <p class="text-3xl font-bold text-gray-900 dark:text-white">{{ stat.value }}</p>
            <p class="text-sm text-gray-500 dark:text-gray-400">{{ stat.description }}</p>
          </div>
        </div>
      </BaseCard>
    </div>
    
    <!-- Main Dashboard Content -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Recent Activity -->
      <div class="lg:col-span-2">
        <BaseCard 
          title="Recent Activity" 
          variant="bordered"
          withHeader
        >
          <div v-if="isLoading" class="py-8">
            <BaseSkeletonLoader type="text" :count="3" class="mb-4" />
          </div>
          <div v-else-if="activities.length === 0" class="py-8 text-center text-gray-500 dark:text-gray-400">
            No recent activities found.
          </div>
          <ul v-else class="divide-y divide-gray-200 dark:divide-gray-700">
            <li v-for="activity in activities" :key="activity.id" class="py-4">
              <div class="flex items-start">
                <div class="flex-shrink-0">
                  <div :class="[
                    'p-2 rounded-full',
                    activity.iconBg,
                    activity.iconColor
                  ]">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="activity.icon"></path>
                    </svg>
                  </div>
                </div>
                <div class="ml-3 flex-1">
                  <div class="flex items-center justify-between">
                    <p class="text-sm font-medium text-gray-900 dark:text-white">
                      {{ activity.title }}
                    </p>
                    <p class="text-xs text-gray-500 dark:text-gray-400">
                      {{ activity.time }}
                    </p>
                  </div>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    {{ activity.description }}
                  </p>
                </div>
              </div>
            </li>
          </ul>
          <div v-if="!isLoading && activities.length > 0" class="mt-4 text-center">
            <BaseButton variant="text" size="sm">
              View all activity
            </BaseButton>
          </div>
        </BaseCard>
        
        <!-- Project Progress -->
        <BaseCard 
          title="Project Progress" 
          variant="bordered"
          withHeader
          class="mt-6"
        >
          <div class="space-y-4">
            <div v-for="(project, index) in projects" :key="index">
              <div class="flex justify-between mb-1">
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ project.name }}</span>
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ project.progress }}%</span>
              </div>
              <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2.5">
                <div 
                  class="h-2.5 rounded-full transition-all" 
                  :class="project.color"
                  :style="{ width: project.progress + '%' }"
                ></div>
              </div>
            </div>
          </div>
        </BaseCard>
      </div>
      
      <!-- Right Column -->
      <div class="space-y-6">
        <!-- Quick Tasks -->
        <BaseCard 
          title="Quick Tasks" 
          variant="bordered"
          withHeader
        >
          <div class="space-y-3">
            <div v-for="(task, index) in tasks" :key="index" class="flex items-center space-x-2">
              <BaseToggleSwitch 
                v-model="task.completed" 
                :label="task.label"
              />
            </div>
          </div>
          <div class="mt-4 pt-3 border-t border-gray-200 dark:border-gray-700">
            <BaseButton variant="text" size="sm" class="text-blue-600 dark:text-blue-400">
              + Add new task
            </BaseButton>
          </div>
        </BaseCard>
        
        <!-- Notifications -->
        <BaseCard 
          title="Notifications" 
          variant="bordered"
          withHeader
        >
          <div class="space-y-4">
            <BaseAlert 
              v-for="(notification, index) in notifications" 
              :key="index"
              :variant="notification.type"
              :title="notification.title"
              :message="notification.message"
              dismissible
              icon
            />
            <div v-if="notifications.length === 0" class="py-4 text-center text-gray-500 dark:text-gray-400">
              No new notifications.
            </div>
          </div>
        </BaseCard>
        
        <!-- Work Types Widget -->
        <WorkTypesWidget class="mt-6" />
        
        <!-- Calendar Events -->
        <BaseCard 
          title="Upcoming Events" 
          variant="bordered"
          withHeader
        >
          <div v-if="upcomingEvents.length === 0" class="py-4 text-center text-gray-500 dark:text-gray-400">
            No upcoming events.
          </div>
          <div v-else class="space-y-3">
            <div 
              v-for="(event, index) in upcomingEvents" 
              :key="index"
              class="p-3 rounded-lg bg-gray-50 dark:bg-gray-800"
            >
              <div class="flex items-start">
                <div class="flex-shrink-0 w-10 text-center">
                  <div class="text-sm font-bold text-gray-900 dark:text-white">{{ event.day }}</div>
                  <div class="text-xs text-gray-500 dark:text-gray-400">{{ event.month }}</div>
                </div>
                <div class="ml-3">
                  <div class="text-sm font-medium text-gray-900 dark:text-white">{{ event.title }}</div>
                  <div class="text-xs text-gray-500 dark:text-gray-400">{{ event.time }}</div>
                </div>
              </div>
            </div>
          </div>
        </BaseCard>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useAuthStore } from '../store/auth';
import BaseCard from '../components/data-display/BaseCard.vue';
import BaseAlert from '../components/feedback/BaseAlert.vue';
import BaseToggleSwitch from '../components/form/BaseToggleSwitch.vue';
import BaseSkeletonLoader from '../components/data-display/BaseSkeletonLoader.vue';
import BaseButton from '../components/base/BaseButton.vue';
import WorkTypesWidget from '../components/dashboard/WorkTypesWidget.vue';

const authStore = useAuthStore();
const user = computed(() => authStore.user);
const isLoading = ref(true);

// Example stats data
const statCards = [
  {
    label: 'Total Users',
    value: '24',
    description: 'Registered accounts',
    icon: 'M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z',
    bgColor: 'bg-blue-100 dark:bg-blue-900',
    textColor: 'text-blue-600 dark:text-blue-300'
  },
  {
    label: 'Active Projects',
    value: '7',
    description: 'Current active projects',
    icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2',
    bgColor: 'bg-green-100 dark:bg-green-900',
    textColor: 'text-green-600 dark:text-green-300'
  },
  {
    label: 'Tasks Completed',
    value: '86%',
    description: 'Overall completion rate',
    icon: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z',
    bgColor: 'bg-purple-100 dark:bg-purple-900',
    textColor: 'text-purple-600 dark:text-purple-300'
  }
];

// Example activities data
const activities = ref([]);

// Example tasks data
const tasks = ref([
  { id: 1, label: 'Complete project setup', completed: true },
  { id: 2, label: 'Review authentication flow', completed: false },
  { id: 3, label: 'Implement dashboard UI', completed: false },
  { id: 4, label: 'Test component library', completed: true }
]);

// Example notifications data
const notifications = ref([
  {
    id: 1,
    type: 'info',
    title: 'System Update',
    message: 'System will undergo maintenance on Saturday, March 30 at 2:00 AM.'
  },
  {
    id: 2,
    type: 'success',
    title: 'Profile Updated',
    message: 'Your profile information has been successfully updated.'
  }
]);

// Example project data
const projects = [
  {
    name: 'Website Core',
    progress: 75,
    color: 'bg-blue-600 dark:bg-blue-500'
  },
  {
    name: 'Component Library',
    progress: 90,
    color: 'bg-green-600 dark:bg-green-500'
  },
  {
    name: 'User Management',
    progress: 45,
    color: 'bg-purple-600 dark:bg-purple-500'
  },
  {
    name: 'API Integration',
    progress: 30,
    color: 'bg-yellow-600 dark:bg-yellow-500'
  }
];

// Example upcoming events
const upcomingEvents = [
  {
    day: '30',
    month: 'Mar',
    title: 'Team Meeting',
    time: '09:00 AM - 10:30 AM'
  },
  {
    day: '02',
    month: 'Apr',
    title: 'Project Deadline',
    time: 'All day'
  },
  {
    day: '05',
    month: 'Apr',
    title: 'Code Review',
    time: '02:00 PM - 03:30 PM'
  }
];

// Simulate loading data from an API
onMounted(() => {
  setTimeout(() => {
    activities.value = [
      {
        id: 1,
        title: 'New user registered',
        description: 'John Doe created a new account',
        time: '2 hours ago',
        icon: 'M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z',
        iconBg: 'bg-blue-100 dark:bg-blue-900',
        iconColor: 'text-blue-600 dark:text-blue-300'
      },
      {
        id: 2,
        title: 'Project updated',
        description: 'Marketing campaign details were updated',
        time: '4 hours ago',
        icon: 'M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z',
        iconBg: 'bg-green-100 dark:bg-green-900',
        iconColor: 'text-green-600 dark:text-green-300'
      },
      {
        id: 3,
        title: 'Task completed',
        description: 'Component library implementation finished',
        time: '1 day ago',
        icon: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z',
        iconBg: 'bg-purple-100 dark:bg-purple-900',
        iconColor: 'text-purple-600 dark:text-purple-300'
      }
    ];
    isLoading.value = false;
  }, 1500);
});
</script>
