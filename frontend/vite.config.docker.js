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
    origin: process.env.VITE_DEV_ORIGIN || undefined,
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
    // Configure for Docker/local dev
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
    hmr: process.env.VITE_HMR_ENABLED === 'false'
      ? false
      : {
          protocol: process.env.VITE_HMR_PROTOCOL || 'ws',
          host: process.env.VITE_HMR_HOST || 'localhost',
          port: process.env.VITE_HMR_PORT ? Number(process.env.VITE_HMR_PORT) : 5173,
          clientPort: process.env.VITE_HMR_CLIENT_PORT ? Number(process.env.VITE_HMR_CLIENT_PORT) : 5173,
          timeout: 120000,
          overlay: true
        }
  }
})
