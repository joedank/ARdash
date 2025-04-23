'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    try {
      // Check if pgvector extension is available
      const [pgvectorCheck] = await queryInterface.sequelize.query(
        `SELECT COUNT(*) as count FROM pg_available_extensions WHERE name = 'vector'`
      );
      
      const pgvectorAvailable = pgvectorCheck[0].count > 0;
      console.log(`pgvector extension available: ${pgvectorAvailable}`);
      
      if (pgvectorAvailable) {
        try {
          // Try to create the extension if it's available but not yet created
          await queryInterface.sequelize.query(`CREATE EXTENSION IF NOT EXISTS vector`);
          console.log('pgvector extension created successfully');
          
          // Check if name_vec column exists and is TEXT type
          const [columns] = await queryInterface.sequelize.query(
            `SELECT column_name, data_type 
             FROM information_schema.columns 
             WHERE table_name = 'work_types' AND column_name = 'name_vec'`
          );
          
          if (columns.length > 0) {
            console.log(`name_vec column exists with type: ${columns[0].data_type}`);
            
            // If column exists and is TEXT, alter it to vector type
            if (columns[0].data_type === 'text') {
              await queryInterface.sequelize.query(
                `ALTER TABLE work_types ALTER COLUMN name_vec TYPE vector(384) USING NULL`
              );
              console.log('Altered name_vec column to vector(384) type');
            }
          } else {
            // If column doesn't exist, add it as vector type
            await queryInterface.sequelize.query(
              `ALTER TABLE work_types ADD COLUMN name_vec vector(384)`
            );
            console.log('Added name_vec column with vector(384) type');
          }
          
          // Create index for vector similarity search
          await queryInterface.sequelize.query(
            `CREATE INDEX IF NOT EXISTS idx_work_types_name_vec ON work_types USING ivfflat (name_vec vector_cosine_ops)`
          );
          console.log('Created vector similarity index');
          
        } catch (error) {
          console.error('Error setting up pgvector:', error.message);
          // If pgvector operations fail, ensure name_vec exists as TEXT
          await queryInterface.sequelize.query(
            `ALTER TABLE work_types ADD COLUMN IF NOT EXISTS name_vec TEXT`
          );
          console.log('Added name_vec as TEXT type (fallback)');
        }
      } else {
        // If pgvector is not available, ensure name_vec exists as TEXT
        await queryInterface.sequelize.query(
          `ALTER TABLE work_types ADD COLUMN IF NOT EXISTS name_vec TEXT`
        );
        console.log('Added name_vec as TEXT type (pgvector not available)');
      }
      
      return Promise.resolve();
    } catch (error) {
      console.error('Migration failed:', error);
      return Promise.reject(error);
    }
  },

  down: async (queryInterface, Sequelize) => {
    try {
      // Check if name_vec column exists
      const [columns] = await queryInterface.sequelize.query(
        `SELECT column_name, data_type 
         FROM information_schema.columns 
         WHERE table_name = 'work_types' AND column_name = 'name_vec'`
      );
      
      if (columns.length > 0) {
        // Drop the index if it exists
        await queryInterface.sequelize.query(
          `DROP INDEX IF EXISTS idx_work_types_name_vec`
        );
        console.log('Dropped vector similarity index');
        
        // Convert vector column back to TEXT if it's vector type
        if (columns[0].data_type !== 'text') {
          await queryInterface.sequelize.query(
            `ALTER TABLE work_types ALTER COLUMN name_vec TYPE TEXT USING NULL`
          );
          console.log('Converted name_vec column back to TEXT type');
        }
      }
      
      return Promise.resolve();
    } catch (error) {
      console.error('Migration rollback failed:', error);
      return Promise.reject(error);
    }
  }
};
