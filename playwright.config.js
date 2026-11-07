import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: 'tests',
  timeout: 60_000,
  use: { baseURL: 'http://localhost:4173' },
  webServer: { command: 'npm run build && npm run preview', port: 4173, reuseExistingServer: !process.env.CI },
  projects: [
    { name: 'desktop', use: { ...devices['Desktop Chrome'], launchOptions: { args: ['--use-gl=swiftshader', '--enable-unsafe-swiftshader'] } } },
    { name: 'phone', use: { ...devices['Pixel 7'], launchOptions: { args: ['--use-gl=swiftshader', '--enable-unsafe-swiftshader'] } } },
  ],
});
