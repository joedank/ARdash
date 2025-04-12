'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      const columns = await queryInterface.describeTable('invoices');
      if (columns.cardDavUri && !columns.card_dav_uri) {
        console.log('Renaming invoices.cardDavUri to invoices.card_dav_uri');
        await queryInterface.renameColumn('invoices', 'cardDavUri', 'card_dav_uri');
      } else {
        console.log('Column invoices.cardDavUri does not exist or invoices.card_dav_uri already exists. Skipping rename.');
      }
    } catch (error) {
      console.error('Error during migration:', error);
      // If the table doesn't exist yet, that's okay for this specific migration's logic
      if (error.name !== 'SequelizeDatabaseError' || !error.message.includes('does not exist')) {
         throw error;
      }
       console.log('Invoices table does not exist yet, skipping column rename.');
    }
  },

  async down(queryInterface, Sequelize) {
     try {
      const columns = await queryInterface.describeTable('invoices');
      if (columns.card_dav_uri && !columns.cardDavUri) {
        console.log('Reverting rename: invoices.card_dav_uri to invoices.cardDavUri');
        await queryInterface.renameColumn('invoices', 'card_dav_uri', 'cardDavUri');
      } else {
         console.log('Column invoices.card_dav_uri does not exist or invoices.cardDavUri already exists. Skipping revert rename.');
      }
    } catch (error) {
       console.error('Error during migration reversal:', error);
       if (error.name !== 'SequelizeDatabaseError' || !error.message.includes('does not exist')) {
         throw error;
      }
       console.log('Invoices table does not exist, skipping column rename reversal.');
    }
  }
};
