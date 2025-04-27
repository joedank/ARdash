/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      // Add pgvector extension for vector similarity search
      // Use the correct method: sequelize.query instead of query
      await queryInterface.sequelize.query(`
        CREATE EXTENSION IF NOT EXISTS vector;
      `);
      
      console.log('Successfully enabled pgvector extension');
    } catch (error) {
      console.error('Failed to enable pgvector extension:', error);
      // Check if this is because the extension already exists
      console.log('Vector extension may already exist, checking...');
      
      // Check if the extension is already installed
      try {
        const [results] = await queryInterface.sequelize.query(
          `SELECT * FROM pg_extension WHERE extname = 'vector';`
        );
        
        if (results && results.length > 0) {
          console.log('Vector extension is already installed, continuing...');
          return; // Continue with migration
        }
      } catch (checkError) {
        console.error('Error checking extension status:', checkError);
      }
      
      // If we get here, it's a real error
      throw error;
    }
  },

  async down(queryInterface, Sequelize) {
    // We don't want to drop the extension in down migrations
    // as it might be used by other tables/features
    console.log('Skipping pgvector extension removal in down migration');
  }
};
