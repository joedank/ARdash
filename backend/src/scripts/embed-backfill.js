const { sequelize } = require('../models');
const { CatalogService } = require('../v2/CatalogService');

async function backfillEmbeddings() {
  console.log('Starting embedding backfill...');
  const catalogService = new CatalogService(sequelize);
  
  try {
    // Get all products that need embeddings
    const products = await sequelize.query(
      `SELECT id, name FROM products WHERE embedding IS NULL AND deleted_at IS NULL`,
      { type: sequelize.QueryTypes.SELECT }
    );
    
    console.log(`Found ${products.length} products without embeddings`);
    
    let successCount = 0;
    let errorCount = 0;
    
    // Process each product
    for (const product of products) {
      try {
        await catalogService.generateAndStoreEmbedding(product.id, product.name);
        successCount++;
        
        // Log progress every 10 products
        if (successCount % 10 === 0) {
          console.log(`Processed ${successCount} products so far...`);
        }
      } catch (err) {
        console.error(`Error generating embedding for product ${product.id} (${product.name}):`, err);
        errorCount++;
      }
    }
    
    console.log(`Embedding backfill complete!`);
    console.log(`Successfully processed: ${successCount} products`);
    
    if (errorCount > 0) {
      console.log(`Failed to process: ${errorCount} products`);
    }
    
    return { count: successCount, errors: errorCount };
  } catch (error) {
    console.error('Error during embedding backfill:', error);
    throw error;
  } finally {
    await sequelize.close();
  }
}

// Execute the function if this script is run directly
if (require.main === module) {
  backfillEmbeddings()
    .then(() => {
      console.log('Backfill script completed successfully');
      process.exit(0);
    })
    .catch(err => {
      console.error('Backfill script failed:', err);
      process.exit(1);
    });
}

module.exports = { backfillEmbeddings };
