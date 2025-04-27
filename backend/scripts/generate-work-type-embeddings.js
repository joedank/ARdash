'use strict';
require('dotenv').config();

process.env.EMBEDDING_DIM = process.env.EMBEDDING_DIM || '3072';
const { sequelize, WorkType } = require('../src/models');
const embeddingProvider = require('../src/services/embeddingProvider');
const logger = require('../src/utils/logger');

(async () => {
  try {
    await embeddingProvider.reinitialize();
    if (!(await embeddingProvider.isEnabled())) {
      throw new Error('Vector similarity disabled in settings');
    }

    const workTypes = await WorkType.findAll({ where: { name_vec: null } });
    logger.info(`Embedding ${workTypes.length} work types…`);

    for (const wt of workTypes) {
      const vec = await embeddingProvider.embed(wt.name);
      if (!vec) { logger.warn(`No vector for "${wt.name}"`); continue; }
      await sequelize.query(
        'UPDATE work_types SET name_vec = $1::vector WHERE id = $2',
        { bind: [JSON.stringify(vec), wt.id] }
      );
    }
    logger.info('Embedding back-fill completed');
    process.exit(0);
  } catch (e) {
    logger.error(e); process.exit(1);
  }
})();
