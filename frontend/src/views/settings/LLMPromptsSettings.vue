<template>
  <BaseCard variant="bordered">
    <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">LLM Prompt Settings</h3>
    <p class="text-gray-600 dark:text-gray-400 mb-6">Customize the prompts used by the LLM estimate generator for optimal results</p>
    
    <!-- LLM Prompt Manager Component -->
    <LLMPromptManager />
  </BaseCard>
</template>

<script setup>
import BaseCard from '../../components/data-display/BaseCard.vue';
import LLMPromptManager from '../../components/settings/LLMPromptManager.vue';
</script>
