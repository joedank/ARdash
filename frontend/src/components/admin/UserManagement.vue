<template>
  <div>
    <div class="flex justify-between items-center mb-6">
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
              placeholder="Search by name, email, or username"
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
          <BaseFormGroup label="Role Filter" input-id="role-filter" class="mb-0">
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

    <!-- Users Table -->
    <BaseCard variant="default" class="mb-6">
      <BaseTable
        :columns="columns"
        :data="filteredUsers"
        :loading="loading"
        :sort-key="sortConfig.key"
        :sort-order="sortConfig.order"
        @sort-change="handleSort"
        @row-click="handleRowClick"
        empty-message="No users found matching your criteria."
      >
        <!-- Name Column with Avatar -->
        <template #cell(name)="{ item }">
          <div class="flex items-center space-x-3">
            <BaseAvatar
              :initials="getInitials(item.name)"
              size="sm"
              :image="item.avatarUrl"
            />
            <span class="font-medium">{{ item.name }}</span>
          </div>
        </template>

        <!-- Role Column with Badge -->
        <template #cell(role)="{ item }">
          <BaseBadge
            :variant="getRoleBadgeVariant(item.role)"
            size="sm"
          >
            {{ item.role }}
          </BaseBadge>
        </template>

        <!-- Status Column with Toggle -->
        <template #cell(status)="{ item }">
          <BaseToggleSwitch
            :model-value="item.status === 'active'"
            @update:model-value="toggleUserStatus(item)"
          >
            <span class="ml-2 text-sm" :class="getStatusTextClass(item.status)">
              {{ item.status === 'active' ? 'Active' : 'Inactive' }}
            </span>
          </BaseToggleSwitch>
        </template>

        <!-- Actions Column -->
        <template #cell(actions)="{ item }">
          <div class="flex space-x-2">
            <button
              @click.stop="openEditUserModal(item)"
              class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
              aria-label="Edit user"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 0L11.828 15H9v-2.828l8.586-8.586z" />
              </svg>
            </button>
            <button
              @click.stop="openDeleteUserModal(item)"
              class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
              aria-label="Delete user"
              :disabled="item.role === 'admin' && item.id === currentUserId"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </div>
        </template>

        <!-- Loading state -->
        <template #loading>
          <div class="py-8">
            <BaseSkeletonLoader type="table" :rows="5" :columns="5" />
          </div>
        </template>

        <!-- Empty state -->
        <template #empty>
          <div class="py-8 text-center">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-gray-400 dark:text-gray-600 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
            <p class="text-gray-500 dark:text-gray-400">No users found matching your criteria.</p>
            <BaseButton variant="outline" size="sm" class="mt-3" @click="resetFilters">
              Reset Filters
            </BaseButton>
          </div>
        </template>

        <!-- Footer with pagination -->
        <template #footer>
          <div class="py-2">
            <BasePagination
              :current-page="currentPage"
              :total-pages="totalPages"
              :total-items="totalItems"
              :items-per-page="itemsPerPage"
              @update:current-page="handlePageChange"
            />
          </div>
        </template>
      </BaseTable>
    </BaseCard>

    <!-- Create/Edit User Modal -->
    <BaseModal
      v-model="showUserModal"
      :title="isEditing ? 'Edit User' : 'Create New User'"
      size="md"
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
          <!-- Name -->
          <BaseFormGroup
            label="Full Name"
            input-id="user-name"
            required
          >
            <BaseInput
              id="user-name"
              v-model="userForm.name"
              placeholder="Enter full name"
              required
              :error="formErrors.name"
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
              :disabled="isEditing"
              required
              :error="formErrors.username"
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
              :error="formErrors.email"
            />
          </BaseFormGroup>

          <!-- Password (only for new users) -->
          <BaseFormGroup
            v-if="!isEditing"
            label="Password"
            input-id="user-password"
            required
          >
            <BaseInput
              id="user-password"
              v-model="userForm.password"
              type="password"
              placeholder="Enter password"
              required
              :error="formErrors.password"
            />
          </BaseFormGroup>

          <!-- Confirm Password (only for new users) -->
          <BaseFormGroup
            v-if="!isEditing"
            label="Confirm Password"
            input-id="user-password-confirm"
            required
          >
            <BaseInput
              id="user-password-confirm"
              v-model="userForm.passwordConfirm"
              type="password"
              placeholder="Confirm password"
              required
              :error="formErrors.passwordConfirm"
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
              :options="roleOptions.filter(r => r.value !== 'all')"
              required
              :error="formErrors.role"
            />
          </BaseFormGroup>

          <!-- Status -->
          <BaseFormGroup
            label="Status"
            input-id="user-status"
            required
          >
            <BaseSelect
              id="user-status"
              v-model="userForm.status"
              :options="statusOptions.filter(s => s.value !== 'all')"
              required
              :error="formErrors.status"
            />
          </BaseFormGroup>
        </div>

        <div class="flex justify-end space-x-3 mt-6">
          <BaseButton
            variant="outline"
            @click="showUserModal = false"
          >
            Cancel
          </BaseButton>
          <BaseButton
            variant="primary"
            type="button"
            :loading="formSubmitting"
            @click="manualSubmit"
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
    <!-- User Details Modal -->
    <BaseModal
      v-model="showDetailsModal"
      :title="`User Details: ${selectedUser?.name || ''}`"
      size="md"
    >
      <div v-if="selectedUser" class="py-2">
        <div class="flex items-center justify-center mb-6">
          <BaseAvatar
            :initials="getInitials(selectedUser.name)"
            size="xl"
            :image="selectedUser.avatarUrl"
          />
        </div>

        <div class="grid grid-cols-1 gap-4">
          <div class="border-b border-gray-200 dark:border-gray-700 pb-3">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Full Name</p>
            <p class="text-gray-900 dark:text-white">{{ selectedUser.name }}</p>
          </div>

          <div class="border-b border-gray-200 dark:border-gray-700 pb-3">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Username</p>
            <p class="text-gray-900 dark:text-white">{{ selectedUser.username }}</p>
          </div>

          <div class="border-b border-gray-200 dark:border-gray-700 pb-3">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Email</p>
            <p class="text-gray-900 dark:text-white">{{ selectedUser.email }}</p>
          </div>

          <div class="border-b border-gray-200 dark:border-gray-700 pb-3">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Role</p>
            <div class="mt-1">
              <BaseBadge
                :variant="getRoleBadgeVariant(selectedUser.role)"
              >
                {{ selectedUser.role }}
              </BaseBadge>
            </div>
          </div>

          <div class="border-b border-gray-200 dark:border-gray-700 pb-3">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Status</p>
            <div class="mt-1">
              <BaseBadge
                :variant="selectedUser.status === 'active' ? 'success' : 'danger'"
              >
                {{ selectedUser.status === 'active' ? 'Active' : 'Inactive' }}
              </BaseBadge>
            </div>
          </div>

          <div class="pb-3">
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Created On</p>
            <p class="text-gray-900 dark:text-white">{{ formatDate(selectedUser.createdAt) }}</p>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="flex justify-between">
          <BaseButton
            variant="outline"
            @click="showDetailsModal = false"
          >
            Close
          </BaseButton>
          <div class="space-x-2">
            <BaseButton
              variant="secondary"
              @click="openEditUserModal(selectedUser); showDetailsModal = false;"
            >
              Edit User
            </BaseButton>
            <BaseButton
              variant="primary"
              :loading="resetPassSubmitting"
              @click="resetUserPassword"
            >
              Reset Password
            </BaseButton>
          </div>
        </div>
      </template>
    </BaseModal>

    <!-- Success Toast -->
    <BaseToastNotification
      v-if="showToast"
      :variant="toastVariant"
      :message="toastMessage"
      @close="showToast = false"
      position="bottom-right"
      :auto-close="3000"
      id="user-management-toast"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { useAuthStore } from '../../store/auth';
