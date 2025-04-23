<template>
  <div class="work-types-list">
    <div class="mb-6 flex justify-between items-center">
      <h2 class="text-xl font-semibold">Work Types</h2>
      <div class="flex space-x-2">
        <button
          @click="showFilters = !showFilters"
          class="px-3 py-1.5 border border-gray-300 dark:border-gray-700 rounded-md flex items-center text-sm"
        >
          <span class="mr-1">Filters</span>
          <span>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-4 w-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"
              />
            </svg>
          </span>
        </button>
        <button
          @click="openCreateModal"
          class="px-3 py-1.5 bg-blue-600 text-white rounded-md flex items-center text-sm"
        >
          <span class="mr-1">Add Work Type</span>
          <span>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-4 w-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 6v6m0 0v6m0-6h6m-6 0H6"
              />
            </svg>
          </span>
        </button>
      </div>
    </div>

    <!-- Filters -->
    <div v-if="showFilters" class="mb-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium mb-1">Parent Bucket</label>
          <select
            v-model="filters.parentBucket"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-md"
            @change="loadWorkTypes"
          >
            <option value="">All Buckets</option>
            <option
              v-for="bucket in parentBuckets"
              :key="bucket"
              :value="bucket"
            >
              {{ bucket }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium mb-1">Measurement Type</label>
          <select
            v-model="filters.measurementType"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-md"
            @change="loadWorkTypes"
          >
            <option value="">All Types</option>
            <option value="area">Area</option>
            <option value="linear">Linear</option>
            <option value="quantity">Quantity</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium mb-1">Search</label>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search work types..."
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-md"
            @input="debounceSearch"
          />
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center py-4">
      <div class="animate-spin h-8 w-8 border-4 border-blue-500 rounded-full border-t-transparent"></div>
    </div>

    <!-- Error State -->
    <div
      v-else-if="error"
      class="p-4 bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-300 rounded-md mb-4"
    >
      {{ error }}
    </div>

    <!-- Empty State -->
    <div
      v-else-if="!workTypes.length"
      class="p-6 text-center bg-gray