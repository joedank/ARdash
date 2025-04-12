<template>
  <div class="max-w-3xl mx-auto px-6 py-8">
    <h1 class="text-3xl font-bold text-blue-400 mb-6">About This Project</h1>
    <p class="text-lg text-gray-300 mb-4">This is a core setup for a Vue.js and Node.js application with PostgreSQL database.</p>
    <p class="text-lg font-medium text-gray-200 mb-2">Features included in this setup:</p>
    <ul class="bg-dark-800 rounded-lg p-5 shadow-sm border border-dark-700 mb-8">
      <li class="flex items-center py-2">
        <span class="text-green-400 mr-2">✓</span>
        <span class="text-gray-300">Vue 3 with Composition API</span>
      </li>
      <li class="flex items-center py-2">
        <span class="text-green-400 mr-2">✓</span>
        <span class="text-gray-300">Vue Router for navigation</span>
      </li>
      <li class="flex items-center py-2">
        <span class="text-green-400 mr-2">✓</span>
        <span class="text-gray-300">Pinia for state management</span>
      </li>
      <li class="flex items-center py-2">
        <span class="text-green-400 mr-2">✓</span>
        <span class="text-gray-300">Axios for API communication</span>
      </li>
      <li class="flex items-center py-2">
        <span class="text-green-400 mr-2">✓</span>
        <span class="text-gray-300">Tailwind CSS for styling</span>
      </li>
      <li class="flex items-center py-2">
        <span class="text-green-400 mr-2">✓</span>
        <span class="text-gray-300">PostgreSQL database with Sequelize ORM</span>
      </li>
      <li class="flex items-center py-2">
        <span class="text-green-400 mr-2">✓</span>
        <span class="text-gray-300">Vite as build tool</span>
      </li>
    </ul>
    <router-link to="/" class="inline-block bg-blue-500 dark:bg-blue-600 hover:bg-blue-600 dark:hover:bg-blue-700 text-white font-bold py-2 px-4 rounded transition-colors">
      Back to Home
    </router-link>
  </div>
</template>
