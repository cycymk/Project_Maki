import { test, expect } from '@playwright/test';

test('game loads, renders and has no errors', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  page.on('console', (m) => {
    // the live-weather fetch may be blocked in CI; that is handled by the game
    if (m.type() === 'error' && !/open-meteo|Failed to load resource/i.test(m.text())) errors.push(m.text());
  });
  await page.goto('/');
  await expect(page.locator('#loading')).toHaveCount(0, { timeout: 30_000 });
  await expect(page.locator('#clock')).not.toHaveText('--:--');

  // canvas actually drew something: a flat single-color frame compresses to a tiny PNG.
  // (Reading the WebGL canvas with drawImage returns blank without preserveDrawingBuffer,
  // so we use a real screenshot instead.)
  await page.waitForTimeout(1500);
  const shot = await page.locator('#c').screenshot();
  expect(shot.length).toBeGreaterThan(30000);
  expect(errors).toEqual([]);
});

test('toolbar opens and closes the settings sheet', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#loading')).toHaveCount(0, { timeout: 30_000 });
  await page.locator('#bSet').click();
  await expect(page.locator('#panel')).toBeVisible();
  await page.locator('#panel [data-close]').click();
  await expect(page.locator('#panel')).toBeHidden();
});
