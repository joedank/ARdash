// Simple script to test language model API connection

// Load environment variables from .env file
require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });

// Import the language model provider service
const languageModelProvider = require('../services/languageModelProvider');
const embeddingProvider = require('../services/embeddingProvider');
const logger = require('../utils/logger'); // Use the same logger for consistency

async function testDeepSeekConnection() {
  logger.info('Starting language model API connection test...');

  try {
    const messages = [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: "Hello! Can you confirm you received this message?" }
    ];

    logger.info('Sending test message to language model API...');
    const completion = await languageModelProvider.generateChatCompletion(messages);

    if (completion && completion.choices && completion.choices.length > 0) {
      const responseContent = completion.choices[0].message?.content;
      logger.info('Successfully received response from language model:');
      console.log('--- Response Start ---');
      console.log(responseContent);
      console.log('--- Response End ---');
      logger.info('Language model API connection test successful!');
    } else {
      logger.error('Received an invalid or empty response structure from language model.');
      console.error('Full Response:', JSON.stringify(completion, null, 2));
    }

    // Test embedding generation
    logger.info('Testing embedding generation...');
    const embeddingResult = await embeddingProvider.embed(
      'This is a test sentence for embedding generation.'
    );

    // Just log the length of the embedding vector to avoid cluttering the console
    logger.info(`Embedding result: Vector of length ${embeddingResult ? embeddingResult.length : 'N/A'}`);
  } catch (error) {
    logger.error('Language model API connection test failed:');
    console.error(error); // Log the full error object
  }
}

// Run the test function
testDeepSeekConnection();