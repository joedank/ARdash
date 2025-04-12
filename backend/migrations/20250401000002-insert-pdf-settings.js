'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const now = new Date();
    const newSettings = [
      {
        key: 'pdf_background_color',
        value: '#f8f9fa',
        group: 'appearance',
        description: 'Background color for table headers in PDF documents',
        created_at: now,
        updated_at: now
      },
      {
        key: 'pdf_font_family',
        value: 'Helvetica',
        group: 'appearance',
        description: 'Font family for PDF documents',
        created_at: now,
        updated_at: now
      },
      {
        key: 'pdf_secondary_color',
        value: '#64748b',
        group: 'appearance',
        description: 'Secondary color for PDF accents',
        created_at: now,
        updated_at: now
      },
      {
        key: 'pdf_table_border_color',
        value: '#e2e8f0',
        group: 'appearance',
        description: 'Border color for tables in PDF documents',
        created_at: now,
        updated_at: now
      },
      {
        key: 'pdf_page_margin',
        value: '50',
        group: 'layout',
        description: 'Page margin in points for PDF documents',
        created_at: now,
        updated_at: now
      },
      {
        key: 'pdf_header_margin',
        value: '30',
        group: 'layout',
        description: 'Top margin for header in PDF documents',
        created_at: now,
        updated_at: now
      },
      {
        key: 'pdf_footer_margin',
        value: '30',
        group: 'layout',
        description: 'Bottom margin for footer in PDF documents',
        created_at: now,
        updated_at: now
      },
      {
        key: 'pdf_watermark_text',
        value: '',
        group: 'appearance',
        description: 'Watermark text for PDF documents (leave empty for no watermark)',
        created_at: now,
        updated_at: now
      }
    ];

    // Insert settings one by one using raw SQL to handle conflicts
    for (const setting of newSettings) {
      await queryInterface.sequelize.query(
        `INSERT INTO settings (key, value, "group", description, created_at, updated_at)
         VALUES ($key, $value, $group, $description, $created_at, $updated_at)
         ON CONFLICT (key)
         DO UPDATE SET
           value = EXCLUDED.value,
           "group" = EXCLUDED."group",
           description = EXCLUDED.description,
           updated_at = EXCLUDED.updated_at;`,
        {
          bind: {
            key: setting.key,
            value: setting.value,
            group: setting.group,
            description: setting.description,
            created_at: setting.created_at,
            updated_at: setting.updated_at
          }
        }
      );
    }
  },

  down: async (queryInterface, Sequelize) => {
    const settingKeys = [
      'pdf_background_color',
      'pdf_font_family',
      'pdf_secondary_color',
      'pdf_table_border_color',
      'pdf_page_margin',
      'pdf_header_margin',
      'pdf_footer_margin',
      'pdf_watermark_text'
    ];

    await queryInterface.sequelize.query(
      `DELETE FROM settings WHERE key IN (${settingKeys.map(key => `'${key}'`).join(',')})`
    );
  }
};