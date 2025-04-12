<template>
  <div class="client-settings">
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-lg font-medium text-gray-900 dark:text-white">Client Management</h2>
      <BaseButton
        variant="primary"
        @click="openCreateClientModal"
        class="flex items-center space-x-2"
      >
        <span>Add Client</span>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 01-2 0v-3H6a1 1 0 010-2h3V6a1 1 0 011-1z" clip-rule="evenodd" />
        </svg>
      </BaseButton>
    </div>

    <!-- Search and Filters -->
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-4 mb-6">
      <div class="flex flex-col md:flex-row md:items-center space-y-4 md:space-y-0 md:space-x-4">
        <div class="flex-1">
          <BaseFormGroup label="Search Clients" input-id="search-clients" class="mb-0">
            <BaseInput
              id="search-clients"
              v-model="searchQuery"
              placeholder="Search by name, company, or email"
              @input="handleSearch"
            >
              <template #suffix>
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
              </template>
            </BaseInput>
          </BaseFormGroup>
        </div>
        <div class="w-full md:w-48">
          <BaseFormGroup label="Client Type" input-id="client-type-filter" class="mb-0">
            <BaseSelect
              id="client-type-filter"
              v-model="typeFilter"
              :options="clientTypeOptions"
              @update:modelValue="handleFilter"
            />
          </BaseFormGroup>
        </div>
        <div class="w-full md:w-48">
          <BaseFormGroup label="Status" input-id="status-filter" class="mb-0">
            <BaseSelect
              id="status-filter"
              v-model="statusFilter"
              :options="statusOptions"
              @update:modelValue="handleFilter"
            />
          </BaseFormGroup>
        </div>
      </div>
    </div>

    <!-- Clients Table / Grid View -->
    <BaseCard variant="default" class="mb-6">
      <!-- Table View -->
      <ClientTableResponsive
        v-if="viewMode === 'table'"
        :filtered-clients="paginatedClients"
        :loading="loading"
        :sort-key="sortConfig.key"
        :sort-order="sortConfig.order"
        :current-page="currentPage"
        :total-pages="totalPages"
        :total-items="totalItems"
        :items-per-page="itemsPerPage"
        :format-client-type="formatClientType"
        :get-client-type-badge-variant="getClientTypeBadgeVariant"
        v-model:columns-display="columnsDisplay"
        @view-change="handleViewChange"
        @sort-change="handleSort"
        @page-change="handlePageChange"
        @row-click="handleRowClick"
        @edit="openEditClientModal"
        @delete="openDeleteClientModal"
        @toggle-status="toggleClientStatus"
        @reset-filters="resetFilters"
      />

      <!-- Grid View -->
      <ClientTableCompact
        v-else
        :filtered-clients="paginatedClients"
        :current-page="currentPage"
        :total-pages="totalPages"
        :total-items="totalItems"
        :items-per-page="itemsPerPage"
        :format-client-type="formatClientType"
        :get-client-type-badge-variant="getClientTypeBadgeVariant"
        @view-change="handleViewChange"
        @page-change="handlePageChange"
        @row-click="handleRowClick"
        @edit="openEditClientModal"
        @delete="openDeleteClientModal"
        @reset-filters="resetFilters"
      />
    </BaseCard>

    <!-- Client Details Drawer -->
    <BaseDrawer
      v-model="showDetailsDrawer"
      position="right"
      widthClass="w-96"
      showBackdrop
      closeOnBackdropClick
      closeOnEsc
    >
      <template #header>
        <div class="flex justify-between items-center">
          <h3 class="text-lg font-medium text-gray-900 dark:text-white">Client Details</h3>
          <button
            @click="showDetailsDrawer = false"
            class="text-gray-400 hover:text-gray-500 dark:text-gray-500 dark:hover:text-gray-400"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </template>

      <!-- Client Details Content -->
      <div v-if="selectedClient" class="space-y-6">
        <!-- Basic Info -->
        <div>
          <div class="flex items-center mb-2">
            <h4 class="text-base font-medium text-gray-900 dark:text-white">
              {{ selectedClient.display_name }}
            </h4>
            <BaseBadge :variant="getClientTypeBadgeVariant(selectedClient.client_type)" size="sm" class="ml-2">
              {{ formatClientType(selectedClient.client_type) }}
            </BaseBadge>
            <BaseBadge :variant="selectedClient.is_active ? 'success' : 'danger'" size="sm" class="ml-1">
              {{ selectedClient.is_active ? 'Active' : 'Inactive' }}
            </BaseBadge>
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400 space-y-1">
            <p v-if="selectedClient.company">{{ selectedClient.company }}</p>
            <p v-if="selectedClient.email">{{ selectedClient.email }}</p>
            <p v-if="selectedClient.phone">{{ selectedClient.phone }}</p>
          </div>
        </div>

        <!-- Billing Info -->
        <div class="pt-4 border-t border-gray-200 dark:border-gray-700">
          <h4 class="font-medium text-gray-900 dark:text-white mb-2">Billing Information</h4>
          <div class="text-sm space-y-2">
            <div v-if="selectedClient.payment_terms" class="flex">
              <span class="text-gray-500 dark:text-gray-400 w-32">Payment Terms:</span>
              <span class="text-gray-900 dark:text-white">{{ selectedClient.payment_terms }}</span>
            </div>
            <div v-if="selectedClient.default_tax_rate !== null" class="flex">
              <span class="text-gray-500 dark:text-gray-400 w-32">Tax Rate:</span>
              <span class="text-gray-900 dark:text-white">{{ selectedClient.default_tax_rate }}%</span>
            </div>
            <div v-if="selectedClient.default_currency" class="flex">
              <span class="text-gray-500 dark:text-gray-400 w-32">Currency:</span>
              <span class="text-gray-900 dark:text-white">{{ selectedClient.default_currency }}</span>
            </div>
          </div>
        </div>

        <!-- Notes -->
        <div v-if="selectedClient.notes" class="pt-4 border-t border-gray-200 dark:border-gray-700">
          <h4 class="font-medium text-gray-900 dark:text-white mb-2">Notes</h4>
          <p class="text-sm text-gray-600 dark:text-gray-400">{{ selectedClient.notes }}</p>
        </div>

        <!-- Addresses -->
        <div class="pt-4 border-t border-gray-200 dark:border-gray-700">
          <h4 class="font-medium text-gray-900 dark:text-white mb-2">Addresses</h4>
          <div v-if="selectedClient.addresses && selectedClient.addresses.length > 0" class="space-y-3">
            <div 
              v-for="address in selectedClient.addresses" 
              :key="address.id"
              class="bg-gray-50 dark:bg-gray-800/50 rounded-md p-3"
            >
              <div class="flex items-center mb-1">
                <h5 class="text-sm font-medium text-gray-900 dark:text-white">{{ address.name }}</h5>
                <BaseBadge v-if="address.is_primary" variant="success" size="sm" class="ml-2">Primary</BaseBadge>
              </div>
              <div class="text-xs text-gray-600 dark:text-gray-400">
                <p>{{ address.street_address }}</p>
                <p>{{ address.city }}, {{ address.state }} {{ address.postal_code }}</p>
                <p v-if="address.country && address.country !== 'USA'">{{ address.country }}</p>
              </div>
              <p v-if="address.notes" class="mt-1 text-xs text-gray-500 dark:text-gray-500 italic">{{ address.notes }}</p>
            </div>
          </div>
          <div v-else class="text-sm text-gray-500 dark:text-gray-400 italic">
            No addresses available
          </div>
        </div>
        
        <!-- Creation Date -->
        <div v-if="selectedClient.created_at" class="text-xs text-gray-500 dark:text-gray-400 pt-2 border-t border-gray-200 dark:border-gray-700">
          Created on {{ formatDate(selectedClient.created_at) }}
        </div>
      </div>

      <template #footer>
        <div class="flex justify-between">
          <BaseButton
            variant="outline"
            size="sm"
            @click="showDetailsDrawer = false"
          >
            Close
          </BaseButton>
          <BaseButton
            variant="primary"
            size="sm"
            @click="openEditClientModal(selectedClient); showDetailsDrawer = false;"
          >
            Edit Client
          </BaseButton>
        </div>
      </template>
    </BaseDrawer>

    <!-- Create/Edit Client Modal -->
    <BaseModal
      v-model="showClientModal"
      :title="isEditing ? 'Edit Client' : 'Create New Client'"
      size="lg"
      persistent
    >
      <!-- Alert for form errors -->
      <BaseAlert
        v-if="formError"
        variant="error"
        :message="formError"
        dismissible
        class="mb-4"
        @close="formError = ''"
      />

      <form @submit.prevent="submitClientForm" id="createClientForm">
        <div class="space-y-4">
          <!-- General Information Section -->
          <div>
            <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">General Information</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- Display Name -->
              <BaseFormGroup
                label="Name"
                input-id="client-name"
                required
              >
                <BaseInput
                  id="client-name"
                  v-model="clientForm.display_name"
                  placeholder="Enter client name"
                  required
                  :error="formErrors.display_name"
                />
              </BaseFormGroup>

              <!-- Company -->
              <BaseFormGroup
                label="Company"
                input-id="client-company"
              >
                <BaseInput
                  id="client-company"
                  v-model="clientForm.company"
                  placeholder="Enter company name (if applicable)"
                  :error="formErrors.company"
                />
              </BaseFormGroup>

              <!-- Email -->
              <BaseFormGroup
                label="Email Address"
                input-id="client-email"
              >
                <BaseInput
                  id="client-email"
                  v-model="clientForm.email"
                  type="email"
                  placeholder="Enter email address"
                  :error="formErrors.email"
                />
              </BaseFormGroup>

              <!-- Phone -->
              <BaseFormGroup
                label="Phone Number"
                input-id="client-phone"
              >
                <BaseInput
                  id="client-phone"
                  v-model="clientForm.phone"
                  placeholder="Enter phone number"
                  :error="formErrors.phone"
                />
              </BaseFormGroup>

              <!-- Client Type -->
              <BaseFormGroup
                label="Client Type"
                input-id="client-type"
                required
              >
                <BaseSelect
                  id="client-type"
                  v-model="clientForm.client_type"
                  :options="clientTypeOptions.filter(t => t.value !== 'all')"
                  required
                  :error="formErrors.client_type"
                />
              </BaseFormGroup>

              <!-- Active Status -->
              <BaseFormGroup
                label="Status"
                input-id="client-status"
                required
              >
                <BaseToggleSwitch
                  id="client-status"
                  v-model="clientForm.is_active"
                  :error="formErrors.is_active"
                >
                  <span class="ml-2 text-sm" :class="clientForm.is_active ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'">
                    {{ clientForm.is_active ? 'Active' : 'Inactive' }}
                  </span>
                </BaseToggleSwitch>
              </BaseFormGroup>
            </div>
          </div>

          <!-- Billing Settings Section -->
          <div>
            <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">Billing Settings</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- Default Tax Rate -->
              <BaseFormGroup
                label="Default Tax Rate (%)"
                input-id="client-tax-rate"
              >
                <BaseInput
                  id="client-tax-rate"
                  v-model="clientForm.default_tax_rate"
                  type="number"
                  step="0.01"
                  min="0"
                  max="100"
                  placeholder="Enter default tax rate (0-100)"
                  :error="formErrors.default_tax_rate"
                />
              </BaseFormGroup>

              <!-- Payment Terms -->
              <BaseFormGroup
                label="Payment Terms"
                input-id="client-payment-terms"
              >
                <BaseInput
                  id="client-payment-terms"
                  v-model="clientForm.payment_terms"
                  placeholder="E.g., Net 30"
                  :error="formErrors.payment_terms"
                />
              </BaseFormGroup>

              <!-- Default Currency -->
              <BaseFormGroup
                label="Default Currency"
                input-id="client-currency"
              >
                <BaseInput
                  id="client-currency"
                  v-model="clientForm.default_currency"
                  placeholder="E.g., USD"
                  maxlength="3"
                  :error="formErrors.default_currency"
                />
              </BaseFormGroup>
            </div>
          </div>

          <!-- Notes Section -->
          <div>
            <BaseFormGroup
              label="Notes"
              input-id="client-notes"
              helper-text="Additional information about this client"
            >
              <textarea
                id="client-notes"
                v-model="clientForm.notes"
                rows="3"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="Enter any additional notes about this client"
                :class="formErrors.notes ? 'border-red-300 focus:border-red-500 focus:ring-red-200' : ''"
              ></textarea>
              <p v-if="formErrors.notes" class="mt-1 text-sm text-red-600 dark:text-red-400">
                {{ formErrors.notes }}
              </p>
            </BaseFormGroup>
          </div>

          <!-- Addresses Section -->
          <div>
            <div class="flex justify-between items-center mb-2">
              <h3 class="text-base font-medium text-gray-900 dark:text-white">Addresses</h3>
              <BaseButton
                variant="secondary"
                size="sm"
                @click="addNewAddress"
                class="flex items-center space-x-1"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 01-2 0v-3H6a1 1 0 010-2h3V6a1 1 0 011-1z" clip-rule="evenodd" />
                </svg>
                <span>Add Address</span>
              </BaseButton>
            </div>

            <!-- Text explaining the importance of addresses based on client type -->
            <div v-if="clientForm.client_type === 'property_manager'" class="mb-4 p-3 bg-blue-50 dark:bg-blue-900/20 border border-blue-100 dark:border-blue-800 rounded-md text-sm text-blue-700 dark:text-blue-300">
              <p>Property managers can have multiple addresses for different properties they manage. At least one primary address is required.</p>
            </div>
            <div v-else-if="clientForm.client_type === 'resident'" class="mb-4 p-3 bg-blue-50 dark:bg-blue-900/20 border border-blue-100 dark:border-blue-800 rounded-md text-sm text-blue-700 dark:text-blue-300">
              <p>Resident clients typically have a single address where they reside, but can have additional addresses if needed.</p>
            </div>

            <!-- Address List -->
            <div v-if="clientForm.addresses && clientForm.addresses.length > 0" class="space-y-4 mb-4">
              <div 
                v-for="(address, index) in clientForm.addresses" 
                :key="address.id || `new-address-${index}`"
                class="border border-gray-200 dark:border-gray-700 rounded-md p-4"
              >
                <div class="flex justify-between mb-2">
                  <div class="flex items-center">
                    <h4 class="font-medium text-gray-900 dark:text-white">{{ address.name }}</h4>
                    <BaseBadge v-if="address.is_primary" variant="success" size="sm" class="ml-2">Primary</BaseBadge>
                  </div>
                  <div class="flex space-x-2">
                    <button
                      type="button"
                      @click="editAddress(index)"
                      class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 0L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </button>
                    <button
                      type="button"
                      @click="removeAddress(index)"
                      class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
                      :disabled="clientForm.addresses.length === 1 && address.is_primary"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </div>
                </div>
                <div class="text-sm text-gray-600 dark:text-gray-400">
                  <p>{{ address.street_address }}</p>
                  <p>{{ address.city }}, {{ address.state }} {{ address.postal_code }}</p>
                  <p v-if="address.country && address.country !== 'USA'">{{ address.country }}</p>
                </div>
              </div>
            </div>
            
            <!-- No Addresses Message -->
            <div v-else class="bg-yellow-50 dark:bg-yellow-900/20 p-4 rounded-md border border-yellow-100 dark:border-yellow-800 mb-4">
              <p class="text-yellow-700 dark:text-yellow-300 text-sm">No addresses added. Please add at least one address.</p>
            </div>

            <!-- Address Form -->
            <div v-if="showAddressForm" class="border border-blue-200 dark:border-blue-700 bg-blue-50 dark:bg-blue-900/20 rounded-md p-4 mb-4">
              <h4 class="text-base font-medium text-gray-900 dark:text-white mb-3">
                {{ isEditingAddress ? 'Edit Address' : 'Add New Address' }}
              </h4>
              
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <!-- Address Name -->
                <BaseFormGroup
                  label="Address Name"
                  input-id="address-name"
                  required
                  helper-text="E.g., 'Main Office' or 'Property at 123 Main St'"
                >
                  <BaseInput
                    id="address-name"
                    v-model="addressForm.name"
                    placeholder="Enter a name for this address"
                    required
                    :error="addressErrors.name"
                  />
                </BaseFormGroup>

                <!-- Street Address -->
                <BaseFormGroup
                  label="Street Address"
                  input-id="address-street"
                  required
                  class="md:col-span-2"
                >
                  <BaseInput
                    id="address-street"
                    v-model="addressForm.street_address"
                    placeholder="Enter street address"
                    required
                    :error="addressErrors.street_address"
                  />
                </BaseFormGroup>

                <!-- City -->
                <BaseFormGroup
                  label="City"
                  input-id="address-city"
                  required
                >
                  <BaseInput
                    id="address-city"
                    v-model="addressForm.city"
                    placeholder="Enter city"
                    required
                    :error="addressErrors.city"
                  />
                </BaseFormGroup>

                <!-- State -->
                <BaseFormGroup
                  label="State"
                  input-id="address-state"
                  required
                >
                  <BaseInput
                    id="address-state"
                    v-model="addressForm.state"
                    placeholder="Enter state"
                    required
                    :error="addressErrors.state"
                  />
                </BaseFormGroup>

                <!-- Postal Code -->
                <BaseFormGroup
                  label="Postal Code"
                  input-id="address-postal"
                  required
                >
                  <BaseInput
                    id="address-postal"
                    v-model="addressForm.postal_code"
                    placeholder="Enter postal code"
                    required
                    :error="addressErrors.postal_code"
                  />
                </BaseFormGroup>

                <!-- Country -->
                <BaseFormGroup
                  label="Country"
                  input-id="address-country"
                >
                  <BaseInput
                    id="address-country"
                    v-model="addressForm.country"
                    placeholder="Enter country (defaults to USA)"
                    :error="addressErrors.country"
                  />
                </BaseFormGroup>

                <!-- Primary Address Toggle -->
                <BaseFormGroup
                  label="Primary Address"
                  input-id="address-primary"
                  class="md:col-span-2"
                >
                  <BaseToggleSwitch
                    id="address-primary"
                    v-model="addressForm.is_primary"
                    :error="addressErrors.is_primary"
                  >
                    <span class="ml-2 text-sm">Make this the primary address</span>
                  </BaseToggleSwitch>
                </BaseFormGroup>

                <!-- Address Notes -->
                <BaseFormGroup
                  label="Notes"
                  input-id="address-notes"
                  class="md:col-span-2"
                >
                  <textarea
                    id="address-notes"
                    v-model="addressForm.notes"
                    rows="2"
                    class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                    placeholder="Additional notes about this address"
                    :class="addressErrors.notes ? 'border-red-300 focus:border-red-500 focus:ring-red-200' : ''"
                  ></textarea>
                  <p v-if="addressErrors.notes" class="mt-1 text-sm text-red-600 dark:text-red-400">
                    {{ addressErrors.notes }}
                  </p>
                </BaseFormGroup>
              </div>

              <!-- Address Form Buttons -->
              <div class="flex justify-end space-x-2 mt-4">
                <BaseButton
                  variant="outline"
                  @click="cancelAddressForm"
                >
                  Cancel
                </BaseButton>
                <BaseButton
                  variant="primary"
                  @click="saveAddress"
                >
                  {{ isEditingAddress ? 'Update Address' : 'Add Address' }}
                </BaseButton>
              </div>
            </div>
          </div>
        </div>

        <!-- Form Buttons -->
        <div class="flex justify-end space-x-3 mt-6">
          <BaseButton
            variant="outline"
            @click="showClientModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            variant="primary"
            type="submit"
            :loading="formSubmitting"
          >
            {{ isEditing ? 'Update Client' : 'Create Client' }}
          </BaseButton>
        </div>
      </form>
    </BaseModal>

    <!-- Delete Client Confirmation Modal -->
    <BaseModal
      v-model="showDeleteModal"
      title="Confirm Deletion"
      size="sm"
    >
      <div class="py-2">
        <p class="text-gray-700 dark:text-gray-300">
          Are you sure you want to delete client <span class="font-bold">{{ clientToDelete?.display_name }}</span>?
        </p>
        <p class="text-gray-500 dark:text-gray-400 text-sm mt-2">
          This action cannot be undone and will delete all associated addresses.
        </p>
      </div>

      <template #footer>
        <div class="flex justify-end space-x-3">
          <BaseButton
            variant="outline"
            @click="showDeleteModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            variant="danger"
            :loading="deleteSubmitting"
            @click="confirmDeleteClient"
          >
            Delete Client
          </BaseButton>
        </div>
      </template>
    </BaseModal>

    <!-- Toast Notification -->
    <BaseToastNotification
      v-if="showToast"
      :id="toastId"
      :variant="toastVariant"
      :message="toastMessage"
      @close="showToast = false"
      position="bottom-right"
      :auto-close="3000"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { debounce } from 'lodash-es';
