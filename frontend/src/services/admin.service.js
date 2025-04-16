import api from './api.service';

class AdminService {
  async getUsers(params) {
    return await api.get('/api/admin/users', { params });
  }

  async createUser(data) {
    console.log('AdminService.createUser called with data:', data);
    try {
      // Make sure we're hitting the correct endpoint
      const response = await api.post('/api/admin/users', data);
      console.log('AdminService.createUser response:', response);
      return response;
    } catch (error) {
      console.error('AdminService.createUser error:', error);
      // Log more detailed error information
      if (error.response) {
        console.error('Error response data:', error.response.data);
        console.error('Error response status:', error.response.status);
      } else if (error.request) {
        console.error('Error request:', error.request);
      }
      throw error;
    }
  }

  async updateUser(id, data) {
    return await api.put(`/api/admin/users/${id}`, data);
  }

  async deleteUser(id) {
    return await api.delete(`/api/admin/users/${id}`);
  }
}

export default new AdminService();
