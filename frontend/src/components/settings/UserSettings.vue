<template>
  <div class="user-settings">
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-lg font-medium text-gray-900 dark:text-white">User Management</h2>
      <BaseButton
        variant="primary"
        @click="openCreateUserModal"
        class="flex items-center space-x-2"
      >
        <span>Add User</span>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 01-2 0v-3H6a1 1 0 010-2h3V6a1 1 0 011-1z" clip-rule="evenodd" />
        </svg>
      </BaseButton>
    </div>

    <!-- Search and Filters -->
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-4 mb-6">
      <div class="flex flex-col md:flex-row md:items-center space-y-4 md:space-y-0 md:space-x-4">
        <div class="flex-1">
          <BaseFormGroup label="Search Users" input-id="search-users" class="mb-0">
            <BaseInput
              id="search-users"
              v-model="searchQuery"
              placeholder="Search by name or email"
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
          <BaseFormGroup label="Role" input-id="role-filter" class="mb-0">
            <BaseSelect
              id="role-filter"
              v-model="roleFilter"
              :options="roleOptions"
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

    <!-- Users Table / Grid View -->
    <BaseCard variant="default" class="mb-6">
      <!-- Table View -->
      <UserTableResponsive
        v-if="viewMode === 'table'"
        :filtered-users="paginatedUsers"
        :loading="loading"
        :sort-key="sortConfig.key"
        :sort-order="sortConfig.order"
        :current-page="currentPage"
        :total-pages="totalPages"
        :total-items="totalItems"
        :items-per-page="itemsPerPage"
        :format-role="formatRole"
        :get-role-badge-variant="getRoleBadgeVariant"
        :current-user="currentUser"
        v-model:columns-display="columnsDisplay"
        @view-change="handleViewChange"
        @sort-change="handleSort"
        @page-change="handlePageChange"
        @row-click="handleRowClick"
        @edit="openEditUserModal"
        @delete="openDeleteUserModal"
        @toggle-status="toggleUserStatus"
        @reset-filters="resetFilters"
      />

      <!-- Grid View -->
      <UserTableCompact
        v-else
        :filtered-users="paginatedUsers"
        :current-page="currentPage"
        :total-pages="totalPages"
        :total-items="totalItems"
        :items-per-page="itemsPerPage"
        :format-role="formatRole"
        :get-role-badge-variant="getRoleBadgeVariant"
        :current-user="currentUser"
        @view-change="handleViewChange"
        @page-change="handlePageChange"
        @row-click="handleRowClick"
        @edit="openEditUserModal"
        @delete="openDeleteUserModal"
        @reset-filters="resetFilters"
      />
    </BaseCard>

    <!-- User Details Drawer -->
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
          <h3 class="text-lg font-medium text-gray-900 dark:text-white">User Details</h3>
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

      <!-- User Details Content -->
      <div v-if="selectedUser" class="space-y-6">
        <!-- Profile Info -->
        <div class="flex items-center">
          <BaseAvatar
            :name="selectedUser.name"
            :image="selectedUser.avatar_url"
            size="lg"
            class="flex-shrink-0 mr-4"
          />
          <div>
            <h4 class="text-base font-medium text-gray-900 dark:text-white">
              {{ selectedUser.name }}
            </h4>
            <div class="mt-1 flex items-center space-x-2">
              <BaseBadge :variant="getRoleBadgeVariant(selectedUser.role)" size="sm">
                {{ formatRole(selectedUser.role) }}
              </BaseBadge>
              <BaseBadge :variant="selectedUser.is_active ? 'success' : 'danger'" size="sm">
                {{ selectedUser.is_active ? 'Active' : 'Inactive' }}
              </BaseBadge>
            </div>
          </div>
        </div>

        <!-- Contact Info -->
        <div class="pt-4 border-t border-gray-200 dark:border-gray-700">
          <h4 class="font-medium text-gray-900 dark:text-white mb-2">Contact Information</h4>
          <div class="text-sm space-y-2">
            <div class="flex">
              <span class="text-gray-500 dark:text-gray-400 w-24">Email:</span>
              <span class="text-gray-900 dark:text-white">{{ selectedUser.email }}</span>
            </div>
            <div v-if="selectedUser.phone" class="flex">
              <span class="text-gray-500 dark:text-gray-400 w-24">Phone:</span>
              <span class="text-gray-900 dark:text-white">{{ selectedUser.phone }}</span>
            </div>
          </div>
        </div>

        <!-- Department Info -->
        <div v-if="selectedUser.department" class="pt-4 border-t border-gray-200 dark:border-gray-700">
          <h4 class="font-medium text-gray-900 dark:text-white mb-2">Department</h4>
          <p class="text-sm text-gray-600 dark:text-gray-400">{{ selectedUser.department }}</p>
        </div>

        <!-- Account Info -->
        <div class="pt-4 border-t border-gray-200 dark:border-gray-700">
          <h4 class="font-medium text-gray-900 dark:text-white mb-2">Account Information</h4>
          <div class="text-sm space-y-2">
            <div class="flex">
              <span class="text-gray-500 dark:text-gray-400 w-24">Created:</span>
              <span class="text-gray-900 dark:text-white">{{ formatDate(selectedUser.created_at) }}</span>
            </div>
            <div class="flex">
              <span class="text-gray-500 dark:text-gray-400 w-24">Last Login:</span>
              <span class="text-gray-900 dark:text-white">{{ formatDate(selectedUser.last_login) || 'Never' }}</span>
            </div>
          </div>
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
            v-if="canEdit(selectedUser)"
            variant="primary"
            size="sm"
            @click="openEditUserModal(selectedUser); showDetailsDrawer = false;"
          >
            Edit User
          </BaseButton>
        </div>
      </template>
    </BaseDrawer>

    <!-- Create/Edit User Modal -->
    <BaseModal
      v-model="showUserModal"
      :title="isEditing ? 'Edit User' : 'Create New User'"
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

      <form @submit.prevent="submitUserForm" id="createUserForm">
        <div class="space-y-4">
          <!-- Basic Information -->
          <div>
            <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">Basic Information</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- Name -->
              <BaseFormGroup
                label="Name"
                input-id="user-name"
                required
              >
                <BaseInput
                  id="user-name"
                  v-model="userForm.name"
                  placeholder="Enter user's name"
                  required
                  :state="formErrors.name ? 'error' : ''"
                  :helperText="formErrors.name"
                />
              </BaseFormGroup>

              <!-- Username -->
              <BaseFormGroup
                label="Username"
                input-id="user-username"
                required
              >
                <BaseInput
                  id="user-username"
                  v-model="userForm.username"
                  placeholder="Enter username"
                  required
                  :state="formErrors.username ? 'error' : ''"
                  :helperText="formErrors.username"
                />
              </BaseFormGroup>

              <!-- Email -->
              <BaseFormGroup
                label="Email Address"
                input-id="user-email"
                required
              >
                <BaseInput
                  id="user-email"
                  v-model="userForm.email"
                  type="email"
                  placeholder="Enter email address"
                  required
                  :state="formErrors.email ? 'error' : ''"
                  :helperText="formErrors.email"
                />
              </BaseFormGroup>

              <!-- Role -->
              <BaseFormGroup
                label="Role"
                input-id="user-role"
                required
              >
                <BaseSelect
                  id="user-role"
                  v-model="userForm.role"
                  :options="availableRoles"
                  required
                  :state="formErrors.role ? 'error' : ''"
                  :helperText="formErrors.role"
                />
              </BaseFormGroup>

              <!-- Department -->
              <BaseFormGroup
                label="Department"
                input-id="user-department"
              >
                <BaseInput
                  id="user-department"
                  v-model="userForm.department"
                  placeholder="Enter department"
                  :state="formErrors.department ? 'error' : ''"
                  :helperText="formErrors.department"
                />
              </BaseFormGroup>

              <!-- Phone -->
              <BaseFormGroup
                label="Phone Number"
                input-id="user-phone"
              >
                <BaseInput
                  id="user-phone"
                  v-model="userForm.phone"
                  placeholder="Enter phone number"
                  :state="formErrors.phone ? 'error' : ''"
                  :helperText="formErrors.phone"
                />
              </BaseFormGroup>

              <!-- Active Status -->
              <BaseFormGroup
                label="Status"
                input-id="user-status"
                required
              >
                <BaseToggleSwitch
                  id="user-status"
                  v-model="userForm.is_active"
                  :state="formErrors.is_active ? 'error' : ''"
                >
                  <span class="ml-2 text-sm" :class="userForm.is_active ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'">
                    {{ userForm.is_active ? 'Active' : 'Inactive' }}
                  </span>
                </BaseToggleSwitch>
              </BaseFormGroup>
            </div>
          </div>

          <!-- Password Section (Only shown for new users or password resets) -->
          <div v-if="!isEditing || showPasswordFields">
            <div class="flex justify-between items-center">
              <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">
                {{ isEditing ? 'Change Password' : 'Set Password' }}
              </h3>
              <button
                v-if="isEditing && !showPasswordFields"
                type="button"
                @click="showPasswordFields = true"
                class="text-sm text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
              >
                Change Password
              </button>
            </div>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <BaseFormGroup
                label="Password"
                input-id="user-password"
                :required="!isEditing"
              >
                <BaseInput
                  id="user-password"
                  v-model="userForm.password"
                  type="password"
                  placeholder="Enter password"
                  :required="!isEditing"
                  :state="formErrors.password ? 'error' : ''"
                  :helperText="formErrors.password"
                  autocomplete="new-password"
                />
              </BaseFormGroup>

              <BaseFormGroup
                label="Confirm Password"
                input-id="user-password-confirm"
                :required="!isEditing"
              >
                <BaseInput
                  id="user-password-confirm"
                  v-model="userForm.password_confirmation"
                  type="password"
                  placeholder="Confirm password"
                  :required="!isEditing"
                  :state="formErrors.password_confirmation ? 'error' : ''"
                  :helperText="formErrors.password_confirmation"
                  autocomplete="new-password"
                />
              </BaseFormGroup>
            </div>
          </div>
        </div>

        <!-- Form Buttons -->
        <div class="flex justify-end space-x-3 mt-6">
          <BaseButton
            variant="outline"
            @click="showUserModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            variant="primary"
            type="submit"
            :loading="formSubmitting"
          >
            {{ isEditing ? 'Update User' : 'Create User' }}
          </BaseButton>
        </div>
      </form>
    </BaseModal>

    <!-- Delete User Confirmation Modal -->
    <BaseModal
      v-model="showDeleteModal"
      title="Confirm Deletion"
      size="sm"
      persistent
    >
      <div class="py-2">
        <p class="text-gray-700 dark:text-gray-300">
          Are you sure you want to delete user <span class="font-bold">{{ userToDelete?.name }}</span>?
        </p>
        <p class="text-gray-500 dark:text-gray-400 text-sm mt-2">
          This action cannot be undone.
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
            @click="confirmDeleteUser"
          >
            Delete User
          </BaseButton>
        </div>
      </template>
    </BaseModal>

    <!-- Toast Notification -->
    
    <!-- Toast Notifications Container -->
    <div class="fixed bottom-4 right-4 z-50 space-y-2">
      <BaseToastNotification
        position="bottom-right"
        v-for="toast in activeToasts"
        :key="toast.id"
        :id="toast.id"
        :variant="toast.variant"
        :message="toast.message"
        :title="toast.title"
        :duration="toast.duration"
        @close="removeToast"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { debounce } from 'lodash-es';
