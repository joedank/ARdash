'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    const tableInfo = await queryInterface.describeTable('invoices');
    const columnsToRemove = [
      'dateCreated', 
      'dateDue', 
      'createdAt', 
      'updatedAt', 
      'deletedAt', 
      'taxTotal', 
      'discountAmount', 
      'pdfPath'
    ];

    for (const column of columnsToRemove) {
      if (tableInfo[column]) {
        console.log(`Removing duplicate column: ${column}`);
        await queryInterface.removeColumn('invoices', column);
      } else {
        console.log(`Column ${column} not found, skipping removal.`);
      }
    }
  },

  async down (queryInterface, Sequelize) {
    // Re-adding columns might be complex due to potential type differences.
    // For simplicity, this down migration assumes the types matched the snake_case versions.
    // A more robust down migration would inspect the snake_case column types before adding.
    console.warn('Re-adding potentially duplicate columns in down migration. Verify types if needed.');
    
    await queryInterface.addColumn('invoices', 'dateCreated', { 
      type: Sequelize.DATEONLY, 
      allowNull: true // Allow null initially if re-adding
    });
    await queryInterface.addColumn('invoices', 'dateDue', { 
      type: Sequelize.DATEONLY, 
      allowNull: true 
    });
    await queryInterface.addColumn('invoices', 'createdAt', { 
      type: Sequelize.DATE, // Assuming DATE matches TIMESTAMP WITH TIME ZONE usage
      allowNull: true 
    });
    await queryInterface.addColumn('invoices', 'updatedAt', { 
      type: Sequelize.DATE, 
      allowNull: true 
    });
    await queryInterface.addColumn('invoices', 'deletedAt', { 
      type: Sequelize.DATE, 
      allowNull: true 
    });
    await queryInterface.addColumn('invoices', 'taxTotal', { 
      type: Sequelize.DECIMAL(10, 2), 
      allowNull: true 
    });
    await queryInterface.addColumn('invoices', 'discountAmount', { 
      type: Sequelize.DECIMAL(10, 2), 
      allowNull: true 
    });
    await queryInterface.addColumn('invoices', 'pdfPath', { 
      type: Sequelize.STRING, 
      allowNull: true 
    });
  }
};
