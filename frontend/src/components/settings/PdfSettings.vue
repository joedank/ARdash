<template>
  <div class="pdf-settings">
    <h2 class="text-lg font-medium mb-4 text-gray-900 dark:text-white">PDF Settings</h2>
    
    <form @submit.prevent="saveSettings">
      <div class="space-y-6">
        <!-- Company Information -->
        <div>
          <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">Company Information</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label for="company_name" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Company Name
              </label>
              <input
                type="text"
                id="company_name"
                v-model="settings.company_name"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="Your Company Name"
              />
            </div>
            <div>
              <label for="company_address" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Company Address
              </label>
              <input
                type="text"
                id="company_address"
                v-model="settings.company_address"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="123 Business St, City, State 12345"
              />
            </div>
            <div>
              <label for="company_phone" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Phone Number
              </label>
              <input
                type="text"
                id="company_phone"
                v-model="settings.company_phone"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="(555) 123-4567"
              />
            </div>
            <div>
              <label for="company_email" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Email Address
              </label>
              <input
                type="email"
                id="company_email"
                v-model="settings.company_email"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="info@yourcompany.com"
              />
            </div>
            <div>
              <label for="company_website" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Website
              </label>
              <input
                type="text"
                id="company_website"
                v-model="settings.company_website"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="www.yourcompany.com"
              />
            </div>
            <div>
              <label for="company_logo" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Company Logo
              </label>
              <div class="flex items-start space-x-3">
                <div>
                  <input
                    type="file"
                    id="company_logo"
                    ref="logoInput"
                    @change="handleLogoUpload"
                    accept="image/*"
                    class="hidden"
                  />
                  <div class="flex items-center">
                    <button
                      type="button"
                      @click="$refs.logoInput.click()"
                      class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                    >
                      Upload Logo
                    </button>
                    <span v-if="uploadStatus" class="ml-2 text-sm" :class="uploadStatus.type === 'success' ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'">
                      {{ uploadStatus.message }}
                    </span>
                  </div>
                </div>
                <div v-if="logoPreview" class="mt-1">
                  <img :src="logoPreview" alt="Company Logo Preview" class="h-16 w-auto object-contain" />
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- PDF Appearance -->
        <div>
          <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">PDF Appearance</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Primary Color -->
            <div>
              <label for="primary_color" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Primary Color
              </label>
              <div class="flex items-center gap-2">
                <ColorPicker
                  v-model="settings.primary_color"
                  format="hex"
                  defaultColor="#3b82f6"
                  inputId="primary_color"
                  @change="(e) => handleColorChange(e.value, 'primary_color')"
                />
                <span class="text-sm text-gray-600 dark:text-gray-400">{{ settings.primary_color }}</span>
              </div>
            </div>
            
            <!-- Secondary Color -->
            <div>
              <label for="pdf_secondary_color" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Secondary Color
              </label>
              <div class="flex items-center gap-2">
                <ColorPicker
                  v-model="settings.pdf_secondary_color"
                  format="hex"
                  defaultColor="#64748b"
                  inputId="pdf_secondary_color"
                  @change="(e) => handleColorChange(e.value, 'pdf_secondary_color')"
                />
                <span class="text-sm text-gray-600 dark:text-gray-400">{{ settings.pdf_secondary_color }}</span>
              </div>
            </div>

            <!-- Background Color -->
            <div>
              <label for="pdf_background_color" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Background Color
              </label>
              <div class="flex items-center gap-2">
                <ColorPicker
                  v-model="settings.pdf_background_color"
                  format="hex"
                  defaultColor="#f8f9fa"
                  inputId="pdf_background_color"
                  @change="(e) => handleColorChange(e.value, 'pdf_background_color')"
                />
                <span class="text-sm text-gray-600 dark:text-gray-400">{{ settings.pdf_background_color }}</span>
              </div>
            </div>

            <!-- Table Border Color -->
            <div>
              <label for="pdf_table_border_color" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Table Border Color
              </label>
              <div class="flex items-center gap-2">
                <ColorPicker
                  v-model="settings.pdf_table_border_color"
                  format="hex"
                  defaultColor="#e2e8f0"
                  inputId="pdf_table_border_color"
                  @change="(e) => handleColorChange(e.value, 'pdf_table_border_color')"
                />
                <span class="text-sm text-gray-600 dark:text-gray-400">{{ settings.pdf_table_border_color }}</span>
              </div>
            </div>

            <!-- Page Margin -->
            <div>
              <label for="pdf_page_margin" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Page Margin (points)
              </label>
              <input
                type="number"
                id="pdf_page_margin"
                v-model="settings.pdf_page_margin"
                min="0"
                max="100"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="50"
              />
            </div>

            <!-- Watermark Text -->
            <div class="md:col-span-2">
              <label for="pdf_watermark_text" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Watermark Text (optional)
              </label>
              <input
                type="text"
                id="pdf_watermark_text"
                v-model="settings.pdf_watermark_text"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="Leave empty for no watermark"
              />
            </div>
          </div>
        </div>
        
        <!-- Invoice Settings -->
        <div>
          <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">Invoice Settings</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label for="invoice_prefix" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Invoice Number Prefix
              </label>
              <input
                type="text"
                id="invoice_prefix"
                v-model="settings.invoice_prefix"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="INV-"
              />
            </div>
            <div>
              <label for="invoice_due_days" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Default Due Days
              </label>
              <input
                type="number"
                id="invoice_due_days"
                v-model="settings.invoice_due_days"
                min="1"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="30"
              />
            </div>
            <div class="md:col-span-2">
              <label for="default_invoice_terms" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Default Invoice Terms
              </label>
              <textarea
                id="default_invoice_terms"
                v-model="settings.default_invoice_terms"
                rows="3"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="Payment is due within {due_days} days from the date of invoice."
              ></textarea>
              <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                Use <code>{due_days}</code> as a placeholder for the due days value.
              </p>
            </div>
            <div class="md:col-span-2">
              <label for="pdf_invoice_footer" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                PDF Footer Text
              </label>
              <textarea
                id="pdf_invoice_footer"
                v-model="settings.pdf_invoice_footer"
                rows="2"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="Thank you for your business."
              ></textarea>
            </div>
          </div>
        </div>
        
        <!-- Estimate Settings -->
        <div>
          <h3 class="text-base font-medium text-gray-900 dark:text-white mb-3">Estimate Settings</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label for="estimate_prefix" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Estimate Number Prefix
              </label>
              <input
                type="text"
                id="estimate_prefix"
                v-model="settings.estimate_prefix"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="EST-"
              />
            </div>
            <div>
              <label for="estimate_valid_days" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Default Valid Days
              </label>
              <input
                type="number"
                id="estimate_valid_days"
                v-model="settings.estimate_valid_days"
                min="1"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="30"
              />
            </div>
            <div class="md:col-span-2">
              <label for="default_estimate_terms" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Default Estimate Terms
              </label>
              <textarea
                id="default_estimate_terms"
                v-model="settings.default_estimate_terms"
                rows="3"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="This estimate is valid for {valid_days} days from the date issued."
              ></textarea>
              <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                Use <code>{valid_days}</code> as a placeholder for the valid days value.
              </p>
            </div>
            <div class="md:col-span-2">
              <label for="pdf_estimate_footer" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                PDF Footer Text
              </label>
              <textarea
                id="pdf_estimate_footer"
                v-model="settings.pdf_estimate_footer"
                rows="2"
                class="w-full rounded-md border-gray-300 dark:border-gray-700 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50 dark:bg-gray-800 dark:text-white"
                placeholder="Thank you for considering our services."
              ></textarea>
            </div>
          </div>
        </div>
        
        <!-- Save Button -->
        <div class="pt-5">
          <div class="flex justify-end">
            <button
              type="submit"
              :disabled="isSaving"
              class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <span v-if="isSaving" class="flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
                Saving...
              </span>
              <span v-else>Save Settings</span>
            </button>
          </div>
          <div v-if="saveStatus" class="mt-3 text-right">
            <div 
              class="inline-block px-3 py-1 rounded-md text-sm" 
              :class="saveStatus.type === 'success' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'"
            >
              {{ saveStatus.message }}
            </div>
          </div>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import ColorPicker from 'primevue/colorpicker';