import clientService from '@/services/clients.service';

// Import Base Components
import BaseButton from '@/components/base/BaseButton.vue';
import BaseInput from '@/components/form/BaseInput.vue';
import BaseSelect from '@/components/form/BaseSelect.vue';
import BaseCard from '@/components/data-display/BaseCard.vue';
import BaseBadge from '@/components/data-display/BaseBadge.vue';
import BaseModal from '@/components/overlays/BaseModal.vue';
import BaseDrawer from '@/components/overlays/BaseDrawer.vue';
import BaseAlert from '@/components/feedback/BaseAlert.vue';
import BaseToastNotification from '@/components/feedback/BaseToastNotification.vue';
import BaseFormGroup from '@/components/form/BaseFormGroup.vue';
import BaseToggleSwitch from '@/components/form/BaseToggleSwitch.vue';

// Import Custom Components
import ClientTableResponsive from './client-tables/ClientTableResponsive.vue';
import ClientTableCompact from './client-tables/ClientTableCompact.vue';

// State
const clients = ref([]);
const loading = ref(false);
const error = ref(null);
const searchQuery = ref('');
const typeFilter = ref('all');
const statusFilter = ref('all');
const viewMode = ref('table'); // 'table' or 'grid'
const columnsDisplay = ref('default'); // 'default', 'compact', 'full'

