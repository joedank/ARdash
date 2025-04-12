'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    // Removed explicit transaction - let Sequelize handle atomicity per command
    try {
      // 1. Rename estimateNumber to estimate_number
      // Drop unique constraint first if it exists on the old name
      try {
        await queryInterface.removeConstraint('estimates', 'estimates_estimateNumber_key');
        console.log("Dropped constraint estimates_estimateNumber_key");
      } catch (e) {
        console.warn("Could not drop constraint estimates_estimateNumber_key, maybe it doesn't exist or was already dropped?");
      }

      // Check if estimateNumber column exists before renaming
      const estimateColumns = await queryInterface.describeTable('estimates');
      if (estimateColumns.estimateNumber) {
         console.log("Renaming estimateNumber to estimate_number");
         await queryInterface.renameColumn('estimates', 'estimateNumber', 'estimate_number');
      } else {
         console.log("Column estimateNumber does not exist, skipping rename.");
      }


      // Re-add unique constraint on the correct name if it doesn't exist
      try {
         await queryInterface.addConstraint('estimates', {
           fields: ['estimate_number'],
           type: 'unique',
           name: 'estimates_estimate_number_key', // Use standard naming
         });
         console.log("Added constraint estimates_estimate_number_key");
      } catch (e) {
         console.warn("Could not add constraint estimates_estimate_number_key, maybe it already exists?");
      }


      // 2. Rename legacy clientId to client_id and make nullable
       if (estimateColumns.clientId) {
         console.log("Renaming clientId to client_id");
         await queryInterface.renameColumn('estimates', 'clientId', 'client_id');
         await queryInterface.changeColumn('estimates', 'client_id', {
           type: Sequelize.STRING,
           allowNull: true // Make it nullable
         });
       } else {
          console.log("Column clientId does not exist, skipping rename/change.");
          // Ensure client_id exists and is nullable if clientId didn't exist
          if (estimateColumns.client_id) {
             await queryInterface.changeColumn('estimates', 'client_id', {
                type: Sequelize.STRING,
                allowNull: true
             });
          }
       }


      // 3. Drop unused cardDavUri column if it exists
      if (estimateColumns.cardDavUri) {
         console.log("Removing column cardDavUri");
         await queryInterface.removeColumn('estimates', 'cardDavUri');
      } else {
         console.log("Column cardDavUri does not exist, skipping removal.");
      }


      // 4. Drop duplicate camelCase columns (keep snake_case versions) if they exist
      const columnsToDrop = [
        'taxTotal', 'discountAmount', 'pdfPath', 'convertedToInvoiceId',
        'createdAt', 'updatedAt', 'deletedAt'
      ];
      const currentEstimateColumns = await queryInterface.describeTable('estimates'); // Re-fetch in case schema changed
      for (const col of columnsToDrop) {
        if (currentEstimateColumns[col]) {
           console.log(`Removing column ${col}`);
           await queryInterface.removeColumn('estimates', col);
        } else {
           console.log(`Column ${col} does not exist, skipping removal.`);
        }
      }

      // 5. Fix status column type (create ENUM type first if it doesn't exist)
      const enumName = 'enum_estimates_status';
      const enumValues = ['draft', 'sent', 'viewed', 'accepted', 'rejected', 'expired']; // Added 'viewed'
      // Create ENUM type raw query
      await queryInterface.sequelize.query(`
        DO $$ BEGIN
          CREATE TYPE "${enumName}" AS ENUM(${enumValues.map(v => `'${v}'`).join(', ')});
        EXCEPTION
          WHEN duplicate_object THEN null;
        END $$;
      `);

      // Alter column type using raw SQL with USING clause
      console.log("Altering status column type to ENUM");
      await queryInterface.sequelize.query(`
        ALTER TABLE "estimates"
        ALTER COLUMN "status" DROP DEFAULT,
        ALTER COLUMN "status" TYPE "${enumName}"
          USING "status"::text::"${enumName}",
        ALTER COLUMN "status" SET DEFAULT 'draft'::"${enumName}",
        ALTER COLUMN "status" SET NOT NULL;
      `);

    } catch (err) {
      console.error("Migration failed:", err);
      throw err;
    }
  },

  async down (queryInterface, Sequelize) {
    // Reverting these changes can be complex. This down migration is a best effort.
    console.warn("Attempting to revert cleanup-estimates-table-schema. This might be incomplete.");
    try {
      // Revert status column type (approximate)
       console.log("Reverting status column type to VARCHAR");
      await queryInterface.sequelize.query(`
        ALTER TABLE "estimates"
        ALTER COLUMN "status" DROP DEFAULT,
        ALTER COLUMN "status" TYPE VARCHAR(255)
          USING "status"::text::VARCHAR(255),
        ALTER COLUMN "status" SET DEFAULT 'draft',
        ALTER COLUMN "status" SET NOT NULL;
      `);
      // Note: Dropping the ENUM type is often complex and skipped in rollbacks

      // Re-add duplicate columns (approximate types)
      console.log("Attempting to re-add dropped camelCase columns");
      await queryInterface.addColumn('estimates', 'taxTotal', { type: Sequelize.DECIMAL(10, 2) }).catch(e=>console.warn("Could not add taxTotal"));
      await queryInterface.addColumn('estimates', 'discountAmount', { type: Sequelize.DECIMAL(10, 2) }).catch(e=>console.warn("Could not add discountAmount"));
      await queryInterface.addColumn('estimates', 'pdfPath', { type: Sequelize.STRING }).catch(e=>console.warn("Could not add pdfPath"));
      await queryInterface.addColumn('estimates', 'convertedToInvoiceId', { type: Sequelize.UUID }).catch(e=>console.warn("Could not add convertedToInvoiceId"));
      await queryInterface.addColumn('estimates', 'createdAt', { type: Sequelize.DATE }).catch(e=>console.warn("Could not add createdAt"));
      await queryInterface.addColumn('estimates', 'updatedAt', { type: Sequelize.DATE }).catch(e=>console.warn("Could not add updatedAt"));
      await queryInterface.addColumn('estimates', 'deletedAt', { type: Sequelize.DATE }).catch(e=>console.warn("Could not add deletedAt"));

      // Re-add cardDavUri
      console.log("Attempting to re-add cardDavUri column");
      await queryInterface.addColumn('estimates', 'cardDavUri', { type: Sequelize.STRING, allowNull: true }).catch(e=>console.warn("Could not add cardDavUri"));

      // Revert client_id column
      console.log("Attempting to revert client_id column to clientId");
       const estimateColumnsDown = await queryInterface.describeTable('estimates');
       if(estimateColumnsDown.client_id) {
          await queryInterface.changeColumn('estimates', 'client_id', {
            type: Sequelize.STRING,
            allowNull: false // Assuming it was not null before
          });
          await queryInterface.renameColumn('estimates', 'client_id', 'clientId');
       }


      // Revert estimate_number column
      console.log("Attempting to revert estimate_number column to estimateNumber");
       if(estimateColumnsDown.estimate_number) {
          try {
            await queryInterface.removeConstraint('estimates', 'estimates_estimate_number_key');
          } catch (e) { console.warn("Could not drop constraint estimates_estimate_number_key during rollback"); }
          await queryInterface.renameColumn('estimates', 'estimate_number', 'estimateNumber');
          try {
            await queryInterface.addConstraint('estimates', {
              fields: ['estimateNumber'], // Use old name
              type: 'unique',
              name: 'estimates_estimateNumber_key', // Use old name
            });
          } catch (e) { console.warn("Could not re-add constraint estimates_estimateNumber_key during rollback"); }
       }


    } catch (err) {
      console.error("Rollback failed:", err);
      throw err;
    }
  }
};