import settingsService from '@/services/settings.service';
import apiService from '@/services/api.service';
import { BACKEND_URL } from '@/config';

// State
const settings = ref({
  // Company Info
  company_name: '',
  company_address: '',
  company_phone: '',
  company_email: '',
  company_website: '',
  company_logo_path: '',
  
  // PDF Appearance
  primary_color: '#3b82f6',
  pdf_secondary_color: '#64748b',
  pdf_background_color: '#f8f9fa',
  pdf_table_border_color: '#e2e8f0',
  pdf_page_margin: '50',
  pdf_header_margin: '30',
  pdf_footer_margin: '30',
  pdf_watermark_text: '',
  
  // Invoice Settings
  invoice_prefix: 'INV-',
  invoice_due_days: '30',
  default_invoice_terms: 'Payment is due within {due_days} days from the date of invoice. Late payments are subject to a 1.5% monthly fee.',
  pdf_invoice_footer: 'Thank you for your business. Please contact us with any questions regarding this invoice.',
  
  // Estimate Settings
  estimate_prefix: 'EST-',
  estimate_valid_days: '30',
  default_estimate_terms: 'This estimate is valid for {valid_days} days from the date issued. To accept this estimate, please sign and return.',
  pdf_estimate_footer: 'Thank you for considering our services. Please contact us with any questions regarding this estimate.'
});

