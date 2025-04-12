'use strict';

const db = require('../models');
const LLMPrompt = db.LLMPrompt;

/**
 * Get all LLM prompts
 */
exports.getAllPrompts = async (req, res) => {
  try {
    const prompts = await LLMPrompt.findAll();
    return res.status(200).json({
      success: true,
      data: prompts
    });
  } catch (error) {
    console.error('Error getting LLM prompts:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve LLM prompts'
    });
  }
};

/**
 * Get a specific prompt by name
 */
exports.getPromptByName = async (req, res) => {
  try {
    const { name } = req.params;
    const prompt = await LLMPrompt.findOne({ where: { name } });
    
    if (!prompt) {
      return res.status(404).json({
        success: false,
        message: `Prompt with name "${name}" not found`
      });
    }
    
    return res.status(200).json({
      success: true,
      data: prompt
    });
  } catch (error) {
    console.error('Error getting LLM prompt:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve LLM prompt'
    });
  }
};

/**
 * Get a specific prompt by ID
 */
exports.getPromptById = async (req, res) => {
  try {
    const { id } = req.params;
    const prompt = await LLMPrompt.findByPk(id);
    
    if (!prompt) {
      return res.status(404).json({
        success: false,
        message: `Prompt with ID ${id} not found`
      });
    }
    
    return res.status(200).json({
      success: true,
      data: prompt
    });
  } catch (error) {
    console.error('Error getting LLM prompt:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve LLM prompt'
    });
  }
};

/**
 * Update an existing prompt
 */
exports.updatePrompt = async (req, res) => {
  try {
    const { id } = req.params;
    const { description, prompt_text } = req.body;
    
    const prompt = await LLMPrompt.findByPk(id);
    
    if (!prompt) {
      return res.status(404).json({
        success: false,
        message: `Prompt with ID ${id} not found`
      });
    }
    
    // Update prompt
    await prompt.update({
      description,
      prompt_text
    });
    
    return res.status(200).json({
      success: true,
      message: 'Prompt updated successfully',
      data: prompt
    });
  } catch (error) {
    console.error('Error updating LLM prompt:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to update LLM prompt'
    });
  }
};
