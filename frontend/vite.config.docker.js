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
      // Enable HMR
      protocol: 'ws',
      clientPort: 5173
    }
  }
})
