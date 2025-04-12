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
      // Proxy API requests to the backend server
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      },
      // Proxy /uploads requests to the backend server
      '/uploads': {
        target: 'http://localhost:3000',
        changeOrigin: true
      }
    },
    // Allow access from local network and external domains
    host: '0.0.0.0',
    // Allow specific hosts to access the server
    allowedHosts: ['job.806040.xyz', 'localhost']
  }
})