// Pagination
const currentPage = ref(1);
const itemsPerPage = ref(10); // Or load from user preference/settings
const totalItems = ref(0);

// Sorting
const sortConfig = ref({ key: 'display_name', order: 'asc' });

// Modals & Drawers
const showClientModal = ref(false);
const showDeleteModal = ref(false);
const showDetailsDrawer = ref(false);
const isEditing = ref(false);
const clientToEdit = ref(null);
const clientToDelete = ref(null);
const selectedClient = ref(null);

// Forms
const clientForm = ref(getInitialClientForm());
const formErrors = ref({});
const formError = ref('');
const formSubmitting = ref(false);
const deleteSubmitting = ref(false);

const showAddressForm = ref(false);
const addressForm = ref(getInitialAddressForm());
const addressErrors = ref({});
const isEditingAddress = ref(false);
const editingAddressIndex = ref(-1);

// Toast Notifications
const showToast = ref(false);
const toastMessage = ref('');
const toastVariant = ref('success'); // 'success', 'error', 'info', 'warning'
const toastId = ref('client-toast-1'); // Add unique ID for toast notifications

// Options
const clientTypeOptions = [
  { value: 'all', label: 'All Types' },
  { value: 'property_manager', label: 'Property Manager' },
  { value: 'resident', label: 'Resident' },
  // Add other types if needed
];