import AdminService from '../../services/admin.service';

// Components
import BaseCard from '../../components/data-display/BaseCard.vue';
import BaseButton from '../../components/base/BaseButton.vue';
import BaseTable from '../../components/data-display/BaseTable.vue';
import BaseBadge from '../../components/data-display/BaseBadge.vue';
import BaseAvatar from '../../components/data-display/BaseAvatar.vue';
import BaseAlert from '../../components/feedback/BaseAlert.vue';
import BaseFormGroup from '../../components/form/BaseFormGroup.vue';
import BaseInput from '../../components/form/BaseInput.vue';
import BaseSelect from '../../components/form/BaseSelect.vue';
import BaseToggleSwitch from '../../components/form/BaseToggleSwitch.vue';
import BaseModal from '../../components/overlays/BaseModal.vue';
import BasePagination from '../../components/navigation/BasePagination.vue';
import BaseSkeletonLoader from '../../components/data-display/BaseSkeletonLoader.vue';
import BaseToastNotification from '../../components/feedback/BaseToastNotification.vue';

// Get the current logged in user
const authStore = useAuthStore();
const currentUserId = computed(() => authStore.user?.id);

// State management
const users = ref([]);
const loading = ref(true);
const searchQuery = ref('');
const roleFilter = ref('all');
const statusFilter = ref('all');
const sortConfig = reactive({
  key: 'name',
  order: 'asc'
});

