<template>
  <BaseCard variant="bordered">
    <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">PDF Configuration</h3>
    <p class="text-gray-600 dark:text-gray-400 mb-6">Configure your PDF documents appearance and settings</p>
    
    <!-- PDF Settings Component -->
    <PdfSettings />
  </BaseCard>
</template>

<script setup>
import BaseCard from '../../components/data-display/BaseCard.vue';
import PdfSettings from '../../components/settings/PdfSettings.vue';
</script>
