// Simple script to test DeepSeek API connection directly

// Load environment variables from .env file
require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });

// Import the service (using CommonJS require) - Corrected casing
const deepSeekService = require('../services/deepseekService');
const logger = require('../utils/logger'); // Use the same logger for consistency

async function testDeepSeekConnection() {
  logger.info('Starting DeepSeek API connection test...');

  if (!process.env.DEEPSEEK_API_KEY || process.env.DEEPSEEK_API_KEY === 'YOUR_DEEPSEEK_API_KEY_HERE') {
    logger.error('DEEPSEEK_API_KEY is not set or is still the placeholder in .env file. Please set it.');
    return;
  }

  try {
    const messages = [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: "Hello! Can you confirm you received this message?" }
    ];

    logger.info('Sending test message to DeepSeek API...');
    const completion = await deepSeekService.generateChatCompletion(messages, 'deepseek-chat');

    if (completion && completion.choices && completion.choices.length > 0) {
      const responseContent = completion.choices[0].message?.content;
      logger.info('Successfully received response from DeepSeek:');
      console.log('--- Response Start ---');
      console.log(responseContent);
      console.log('--- Response End ---');
      logger.info('DeepSeek API connection test successful!');
    } else {
      logger.error('Received an invalid or empty response structure from DeepSeek.');
      console.error('Full Response:', JSON.stringify(completion, null, 2));
    }
  } catch (error) {
    logger.error('DeepSeek API connection test failed:');
    console.error(error); // Log the full error object
  }
}

// Run the test function
testDeepSeekConnection();