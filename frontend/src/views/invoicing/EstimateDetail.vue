<template>
  <div class="estimate-detail">
    <!-- Header with back button and title -->
    <div class="mb-6">
      <div class="flex items-center mb-2">
        <router-link to="/invoicing/estimates" class="text-blue-600 dark:text-blue-400 mr-2">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
        </router-link>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Estimate {{ estimate.estimateNumber }}</h1>

        <!-- Status Badge -->
        <span
          v-if="estimate.status"
          class="ml-3 px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full"
          :class="getStatusClass(estimate.status)"
        >
          {{ capitalize(estimate.status) }}
        </span>

        <!-- Delete Trash Can Icon -->
        <button
          @click="confirmDelete"
          class="ml-auto p-2 text-red-600 hover:text-red-800 dark:text-red-500 dark:hover:text-red-400 transition-colors"
          aria-label="Delete estimate"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
          </svg>
        </button>
      </div>
      <p class="text-sm text-gray-600 dark:text-gray-400">
        Created on {{ formatDate(estimate.dateCreated) }} • Valid until {{ formatDate(estimate.validUntil) }}
      </p>
    </div>

    <!-- Loading Indicator -->
    <div v-if="isLoading" class="flex justify-center py-12">
      <svg xmlns="http://www.w3.org/2000/svg" class="animate-spin h-10 w-10 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
      </svg>
    </div>

    <!-- Error Message -->
    <div v-else-if="error" class="bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-700 rounded-md p-4 mb-6">
      <div class="flex">
        <div class="flex-shrink-0">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-red-400 dark:text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800 dark:text-red-300">Error loading estimate</h3>
          <div class="mt-2 text-sm text-red-700 dark:text-red-400">{{ error }}</div>
        </div>
      </div>
    </div>

    <!-- Invoice Content -->
    <div v-else class="space-y-6">
      <!-- Actions Bar -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-4">
        <div class="flex flex-wrap gap-3 justify-end">
          <!-- Mark as Sent/Viewed (based on current status) -->
          <button
            v-if="estimate.status === 'draft'"
            @click="markAsSent"
            class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            <span class="flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
              Mark as Sent
            </span>
          </button>

          <!-- Download PDF -->
          <button
            @click="downloadPdf"
            class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            <span class="flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              Download PDF
            </span>
          </button>

          <!-- Convert to Invoice Button -->
          <button
            v-if="estimate.status !== 'paid' && estimate.status !== 'draft'"
            @click="showConvertModal = true"
            class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 dark:bg-green-500 dark:hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
          >
            <span class="flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              Convert to Invoice
            </span>
          </button>

          <!-- Edit Button -->
          <button
            @click="editEstimate"
            class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            <span class="flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
              </svg>
              Edit Estimate
            </span>
          </button>


        </div>
      </div>

      <!-- Client and Estimate Details -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Client Information -->
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Client Information</h2>

          <div v-if="estimate.client" class="border border-gray-200 dark:border-gray-700 rounded-md p-4 bg-gray-50 dark:bg-gray-700">
            <div class="flex justify-between">
              <div>
                <h3 class="text-base font-medium text-gray-900 dark:text-white">
                  {{ estimate.client.displayName }}
                </h3>
                <p v-if="estimate.client.company" class="mt-1 text-sm text-gray-600 dark:text-gray-400">
                  {{ estimate.client.company }}
                </p>
              </div>
            </div>

            <div class="mt-3 text-sm text-gray-600 dark:text-gray-400">
              <p v-if="estimate.client.email">
                <span class="font-medium">Email:</span> {{ estimate.client.email }}
              </p>
              <p v-if="estimate.client.phone">
                <span class="font-medium">Phone:</span> {{ estimate.client.phone }}
              </p>
              <p v-if="estimate.client.address">
                <span class="font-medium">Address:</span> {{ formatAddress(estimate.client.address) }}
              </p>
            </div>
          </div>
        </div>

        <!-- Estimate Details -->
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Estimate Details</h2>

          <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
              <p class="font-medium text-gray-700 dark:text-gray-300">Estimate Number</p>
              <p class="text-gray-900 dark:text-white">{{ estimate.estimateNumber }}</p>
            </div>

            <div>
              <p class="font-medium text-gray-700 dark:text-gray-300">Status</p>
              <p>
                <span
                  class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full"
                  :class="getStatusClass(estimate.status)"
                >
                  {{ capitalize(estimate.status) }}
                </span>
              </p>
            </div>

            <div>
              <p class="font-medium text-gray-700 dark:text-gray-300">Date Created</p>
              <p class="text-gray-900 dark:text-white">{{ formatDate(estimate.dateCreated) }}</p>
            </div>

            <div>
              <p class="font-medium text-gray-700 dark:text-gray-300">Valid Until</p>
              <p class="text-gray-900 dark:text-white">{{ formatDate(estimate.validUntil) }}</p>
            </div>

            <div v-if="estimate.dateSent">
              <p class="font-medium text-gray-700 dark:text-gray-300">Date Sent</p>
              <p class="text-gray-900 dark:text-white">{{ formatDate(estimate.dateSent) }}</p>
            </div>

            <div v-if="estimate.dateViewed">
              <p class="font-medium text-gray-700 dark:text-gray-300">Date Viewed</p>
              <p class="text-gray-900 dark:text-white">{{ formatDate(estimate.dateViewed) }}</p>
            </div>

            <div v-if="estimate.dateAccepted">
              <p class="font-medium text-gray-700 dark:text-gray-300">Date Paid</p>
              <p class="text-gray-900 dark:text-white">{{ formatDate(estimate.dateAccepted) }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Line Items -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Estimate Items</h2>

        <!-- Items Table -->
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-700">
              <tr>
                <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Description
                </th>
                <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider w-24">
                  Quantity
                </th>
                <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider w-32">
                  Price
                </th>
                <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider w-24">
                  Tax (%)
                </th>
                <th scope="col" class="px-3 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider w-32">
                  Total
                </th>
              </tr>
            </thead>
            <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              <tr v-for="(item, index) in estimate.items" :key="index">
                <td class="px-3 py-4 whitespace-pre-wrap text-sm text-gray-900 dark:text-white">
                  {{ item.description }}
                </td>
                <td class="px-3 py-4 text-sm text-gray-900 dark:text-white">
                  {{ item.quantity }}
                </td>
                <td class="px-3 py-4 text-sm text-gray-900 dark:text-white">
                  ${{ formatNumber(item.price) }}
                </td>
                <td class="px-3 py-4 text-sm text-gray-900 dark:text-white">
                  {{ item.taxRate }}%
                </td>
                <td class="px-3 py-4 text-sm text-gray-900 dark:text-white">
                  ${{ formatNumber(item.itemTotal) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Totals Section -->
        <div class="mt-6 flex justify-end">
          <div class="w-64 space-y-2">
            <div class="flex justify-between text-sm">
              <span class="text-gray-600 dark:text-gray-400">Subtotal:</span>
              <span class="font-medium text-gray-900 dark:text-white">${{ formatNumber(estimate.subtotal) }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="text-gray-600 dark:text-gray-400">Tax:</span>
              <span class="font-medium text-gray-900 dark:text-white">${{ formatNumber(estimate.taxTotal) }}</span>
            </div>
            <div v-if="estimate.discountAmount > 0" class="flex justify-between text-sm">
              <span class="text-gray-600 dark:text-gray-400">Discount:</span>
              <span class="font-medium text-gray-900 dark:text-white">-${{ formatNumber(estimate.discountAmount) }}</span>
            </div>
            <div class="flex justify-between border-t border-gray-200 dark:border-gray-700 pt-2 text-base">
              <span class="font-medium text-gray-700 dark:text-gray-300">Total:</span>
              <span class="font-bold text-gray-900 dark:text-white">${{ formatNumber(estimate.total) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Notes and Terms -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Notes -->
          <div>
            <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-2">Notes</h2>
            <div class="border border-gray-200 dark:border-gray-700 rounded-md p-4 bg-gray-50 dark:bg-gray-700 text-sm text-gray-700 dark:text-gray-300 whitespace-pre-wrap">
              {{ estimate.notes || 'No notes provided.' }}
            </div>
          </div>

          <!-- Terms -->
          <div>
            <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-2">Terms & Conditions</h2>
            <div class="border border-gray-200 dark:border-gray-700 rounded-md p-4 bg-gray-50 dark:bg-gray-700 text-sm text-gray-700 dark:text-gray-300 whitespace-pre-wrap">
              {{ estimate.terms || 'No terms provided.' }}
            </div>
          </div>
        </div>
      </div>

      <!-- Payment History -->
      <div v-if="estimate.revisions && estimate.revisions.length > 0" class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Payment History</h2>

        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-700">
              <tr>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Date
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Amount
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Method
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Notes
                </th>
              </tr>
            </thead>
            <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              <tr v-for="payment in estimate.revisions" :key="payment.id">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                  {{ formatDate(payment.date) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                  ${{ formatNumber(payment.amount) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                  {{ payment.method }}
                </td>
                <td class="px-6 py-4 text-sm text-gray-900 dark:text-white">
                  {{ payment.notes || '-' }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>

  <!-- Convert to Invoice Modal -->
  <teleport to="body">
    <div v-if="showConvertModal" class="fixed inset-0 z-50 overflow-y-auto">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 dark:bg-gray-900 dark:bg-opacity-75 transition-opacity"></div>
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen">&#8203;</span>
        <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6">
          <div>
            <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white mb-4">Convert to Invoice</h3>

            <!-- Simplified Modal Content -->
            <div class="mt-3 text-center sm:mt-5">
              <p class="text-sm text-gray-500 dark:text-gray-400">
                Are you sure you want to convert this estimate to an invoice? This will create a new invoice based on the estimate details.
              </p>
            </div>

            <!-- Error Message -->
            <div v-if="convertError" class="mt-4 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-700 rounded-md p-3">
              <p class="text-sm text-red-700 dark:text-red-400">{{ convertError }}</p>
            </div>

              <!-- Error Message -->
              <div v-if="convertError" class="bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-700 rounded-md p-3">
                <p class="text-sm text-red-700 dark:text-red-400">{{ convertError }}</p>
              </div>

              <!-- Buttons -->
              <div class="mt-5 sm:mt-6 sm:grid sm:grid-cols-2 sm:gap-3 sm:grid-flow-row-dense">
                <button
                  type="button"
                  @click="convertToInvoice"
                  :disabled="isConverting"
                  class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-green-600 text-base font-medium text-white hover:bg-green-700 dark:bg-green-500 dark:hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 sm:col-start-2 sm:text-sm"
                >
                  <span v-if="isConverting" class="flex items-center">
                    <svg xmlns="http://www.w3.org/2000/svg" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                    </svg>
                    Processing...
                  </span>
                  <span v-else>Convert to Invoice</span>
                </button>
                <button
                  type="button"
                  @click="showConvertModal = false"
                  class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:col-start-1 sm:text-sm"
                >
                  Cancel
                </button>
              </div>
          </div>
        </div>
      </div>
    </div>
  </teleport>

  <!-- Delete Confirmation Modal -->
  <teleport to="body">
    <div v-if="showDeleteModal" class="fixed inset-0 z-50 overflow-y-auto">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 dark:bg-gray-900 dark:bg-opacity-75 transition-opacity"></div>
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen">&#8203;</span>
        <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6">
          <div>
            <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100 dark:bg-red-900">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-red-600 dark:text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
            </div>
            <div class="mt-3 text-center sm:mt-5">
              <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white">
                Delete Estimate
              </h3>
              <div class="mt-2">
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Are you sure you want to delete estimate {{ estimate.estimateNumber }}? This action cannot be undone.
                </p>
                <p v-if="estimate.status !== 'draft'" class="mt-2 text-sm text-red-500 dark:text-red-400 font-medium">
                  Warning: This estimate is not in draft status. Deleting it may affect client history and business records.
                </p>
              </div>
            </div>
          </div>
          <div class="mt-5 sm:mt-6 sm:grid sm:grid-cols-2 sm:gap-3 sm:grid-flow-row-dense">
            <button
              type="button"
              @click="deleteEstimate"
              :disabled="isDeleting"
              class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-white hover:bg-red-700 dark:bg-red-500 dark:hover:bg-red-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:col-start-2 sm:text-sm"
            >
              <span v-if="isDeleting" class="flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
                Deleting...
              </span>
              <span v-else>Delete</span>
            </button>
            <button
              type="button"
              @click="showDeleteModal = false"
              class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:col-start-1 sm:text-sm"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </div>
  </teleport>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import estimatesService from '@/services/estimates.service';

const route = useRoute();
const router = useRouter();

// State
const estimate = ref({
  id: '',
  estimateNumber: '',
  client: null,
  clientId: '',
  dateCreated: '',
  dateDue: '',
  dateSent: null,
  dateViewed: null,
  datePaid: null,
  items: [],
  subtotal: 0,
  taxTotal: 0,
  discountAmount: 0,
  total: 0,
  notes: '',
  terms: '',
  status: 'draft',
  payments: []
});

const isLoading = ref(true);
const error = ref('');

// Payment modal state
const showConvertModal = ref(false); // Keep modal trigger state
const isConverting = ref(false);
const convertError = ref('');

// Delete modal state
const showDeleteModal = ref(false);
const isDeleting = ref(false);

// Load estimate data
const loadEstimate = async () => {
  try {
    isLoading.value = true;
    error.value = '';

    const estimateId = route.params.id;

    // Check if estimateId is defined before making the API call
    if (!estimateId) {
      console.error('Estimate ID is undefined. Route params:', route.params);
      error.value = 'Invalid estimate ID. Please try again or go back to the estimates list.';
      isLoading.value = false;
      return;
    }

    console.log('Loading estimate with ID:', estimateId);
    const response = await estimatesService.getEstimate(estimateId);

    if (response && response.success && response.data) {
      estimate.value = response.data;
    } else {
      error.value = response?.message || 'Failed to load estimate. Please try again.';
    }
  } catch (err) {
    console.error('Error loading estimate:', err);
    error.value = err.message || 'An unexpected error occurred. Please try again.';
  } finally {
    isLoading.value = false;
  }
};

// Actions
const markAsSent = async () => {
  try {
    const response = await estimatesService.markEstimateAsSent(estimate.value.id);

    if (response && response.success && response.data) {
      // Update local estimate data
      estimate.value.status = 'sent';
      estimate.value.dateSent = new Date().toISOString();
    } else {
      alert(response?.message || 'Failed to mark estimate as sent. Please try again.');
    }
  } catch (err) {
    console.error('Error marking estimate as sent:', err);
    alert(err.message || 'An unexpected error occurred. Please try again.');
  }
};

const downloadPdf = async () => {
  try {
    // Generate and download PDF
    const blob = await estimatesService.generatePdf(estimate.value.id);

    // Create download link
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.style.display = 'none';
    a.href = url;
    a.download = `estimate_${estimate.value.estimateNumber}.pdf`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
  } catch (err) {
    console.error('Error downloading PDF:', err);
    alert('Error downloading PDF. Please try again.');
  }
};

const editEstimate = () => {
  // Navigate to edit page with estimate ID
  router.push(`/invoicing/edit-estimate/${estimate.value.id}`);
};

const confirmDelete = () => {
  showDeleteModal.value = true;
};

const deleteEstimate = async () => {
  try {
    isDeleting.value = true;

    const response = await estimatesService.deleteEstimate(estimate.value.id);

    if (response && response.success) {
      // Redirect to estimates list
      router.push('/invoicing/estimates');
    } else {
      alert(response?.message || 'Failed to delete estimate. Please try again.');
      showDeleteModal.value = false;
    }
  } catch (err) {
    console.error('Error deleting estimate:', err);
    alert(err.message || 'An unexpected error occurred. Please try again.');
    showDeleteModal.value = false;
  } finally {
    isDeleting.value = false;
  }
};

const convertToInvoice = async () => {
  try {
    isConverting.value = true;
    convertError.value = '';

    // Call the correct service function to convert the estimate
    const response = await estimatesService.convertToInvoice(estimate.value.id);

    if (response && response.success && response.data) {
      const newInvoice = response.data;
      // Close modal
      showConvertModal.value = false;
      // Redirect to the newly created invoice detail page
      router.push(`/invoicing/invoice/${newInvoice.id}`);
    } else {
      convertError.value = response?.message || 'Failed to convert estimate to invoice. Please try again.';
    }
  } catch (err) {
    console.error('Error converting estimate to invoice:', err);
    convertError.value = err.message || 'An unexpected error occurred. Please try again.';
  } finally {
    isConverting.value = false;
  }
};

// Helper methods
const formatDate = (dateString) => {
  if (!dateString) return '-';
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

const formatNumber = (value) => {
  if (value === null || value === undefined) return '0.00';
  return parseFloat(value).toFixed(2);
};

const formatAddress = (address) => {
  if (!address) return '';
  // Replace semicolons with commas and spaces
  return address.replace(/;/g, ', ');
};

const capitalize = (str) => {
  if (!str) return '';
  return str.charAt(0).toUpperCase() + str.slice(1);
};

const getStatusClass = (status) => {
  switch (status) {
    case 'draft':
      return 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300';
    case 'sent':
      return 'bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-300';
    case 'accepted':
      return 'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-300';
    case 'rejected':
      return 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-300';
    default:
      return 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300';
  }
};
// Initialize
onMounted(() => {
  console.log('EstimateDetail mounted, route:', route);
  console.log('Route params:', route.params);
  console.log('Route query:', route.query);
  console.log('Route path:', route.path);
  console.log('Route name:', route.name);

  // Ensure the route params are available before loading the estimate
  if (route.params.id) {
    console.log('Route param id is available:', route.params.id);
    loadEstimate();
  } else {
    console.error('Route params not available on mount. Current route:', route);
    // Try again after a short delay to allow for route params to be populated
    setTimeout(() => {
      console.log('After delay - route params:', route.params);
      if (route.params.id) {
        console.log('Route params available after delay, loading estimate with ID:', route.params.id);
        loadEstimate();
      } else {
        console.error('Route params still not available after delay');
        error.value = 'Unable to determine which estimate to load. Please try again.';
      }
    }, 100);
  }
});
</script>
