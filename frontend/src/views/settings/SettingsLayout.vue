<template>
  <div class="max-w-4xl mx-auto">
    <!-- Page Header -->
    <div class="mb-6">
      <h1 class="text-3xl font-bold text-gray-900 dark:text-white">Settings</h1>
      <p class="text-gray-600 dark:text-gray-400">Manage your application preferences</p>
    </div>
    
    <!-- Settings Menubar Component -->
    <SettingsMenubar />
  </div>
</template>

<script setup>
import SettingsMenubar from '../../components/settings/SettingsMenubar.vue';
</script>
