import { afterEach, describe, expect, it, vi } from 'vitest'
import { mount, type VueWrapper } from '@vue/test-utils'
import { h, nextTick } from 'vue'
import { TxLoadIndicator, TxMenu, TxPopup, TxTabs, TxToast, TxToolbar, TxTooltip } from '../src'

const mounted: VueWrapper[] = []
function render(component: Parameters<typeof mount>[0], options: Record<string, unknown> = {}): VueWrapper { const wrapper = mount(component, options); mounted.push(wrapper); return wrapper }
afterEach(() => { mounted.splice(0).forEach(wrapper => wrapper.unmount()); document.body.innerHTML = ''; vi.useRealTimers() })

describe('navigation and feedback', () => {
  it('moves tab focus with arrows, skips disabled tabs and updates panel', async () => {
    const wrapper = render(TxTabs, { props: { items: ['Eins', { text: 'Zwei', disabled: true }, 'Drei'] }, attachTo: document.body, slots: { default: ({ selectedIndex }: { selectedIndex: number }) => `Panel ${selectedIndex}` } })
    await wrapper.findAll('[role=tab]')[0].trigger('keydown', { key: 'ArrowRight' })
    expect(document.activeElement).toBe(wrapper.findAll('[role=tab]')[2].element)
    expect(wrapper.get('[role=tabpanel]').text()).toBe('Panel 2')
    await wrapper.findAll('[role=tab]')[2].trigger('keydown', { key: 'Home' })
    expect(wrapper.get('[role=tabpanel]').text()).toBe('Panel 0')
  })
  it('does not activate disabled menus and supports toolbar slots', async () => {
    const menu = render(TxMenu, { props: { items: ['Datei', { text: 'Export', disabled: true }] } })
    await menu.findAll('button')[1].trigger('click')
    expect(menu.emitted('itemClick')).toBeUndefined()
    await menu.findAll('button')[0].trigger('click')
    expect(menu.emitted('itemClick')?.[0]?.[0]).toMatchObject({ itemData: 'Datei', itemIndex: 0 })
    const toolbar = render(TxToolbar, { slots: { default: 'Links', after: 'Rechts' } })
    expect(toolbar.text()).toBe('LinksRechts')
  })
  it('keeps disabled or empty tab lists keyboard accessible without invalid panels', async () => {
    const wrapper = render(TxTabs, { props: { items: [{ text: 'Gesperrt', disabled: true }, 'Verfügbar'] }, slots: { default: 'Inhalt' } })
    expect(wrapper.findAll('[role=tab]')[1].attributes('tabindex')).toBe('0')
    await wrapper.setProps({ items: [] })
    expect(wrapper.find('[role=tabpanel]').exists()).toBe(false)
  })
  it('focuses, traps focus, requests closing on Escape and restores the trigger', async () => {
    const trigger = document.createElement('button'); document.body.append(trigger); trigger.focus()
    const wrapper = render(TxPopup, { props: { visible: true, title: 'Testdialog' }, attachTo: document.body, slots: { default: () => h('input', { 'aria-label': 'Name' }), footer: () => h('button', 'Ende') } })
    await nextTick(); await nextTick()
    const buttons = wrapper.findAll('button')
    expect(document.activeElement).toBe(buttons[0].element)
    ;(buttons.at(-1)!.element as HTMLButtonElement).focus()
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Tab', bubbles: true, cancelable: true }))
    expect(document.activeElement).toBe(buttons[0].element)
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }))
    expect(wrapper.emitted('update:visible')?.at(-1)).toEqual([false])
    await wrapper.setProps({ visible: false })
    expect(document.activeElement).toBe(trigger)
  })
  it('only closes the topmost popup on Escape', async () => {
    const first = render(TxPopup, { props: { visible: true }, attachTo: document.body })
    await nextTick()
    const second = render(TxPopup, { props: { visible: true }, attachTo: document.body })
    await nextTick(); await nextTick()
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }))
    expect(first.emitted('update:visible')).toBeUndefined()
    expect(second.emitted('update:visible')?.at(-1)).toEqual([false])
  })
  it('supports timed and persistent toasts and clears timers on unmount', async () => {
    vi.useFakeTimers()
    const toast = render(TxToast, { props: { visible: true, message: 'Fertig', displayTime: 100 } })
    vi.advanceTimersByTime(100)
    expect(toast.emitted('update:visible')).toEqual([[false]])
    await toast.setProps({ displayTime: 0 })
    vi.advanceTimersByTime(1000)
    expect(toast.emitted('update:visible')).toHaveLength(1)
    await toast.setProps({ displayTime: 50 })
    toast.unmount()
    expect(vi.getTimerCount()).toBe(0)
  })
  it('shows tooltips on focus, dismisses with Escape and labels loading', async () => {
    const tooltip = render(TxTooltip, { props: { text: 'Hilfe' }, slots: { default: 'Info' } })
    expect(tooltip.get('[role=tooltip]').attributes('hidden')).toBeDefined()
    await tooltip.trigger('focusin')
    expect(tooltip.get('[role=tooltip]').attributes('hidden')).toBeUndefined()
    await tooltip.trigger('keydown', { key: 'Escape' })
    expect(tooltip.get('[role=tooltip]').attributes('hidden')).toBeDefined()
    const loader = render(TxLoadIndicator, { props: { label: 'Lädt' } })
    expect(loader.get('[role=status]').text()).toBe('Lädt')
    await loader.setProps({ visible: false })
    expect(loader.find('[role=status]').exists()).toBe(false)
  })
})
