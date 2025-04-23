import apiService from './api.service';

/**
 * Service for handling product/service catalog
 */
class ProductsService {
  /**
   * List products with optional filters
   * @param {Object} filters - Query filters (type, isActive, search)
   * @returns {Promise} Response data with products array
   */
  async listProducts(filters = {}) {
    const queryParams = new URLSearchParams();

    // Add filters to query params
    if (filters.type) queryParams.append('type', filters.type);
    if (filters.isActive !== undefined) queryParams.append('isActive', filters.isActive);
    if (filters.search) queryParams.append('search', filters.search);

    return apiService.get(`/api/products?${queryParams.toString()}`);
  }

  /**
   * Create a new product
   * @param {Object} productData - Product data
   * @returns {Promise} Response data with created product
   */
  async createProduct(productData) {
    return apiService.post('/api/products', productData);
  }

  /**
   * Get product details
   * @param {string} id - Product ID
   * @returns {Promise} Response data with product details
   */
  async getProduct(id) {
    return apiService.get(`/api/products/${id}`);
  }

  /**
   * Update a product
   * @param {string} id - Product ID
   * @param {Object} productData - Updated product data
   * @returns {Promise} Response data with updated product
   */
  async updateProduct(id, productData) {
    return apiService.put(`/api/products/${id}`, productData);
  }

  /**
   * Delete a product
   * @param {string} id - Product ID
   * @returns {Promise} Response data
   */
  async deleteProduct(id) {
    return apiService.delete(`/api/products/${id}`);
  }

  /**
   * Create multiple products in bulk
   * @param {Array} productsData - Array of product data objects
   * @returns {Promise} Response with created products
   */
  async createBulkProducts(productsData) {
    try {
      if (!Array.isArray(productsData) || productsData.length === 0) {
        return {
          success: false,
          message: 'Products data must be a non-empty array'
        };
      }

      console.log(`Creating ${productsData.length} products in bulk`);
      
      // Create products one by one to ensure proper error handling
      const results = await Promise.all(
        productsData.map(async (productData) => {
          try {
            const response = await this.createProduct(productData);
            return { success: true, data: response.data };
          } catch (error) {
            console.error(`Error creating product ${productData.name}:`, error);
            return { 
              success: false, 
              error, 
              productData,
              message: error.response?.data?.message || error.message 
            };
          }
        })
      );

      // Count successes and failures
      const successCount = results.filter(result => result.success).length;
      const failureCount = results.length - successCount;

      // If all failed, return error
      if (successCount === 0) {
        return {
          success: false,
          message: `Failed to create any products. All ${failureCount} operations failed.`,
          results
        };
      }

      // If some failed, return partial success
      if (failureCount > 0) {
        return {
          success: true,
          message: `Created ${successCount} products, but ${failureCount} failed.`,
          results
        };
      }

      // All succeeded
      return {
        success: true,
        message: `Successfully created ${successCount} products`,
        results
      };
    } catch (error) {
      console.error('Error in bulk product creation:', error);
      return {
        success: false,
        message: error.message || 'An unexpected error occurred during bulk product creation',
        error
      };
    }
  }
  
  /**
   * Get product details by ID
   * @param {string} id - Product ID
   * @returns {Promise} Response with standardized format
   */
  async getProductById(id) {
    try {
      const response = await this.getProduct(id);
      return {
        success: true,
        data: response.data,
        message: 'Product retrieved successfully'
      };
    } catch (error) {
      console.error(`Error getting product ${id}:`, error);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get product',
        error
      };
    }
  }
}

export default new ProductsService();
