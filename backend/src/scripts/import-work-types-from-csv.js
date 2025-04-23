const fs = require('fs');
const path = require('path');
const { parse } = require('csv-parse/sync');
const { v4: uuidv4 } = require('uuid');
const { sequelize, Sequelize } = require('../models');

const WorkType = sequelize.define('WorkType', {
  id: {
    type: Sequelize.UUID,
    defaultValue: Sequelize.UUIDV4,
    primaryKey: true
  },
  name: Sequelize.STRING,
  parent_bucket: Sequelize.STRING,
  measurement_type: Sequelize.STRING,
  suggested_units: Sequelize.STRING,
  unit_cost_material: Sequelize.DECIMAL(10, 2),
  unit_cost_labor: Sequelize.DECIMAL(10, 2),
  productivity_unit_per_hr: Sequelize.DECIMAL(10, 2),
  revision: {
    type: Sequelize.INTEGER,
    defaultValue: 1
  }
}, {
  tableName: 'work_types',
  underscored: true,
  timestamps: true
});

async function importWorkTypes() {
  try {
    const csvFile = '/app/work_types.csv';
    console.log(`Reading CSV file: ${csvFile}`);

    const fileContent = fs.readFileSync(csvFile, 'utf8');
    const records = parse(fileContent, {
      columns: true,
      skip_empty_lines: true
    });

    console.log(`Found ${records.length} work types to import`);

    const transaction = await sequelize.transaction();

    try {
      let created = 0;
      for (const record of records) {
        // Generate UUID if needed
        if (!record.id || record.id.startsWith('<uuid')) {
          record.id = uuidv4();
        }

        // Set default values for new columns
        record.unit_cost_material = record.unit_cost_material || 0;
        record.unit_cost_labor = record.unit_cost_labor || 0;
        record.productivity_unit_per_hr = record.productivity_unit_per_hr || 0;
        record.revision = 1;

        // Check if work type already exists
        const existingWorkType = await WorkType.findOne({
          where: { name: record.name },
          transaction
        });

        if (existingWorkType) {
          console.log(`Work type already exists: ${record.name}`);
          continue;
        }

        await WorkType.create(record, { transaction });
        created++;
      }

      await transaction.commit();
      console.log(`Successfully imported ${created} work types`);
    } catch (error) {
      await transaction.rollback();
      throw error;
    }

    await sequelize.close();
  } catch (error) {
    console.error('Import failed:', error);
    process.exit(1);
  }
}

importWorkTypes();
