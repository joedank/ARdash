const { CatalogService } = require('../backend/src/v2/CatalogService');
const { sequelize } = require('../backend/src/models');

describe('CatalogService', () => {
  let catalogService;
  
  beforeAll(async () => {
    catalogService = new CatalogService(sequelize);
  });
  
  it('matches Subfloor Replacement by trigram', async () => {
    const res = await catalogService.upsertOrMatch({ name: 'Subfloor Replacement' }, {});
    expect(res.kind).toBe('match');
  });
  
  // Additional tests could be added here
});
