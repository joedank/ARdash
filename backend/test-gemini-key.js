const axios = require('axios');

const API_KEY = 'AIzaSyBnoXQYtgI54--0oYVaIFxgdR0eebE7CMw';
const BASE_URL = 'https://generativelanguage.googleapis.com/v1beta';
const TEST_TEXT = 'This is a test sentence for embedding';

async function testGeminiKey() {
  try {
    const response = await axios.post(
      `${BASE_URL}/models/embedding-001:embedContent?key=${API_KEY}`,
      {
        content: {
          parts: [{
            text: TEST_TEXT
          }]
        }
      },
      {
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );

    console.log('API Response:', response.data);
    if (response.data.embedding) {
      console.log('Key is valid and has embedding permissions');
      console.log('Embedding vector length:', response.data.embedding.values.length);
    }
  } catch (error) {
    console.error('API Error:', error.response ? error.response.data : error.message);
    console.error('Key validation failed');
  }
}

testGeminiKey();