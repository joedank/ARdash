'use strict';

module.exports = (sequelize, DataTypes) => {
  const LLMPrompt = sequelize.define('LLMPrompt', {
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    prompt_text: {
      type: DataTypes.TEXT,
      allowNull: false
    }
  }, {
    tableName: 'llm_prompts',
    underscored: true
  });

  return LLMPrompt;
};
