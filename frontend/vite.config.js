import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    sourcemap: false,
    minify: 'esbuild',
    target: 'es2015', // Đảm bảo tương thích với các trình duyệt cũ hơn
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'], // Tách các thư viện lớn thành chunk riêng
        },
      },
    },
  },
  server: {
    host: true,
    port: 5173,
  },
  preview: {
    host: true,
    port: 5173,
  },
  esbuild: {
    drop: ['console', 'debugger'], // Loại bỏ console.log và debugger statements
  },
})
