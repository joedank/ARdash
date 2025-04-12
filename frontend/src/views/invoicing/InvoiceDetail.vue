<template>
  <div class="invoice-detail">
    <!-- Header with back button and title -->
    <div class="mb-6">
      <div class="flex items-center mb-2">
        <router-link to="/invoicing/invoices" class="text-blue-600 dark:text-blue-400 mr-2">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
        </router-link>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Invoice {{ invoice.invoiceNumber }}</h1>
        
        <!-- Status Badge -->
        <span 
          v-if="invoice.status" 
          class="ml-3 px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full" 
          :class="getStatusClass(invoice.status)"
        >
          {{ capitalize(invoice.status) }}
        </span>

        <!-- Delete Trash Can Icon -->
        <button
          @click="confirmDelete"
          class="ml-auto p-2 text-red-600 hover:text-red-800 dark:text-red-500 dark:hover:text-red-400 transition-colors"
          aria-label="Delete invoice"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
          </svg>
        </button>
      </div>
      <p class="text-sm text-gray-600 dark:text-gray-400">
        Created on {{ formatDate(invoice.dateCreated) }} • Due on {{ formatDate(invoice.dateDue) }}
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
          <h3 class="text-sm font-medium text-red-800 dark:text-red-300">Error loading invoice</h3>
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
            v-if="invoice.status === 'draft'"
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
          
          <!-- Record Payment Button -->
          <button
            v-if="invoice.status !== 'paid' && invoice.status !== 'draft'"
            @click="showPaymentModal = true"
            class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 dark:bg-green-500 dark:hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
          >
            <span class="flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              Record Payment
            </span>
          </button>
          <!-- Edit Button -->
          <button
            @click="editInvoice"
            class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            <span class="flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
              </svg>
              Edit Invoice
            </span>
          </button>
          

        </div>
      </div>
      
      <!-- Client and Invoice Details -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Client Information -->
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Client Information</h2>
          
          <div v-if="invoice.client" class="border border-gray-200 dark:border-gray-700 rounded-md p-4 bg-gray-50 dark:bg-gray-700">
            <div class="flex justify-between">
              <div>
                <h3 class="text-base font-medium text-gray-900 dark:text-white">
                  {{ getClientName(invoice.client) }}
                </h3>
                <p v-if="invoice.client.company" class="mt-1 text-sm text-gray-600 dark:text-gray-400">
                  {{ invoice.client.company }}
                </p>
              </div>
            </div>
            
            <div class="mt-3 text-sm text-gray-600 dark:text-gray-400">
              <p v-if="invoice.client.email">
                <span class="font-medium">Email:</span> {{ invoice.client.email }}
              </p>
              <p v-if="invoice.client.phone">
                <span class="font-medium">Phone:</span> {{ invoice.client.phone }}
              </p>
              
              <!-- Display the invoice address -->
              <div v-if="invoice.address" class="mt-2">
                <p class="font-medium">Invoice Address:</p>
                <p class="whitespace-pre-wrap">{{ formatInvoiceAddress(invoice.address) }}</p>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Invoice Details -->
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Invoice Details</h2>
          
          <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
              <p class="font-medium text-gray-700 dark:text-gray-300">Invoice Number</p>
              <p class="text-gray-900 dark:text-white">{{ invoice.invoiceNumber }}</p>
            </div>
            
            <div>
              <p class="font-medium text-gray-700 dark:text-gray-300">Status</p>
              <p>
                <span 
                  class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full" 
                  :class="getStatusClass(invoice.status)"
                >
                  {{ capitalize(invoice.status) }}
                </span>
              </p>
            </div>
            
            <div>
              <p class="font-medium text-gray-700 dark:text-gray-300">Date Created</p>
              <p class="text-gray-900 dark:text-white">{{ formatDate(invoice.dateCreated) }}</p>
            </div>
            
            <div>
              <p class="font-medium text-gray-700 dark:text-gray-300">Due Date</p>
              <p class="text-gray-900 dark:text-white">{{ formatDate(invoice.dateDue) }}</p>
            </div>
            
            <div v-if="invoice.dateSent">
              <p class="font-medium text-gray-700 dark:text-gray-300">Date Sent</p>
              <p class="text-gray-900 dark:text-white">{{ formatDate(invoice.dateSent) }}</p>
            </div>
            
            <div v-if="invoice.dateViewed">
              <p class="font-medium text-gray-700 dark:text-gray-300">Date Viewed</p>
              <p class="text-gray-900 dark:text-white">{{ formatDate(invoice.dateViewed) }}</p>
            </div>
            
            <div v-if="invoice.datePaid">
              <p class="font-medium text-gray-700 dark:text-gray-300">Date Paid</p>
              <p class="text-gray-900 dark:text-white">{{ formatDate(invoice.datePaid) }}</p>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Line Items -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Invoice Items</h2>
        
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
              <tr v-for="(item, index) in invoice.items" :key="index">
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
              <span class="font-medium text-gray-900 dark:text-white">${{ formatNumber(invoice.subtotal) }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="text-gray-600 dark:text-gray-400">Tax:</span>
              <span class="font-medium text-gray-900 dark:text-white">${{ formatNumber(invoice.taxTotal) }}</span>
            </div>
            <div v-if="invoice.discountAmount > 0" class="flex justify-between text-sm">
              <span class="text-gray-600 dark:text-gray-400">Discount:</span>
              <span class="font-medium text-gray-900 dark:text-white">-${{ formatNumber(invoice.discountAmount) }}</span>
            </div>
            <div class="flex justify-between border-t border-gray-200 dark:border-gray-700 pt-2 text-base">
              <span class="font-medium text-gray-700 dark:text-gray-300">Total:</span>
              <span class="font-bold text-gray-900 dark:text-white">${{ formatNumber(invoice.total) }}</span>
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
              {{ invoice.notes || 'No notes provided.' }}
            </div>
          </div>
          
          <!-- Terms -->
          <div>
            <h2 class="text-lg font-medium text-gray-900 dark:text-white mb-2">Terms & Conditions</h2>
            <div class="border border-gray-200 dark:border-gray-700 rounded-md p-4 bg-gray-50 dark:bg-gray-700 text-sm text-gray-700 dark:text-gray-300 whitespace-pre-wrap">
              {{ invoice.terms || 'No terms provided.' }}
            </div>
          </div>
        </div>
      </div>
      
      <!-- Payment History -->
      <div v-if="invoice.payments && invoice.payments.length > 0" class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
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
              <tr v-for="payment in invoice.payments" :key="payment.id">
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
  
  <!-- Payment Modal -->
  <teleport to="body">
    <div v-if="showPaymentModal" class="fixed inset-0 z-50 overflow-y-auto">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 dark:bg-gray-900 dark:bg-opacity-75 transition-opacity"></div>
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen">&#8203;</span>
        <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6">
          <div>
            <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white mb-4">Record Payment</h3>
            
            <form @submit.prevent="submitPayment" class="space-y-4">
              <!-- Payment Amount -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Payment Amount</label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <span class="text-gray-500 dark:text-gray-400">$</span>
                  </div>
                  <input
                    type="number"
                    v-model="paymentData.amount"
                    min="0.01"
                    step="0.01"
                    class="pl-7 block w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                    :placeholder="`Due: $${formatNumber(invoice.total)}`"
                    required
                  />
                </div>
                <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">
                  Total due: ${{ formatNumber(invoice.total) }}
                </p>
              </div>
              
              <!-- Payment Date -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Payment Date</label>
                <input
                  type="date"
                  v-model="paymentData.date"
                  class="block w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                  required
                />
              </div>
              
              <!-- Payment Method -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Payment Method</label>
                <select
                  v-model="paymentData.method"
                  class="block w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                  required
                >
                  <option value="">Select payment method</option>
                  <option value="Credit Card">Credit Card</option>
                  <option value="Bank Transfer">Bank Transfer</option>
                  <option value="Cash">Cash</option>
                  <option value="Check">Check</option>
                  <option value="PayPal">PayPal</option>
                  <option value="Other">Other</option>
                </select>
              </div>
              
              <!-- Notes -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Notes (Optional)</label>
                <textarea
                  v-model="paymentData.notes"
                  rows="3"
                  class="block w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-700 dark:text-white"
                  placeholder="Add any notes about this payment..."
                ></textarea>
              </div>
              
              <!-- Error Message -->
              <div v-if="paymentError" class="bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-700 rounded-md p-3">
                <p class="text-sm text-red-700 dark:text-red-400">{{ paymentError }}</p>
              </div>
              
              <!-- Buttons -->
              <div class="mt-5 sm:mt-6 sm:grid sm:grid-cols-2 sm:gap-3 sm:grid-flow-row-dense">
                <button
                  type="submit"
                  :disabled="isSubmittingPayment"
                  class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-green-600 text-base font-medium text-white hover:bg-green-700 dark:bg-green-500 dark:hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 sm:col-start-2 sm:text-sm"
                >
                  <span v-if="isSubmittingPayment" class="flex items-center">
                    <svg xmlns="http://www.w3.org/2000/svg" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                    </svg>
                    Processing...
                  </span>
                  <span v-else>Record Payment</span>
                </button>
                <button
                  type="button"
                  @click="showPaymentModal = false"
                  class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:col-start-1 sm:text-sm"
                >
                  Cancel
                </button>
              </div>
            </form>
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
                Delete Invoice
              </h3>
              <div class="mt-2">
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Are you sure you want to delete invoice {{ invoice.invoiceNumber }}? This action cannot be undone.
                </p>
                <p v-if="invoice.status !== 'draft'" class="mt-2 text-sm text-red-500 dark:text-red-400 font-medium">
                  Warning: This invoice is not in draft status. Deleting it may have business and accounting implications.
                </p>
              </div>
            </div>
          </div>
          <div class="mt-5 sm:mt-6 sm:grid sm:grid-cols-2 sm:gap-3 sm:grid-flow-row-dense">
            <button
              type="button"
              @click="deleteInvoice"
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
import invoicesService from '@/services/invoices.service';
import clientsService from '@/services/clients.service';

const route = useRoute();
const router = useRouter();

// State
const invoice = ref({
  id: '',
  invoiceNumber: '',
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
const showPaymentModal = ref(false);
const paymentData = ref({
  amount: '',
  date: new Date().toISOString().split('T')[0], // Today's date
  method: '',
  notes: ''
});
const isSubmittingPayment = ref(false);
const paymentError = ref('');

// Delete modal state
const showDeleteModal = ref(false);
const isDeleting = ref(false);

// Helper function to get client name regardless of property naming convention
const getClientName = (client) => {
  if (!client) return 'Unknown Client';
  
  // Try different client name properties
  if (client.displayName) return client.displayName;
  if (client.display_name) return client.display_name;
  if (client.name) return client.name;
  
  // If no name property is found, check any potential ID properties
  if (client.id) return `Client #${client.id}`;
  if (client.client_id) return `Client #${client.client_id}`;
  
  return 'Unknown Client';
};

// Load invoice data
const loadInvoice = async () => {
  try {
    isLoading.value = true;
    error.value = '';
    
    const invoiceId = route.params.id;
    const response = await invoicesService.getInvoice(invoiceId);
    
    if (response && response.success && response.data) {
      invoice.value = response.data;
      
      // Log client information for debugging
      console.log('Client data received:', invoice.value.client);
      
      // If the client reference exists but has no name properties, try to fetch directly
      if (invoice.value.client && !getClientName(invoice.value.client) && invoice.value.client_fk_id) {
        try {
          const clientResponse = await clientsService.getClient(invoice.value.client_fk_id);
          if (clientResponse && clientResponse.success && clientResponse.data) {
            invoice.value.client = clientResponse.data;
            console.log('Client data fetched directly:', invoice.value.client);
          }
        } catch (clientErr) {
          console.error('Error fetching client data directly:', clientErr);
        }
      }
      
      // If the address isn't included in the response but we have an addressId,
      // we may need to fetch it separately
      if (!invoice.value.address && invoice.value.address_id) {
        try {
          // Fetch address directly if needed
          const clientId = invoice.value.client_fk_id || invoice.value.client_id;
          if (clientId) {
            console.log('Attempting to fetch address with clientId:', clientId, 'and addressId:', invoice.value.address_id);
            const addressResponse = await clientsService.getClientAddress(clientId, invoice.value.address_id);
            if (addressResponse && addressResponse.success && addressResponse.data) {
              invoice.value.address = addressResponse.data;
              console.log('Address data fetched directly:', invoice.value.address);
            }
          } else {
            console.warn('No client ID found for invoice:', invoice.value.id);
          }
        } catch (addressErr) {
          console.error('Error loading invoice address:', addressErr);
          // Continue showing the invoice even if address loading fails
        }
      }
    } else {
      error.value = response?.message || 'Failed to load invoice. Please try again.';
    }
  } catch (err) {
    console.error('Error loading invoice:', err);
    error.value = err.message || 'An unexpected error occurred. Please try again.';
  } finally {
    isLoading.value = false;
  }
};

// Actions
const markAsSent = async () => {
  try {
    const response = await invoicesService.markInvoiceAsSent(invoice.value.id);
    
    if (response && response.success && response.data) {
      // Update local invoice data
      invoice.value.status = 'sent';
      invoice.value.dateSent = new Date().toISOString();
    } else {
      alert(response?.message || 'Failed to mark invoice as sent. Please try again.');
    }
  } catch (err) {
    console.error('Error marking invoice as sent:', err);
    alert(err.message || 'An unexpected error occurred. Please try again.');
  }
};

const downloadPdf = async () => {
  try {
    // Get and download PDF
    const blob = await invoicesService.getInvoicePdf(invoice.value.id);
    
    // Create download link
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.style.display = 'none';
    a.href = url;
    a.download = `invoice_${invoice.value.invoiceNumber}.pdf`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
  } catch (err) {
    console.error('Error downloading PDF:', err);
    alert('Error downloading PDF. Please try again.');
  }
};

const editInvoice = () => {
  // Navigate to edit page with invoice ID
  router.push(`/invoicing/edit-invoice/${invoice.value.id}`);
};

const confirmDelete = () => {
  showDeleteModal.value = true;
};

const deleteInvoice = async () => {
  try {
    isDeleting.value = true;
    
    const response = await invoicesService.deleteInvoice(invoice.value.id);
    
    if (response && response.success) {
      // Redirect to invoices list
      router.push('/invoicing/invoices');
    } else {
      if (response?.message === 'Only draft invoices can be deleted') {
        alert('This invoice cannot be deleted because it is not a draft. Only draft invoices can be deleted.');
      } else {
        alert(response?.message || 'Failed to delete invoice. Please try again.');
      }
      showDeleteModal.value = false;
    }
  } catch (err) {
    console.error('Error deleting invoice:', err);
    if (err.message && err.message.includes('address')) {
      // If the error is related to address loading, continue with deletion attempt
      try {
        const response = await invoicesService.deleteInvoice(invoice.value.id);
        if (response && response.success) {
          router.push('/invoicing/invoices');
          return;
        }
      } catch (retryErr) {
        console.error('Error on retry deleting invoice:', retryErr);
      }
    }
    alert(err.message || 'An unexpected error occurred. Please try again.');
    showDeleteModal.value = false;
  } finally {
    isDeleting.value = false;
  }
};

const submitPayment = async () => {
  try {
    isSubmittingPayment.value = true;
    paymentError.value = '';
    
    // Validate payment amount
    const amount = parseFloat(paymentData.value.amount);
    if (isNaN(amount) || amount <= 0) {
      paymentError.value = 'Please enter a valid payment amount.';
      return;
    }
    
    // Submit payment
    const response = await invoicesService.addPayment(invoice.value.id, paymentData.value);
    
    if (response && response.success && response.data) {
      // Update local invoice data
      invoice.value = response.data;
      
      // Reset payment form
      paymentData.value = {
        amount: '',
        date: new Date().toISOString().split('T')[0],
        method: '',
        notes: ''
      };
      
      // Close modal
      showPaymentModal.value = false;
    } else {
      paymentError.value = response?.message || 'Failed to record payment. Please try again.';
    }
  } catch (err) {
    console.error('Error recording payment:', err);
    paymentError.value = err.message || 'An unexpected error occurred. Please try again.';
  } finally {
    isSubmittingPayment.value = false;
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

// Format address for display
const formatInvoiceAddress = (address) => {
  if (!address) return 'No address available';
  
  // Handle different address data structures
  if (typeof address === 'string') {
    // If address is already a formatted string, just replace semicolons with line breaks
    return address.replace(/;/g, '\n');
  }
  
  // If address is an object with address fields
  const parts = [];
  
  if (address.street_address) parts.push(address.street_address);
  if (address.street2) parts.push(address.street2);
  
  const cityLine = [
    address.city,
    address.state,
    address.postal_code || address.zipCode || address.zip
  ].filter(Boolean).join(', ');
  
  if (cityLine) parts.push(cityLine);
  if (address.country) parts.push(address.country);
  
  return parts.join('\n');
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
    case 'viewed':
      return 'bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-300';
    case 'paid':
      return 'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-300';
    case 'overdue':
      return 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-300';
    default:
      return 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300';
  }
};

// Initialize
onMounted(() => {
  loadInvoice();
});
</script>
