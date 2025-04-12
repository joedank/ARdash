module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('invoices', 'address_id', {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: 'client_addresses',
        key: 'id'
      },
      comment: 'Foreign key to client_addresses table for the selected address'
    });
  },
  
  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('invoices', 'address_id');
  }
};