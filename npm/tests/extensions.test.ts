import { afterEach, describe, expect, it, vi } from 'vitest'
import { mount, flushPromises, type VueWrapper } from '@vue/test-utils'
import {
  TxDataSource,
  TxRadioGroup,
  TxButtonGroup,
  TxTagBox,
  TxLookup,
  TxList,
  TxTabPanel,
  TxRangeSlider,
  TxRangeSelector,
  TxLoadPanel,
  TxFileUploader,
  TxMemoryFileProvider,
  txProject,
  txUnproject,
  notify,
  TxDataGrid,
  TxCardView,
  TxContextMenu,
  TxPopup,
  TxTooltip,
} from '../src'
const wrappers: VueWrapper[] = []
function render(
  component: Parameters<typeof mount>[0],
  options: Record<string, unknown> = {},
): VueWrapper {
  const w = mount(component, options)
  wrappers.push(w)
  return w
}
afterEach(() => {
  wrappers.splice(0).forEach((w) => w.unmount())
  document.body.innerHTML = ''
  vi.useRealTimers()
})
describe('new controls and shared data binding', () => {
  it('opens a keyboard context menu, skips disabled actions and restores focus', async () => {
    const w = render(TxContextMenu, {
      props: {
        items: [
          { id: 'disabled', text: 'Disabled', disabled: true },
          { id: 'open', text: 'Open' },
        ],
      },
      slots: { default: '<button>Target</button>' },
      attachTo: document.body,
    })
    const target = w.get('button')
    ;(target.element as HTMLButtonElement).focus()
    await target.trigger('keydown', { key: 'F10', shiftKey: true })
    await flushPromises()
    expect(w.find('[role=menu]').exists()).toBe(true)
    expect(document.activeElement?.textContent).toBe('Open')
    await w.get('[role=menu]').trigger('keydown', { key: 'Escape' })
    expect(document.activeElement).toBe(target.element)
  })
  it('allows cancelling popup close requests and controlling tooltip visibility', async () => {
    const popup = render(TxPopup, {
      props: {
        visible: true,
        onHiding: (event: { cancel: boolean }) => (event.cancel = true),
      },
      attachTo: document.body,
    })
    await flushPromises()
    await popup.get('button').trigger('click')
    expect(popup.emitted('update:visible')).toBeUndefined()
    const tip = render(TxTooltip, {
      props: { visible: true, text: 'Controlled' },
    })
    expect(tip.get('[role=tooltip]').attributes('hidden')).toBeUndefined()
    await tip.setProps({ visible: false })
    expect(tip.get('[role=tooltip]').attributes('hidden')).toBeDefined()
  })
  it('shares a source without taking ownership and prefers dataSource over items', async () => {
    const source = new TxDataSource({
      store: [
        { id: 1, text: 'One' },
        { id: 2, text: 'Two' },
      ],
      paginate: false,
    })
    const dispose = vi.spyOn(source, 'dispose'),
      radio = render(TxRadioGroup, {
        props: { items: ['ignored'], dataSource: source },
      }),
      group = render(TxButtonGroup, {
        props: { dataSource: source, selectionMode: 'multiple' },
      })
    await flushPromises()
    expect(radio.text()).not.toContain('ignored')
    expect(group.text()).toContain('Two')
    await radio.findAll('button')[0].trigger('click')
    expect(radio.emitted('update:modelValue')?.[0]).toEqual([1])
    await source.remove(2)
    await flushPromises()
    expect(group.text()).not.toContain('Two')
    radio.unmount()
    expect(dispose).not.toHaveBeenCalled()
    source.dispose()
  })
  it('loads grid pages only once and preserves keys across page changes', async () => {
    const source = new TxDataSource({
      store: [
        { id: 1, text: 'One' },
        { id: 2, text: 'Two' },
        { id: 3, text: 'Three' },
      ],
      pageSize: 1,
    })
    const grid = render(TxDataGrid, {
      props: {
        dataSource: source,
        selection: 'multiple',
        selectedRowKeys: [1],
      },
    })
    await flushPromises()
    expect(grid.text()).toContain('Seite 1 / 3')
    await source.configure({ pageIndex: 1 })
    await flushPromises()
    expect(grid.text()).toContain('Seite 2 / 3')
    expect(grid.text()).toContain('Two')
    expect(grid.text()).not.toContain('Three')
    expect(grid.emitted('update:selectedRowKeys')).toBeUndefined()
    await source.remove(1)
    await flushPromises()
    expect(grid.emitted('update:selectedRowKeys')?.at(-1)).toEqual([[]])
  })
  it('keeps CardView paging and page-size controls synchronized with its source', async () => {
    const source = new TxDataSource({
      store: [
        { id: 1, title: 'One' },
        { id: 2, title: 'Two' },
        { id: 3, title: 'Three' },
      ],
      pageSize: 1,
    })
    const w = render(TxCardView, { props: { dataSource: source } })
    await flushPromises()
    expect(w.text()).toContain('Seite 1 / 3')
    await source.configure({ pageIndex: 1 })
    await flushPromises()
    expect(w.text()).toContain('Seite 2 / 3')
    expect(w.text()).toContain('Two')
    await source.configure({ pageSize: 2 })
    await flushPromises()
    expect(w.text()).toContain('Seite 1 / 2')
    expect(w.findAll('.tx-cardview-item')).toHaveLength(2)
  })
  it('supports radio keyboard navigation and disabled entries', async () => {
    const w = render(TxRadioGroup, {
      props: { items: ['One', { text: 'Disabled', disabled: true }, 'Three'] },
    })
    await w.findAll('button')[0].trigger('keydown', { key: 'ArrowRight' })
    expect(w.emitted('update:modelValue')?.[0]).toEqual(['Three'])
  })
  it('keeps TagBox draft values until confirmation', async () => {
    const w = render(TxTagBox, {
      props: {
        items: ['One', 'Two'],
        modelValue: [],
        applyValueMode: 'useButtons',
      },
    })
    await w.get('.tx-control').trigger('click')
    await flushPromises()
    await w.findAll('[role=option]')[0].trigger('click')
    expect(w.emitted('update:modelValue')).toBeUndefined()
    const apply = w.findAll('button').find((b) => b.text() === 'Übernehmen')!
    await apply.trigger('click')
    expect(w.emitted('update:modelValue')?.[0]).toEqual([['One']])
  })
  it('searches a Lookup and renders a real TabPanel', async () => {
    const w = render(TxLookup, { props: { items: ['One', 'Two'] } })
    await w.get('.tx-control').trigger('click')
    await flushPromises()
    await w.get('input[type=search]').setValue('Two')
    expect(w.findAll('[role=option]')).toHaveLength(1)
    const panel = render(TxTabPanel, {
      props: { items: ['A', 'B'] },
      slots: {
        default: ({ selectedIndex }: { selectedIndex: number }) =>
          `Page ${selectedIndex}`,
      },
    })
    await panel.findAll('[role=tab]')[1].trigger('click')
    expect(panel.get('[role=tabpanel]').text()).toBe('Page 1')
  })
  it('constrains ranges and retains Date values', async () => {
    const slider = render(TxRangeSlider, {
      props: { modelValue: [20, 60], minRange: 10, maxRange: 50, step: 5 },
    })
    await slider.findAll('input')[0].setValue('59')
    expect(slider.emitted('update:modelValue')?.at(-1)).toEqual([[50, 60]])
    const range = render(TxRangeSelector, {
      props: {
        min: new Date(0),
        max: new Date(10000),
        modelValue: [new Date(1000), new Date(5000)],
        step: 1000,
      },
    })
    await range.findAll('input')[1].setValue('7000')
    expect((range.emitted('update:modelValue')?.[0]?.[0] as Date[])[1]).toEqual(
      new Date(7000),
    )
  })
  it('renders virtual lists without mounting every entry', () => {
    const w = render(TxList, {
      props: {
        items: Array.from({ length: 1000 }, (_, i) => `Item ${i}`),
        virtual: true,
        height: 200,
      },
    })
    expect(w.findAll('[role=listitem]').length).toBeLessThan(20)
  })
  it('binds LoadPanel to source loading and cleans timers', async () => {
    vi.useFakeTimers()
    const w = render(TxLoadPanel, { props: { visible: true, delay: 50 } })
    expect(w.find('[role=status]').exists()).toBe(false)
    await vi.advanceTimersByTimeAsync(50)
    expect(w.find('[role=status]').exists()).toBe(true)
    await w.setProps({ visible: false })
    expect(w.find('[role=status]').exists()).toBe(false)
  })
  it('updates and closes notifications and projects map coordinates', () => {
    const handle = notify({ message: 'Hello', displayTime: 0 })
    expect(document.body.textContent).toContain('Hello')
    handle.update({ message: 'Updated' })
    handle.close()
    expect(document.body.textContent).not.toContain('Hello')
    const point = { lat: 52.52, lng: 13.405 },
      projected = txProject(point, 8),
      result = txUnproject(projected.x, projected.y, 8)
    expect(result.lat).toBeCloseTo(point.lat)
    expect(result.lng).toBeCloseTo(point.lng)
  })
  it('rejects recursive file moves and duplicate names and preserves content', async () => {
    const provider = new TxMemoryFileProvider(),
      a = await provider.createDirectory(null, 'A'),
      b = await provider.createDirectory(a.id, 'B')
    await expect(provider.move(a.id, b.id)).rejects.toThrow('selbst')
    await expect(provider.createDirectory(null, 'A')).rejects.toThrow(
      'vorhanden',
    )
    const file = new File(['hello'], 'hello.txt')
    const uploaded = await provider.upload(a.id, file)
    expect((await provider.download(uploaded.id)).size).toBe(5)
    await provider.remove(a.id)
    expect(await provider.list(a.id)).toEqual([])
  })
  it('validates uploads before calling adapter', async () => {
    const adapter = vi.fn()
    const w = render(TxFileUploader, {
      props: { adapter, maxFileSize: 2, uploadMode: 'instantly' },
    })
    const input = w.get('input')
    Object.defineProperty(input.element, 'files', {
      value: [new File(['large'], 'large.txt')],
    })
    await input.trigger('change')
    expect(w.text()).toContain('Dateigröße nicht erlaubt')
    expect(adapter).not.toHaveBeenCalled()
  })
  it('keeps the upload queue stable when its DataSource reloads', async () => {
    const file = new File(['hello'], 'hello.txt'),
      source = new TxDataSource<File>({ store: [file], paginate: false })
    const w = render(TxFileUploader, {
      props: { dataSource: source, multiple: true },
    })
    await flushPromises()
    expect(w.findAll('li')).toHaveLength(1)
    await source.reload()
    await flushPromises()
    expect(w.findAll('li')).toHaveLength(1)
    source.dispose()
  })
})
