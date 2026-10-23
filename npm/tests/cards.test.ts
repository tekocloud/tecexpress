import { afterEach, describe, expect, it } from 'vitest'
import { mount, type VueWrapper } from '@vue/test-utils'
import { defineComponent, h, ref } from 'vue'
import { TxCard, TxCardView, type RowKey } from '../src'

const rows = [
  { id: 'a', title: 'Portal', subtitle: 'Web', owner: 'Anna' },
  { id: 'b', title: 'Workspace', subtitle: 'Desktop', owner: 'Ben' },
  { id: 'c', title: 'Studio', subtitle: 'Web', owner: 'Clara' },
  { id: 'd', title: 'Analytics', subtitle: 'Insights', owner: 'Dora' }
]
const mounted: VueWrapper[] = []
function view(props = {}, slots = {}) { const wrapper = mount(TxCardView, { props: { dataSource: rows, columns: [{ dataField: 'owner', caption: 'Team' }], ...props }, slots }); mounted.push(wrapper); return wrapper }
afterEach(() => mounted.splice(0).forEach(wrapper => wrapper.unmount()))

describe('cards', () => {
  it('renders semantic Card content, media, actions and footer', () => {
    const card = mount(TxCard, { props: { title: 'Titel', subtitle: 'Untertitel', imageUrl: '/cover.png', imageAlt: 'Projektcover', variant: 'elevated' }, slots: { default: 'Inhalt', actions: () => h('button', 'Aktion'), footer: 'Fußzeile' } }); mounted.push(card)
    expect(card.element.tagName).toBe('ARTICLE')
    expect(card.get('h3').attributes('id')).toBe(card.attributes('aria-labelledby'))
    expect(card.get('img').attributes('alt')).toBe('Projektcover')
    expect(card.get('.tx-card-actions').text()).toBe('Aktion')
    expect(card.get('.tx-card-body').text()).toBe('Inhalt')
    expect(card.get('.tx-card-footer').text()).toBe('Fußzeile')
    expect(card.classes()).toContain('tx-card-elevated')
  })
  it('allows Card slot overrides and switches to an accessible loading state', async () => {
    const card = mount(TxCard, { props: { title: 'Fallback' }, slots: { header: 'Eigener Header', media: 'Medium', default: 'Inhalt' } }); mounted.push(card)
    expect(card.find('h3').exists()).toBe(false)
    expect(card.attributes('aria-labelledby')).toBeUndefined()
    expect(card.get('.tx-card-media').text()).toBe('Medium')
    await card.setProps({ loading: true })
    expect(card.attributes('aria-busy')).toBe('true')
    expect(card.get('[role=status]').text()).toContain('Karte wird geladen')
    expect(card.get('.tx-card-body').text()).not.toContain('Inhalt')
  })
  it('searches configured fields, resets pages and clamps after data changes', async () => {
    const wrapper = view({ pageSize: 2 })
    await wrapper.get('[aria-label="Nächste Kartenseite"]').trigger('click')
    expect(wrapper.findAll('.tx-card-title')[0].text()).toBe('Studio')
    await wrapper.get('input[type=search]').setValue('ANNA')
    expect(wrapper.findAll('.tx-card-title')).toHaveLength(1)
    expect(wrapper.get('.tx-card-title').text()).toBe('Portal')
    expect(wrapper.get('.tx-cardview-footer').text()).toContain('Seite 1 / 1')
    await wrapper.get('input[type=search]').setValue('')
    await wrapper.get('[aria-label="Nächste Kartenseite"]').trigger('click')
    await wrapper.setProps({ dataSource: [rows[0]] })
    expect(wrapper.get('.tx-card-title').text()).toBe('Portal')
    expect(wrapper.get('.tx-cardview-footer').text()).toContain('Seite 1 / 1')
  })
  it('retains selection across search and paging and prunes removed keys', async () => {
    const wrapper = view({ selection: 'multiple', pageSize: 2 })
    await wrapper.get('[aria-label="Karte Portal auswählen"]').setValue(true)
    await wrapper.get('[aria-label="Nächste Kartenseite"]').trigger('click')
    await wrapper.get('[aria-label="Karte Studio auswählen"]').setValue(true)
    expect(wrapper.emitted('update:selectedCardKeys')?.at(-1)).toEqual([['a', 'c']])
    await wrapper.get('input[type=search]').setValue('Portal')
    expect(wrapper.get('[aria-label="Karte Portal auswählen"]').element).toHaveProperty('checked', true)
    await wrapper.setProps({ dataSource: rows.filter(row => row.id !== 'a') })
    expect(wrapper.emitted('update:selectedCardKeys')?.at(-1)).toEqual([['c']])
  })
  it('round trips controlled single selection', async () => {
    const selected = ref<RowKey[]>([])
    const parent = mount(defineComponent({ setup: () => () => h(TxCardView, { dataSource: rows, selection: 'single', selectedCardKeys: selected.value, 'onUpdate:selectedCardKeys': keys => { selected.value = keys } }) })); mounted.push(parent)
    await parent.get('[aria-label="Karte Portal auswählen"]').setValue(true)
    await parent.get('[aria-label="Karte Studio auswählen"]').setValue(true)
    expect(selected.value).toEqual(['c'])
    expect(parent.get('[aria-label="Karte Portal auswählen"]').element).toHaveProperty('checked', false)
  })
  it('emits cardClick through an accessible Details button and supports templates', async () => {
    const wrapper = view({}, { field: ({ value }: { value: unknown }) => h('b', String(value)) })
    await wrapper.get('[aria-label="Details: Portal"]').trigger('click')
    expect(wrapper.emitted('cardClick')?.[0]?.[0]).toMatchObject({ data: rows[0], key: 'a', index: 0 })
    expect(wrapper.get('.tx-card-fields b').text()).toBe('Anna')
    const templated = view({ selection: 'multiple' }, { item: ({ data, selected }: { data: typeof rows[0]; selected: boolean }) => h('div', { class: 'custom-card' }, `${data.title}: ${selected}`) })
    await templated.get('[aria-label="Karte Portal auswählen"]').setValue(true)
    expect(templated.get('.custom-card').text()).toBe('Portal: true')
  })
  it('handles disabled, loading, empty and search-disabled states', async () => {
    const wrapper = view({ disabled: true, selection: 'multiple' })
    await wrapper.get('[aria-label="Details: Portal"]').trigger('click')
    expect(wrapper.emitted('cardClick')).toBeUndefined()
    await wrapper.setProps({ disabled: false, loading: true })
    expect(wrapper.text()).toContain('Karten werden geladen')
    expect(wrapper.find('.tx-cardview-grid').exists()).toBe(false)
    await wrapper.setProps({ loading: false, dataSource: [], searchEnabled: false })
    expect(wrapper.text()).toContain('Keine Karten vorhanden')
    expect(wrapper.find('input[type=search]').exists()).toBe(false)
  })
  it('rejects ambiguous keys and renders user text without HTML interpretation', () => {
    expect(() => view({ dataSource: [{ title: 'No ID' }] })).toThrow('keyExpr')
    expect(() => view({ dataSource: [{ id: 1 }, { id: 1 }] })).toThrow('doppelte')
    const wrapper = view({ dataSource: [{ id: 'x', title: '<img src=x onerror=alert(1)>' }] })
    expect(wrapper.find('img').exists()).toBe(false)
    expect(wrapper.get('h3').text()).toBe('<img src=x onerror=alert(1)>')
  })
})
