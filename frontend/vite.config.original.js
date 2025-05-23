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
        changeOrigin: true,
        secure: false
      },
      // Proxy /uploads requests to the backend server
      '/uploads': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        secure: false
      }
    },
    // Allow access from local network and external domains
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
    // Configure HMR specifically for proxy environment
    hmr: {
      // Use ws protocol for more reliable proxy compatibility
      protocol: 'ws',
      // No need to specify clientPort with proper Nginx configuration
      // host: 'job.806040.xyz' // Let Vite determine this automatically
    },
    // Allow specific hosts to access the server
    allowedHosts: ['job.806040.xyz', 'localhost', '192.168.0.190']
  }
})
