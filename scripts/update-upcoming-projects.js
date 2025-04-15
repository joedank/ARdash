#!/usr/bin/env node

/**
 * This script updates 'upcoming' projects to 'in_progress' when their scheduled date arrives.
 * It is designed to be run as a daily cron job.
 * 
 * Usage:
 * node update-upcoming-projects.js
 * 
 * Recommended cron schedule: Once daily at midnight
 * 0 0 * * * cd /path/to/project && node scripts/update-upcoming-projects.js >> logs/cron.log 2>&1
 */

'use strict';

// Load environment variables
require('dotenv').config();

const axios = require('axios');
const fs = require('fs');
const path = require('path');

// Configure API URL and auth token
const API_URL = process.env.API_URL || 'http://localhost:3000/api';
const API_TOKEN = process.env.API_TOKEN; // Use an API token for authentication

// Setup logging
const LOG_DIR = path.join(__dirname, '..', 'logs');
const logFile = path.join(LOG_DIR, 'update-upcoming-projects.log');

// Create logs directory if it doesn't exist
if (!fs.existsSync(LOG_DIR)) {
  fs.mkdirSync(LOG_DIR, { recursive: true });
}

// Log function
function log(message) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}\n`;
  
  // Log to console
  console.log(logMessage);
  
  // Append to log file
  fs.appendFileSync(logFile, logMessage);
}

async function updateUpcomingProjects() {
  try {
    log('Starting update of upcoming projects...');
    
    // Set up headers with authentication
    const headers = {};
    if (API_TOKEN) {
      headers['Authorization'] = `Bearer ${API_TOKEN}`;
    }
    
    // Call the API endpoint to update upcoming projects
    const response = await axios.post(`${API_URL}/projects/update-upcoming`, {}, { headers });
    
    if (response.data && response.data.success) {
      log(`Success: ${response.data.message}`);
      if (response.data.data) {
        log(`Updated ${response.data.data.updatedCount} projects from upcoming to in_progress`);
      }
    } else {
      log(`API call succeeded but returned error: ${response.data.message || 'Unknown error'}`);
    }
    
    log('Update completed.');
  } catch (error) {
    log(`Error updating upcoming projects: ${error.message}`);
    if (error.response) {
      log(`Status: ${error.response.status}, Data: ${JSON.stringify(error.response.data)}`);
    }
    process.exit(1);
  }
}

// Execute the update function
updateUpcomingProjects();
