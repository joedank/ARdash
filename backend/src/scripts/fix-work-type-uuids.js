'use strict';

const { v4: uuidv4 } = require('uuid');
const { sequelize } = require('../models');

async function fixWorkTypeUuids() {
  try {
    // Get all work types with non-standard UUIDs
    const [workTypes] = await sequelize.query(
      `SELECT id, name FROM work_types WHERE id::text !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'`
    );

    console.log(`Found ${workTypes.length} work types with non-standard UUIDs`);

    // Update each work type with a new UUID
    for (const workType of workTypes) {
      const oldId = workType.id;
      const newId = uuidv4();

      console.log(`Updating work type "${workType.name}" from ${oldId} to ${newId}`);

      // Start a transaction for each update to ensure consistency
      await sequelize.transaction(async (transaction) => {
        // Update foreign keys in work_type_materials
        await sequelize.query(
          `UPDATE work_type_materials SET work_type_id = '${newId}' WHERE work_type_id = '${oldId}'`,
          { transaction }
        );

        // Update foreign keys in work_type_tags
        await sequelize.query(
          `UPDATE work_type_tags SET work_type_id = '${newId}' WHERE work_type_id = '${oldId}'`,
          { transaction }
        );

        // Update foreign keys in work_type_cost_history
        await sequelize.query(
          `UPDATE work_type_cost_history SET work_type_id = '${newId}' WHERE work_type_id = '${oldId}'`,
          { transaction }
        );

        // Update the work type itself
        await sequelize.query(
          `UPDATE work_types SET id = '${newId}' WHERE id = '${oldId}'`,
          { transaction }
        );
      });
    }

    console.log('Successfully updated all non-standard UUIDs');
  } catch (error) {
    console.error('Failed to update work type UUIDs:', error);
  } finally {
    await sequelize.close();
  }
}

fixWorkTypeUuids();