import { useAuthStore } from '@/store/auth';
import adminService from '@/services/admin.service';
import { generateId } from '@/utils/id';

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
import BaseAvatar from '@/components/data-display/BaseAvatar.vue';

// Import Custom Components
import UserTableResponsive from './user-tables/UserTableResponsive.vue';
import UserTableCompact from './user-tables/UserTableCompact.vue';

const auth = useAuthStore();
const currentUser = computed(() => auth.user);
// State
const users = ref([]);
const loading = ref(false);
const activeToasts = ref([]); // Array to hold active toasts

const error = ref(null);
const searchQuery = ref('');
const roleFilter = ref('all');
const statusFilter = ref('all');
const viewMode = ref('table');
const columnsDisplay = ref('default');

// Pagination - Initialize with default values to avoid undefined
const currentPage = ref(1);
const itemsPerPage = ref(10);
const totalItems = ref(0);

// Sorting
const sortConfig = ref({ key: 'name', order: 'asc' });

// Modals & Drawers
const showUserModal = ref(false);
const showDeleteModal = ref(false);
const showDetailsDrawer = ref(false);
const isEditing = ref(false);
const userToEdit = ref(null);
const userToDelete = ref(null);
const selectedUser = ref(null);
const showPasswordFields = ref(false);

// Forms
const userForm = ref(getInitialUserForm());
const formErrors = ref({});
const formError = ref('');
const formSubmitting = ref(false);
const deleteSubmitting = ref(false);

