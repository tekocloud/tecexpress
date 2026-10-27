import { expect, test } from '@playwright/test'

test('extended controls share data, filter remotely and manage files', async ({
  page,
}) => {
  const errors: string[] = []
  page.on('pageerror', (error) => errors.push(error.message))
  await page.goto('/')
  const root = page.locator('#extensions')
  await root.getByRole('radio', { name: 'Vertrieb' }).click()
  await expect(root).toContainText('Auswahl: sales')
  await root.locator('.tx-lookup').last().getByRole('button').first().click()
  const lookup = page.getByRole('dialog', {
    name: 'Remote-Suche (simulierter Store)',
  })
  await expect(lookup).toBeVisible()
  await lookup.getByRole('searchbox').fill('Vertrieb')
  await lookup.getByRole('option', { name: /Vertrieb/ }).click()
  await expect(lookup).toHaveCount(0)
  const manager = root.getByRole('region', { name: 'Dateimanager' })
  await manager.getByLabel('Dateiname').fill('Bilder')
  await manager.getByRole('button', { name: 'Neuer Ordner' }).click()
  await expect(manager.getByRole('button', { name: '📁 Bilder' })).toBeVisible()
  await manager.getByRole('button', { name: '📁 Dokumente' }).click()
  await expect(
    manager.getByRole('button', { name: '📄 Willkommen.txt' }),
  ).toBeVisible()
  await manager.getByRole('button', { name: 'Dateien', exact: true }).click()
  await manager.getByLabel('Bilder auswählen').check()
  await manager.getByRole('button', { name: 'Löschen', exact: true }).click()
  await expect(manager.getByRole('button', { name: '📁 Bilder' })).toHaveCount(
    0,
  )
  expect(errors).toEqual([])
})

for (const theme of ['light', 'dark'])
  test(`extensions ${theme}: responsive layout, popup and notification stack`, async ({
    page,
  }, info) => {
    await page.addInitScript(
      (value) => localStorage.setItem('tx-demo-theme', value),
      theme,
    )
    await page.goto('/')
    const root = page.locator('#extensions')
    await root.scrollIntoViewIfNeeded()
    await root.getByRole('button', { name: 'notify()', exact: true }).click()
    await root.getByRole('button', { name: 'notify()', exact: true }).click()
    await expect(page.locator('.tx-notification')).toHaveCount(2)
    await root.getByRole('button', { name: 'Verschiebbarer Dialog' }).click()
    await expect(
      page.getByRole('dialog', { name: 'Flexibler Dialog' }),
    ).toBeVisible()
    await page.keyboard.press('Escape')
    await expect(page.getByRole('dialog')).toHaveCount(0)
    await root.screenshot({ path: info.outputPath(`${theme}-extensions.png`) })
    await page.setViewportSize({ width: 390, height: 844 })
    await root.scrollIntoViewIfNeeded()
    expect(
      await page.evaluate(
        () => document.documentElement.scrollWidth <= innerWidth,
      ),
    ).toBe(true)
    await root.screenshot({
      path: info.outputPath(`${theme}-extensions-mobile.png`),
    })
  })