// Pagination
const currentPage = ref(1);
const totalPages = ref(1);
const totalItems = ref(0);
const itemsPerPage = ref(10);

// User form
const showUserModal = ref(false);
const isEditing = ref(false);
const formSubmitting = ref(false);
const formError = ref('');
const formErrors = reactive({
  name: '',
  username: '',
  email: '',
  password: '',
  passwordConfirm: '',
  role: '',
  status: ''
});

const userForm = reactive({
  id: null,
  name: '',
  username: '',
  email: '',
  password: '',
  passwordConfirm: '',
  role: 'user',
  status: 'active'
});

// User deletion
const showDeleteModal = ref(false);
const userToDelete = ref(null);
const deleteSubmitting = ref(false);

// User details
const showDetailsModal = ref(false);
const selectedUser = ref(null);
const resetPassSubmitting = ref(false);

// Toast notification
const showToast = ref(false);
const toastMessage = ref('');
const toastVariant = ref('success');

// Table columns
const columns = [
  { key: 'name', label: 'Name', sortable: true },
  { key: 'username', label: 'Username', sortable: true },
  { key: 'email', label: 'Email', sortable: true },
  { key: 'role', label: 'Role', sortable: false },
  { key: 'status', label: 'Status', sortable: false },
  { key: 'actions', label: 'Actions', sortable: false }
];

// Options for filters and forms
const roleOptions = [
  { value: 'all', label: 'All Roles' },
  { value: 'admin', label: 'Admin' },
  { value: 'user', label: 'User' }
];