const statusOptions = [
  { value: 'all', label: 'All Statuses' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
];

// Computed Properties
const filteredClients = computed(() => {
  let filtered = [...clients.value];

  // Apply search query
  if (searchQuery.value) {
    const lowerQuery = searchQuery.value.toLowerCase();
    filtered = filtered.filter(client =>
      client.display_name?.toLowerCase().includes(lowerQuery) ||
      client.company?.toLowerCase().includes(lowerQuery) ||
      client.email?.toLowerCase().includes(lowerQuery)
    );
  }

  // Apply type filter
  if (typeFilter.value !== 'all') {
    filtered = filtered.filter(client => client.client_type === typeFilter.value);
  }

  // Apply status filter
  if (statusFilter.value !== 'all') {
    const isActive = statusFilter.value === 'active';
    filtered = filtered.filter(client => client.is_active === isActive);
  }

  // Apply sorting
  if (sortConfig.value.key) {
    filtered.sort((a, b) => {
      let valA = a[sortConfig.value.key];
      let valB = b[sortConfig.value.key];

      // Handle different data types for sorting
      if (typeof valA === 'string') valA = valA.toLowerCase();
      if (typeof valB === 'string') valB = valB.toLowerCase();
      if (typeof valA === 'boolean') valA = valA ? 1 : 0;
      if (typeof valB === 'boolean') valB = valB ? 1 : 0;
      // Add more type handling if needed (dates, numbers)

      if (valA < valB) return sortConfig.value.order === 'asc' ? -1 : 1;
      if (valA > valB) return sortConfig.value.order === 'asc' ? 1 : -1;
      return 0;
    });
  }
  
  totalItems.value = filtered.length; // Update total items based on filtering
  return filtered;
});

const totalPages = computed(() => {
  // Ensure we always return at least 1 page, even when there are no items
  return Math.max(1, Math.ceil(totalItems.value / itemsPerPage.value));
});

const paginatedClients = computed(() => {
  if (!filteredClients.value.length) {
    return [];
  }
  const start = (currentPage.value - 1) * itemsPerPage.value;
  const end = start + itemsPerPage.value;
  // Ensure we don't try to slice beyond array bounds
  return filteredClients.value.slice(Math.min(start, filteredClients.value.length), Math.min(end, filteredClients.value.length));
});

// Methods
async function fetchClients() {
  loading.value = true;
  error.value = null;
  try {
    const response = await clientService.getAllClients(); // Corrected function name
    const fetchedClients = response.data || [];
    clients.value = fetchedClients;
    totalItems.value = fetchedClients.length; // Set totalItems immediately after fetch
    clients.value = response.data || [];
    totalItems.value = clients.value.length; // Initial total count
  } catch (err) {
    console.error('Error fetching clients:', err);
    error.value = 'Failed to load clients. Please try again.';
    showToastNotification('Failed to load clients.', 'error');
    clients.value = []; // Ensure clients is empty on error
    totalItems.value = 0; // Ensure totalItems is 0 on error
    clients.value = []; // Ensure clients is empty on error
    totalItems.value = 0; // Ensure totalItems is 0 on error
  } finally {
    loading.value = false;
  }
}

const debouncedFetch = debounce(fetchClients, 300);

function handleSearch() {
  currentPage.value = 1; // Reset page on search
  // If API supports server-side search, call debouncedFetch() here
}

function handleFilter() {
  currentPage.value = 1; // Reset page on filter change
  // If API supports server-side filtering, call debouncedFetch() here
}

function handleSort(newSortConfig) {
  sortConfig.value = newSortConfig;
  currentPage.value = 1; // Reset page on sort change
}

function handlePageChange(newPage) {
  currentPage.value = newPage;
}

function handleViewChange(newMode) {
  viewMode.value = newMode;
  // Persist view mode preference if needed (e.g., localStorage)
}

function handleRowClick(client) {
  selectedClient.value = client;
  showDetailsDrawer.value = true;
}

function resetFilters() {
  searchQuery.value = '';
  typeFilter.value = 'all';
  statusFilter.value = 'all';
  sortConfig.value = { key: 'display_name', order: 'asc' };
  currentPage.value = 1;
  // If using server-side filtering/search, call fetchClients() here
}

function formatClientType(type) {
  if (!type) return 'N/A';
  return type.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
}

function getClientTypeBadgeVariant(type) {
  switch (type) {
    case 'property_manager': return 'info';
    case 'resident': return 'primary';
    default: return 'secondary';
  }
}

function formatDate(dateString) {
  if (!dateString) return 'N/A';
  try {
    return new Date(dateString).toLocaleDateString(undefined, {
      year: 'numeric', month: 'short', day: 'numeric'
    });
  } catch (e) {
    return dateString; // Fallback
  }
}

// --- Client Modal ---
function getInitialClientForm() {
  return {
    id: null,
    display_name: '',
    company: '',
    email: '',
    phone: '',
    client_type: 'resident', // Default type
    is_active: true,
    payment_terms: '',
    default_tax_rate: null,
    default_currency: 'USD', // Default currency
    notes: '',
    addresses: [], // Array of address objects
  };
}

function getInitialAddressForm() {
  return {
    id: null, // For existing addresses during edit
    name: '',
    street_address: '',
    city: '',
    state: '',
    postal_code: '',
    country: 'USA', // Default country
    is_primary: false,
    notes: '',
  };
}

function openCreateClientModal() {
  isEditing.value = false;
  clientForm.value = getInitialClientForm();
  // Ensure at least one empty primary address when creating
  if (clientForm.value.addresses.length === 0) {
    const newAddress = getInitialAddressForm();
    newAddress.is_primary = true;
    newAddress.name = 'Primary Address'; // Default name
    clientForm.value.addresses.push(newAddress);
  }
  formErrors.value = {};
  formError.value = '';
  showAddressForm.value = false; // Hide address form initially
  showClientModal.value = true;
}

function openEditClientModal(client) {
  isEditing.value = true;
  clientToEdit.value = client;
  // Deep copy to avoid modifying original object directly
  clientForm.value = JSON.parse(JSON.stringify({
    ...getInitialClientForm(), // Start with defaults
    ...client, // Override with client data
    addresses: client.addresses ? JSON.parse(JSON.stringify(client.addresses)) : [], // Deep copy addresses
    default_tax_rate: client.default_tax_rate !== null ? Number(client.default_tax_rate) : null, // Ensure number
  }));
  // Ensure addresses array exists
  if (!clientForm.value.addresses) {
    clientForm.value.addresses = [];
  }
  // Ensure at least one primary address if none exist (safety net)
  if (clientForm.value.addresses.length > 0 && !clientForm.value.addresses.some(a => a.is_primary)) {
    clientForm.value.addresses[0].is_primary = true;
  } else if (clientForm.value.addresses.length === 0) {
     const newAddress = getInitialAddressForm();
     newAddress.is_primary = true;
     newAddress.name = 'Primary Address';
     clientForm.value.addresses.push(newAddress);
  }

  formErrors.value = {};
  formError.value = '';
  showAddressForm.value = false; // Hide address form initially
  showClientModal.value = true;
}

function validateClientForm() {
  formErrors.value = {};
  let isValid = true;

  if (!clientForm.value.display_name?.trim()) {
    formErrors.value.display_name = 'Client name is required.';
    isValid = false;
  }
  if (!clientForm.value.client_type) {
    formErrors.value.client_type = 'Client type is required.';
    isValid = false;
  }
  if (!clientForm.value.addresses || clientForm.value.addresses.length === 0) {
    formError.value = 'At least one address is required.'; // General form error
    isValid = false;
  } else if (!clientForm.value.addresses.some(a => a.is_primary)) {
    formError.value = 'At least one address must be marked as primary.'; // General form error
    isValid = false;
  }
  // Add more specific validations (email format, phone format, tax rate range, currency format)
  if (clientForm.value.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(clientForm.value.email)) {
      formErrors.value.email = 'Please enter a valid email address.';
      isValid = false;
  }
  if (clientForm.value.default_tax_rate !== null && (isNaN(clientForm.value.default_tax_rate) || clientForm.value.default_tax_rate < 0 || clientForm.value.default_tax_rate > 100)) {
      formErrors.value.default_tax_rate = 'Tax rate must be between 0 and 100.';
      isValid = false;
  }
   if (clientForm.value.default_currency && clientForm.value.default_currency.length !== 3) {
      formErrors.value.default_currency = 'Currency code must be 3 letters (e.g., USD).';
      isValid = false;
  }


  return isValid;
}

async function submitClientForm() {
  formError.value = '';
  if (!validateClientForm()) {
    formError.value = 'Please correct the errors in the form.';
    return;
  }

  formSubmitting.value = true;
  try {
    if (isEditing.value) {
      const clientId = clientForm.value.id;
      
      // 1. Extract client data without addresses for separate handling
      const { addresses, ...clientData } = { ...clientForm.value };
      
      // Ensure tax rate is a number or null
      clientData.default_tax_rate = clientData.default_tax_rate !== '' ? Number(clientData.default_tax_rate) : null;
      
      // 2. Update the main client data
      await clientService.updateClient(clientId, clientData);
      
      // 3. Handle address updates separately
      if (addresses && Array.isArray(addresses)) {
        // Get current addresses from server
        const currentClientResponse = await clientService.getClientById(clientId);
        const currentAddresses = currentClientResponse.data.addresses || [];
        
        // Identify addresses to add, update, or delete
        const addressesToUpdate = addresses.filter(a => typeof a.id === 'number');
        const addressesToAdd = addresses.filter(a => typeof a.id !== 'number');
        const addressesToDelete = currentAddresses.filter(
          currentAddr => !addresses.some(newAddr => newAddr.id === currentAddr.id)
        );
        
        // Delete addresses that aren't in the new list
        for (const addr of addressesToDelete) {
          await clientService.deleteClientAddress(clientId, addr.id);
        }
        
        // Update existing addresses
        for (const addr of addressesToUpdate) {
          const { id, ...addressData } = addr;
          await clientService.updateClientAddress(clientId, id, addressData);
        }
        
        // Add new addresses
        for (const addr of addressesToAdd) {
          const { id, ...addressData } = addr; // Remove temporary id
          await clientService.addClientAddress(clientId, addressData);
        }
      }
      
      // 4. Refresh the client list
      await fetchClients();
      
      // 5. Refresh the selected client if it's the one being edited
      if (selectedClient.value && selectedClient.value.id === clientId) {
        const updatedClientResponse = await clientService.getClientById(clientId);
        selectedClient.value = updatedClientResponse.data;
      }
      
      showToastNotification('Client updated successfully.', 'success');
    } else {
      // For new clients, we can use the existing method since it creates everything at once
      const payload = { ...clientForm.value };
      // Ensure tax rate is a number or null
      payload.default_tax_rate = payload.default_tax_rate !== '' ? Number(payload.default_tax_rate) : null;
      // Format addresses for creation (remove temporary IDs)
      payload.addresses = payload.addresses.map(addr => {
        const { id, ...rest } = addr;
        return rest; // New addresses don't need IDs
      });
      
      await clientService.createClient(payload);
      await fetchClients(); // Refresh the list
      showToastNotification('Client created successfully.', 'success');
    }
    
    showClientModal.value = false;
  } catch (err) {
    console.error('Error submitting client form:', err);
    formError.value = err.response?.data?.message || `Failed to ${isEditing.value ? 'update' : 'create'} client. Please try again.`;
    showToastNotification(formError.value, 'error');
  } finally {
    formSubmitting.value = false;
  }
}

// --- Address Management ---
function addNewAddress() {
  addressForm.value = getInitialAddressForm();
  // If this is the *only* address being added, make it primary by default
  if (clientForm.value.addresses.length === 0) {
      addressForm.value.is_primary = true;
      addressForm.value.name = 'Primary Address';
  } else {
      addressForm.value.is_primary = false; // Default to non-primary if others exist
      addressForm.value.name = `Address ${clientForm.value.addresses.length + 1}`; // Default name
  }
  addressErrors.value = {};
  isEditingAddress.value = false;
  editingAddressIndex.value = -1;
  showAddressForm.value = true;
}

function editAddress(index) {
  // Deep copy the address to edit
  addressForm.value = JSON.parse(JSON.stringify(clientForm.value.addresses[index]));
  addressErrors.value = {};
  isEditingAddress.value = true;
  editingAddressIndex.value = index;
  showAddressForm.value = true;
}

function removeAddress(index) {
  // Prevent deleting the last primary address
  if (clientForm.value.addresses.length === 1 && clientForm.value.addresses[index].is_primary) {
      showToastNotification('Cannot delete the only primary address.', 'warning');
      return;
  }
  const removedAddress = clientForm.value.addresses.splice(index, 1)[0];

  // If the removed address was primary, and there are still addresses left,
  // make the first remaining address primary.
  if (removedAddress.is_primary && clientForm.value.addresses.length > 0) {
      clientForm.value.addresses[0].is_primary = true;
  }

  // If removing the address being edited in the form
  if (isEditingAddress.value && editingAddressIndex.value === index) {
      cancelAddressForm();
  } else if (isEditingAddress.value && editingAddressIndex.value > index) {
      // Adjust index if an earlier address was removed
      editingAddressIndex.value--;
  }
}

function validateAddressForm() {
    addressErrors.value = {};
    let isValid = true;
    if (!addressForm.value.name?.trim()) {
        addressErrors.value.name = 'Address name is required.';
        isValid = false;
    }
    if (!addressForm.value.street_address?.trim()) {
        addressErrors.value.street_address = 'Street address is required.';
        isValid = false;
    }
    if (!addressForm.value.city?.trim()) {
        addressErrors.value.city = 'City is required.';
        isValid = false;
    }
     if (!addressForm.value.state?.trim()) {
        addressErrors.value.state = 'State is required.';
        isValid = false;
    }
    if (!addressForm.value.postal_code?.trim()) {
        addressErrors.value.postal_code = 'Postal code is required.';
        isValid = false;
    }
    // Add more specific validations if needed (e.g., postal code format)
    return isValid;
}

function saveAddress() {
  if (!validateAddressForm()) {
      return;
  }

  // Handle primary address logic: if this one is set to primary, unset others
  if (addressForm.value.is_primary) {
    clientForm.value.addresses.forEach((addr, i) => {
      if (i !== editingAddressIndex.value) { // Don't unset itself if editing
        addr.is_primary = false;
      }
    });
  } else {
    // If unsetting the *only* primary address, prevent it or auto-set another
    const primaryAddresses = clientForm.value.addresses.filter((addr, i) => 
        addr.is_primary && i !== editingAddressIndex.value // Exclude the one being edited if it was primary
    );
    // If this was the only primary address and is being unset
    if (primaryAddresses.length === 0 && (!isEditingAddress.value || clientForm.value.addresses[editingAddressIndex.value]?.is_primary)) {
        // If there are other addresses, make the first one primary
        if (clientForm.value.addresses.length > (isEditingAddress.value ? 1 : 0)) {
             showToastNotification('Cannot unset the only primary address. Setting the first address as primary.', 'warning');
             // Find the first address that isn't the one being edited (if applicable) and make it primary
             const firstOtherIndex = clientForm.value.addresses.findIndex((_, i) => i !== editingAddressIndex.value);
             if (firstOtherIndex !== -1) {
                 clientForm.value.addresses[firstOtherIndex].is_primary = true;
             } else {
                 // This case should ideally not happen if logic is correct, but as fallback, keep current primary
                 addressForm.value.is_primary = true; 
             }
        } else {
            // If this is truly the only address, it must remain primary
            showToastNotification('The only address must be primary.', 'warning');
            addressForm.value.is_primary = true;
        }
    }
  }


  const addressData = JSON.parse(JSON.stringify(addressForm.value)); // Deep copy

  if (isEditingAddress.value) {
    // Update existing address
    clientForm.value.addresses.splice(editingAddressIndex.value, 1, addressData);
  } else {
    // Add new address
    clientForm.value.addresses.push(addressData);
  }

  // Ensure there's always at least one primary address after saving
  if (!clientForm.value.addresses.some(a => a.is_primary) && clientForm.value.addresses.length > 0) {
      clientForm.value.addresses[0].is_primary = true;
      showToastNotification('Automatically set the first address as primary.', 'info');
  }


  cancelAddressForm(); // Hide form after saving
}

function cancelAddressForm() {
  showAddressForm.value = false;
  addressForm.value = getInitialAddressForm();
  addressErrors.value = {};
  isEditingAddress.value = false;
  editingAddressIndex.value = -1;
}

// --- Delete Client ---
function openDeleteClientModal(client) {
  clientToDelete.value = client;
  showDeleteModal.value = true;
}

async function confirmDeleteClient() {
  if (!clientToDelete.value) return;
  deleteSubmitting.value = true;
  try {
    await clientService.deleteClient(clientToDelete.value.id);
    showToastNotification('Client deleted successfully.', 'success');
    showDeleteModal.value = false;
    fetchClients(); // Refresh list
    // If the deleted client was selected in the details drawer, close it
    if (selectedClient.value?.id === clientToDelete.value.id) {
        showDetailsDrawer.value = false;
        selectedClient.value = null;
    }
  } catch (err) {
    console.error('Error deleting client:', err);
    showToastNotification(err.response?.data?.message || 'Failed to delete client.', 'error');
  } finally {
    deleteSubmitting.value = false;
    clientToDelete.value = null;
  }
}

// --- Toggle Status ---
async function toggleClientStatus(client) {
    const originalStatus = client.is_active;
    // Optimistically update UI
    client.is_active = !client.is_active; 

    try {
        await clientService.updateClient(client.id, { is_active: client.is_active });
        showToastNotification(`Client status updated to ${client.is_active ? 'Active' : 'Inactive'}.`, 'success');
        // Optional: refetch specific client data if needed
        // const updatedClient = await clientService.getClientById(client.id);
        // const index = clients.value.findIndex(c => c.id === client.id);
        // if (index !== -1) clients.value.splice(index, 1, updatedClient.data);

    } catch (err) {
        console.error('Error updating client status:', err);
        // Revert optimistic update
        client.is_active = originalStatus; 
        showToastNotification(err.response?.data?.message || 'Failed to update client status.', 'error');
    }
}


// --- Toast Notification ---
let toastCounter = 0; // Counter for unique toast IDs
function showToastNotification(message, variant = 'success') {
  toastCounter++;
  toastId.value = `client-toast-${toastCounter}`; // Update the toast ID for each notification
  toastMessage.value = message;
  toastVariant.value = variant;
  showToast.value = true;
}

// Lifecycle Hooks
onMounted(() => {
  fetchClients();
  // Load persisted view mode or column settings if implemented
});

// Watch filteredClients to reset pagination when results change significantly
watch(filteredClients, (newClients) => {
  const maxPossiblePage = Math.max(1, Math.ceil(newClients.length / itemsPerPage.value));
  if (currentPage.value > maxPossiblePage) {
    // If current page is now beyond available pages, reset to last available page
    currentPage.value = maxPossiblePage;
  }
});

</script>

<style scoped>
/* Add any component-specific styles here */
.client-settings {
  /* Example style */
  padding: 1rem; 
}
</style>