// Logo upload state
const logoInput = ref(null);
const logoPreview = ref('');
const uploadStatus = ref(null);

// Form state
const isSaving = ref(false);
const saveStatus = ref(null);

// Load settings on component mount
onMounted(async () => {
  try {
    const response = await settingsService.getAllSettings();
    
    if (response && response.success && response.data) {
      // Populate settings from response
      for (const setting of response.data) {
        if (setting.key in settings.value) {
          settings.value[setting.key] = setting.value;
        }
      }
      
      // Set logo preview if available
      if (settings.value.company_logo_path) {
        logoPreview.value = `${BACKEND_URL}/uploads/logos/${settings.value.company_logo_path}`;
      }
    }
  } catch (err) {
    console.error('Error loading settings:', err);
  }
});

// Handle logo upload
const handleLogoUpload = async (event) => {
  try {
    uploadStatus.value = null;
    
    const file = event.target.files[0];
    if (!file) return;
    
    // Check file type
    if (!file.type.startsWith('image/')) {
      uploadStatus.value = {
        type: 'error',
        message: 'Only image files are allowed'
      };
      return;
    }
    
    // Check file size (max 2MB)
    const maxSize = 2 * 1024 * 1024;
    if (file.size > maxSize) {
      uploadStatus.value = {
        type: 'error',
        message: 'File size exceeds the limit (2MB)'
      };
      return;
    }
    
    // Create FormData
    const formData = new FormData();
    formData.append('logo', file);
    
    // Upload logo
    const response = await apiService.post('/upload/logo', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
    
    if (response && response.success && response.data) {
      // Update logo preview with full backend URL
      logoPreview.value = `${BACKEND_URL}${response.data.path}`;
      settings.value.company_logo_path = response.data.filename;
      
      uploadStatus.value = {
        type: 'success',
        message: 'Logo uploaded successfully'
      };
    } else {
      uploadStatus.value = {
        type: 'error',
        message: response?.message || 'Failed to upload logo'
      };
    }
  } catch (err) {
    console.error('Error uploading logo:', err);
    uploadStatus.value = {
      type: 'error',
      message: err.message || 'An unexpected error occurred'
    };
  } finally {
    // Reset file input
    if (logoInput.value) {
      logoInput.value.value = '';
    }
  }
};

// Validate and normalize hex color code
const isValidHexColor = (color) => {
  return /^#[0-9A-F]{6}$/i.test(color);
};

// Format and normalize color to valid hex with # prefix
const normalizeHexColor = (color) => {
  if (!color) return '#000000'; // Default to black if empty
  
  // If color already has # prefix and is valid format
  if (isValidHexColor(color)) return color;
  
  // If color has # prefix but might be in short form (#RGB)
  if (color.startsWith('#')) {
    // Convert #RGB to #RRGGBB
    if (/^#[0-9A-F]{3}$/i.test(color)) {
      return `#${color[1]}${color[1]}${color[2]}${color[2]}${color[3]}${color[3]}`;
    }
    // If it has # but invalid format, return default
    return '#000000';
  }
  
  // If color doesn't have # prefix, add it
  if (/^[0-9A-F]{6}$/i.test(color)) {
    return `#${color}`;
  }
  
  // For any other invalid format, return default
  return '#000000';
};

// Handle color change from the ColorPicker
const handleColorChange = (color, fieldName) => {
  settings.value[fieldName] = normalizeHexColor(color);
};

// Save settings
const saveSettings = async () => {
  try {
    isSaving.value = true;
    saveStatus.value = null;

    // Validate and normalize color values
    const colorFields = ['primary_color', 'pdf_secondary_color', 'pdf_background_color', 'pdf_table_border_color'];
    for (const field of colorFields) {
      // Normalize color format before validation
      settings.value[field] = normalizeHexColor(settings.value[field]);
      
      // Verify it's valid after normalization
      if (!isValidHexColor(settings.value[field])) {
        throw new Error(`Invalid color format for ${field}. Please use a valid hex color (e.g., #C0CBDA)`);
      }
    }
    
    // Prepare settings for API
    const updatedSettings = {};
    Object.entries(settings.value).forEach(([key, value]) => {
      updatedSettings[key] = value;
    });
    
    // Group settings by type
    const groups = {
      company: [
        'company_name',
        'company_address',
        'company_phone',
        'company_email',
        'company_website',
        'company_logo_path'
      ],
      appearance: [
        'primary_color',
        'pdf_secondary_color',
        'pdf_background_color',
        'pdf_table_border_color',
        'pdf_page_margin',
        'pdf_header_margin',
        'pdf_footer_margin',
        'pdf_watermark_text'
      ],
      invoice: [
        'invoice_prefix',
        'invoice_due_days',
        'default_invoice_terms',
        'pdf_invoice_footer'
      ],
      estimate: [
        'estimate_prefix',
        'estimate_valid_days',
        'default_estimate_terms',
        'pdf_estimate_footer'
      ]
    };
    
    // Save settings by group
    for (const [group, keys] of Object.entries(groups)) {
      const groupSettings = {};
      keys.forEach(key => {
        groupSettings[key] = settings.value[key];
      });
      
      await settingsService.updateMultipleSettings(groupSettings, group);
    }
    
    saveStatus.value = {
      type: 'success',
      message: 'Settings saved successfully'
    };
    
    // Clear status after 3 seconds
    setTimeout(() => {
      saveStatus.value = null;
    }, 3000);
  } catch (err) {
    console.error('Error saving settings:', err);
    saveStatus.value = {
      type: 'error',
      message: err.message || 'Failed to save settings'
    };
  } finally {
    isSaving.value = false;
  }
};
</script>

<style>
/* Basic z-index styles for potential overlay issues */
.pdf-settings .color-setting-group {
  position: relative;
}

/* Add dark mode support for better contrast */
@media (prefers-color-scheme: dark) {
  .p-colorpicker-panel {
    background-color: #1e293b !important;
    border-color: #475569 !important;
  }
  
  .p-colorpicker-color-handle,
  .p-colorpicker-hue-handle {
    border-color: #fff !important;
  }
}
</style>