// Options
const roleOptions = [
  { value: 'all', label: 'All Roles' },
  { value: 'admin', label: 'Administrator' },
  { value: 'manager', label: 'Manager' },
  { value: 'user', label: 'User' }
];

const availableRoles = roleOptions.filter(r => r.value !== 'all');

const statusOptions = [
  { value: 'all', label: 'All Statuses' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' }
];

// Computed Properties
const filteredUsers = computed(() => {
  if (!users.value || !Array.isArray(users.value)) {
    return [];
  }
  let filtered = [...users.value];

  // Apply search query
  if (searchQuery.value) {
    const lowerQuery = searchQuery.value.toLowerCase();
    filtered = filtered.filter(user =>
      user.name?.toLowerCase().includes(lowerQuery) ||
      user.email?.toLowerCase().includes(lowerQuery) ||
      user.department?.toLowerCase().includes(lowerQuery)
    );
  }

  // Apply role filter
  if (roleFilter.value !== 'all') {
    filtered = filtered.filter(user => user.role === roleFilter.value);
  }

  // Apply status filter
  if (statusFilter.value !== 'all') {
    const isActive = statusFilter.value === 'active';
    filtered = filtered.filter(user => user.is_active === isActive);
  }

  // Apply sorting
  if (sortConfig.value.key) {
    filtered.sort((a, b) => {
      let valA = a[sortConfig.value.key];
      let valB = b[sortConfig.value.key];

      if (typeof valA === 'string') valA = valA.toLowerCase();
      if (typeof valB === 'string') valB = valB.toLowerCase();
      if (typeof valA === 'boolean') valA = valA ? 1 : 0;
      if (typeof valB === 'boolean') valB = valB ? 1 : 0;

      if (valA < valB) return sortConfig.value.order === 'asc' ? -1 : 1;
      if (valA > valB) return sortConfig.value.order === 'asc' ? 1 : -1;
      return 0;
    });
  }
  
  // Make sure to set totalItems as a number to avoid NaN or undefined
  totalItems.value = filtered.length || 0;
  return filtered;
});

const totalPages = computed(() => {
  // Ensure totalItems is a number and not undefined
  const items = typeof totalItems.value === 'number' ? totalItems.value : 0;
  const perPage = typeof itemsPerPage.value === 'number' ? itemsPerPage.value : 10;
  return Math.max(1, Math.ceil(items / perPage));
});

const paginatedUsers = computed(() => {
  if (!filteredUsers.value.length) {
    return [];
  }
  const start = (currentPage.value - 1) * itemsPerPage.value;
  const end = start + itemsPerPage.value;
  return filteredUsers.value.slice(
    Math.min(start, filteredUsers.value.length),
    Math.min(end, filteredUsers.value.length)
  );
});

// Methods
function getInitialUserForm() {
  return {
    name: '',
    username: '',
    email: '',
    role: 'user',
    department: '',
    phone: '',
    is_active: true,
    password: '',
    password_confirmation: ''
  };
}

async function fetchUsers() {
  // Initialize pagination values to avoid undefined
  totalItems.value = 0;
  
  loading.value = true;
  error.value = null;
  try {
    // Use adminService for user management operations
    const response = await adminService.getUsers();
    if (response) {
      // The response is already unwrapped by the API service
      users.value = Array.isArray(response.users) ? response.users : response;
      // Explicitly set totalItems as a number
      totalItems.value = users.value.length || 0;
    } else {
      throw new Error('Invalid response format from server');
    }
  } catch (err) {
    console.error('Error fetching users:', err);
    error.value = err.response?.data?.message || 'Failed to load users. Please try again.';
    showToastNotification(error.value, 'error');
    users.value = [];
    totalItems.value = 0;
  } finally {
    loading.value = false;
  }
}

const debouncedFetch = debounce(fetchUsers, 300);

function handleSearch() {
  currentPage.value = 1;
}

function handleFilter() {
  currentPage.value = 1;
}

function handleSort(newSortConfig) {
  sortConfig.value = newSortConfig;
  currentPage.value = 1;
}

function handlePageChange(newPage) {
  currentPage.value = newPage;
}

function handleViewChange(newMode) {
  viewMode.value = newMode;
}

function handleRowClick(user) {
  selectedUser.value = user;
  showDetailsDrawer.value = true;
}

function resetFilters() {
  searchQuery.value = '';
  roleFilter.value = 'all';
  statusFilter.value = 'all';
  sortConfig.value = { key: 'name', order: 'asc' };
  currentPage.value = 1;
}

function formatRole(role) {
  if (!role) return 'N/A';
  return role.charAt(0).toUpperCase() + role.slice(1);
}

function getRoleBadgeVariant(role) {
  switch (role) {
    case 'admin': return 'error';
    case 'manager': return 'warning';
    case 'user': return 'info';
    default: return 'secondary';
  }
}

function formatDate(dateString) {
  if (!dateString) return 'N/A';
  return new Date(dateString).toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
}

function canEdit(user) {
  if (!user || !currentUser.value) return false;
  
  // Admins can edit anyone except other admins (unless it's themselves)
  if (currentUser.value.role === 'admin') {
    if (user.id === currentUser.value.id) return true;
    return user.role !== 'admin';
  }
  
  // Managers can only edit regular users
  if (currentUser.value.role === 'manager') {
    return user.role === 'user';
  }
  
  // Regular users can't edit anyone
  return false;
}

function openCreateUserModal() {
  isEditing.value = false;
  userForm.value = getInitialUserForm();
  formErrors.value = {};
  formError.value = '';
  showPasswordFields.value = false;
  showUserModal.value = true;
}

function openEditUserModal(user) {
  if (!canEdit(user)) {
    showToastNotification("You don't have permission to edit this user.", 'error');
    return;
  }

  isEditing.value = true;
  userToEdit.value = user;
  userForm.value = {
    ...getInitialUserForm(),
    ...user,
    password: '',
    password_confirmation: ''
  };
  
  formErrors.value = {};
  formError.value = '';
  showPasswordFields.value = false;
  showUserModal.value = true;
}

async function submitUserForm() {
  formErrors.value = {};
  if (!validateUserForm()) {
    formError.value = 'Please correct the errors in the form.';
    return;
  }

  formSubmitting.value = true;
  try {
    const payload = { ...userForm.value };
    
    // Only include password fields if they're being set/changed
    if (!payload.password) {
      delete payload.password;
      delete payload.password_confirmation;
    }

    if (isEditing.value) {
      const result = await adminService.updateUser(userToEdit.value.id, payload);
      if (result) {
        showToastNotification('User updated successfully.', 'success');
      }
    } else {
      const result = await adminService.createUser(payload);
      if (result) {
        showToastNotification('User created successfully.', 'success');
      }
    }
    
    showUserModal.value = false;
    fetchUsers();
  } catch (err) {
    console.error('Error submitting user form:', err);
    formError.value = err.response?.data?.message || `Failed to ${isEditing.value ? 'update' : 'create'} user.`;
    showToastNotification(formError.value, 'error');
  } finally {
    formSubmitting.value = false;
  }
}

function validateUserForm() {
  let isValid = true;
  formErrors.value = {}; // Clear previous errors

  if (!userForm.value.name?.trim()) {
    formErrors.value.name = 'Name is required.';
    isValid = false;
  }
  
  if (!userForm.value.username?.trim()) {
    formErrors.value.username = 'Username is required.';
    isValid = false;
  }

  if (!userForm.value.email?.trim()) {
    formErrors.value.email = 'Email is required.';
    isValid = false;
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(userForm.value.email)) {
    formErrors.value.email = 'Please enter a valid email address.';
    isValid = false;
  }

  if (!userForm.value.role) {
    formErrors.value.role = 'Role is required.';
    isValid = false;
  }

  // Validate password fields if they're being set
  if (!isEditing.value || showPasswordFields.value) {
    if (!userForm.value.password && !isEditing.value) {
      formErrors.value.password = 'Password is required for new users.';
      isValid = false;
    } else if (userForm.value.password) {
      if (userForm.value.password.length < 8) {
        formErrors.value.password = 'Password must be at least 8 characters.';
        isValid = false;
      }
      if (userForm.value.password !== userForm.value.password_confirmation) {
        formErrors.value.password_confirmation = 'Passwords do not match.';
        isValid = false;
      }
    }
  }

  // If validation failed, highlight the errors by adding error states to inputs
  if (!isValid) {
    // Create a list of fields with errors to display in the alert
    const errorFields = Object.keys(formErrors.value).map(field => {
      // Convert camelCase to Title Case (e.g., 'userName' to 'User Name')
      return field.replace(/([A-Z])/g, ' $1')
                 .replace(/_/g, ' ')
                 .replace(/^./, str => str.toUpperCase());
    });
    
    // Set a more descriptive error message
    formError.value = `Please correct the following fields: ${errorFields.join(', ')}`;
  }

  return isValid;
}

function openDeleteUserModal(user) {
  if (user.id === currentUser.value.id) {
    showToastNotification("You cannot delete your own account.", 'error');
    return;
  }
  
  if (currentUser.value.role !== 'admin') {
    showToastNotification("Only administrators can delete users.", 'error');
    return;
  }
  
  if (user.role === 'admin') {
    showToastNotification("Administrators cannot be deleted.", 'error');
    return;
  }

  userToDelete.value = user;
  showDeleteModal.value = true;
}

async function confirmDeleteUser() {
  if (!userToDelete.value) return;
  
  deleteSubmitting.value = true;
  try {
    await adminService.deleteUser(userToDelete.value.id);
    showToastNotification('User deleted successfully.', 'success');
    showDeleteModal.value = false;
    fetchUsers();
    
    if (selectedUser.value?.id === userToDelete.value.id) {
      showDetailsDrawer.value = false;
      selectedUser.value = null;
    }
  } catch (err) {
    console.error('Error deleting user:', err);
    showToastNotification(err.response?.data?.message || 'Failed to delete user.', 'error');
  } finally {
    deleteSubmitting.value = false;
    userToDelete.value = null;
  }
}

async function toggleUserStatus(user) {
  if (user.id === currentUser.value.id) {
    showToastNotification("You cannot change your own status.", 'error');
    return;
  }
  if (currentUser.value.role !== 'admin' && user.role === 'admin') {
    showToastNotification("You don't have permission to change an administrator's status.", 'error');
    return;
  }

  const originalStatus = user.is_active;
  user.is_active = !user.is_active;

  try {
    await adminService.updateUser(user.id, { is_active: user.is_active });
    showToastNotification(`User status updated to ${user.is_active ? 'Active' : 'Inactive'}.`, 'success');
  } catch (err) {
    console.error('Error updating user status:', err);
    user.is_active = originalStatus;
    showToastNotification(err.response?.data?.message || 'Failed to update user status.', 'error');
  }
}

function showToastNotification(message, variant = 'success', title = '', duration = 5000) {
  const newToast = {
    id: generateId(), // Use the correct function name
    message,
    variant,
    title: title || (variant === 'error' ? 'Error' : variant === 'success' ? 'Success' : variant === 'warning' ? 'Warning' : 'Info'),
    duration
  };
  activeToasts.value.push(newToast);
}

function removeToast(toastId) {
  activeToasts.value = activeToasts.value.filter(toast => toast.id !== toastId);
}

// Lifecycle Hooks
onMounted(async () => {
  // Set initial value for totalItems to prevent undefined during initial render
  totalItems.value = 0;
  
  try {
    await fetchUsers();
  } catch (err) {
    console.error('Error during initial users fetch:', err);
    showToastNotification('Failed to load users. Please try again.', 'error');
  }
});

// Watchers
watch(filteredUsers, (newUsers) => {
  const maxPossiblePage = Math.max(1, Math.ceil(newUsers.length / itemsPerPage.value));
  if (currentPage.value > maxPossiblePage) {
    currentPage.value = maxPossiblePage;
  }
});

</script>

<style scoped>
/* Add any component-specific styles here */
.user-settings {
  padding: 1rem; 
}
</style>