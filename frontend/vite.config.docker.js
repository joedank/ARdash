import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'

export default defineConfig({
  plugins: [
    vue(),
    tailwindcss()
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  },
  server: {
    proxy: {
      // Proxy API requests to the backend service defined in docker-compose
      '/api': {
        target: 'http://backend:3000',
        changeOrigin: true,
        secure: false
      },
      // Proxy /uploads requests to the backend service
      '/uploads': {
        target: 'http://backend:3000',
        changeOrigin: true,
        secure: false
      }
    },
    // Configure for Docker
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
    allowedHosts: ['job.806040.xyz', 'localhost'],
    hmr: {
      // Enable HMR with more robust configuration
      host: 'job.806040.xyz',
      port: 5173,
      // When accessed via HTTPS, this will handle clientPort appropriately
      // Don't specify protocol explicitly - let browser determine it
      timeout: 120000, // Increased timeout for better reliability
      overlay: true,
      // Allow both localhost and the domain name
      clientPort: 5173
    }
  }
})