const statusOptions = [
  { value: 'all', label: 'All Statuses' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' }
];

// Fetch users on component mount
onMounted(async () => {
  await fetchUsers();
});

// Computed filtered users
const filteredUsers = computed(() => {
  return users.value;
});

// Fetch users from the API
async function fetchUsers() {
  loading.value = true;

  try {
    const response = await AdminService.getUsers({
      page: currentPage.value,
      limit: itemsPerPage.value,
      search: searchQuery.value,
      role: roleFilter.value,
      status: statusFilter.value,
      sortKey: sortConfig.key,
      sortOrder: sortConfig.order
    });

    users.value = response.data.users;
    totalItems.value = response.data.pagination.totalItems;
    totalPages.value = response.data.pagination.totalPages;
    currentPage.value = response.data.pagination.currentPage;
  } catch (error) {
    showToast.value = true;
    toastMessage.value = error.message || 'Error fetching users';
    toastVariant.value = 'error';
  } finally {
    loading.value = false;
  }
}

// Open the create user modal
function openCreateUserModal() {
  console.log('Opening create user modal');
  isEditing.value = false;

  // Explicitly reset form data with default values
  userForm.id = null;
  userForm.name = '';
  userForm.username = '';
  userForm.email = '';
  userForm.password = '';
  userForm.passwordConfirm = '';
  userForm.role = 'user';
  userForm.status = 'active';

  // Reset errors
  Object.keys(formErrors).forEach(key => formErrors[key] = '');
  formError.value = '';

  // Log the form state after reset
  console.log('Form reset to:', { ...userForm });

  // Open the modal
  showUserModal.value = true;
}

// Open the edit user modal
function openEditUserModal(user) {
  isEditing.value = true;

  // Set form data from user
  Object.keys(userForm).forEach(key => {
    if (key !== 'password' && key !== 'passwordConfirm') {
      userForm[key] = user[key];
    } else {
      userForm[key] = '';
    }
  });

  // Reset errors
  Object.keys(formErrors).forEach(key => formErrors[key] = '');
  formError.value = '';

  showUserModal.value = true;
}

// Submit the user form
async function submitUserForm() {
  console.log('Submit user form called');
  // Validate form
  if (!validateForm()) {
    console.log('Form validation failed');
    return;
  }

  formSubmitting.value = true;
  formError.value = ''; // Clear previous errors

  try {
    if (isEditing.value) {
      // Update existing user
      console.log('Updating user:', userForm.id);
      const response = await AdminService.updateUser(userForm.id, {
        name: userForm.name,
        email: userForm.email,
        role: userForm.role,
        status: userForm.status
      });

      // Update user in the list
      const userIndex = users.value.findIndex(u => u.id === userForm.id);
      if (userIndex !== -1) {
        users.value[userIndex] = { ...users.value[userIndex], ...userForm };
      }

      // Close modal first
      showUserModal.value = false;
      
      // Then show success notification
      showToast.value = true;
      toastMessage.value = 'User updated successfully';
      toastVariant.value = 'success';
    } else {
      // Create new user
      console.log('Creating new user with data:', {
        name: userForm.name,
        username: userForm.username,
        email: userForm.email,
        password: userForm.password,
        role: userForm.role,
        status: userForm.status
      });
      
      try {
        const userData = {
          name: userForm.name,
          username: userForm.username,
          email: userForm.email,
          password: userForm.password,
          role: userForm.role,
          status: userForm.status
        };
        
        console.log('Sending user data to API:', userData);
        const response = await AdminService.createUser(userData);
        
        console.log('User creation response:', response);

        // Close the modal first, then show success
        showUserModal.value = false;
        
        // Show success message
        showToast.value = true;
        toastMessage.value = 'User created successfully';
        toastVariant.value = 'success';
        
        // Refresh the user list after a short delay
        setTimeout(() => {
          fetchUsers();
        }, 300); // Increased delay to ensure modal is fully closed
      } catch (error) {
        // Handle creation errors
        console.error('Error creating user:', error);
        formError.value = error.response?.data?.message || error.message || 'Error creating user';
        showToast.value = true;
        toastMessage.value = formError.value;
        toastVariant.value = 'error';
        return;
      }
    }
  } catch (error) {
    console.error('Form submission error:', error);
    formError.value = error.response?.data?.message || error.message || 'Error saving user';
    showToast.value = true;
    toastMessage.value = formError.value;
    toastVariant.value = 'error';
  } finally {
    formSubmitting.value = false;
  }
}

// Validate the user form
function validateForm() {
  let isValid = true;

  // Reset errors
  Object.keys(formErrors).forEach(key => formErrors[key] = '');
  formError.value = '';

  console.log('Validating form with data:', { ...userForm });

  // Validate name
  if (!userForm.name || !userForm.name.trim()) {
    formErrors.name = 'Name is required';
    console.log('Name validation failed');
    isValid = false;
  }

  // Validate username
  if (!userForm.username || !userForm.username.trim()) {
    formErrors.username = 'Username is required';
    console.log('Username validation failed: empty');
    isValid = false;
  } else if (!/^[a-zA-Z0-9_]{3,}$/.test(userForm.username)) {
    formErrors.username = 'Username must be at least 3 characters and contain only letters, numbers, and underscores';
    console.log('Username validation failed: format');
    isValid = false;
  }

  // Validate email
  if (!userForm.email || !userForm.email.trim()) {
    formErrors.email = 'Email is required';
    console.log('Email validation failed: empty');
    isValid = false;
  } else if (!/\S+@\S+\.\S+/.test(userForm.email)) {
    formErrors.email = 'Invalid email format';
    console.log('Email validation failed: format');
    isValid = false;
  }

  // Validate password for new users
  if (!isEditing.value) {
    if (!userForm.password) {
      formErrors.password = 'Password is required';
      console.log('Password validation failed: empty');
      isValid = false;
    } else if (userForm.password.length < 8) {
      formErrors.password = 'Password must be at least 8 characters';
      console.log('Password validation failed: too short');
      isValid = false;
    }

    // Validate password confirmation
    if (userForm.password !== userForm.passwordConfirm) {
      formErrors.passwordConfirm = 'Passwords do not match';
      console.log('Password confirmation validation failed');
      isValid = false;
    }
  }

  // Validate role
  if (!userForm.role) {
    formErrors.role = 'Role is required';
    console.log('Role validation failed');
    isValid = false;
  }

  // Validate status
  if (!userForm.status) {
    formErrors.status = 'Status is required';
    console.log('Status validation failed');
    isValid = false;
  }

  if (!isValid) {
    console.log('Form validation errors:', formErrors);
    // Set a global form error message
    formError.value = 'Please fix the errors in the form before submitting.';
  } else {
    console.log('Form validation passed');
  }

  return isValid;
}

// Open the delete user modal
function openDeleteUserModal(user) {
  userToDelete.value = user;
  showDeleteModal.value = true;
}

// Confirm user deletion
async function confirmDeleteUser() {
  if (!userToDelete.value) return;

  deleteSubmitting.value = true;

  try {
    await AdminService.deleteUser(userToDelete.value.id);

    // Remove user from the list
    users.value = users.value.filter(u => u.id !== userToDelete.value.id);

    // Update totals
    totalItems.value -= 1;
    totalPages.value = Math.ceil(totalItems.value / itemsPerPage.value);

    showToast.value = true;
    toastMessage.value = 'User deleted successfully';
    toastVariant.value = 'success';
    showDeleteModal.value = false;
  } catch (error) {
    showToast.value = true;
    toastMessage.value = error.message || 'Error deleting user';
    toastVariant.value = 'error';
  } finally {
    deleteSubmitting.value = false;
  }
}

// Toggle user status
async function toggleUserStatus(user) {
  try {
    const newStatus = user.status === 'active' ? 'inactive' : 'active';
    
    await AdminService.updateUser(user.id, {
      ...user,
      status: newStatus
    });

    // Update user in the list
    const userIndex = users.value.findIndex(u => u.id === user.id);
    if (userIndex !== -1) {
      users.value[userIndex].status = newStatus;
    }

    showToast.value = true;
    toastMessage.value = `User status updated to ${newStatus}`;
    toastVariant.value = 'success';
  } catch (error) {
    showToast.value = true;
    toastMessage.value = error.message || 'Error updating user status';
    toastVariant.value = 'error';
  }
}

// Format date
function formatDate(dateString) {
  const date = new Date(dateString);
  const options = { year: 'numeric', month: 'long', day: 'numeric' };
  return date.toLocaleDateString(undefined, options);
}

// Get initials from name
function getInitials(name) {
  if (!name) return '';
  const nameParts = name.split(' ');
  let initials = '';
  for (let i = 0; i < Math.min(nameParts.length, 2); i++) {
    if (nameParts[i].length > 0) {
      initials += nameParts[i].charAt(0).toUpperCase();
    }
  }
  return initials;
}

// Get role badge variant
function getRoleBadgeVariant(role) {
  switch (role) {
    case 'admin':
      return 'danger';
    case 'user':
      return 'primary';
    default:
      return 'secondary';
  }
}

// Get status text class
function getStatusTextClass(status) {
  switch (status) {
    case 'active':
      return 'text-green-500 dark:text-green-400';
    case 'inactive':
      return 'text-red-500 dark:text-red-400';
    default:
      return 'text-gray-500 dark:text-gray-400';
  }
}

// Reset filters
function resetFilters() {
  searchQuery.value = '';
  roleFilter.value = 'all';
  statusFilter.value = 'all';
  currentPage.value = 1;
  fetchUsers();
}

// Handle search
function handleSearch() {
  currentPage.value = 1;
  fetchUsers();
}

// Handle filter
function handleFilter() {
  currentPage.value = 1;
  fetchUsers();
}

// Handle sort
function handleSort(key, order) {
  sortConfig.key = key;
  sortConfig.order = order;
  fetchUsers();
}

// Handle page change
function handlePageChange(page) {
  currentPage.value = page;
  fetchUsers();
}

// Open user details modal
function handleRowClick(item) {
  selectedUser.value = item;
  showDetailsModal.value = true;
}

// Manual submit handler for direct button clicks
function manualSubmit(event) {
  // Prevent default form submission
  event.preventDefault();
  event.stopPropagation(); // Explicitly stop event propagation
  console.log('Manual submit triggered');
  
  // Add additional debugging
  console.log('Form data:', { ...userForm });
  
  // Call the main submission handler directly
  submitUserForm();
}

// Reset user password
async function resetUserPassword() {
  if (!selectedUser.value) return;

  resetPassSubmitting.value = true;

  try {
    await AdminService.resetUserPassword(selectedUser.value.id);

    showToast.value = true;
    toastMessage.value = 'Password reset successfully';
    toastVariant.value = 'success';
  } catch (error) {
    showToast.value = true;
    toastMessage.value = error.message || 'Error resetting password';
    toastVariant.value = 'error';
  } finally {
    resetPassSubmitting.value = false;
  }
}
</script>

<style scoped>
/* Add any component-specific styles here */
</style>
