<template>
  <BaseCard variant="bordered">
    <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Project Management</h3>
    <p class="text-gray-600 dark:text-gray-400 mb-6">Manage your projects and assessments</p>
    
    <!-- Project Settings Component -->
    <ProjectSettings />
  </BaseCard>
</template>

<script setup>
import BaseCard from '../../components/data-display/BaseCard.vue';
import ProjectSettings from '../../components/settings/ProjectSettings.vue';
</script>
