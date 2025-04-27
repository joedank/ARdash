'use strict';

module.exports = {
  async up({ context: queryInterface }) {
    await queryInterface.sequelize.query(`
      COMMENT ON COLUMN clients.client_type
      IS 'Indicates if client is a property manager or resident';
    `);
  },
  
  async down({ context: queryInterface }) {
    // Remove the comment by setting it to empty string
    await queryInterface.sequelize.query(`
      COMMENT ON COLUMN clients.client_type
      IS '';
    `);
  }
};