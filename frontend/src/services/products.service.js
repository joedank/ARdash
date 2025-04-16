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
}

export default new ProductsService();
