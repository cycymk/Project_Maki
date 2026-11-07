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

  // canvas actually drew something (not a single flat color)
  const varied = await page.evaluate(() => {
    const c = document.querySelector('#c');
    const g = document.createElement('canvas'); g.width = 32; g.height = 32;
    const x = g.getContext('2d'); x.drawImage(c, 0, 0, 32, 32);
    const d = x.getImageData(0, 0, 32, 32).data; const set = new Set();
    for (let i = 0; i < d.length; i += 16) set.add(`${d[i] >> 4},${d[i + 1] >> 4},${d[i + 2] >> 4}`);
    return set.size;
  });
  expect(varied).toBeGreaterThan(8);
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
