import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath } from 'node:url'
export default defineConfig({
  root: fileURLToPath(new URL('.', import.meta.url)), base: '/vue/', plugins: [vue()],
  resolve: { alias: [
    { find: '@tekocloud.de/tecexpress/themes', replacement: fileURLToPath(new URL('../../../npm/themes', import.meta.url)) },
    { find: '@tekocloud.de/tecexpress', replacement: fileURLToPath(new URL('../../../npm/dist/tecexpress.js', import.meta.url)) },
  ] },
  build: { outDir: 'dist', emptyOutDir: true },
})
