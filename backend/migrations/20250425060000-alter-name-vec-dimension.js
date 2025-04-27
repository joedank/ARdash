'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.sequelize.transaction(async t => {
      // drop any vector indexes on name_vec (both ivfflat and hnsw)
      await queryInterface.sequelize.query(
        `DO $$
       DECLARE idx text;
       BEGIN
         -- Drop any ivfflat indexes
         FOR idx IN SELECT indexname FROM pg_indexes
         WHERE tablename='work_types' AND indexdef ILIKE '%ivfflat%' LOOP
           EXECUTE 'DROP INDEX IF EXISTS '||idx;
         END LOOP;
         
         -- Drop any hnsw indexes
         FOR idx IN SELECT indexname FROM pg_indexes
         WHERE tablename='work_types' AND indexdef ILIKE '%hnsw%' LOOP
           EXECUTE 'DROP INDEX IF EXISTS '||idx;
         END LOOP;
       END$$;`, { transaction: t }
      );

      // enlarge vector dimension
      await queryInterface.sequelize.query(
        `ALTER TABLE work_types
       ALTER COLUMN name_vec TYPE vector(${process.env.EMBEDDING_DIM || 3072})
       USING name_vec`, { transaction: t }
      );
    });
  },
  async down(queryInterface) {
    await queryInterface.sequelize.query(
      'ALTER TABLE work_types ALTER COLUMN name_vec TYPE vector(384) USING name_vec;'
    );
  }
};