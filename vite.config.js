import { defineConfig } from 'vite';

// base './' so the build works on GitHub Pages (/Project_Maki/) and Cloudflare Pages (/)
export default defineConfig({
  base: './',
  server: { port: 5173 },
});
