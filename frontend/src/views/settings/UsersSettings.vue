<template>
  <BaseCard variant="bordered">
    <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">User Management</h3>
    <p class="text-gray-600 dark:text-gray-400 mb-6">Manage users and their permissions</p>
    
    <!-- Import the UserSettings component -->
    <UserSettings />
  </BaseCard>
</template>

<script setup>
import BaseCard from '../../components/data-display/BaseCard.vue';
import UserSettings from '../../components/settings/UserSettings.vue';
</script>
