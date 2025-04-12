const { User } = require('../models');
const { Op } = require('sequelize');

// Get all users with pagination, sorting, and filtering
exports.getUsers = async (req, res) => {
  try {
    const { page = 1, limit = 10, search = '', role = 'all', status = 'all', sortKey = 'name', sortOrder = 'asc' } = req.query;

    const offset = (page - 1) * limit;

    const where = {};
    if (search) {
      // Search across username, email, firstName, or lastName
      where[Op.or] = [
        { username: { [Op.iLike]: `%${search}%` } },
        { email: { [Op.iLike]: `%${search}%` } },
        { firstName: { [Op.iLike]: `%${search}%` } },
        { lastName: { [Op.iLike]: `%${search}%` } }
      ];
    }
    if (role !== 'all') {
      where.role = role;
    }
    if (status !== 'all') {
      // Map status to isActive field
      where.isActive = status === 'active' ? true : false;
    }

    // Map sortKey to actual database fields
    let orderField = sortKey;
    if (sortKey === 'name') {
      orderField = 'username'; // Default to username if sorting by name
    }
    
    const order = [[orderField, sortOrder]];

    const { count, rows } = await User.findAndCountAll({
      where,
      offset,
      limit,
      order
    });

    // Format user data to match frontend expectations
    const formattedUsers = rows.map(user => ({
      id: user.id,
      name: `${user.firstName || ''} ${user.lastName || ''}`.trim() || user.username,
      username: user.username,
      email: user.email,
      role: user.role,
      is_active: user.isActive, // Match frontend field name expectations
      created_at: user.createdAt, // Include both formats for compatibility
      createdAt: user.createdAt
    }));

    // Return response in format expected by frontend (users at the top level)
    res.json({
      success: true,
      users: formattedUsers, // Move users to the top level as expected by frontend
      pagination: {
        totalItems: count,
        totalPages: Math.ceil(count / limit),
        currentPage: parseInt(page)
      },
      message: 'Users fetched successfully'
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error fetching users',
      error: error.message 
    });
  }
};

// Create a new user
exports.createUser = async (req, res) => {
  try {
    // Transform the name field into firstName and lastName
    const userData = { ...req.body };
    
    if (userData.name) {
      // Split the name into first and last name
      const nameParts = userData.name.split(' ');
      userData.firstName = nameParts[0] || '';
      userData.lastName = nameParts.slice(1).join(' ') || '';
      
      // Set the username field to handle the notNull constraint
      // If email exists, use the part before @ as username, otherwise use the name
      if (!userData.username) {
        if (userData.email) {
          userData.username = userData.email.split('@')[0];
        } else {
          userData.username = userData.name.replace(/\s+/g, '_').toLowerCase();
        }
      }
      
      // Remove the original name field as it's not in the model
      delete userData.name;
    }
    
    // Map is_active to isActive for model compatibility
    if (userData.is_active !== undefined) {
      userData.isActive = !!userData.is_active;
      delete userData.is_active;
    } else if (userData.status) {
      userData.isActive = userData.status === 'active';
      delete userData.status;
    }
    
    console.log('Creating user with data:', userData);
    const user = await User.create(userData);
    
    // Format the response to match frontend expectations
    const formattedUser = {
      id: user.id,
      name: `${user.firstName || ''} ${user.lastName || ''}`.trim() || user.username,
      username: user.username,
      email: user.email,
      role: user.role,
      is_active: user.isActive,
      created_at: user.createdAt
    };
    
    res.status(201).json({ 
      success: true,
      message: 'User created successfully', 
      user: formattedUser // Return user at top level for consistency
    });
  } catch (error) {
    console.error('User creation error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error creating user', 
      error: error.message 
    });
  }
};

// Update an existing user
exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const userData = { ...req.body };
    
    // Map name to firstName and lastName if provided
    if (userData.name) {
      const nameParts = userData.name.split(' ');
      userData.firstName = nameParts[0] || '';
      userData.lastName = nameParts.slice(1).join(' ') || '';
      delete userData.name;
    }
    
    // Map is_active to isActive for model compatibility
    if (userData.is_active !== undefined) {
      userData.isActive = !!userData.is_active;
      delete userData.is_active;
    }
    
    // Update user in database
    const [updated] = await User.update(userData, { 
      where: { id },
      returning: true
    });

    if (updated) {
      const updatedUser = await User.findByPk(id);
      
      // Format for frontend
      const formattedUser = {
        id: updatedUser.id,
        name: `${updatedUser.firstName || ''} ${updatedUser.lastName || ''}`.trim() || updatedUser.username,
        username: updatedUser.username,
        email: updatedUser.email,
        role: updatedUser.role,
        is_active: updatedUser.isActive,
        created_at: updatedUser.createdAt
      };
      
      return res.json({ 
        success: true,
        message: 'User updated successfully', 
        user: formattedUser // Return user at top level
      });
    } else {
      return res.status(404).json({ 
        success: false,
        message: 'User not found' 
      });
    }
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error updating user',
      error: error.message 
    });
  }
};

// Delete a user
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await User.destroy({ where: { id } });
    
    if (deleted) {
      res.json({ 
        success: true,
        message: 'User deleted successfully' 
      });
    } else {
      res.status(404).json({ 
        success: false,
        message: 'User not found' 
      });
    }
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error deleting user',
      error: error.message 
    });
  }
};
