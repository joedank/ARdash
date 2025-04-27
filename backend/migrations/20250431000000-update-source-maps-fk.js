'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    const qi = queryInterface;
    await qi.sequelize.transaction(async (t) => {
      // 1. remove broken references
      await qi.sequelize.query(
        `DELETE FROM source_maps
         WHERE estimate_item_id NOT IN (SELECT id FROM estimate_items)`,
        { transaction: t }
      );

      // 2. Check if constraint exists first, then add if missing
      const [constraintExists] = await qi.sequelize.query(
        `SELECT 1 FROM pg_constraint
         WHERE conname = 'source_maps_estimate_item_id_fkey'`,
        { transaction: t }
      );

      if (constraintExists.length === 0) {
        // Constraint doesn't exist, add it
        await qi.sequelize.query(
          `ALTER TABLE source_maps
           ADD CONSTRAINT source_maps_estimate_item_id_fkey
           FOREIGN KEY (estimate_item_id)
           REFERENCES estimate_items(id)
           DEFERRABLE INITIALLY DEFERRED`,
          { transaction: t }
        );
      } else {
        console.log('Foreign key constraint already exists, skipping creation');
      }
    });
  },
  async down(queryInterface, Sequelize) {
    const qi = queryInterface;
    await qi.sequelize.query(
      `ALTER TABLE source_maps
       DROP CONSTRAINT IF EXISTS source_maps_estimate_item_id_fkey`
    );
  },
};