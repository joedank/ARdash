<template>
  <BaseCard variant="bordered">
    <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Product Catalog</h3>
    <p class="text-gray-600 dark:text-gray-400 mb-6">Manage your products and services for estimates and invoices</p>
    
    <!-- Product Catalog Manager Component -->
    <ProductCatalogManager />
  </BaseCard>
</template>

<script setup>
import BaseCard from '../../components/data-display/BaseCard.vue';
import ProductCatalogManager from '../../components/settings/ProductCatalogManager.vue';
</script>
