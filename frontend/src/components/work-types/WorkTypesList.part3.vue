
                  <!-- Parent Bucket -->
                  <div>
                    <label
                      for="parentBucket"
                      class="block text-sm font-medium text-gray-700 dark:text-gray-300"
                    >
                      Parent Bucket
                    </label>
                    <select
                      id="parentBucket"
                      v-model="formData.parentBucket"
                      class="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-800 dark:text-gray-100"
                      required
                    >
                      <option disabled value="">Select a bucket</option>
                      <option
                        v-for="bucket in parentBuckets"
                        :key="bucket"
                        :value="bucket"
                      >
                        {{ bucket }}
                      </option>
                    </select>
                    <div
                      v-if="validationErrors.parentBucket"
                      class="text-red-600 dark:text-red-400 text-sm mt-1"
                    >
                      {{ validationErrors.parentBucket }}
                    </div>
                  </div>

                  <!-- Measurement Type -->
                  <div>
                    <label
                      for="measurementType"
                      class="block text-sm font-medium text-gray-700 dark:text-gray-300"
                    >
                      Measurement Type
                    </label>
                    <select
                      id="measurementType"
                      v-model="formData.measurementType"
                      class="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-800 dark:text-gray-100"
                      required
                    >
                      <option disabled value="">Select a measurement type</option>
                      <option value="area">Area</option>
                      <option value="linear">Linear</option>
                      <option value="quantity">Quantity</option>
                    </select>
                    <div
                      v-if="validationErrors.measurementType"
                      class="text-red-600 dark:text-red-400 text-sm mt-1"
                    >
                      {{ validationErrors.measurementType }}
                    </div>
                  </div>

                  <!-- Suggested Units -->
                  <div>
                    <label
                      for="suggestedUnits"
                      class="block text-sm font-medium text-gray-700 dark:text-gray-300"
                    >
                      Suggested Units
                    </label>
                    <input
                      type="text"
                      id="suggestedUnits"
                      v-model="formData.suggestedUnits"
                      class="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-800 dark:text-gray-100"
                      required
                    />
                    <div
                      v-if="validationErrors.suggestedUnits"
                      class="text-red-600 dark:text-red-400 text-sm mt-1"
                    >
                      {{ validationErrors.suggestedUnits }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 dark:bg-gray-800 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button
              @click="saveWorkType"
              class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm"
              :disabled="loading"
            >
              {{ isEditing ? 'Update' : 'Create' }}
            </button>
            <button
              @click="showModal = false"
              type="button"
              class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-700 shadow-sm px-4 py-2 bg-white dark:bg-gray-900 text-base font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div
      v-if="showDeleteModal"
      class="fixed inset-0 z-40 overflow-y-auto"
      aria-labelledby="modal-title"
      role="dialog"
      aria-modal="true"
    >
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <!-- Background overlay -->
        <div
          class="fixed inset-0 bg-gray-500 dark:bg-gray-900 bg-opacity-75 dark:bg-opacity-75 transition-opacity"
          aria-hidden="true"
          @click="showDeleteModal = false"
        ></div>

        <!-- Modal panel -->
        <div
          class="inline-block align-bottom bg-white dark:bg-gray-900 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full"
        >
          <div class="bg-white dark:bg-gray-900 px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div class="sm:flex sm:items-start">
              <div
                class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 dark:bg-red-900 sm:mx-0 sm:h-10 sm:w-10"
              >
                <svg
                  class="h-6 w-6 text-red-600 dark:text-red-400"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  aria-hidden="true"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                  />
                </svg>
              </div>
              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                <h3
                  class="text-lg leading-6 font-medium text-gray-900 dark:text-gray-100"
                  id="modal-title"
                >
                  Delete Work Type
                </h3>
                <div class="mt-2">
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    Are you sure you want to delete the work type
                    <span class="font-medium text-gray-700 dark:text-gray-300">
                      "{{ workTypeToDelete?.name }}"
                    </span>? This action cannot be undone.
                  </p>
                </div>
              </div>
            </div>
          </div>
