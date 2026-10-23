import { afterEach, describe, expect, it } from 'vitest'
import { mount, type VueWrapper } from '@vue/test-utils'
import { h, Fragment, nextTick } from 'vue'
import { TxColumn, TxDataGrid } from '../src'
import { queryRows } from '../src/data/query'

const rows = [
  { id: 'a', name: 'Anna', city: 'Berlin', amount: 30 },
  { id: 'b', name: 'Ben', city: 'Hamburg', amount: 10 },
  { id: 'c', name: 'Clara', city: 'Berlin', amount: 20 },
  { id: 'd', name: 'Dora', city: 'Berlin', amount: 40 }
]
const columns = [{ dataField: 'name', caption: 'Name' }, { dataField: 'city', caption: 'Stadt' }, { dataField: 'amount', caption: 'Betrag' }]
const mounted: VueWrapper[] = []
function grid(props = {}, slots = {}) { const wrapper = mount(TxDataGrid, { props: { dataSource: rows, columns, ...props }, slots }); mounted.push(wrapper); return wrapper }
const body = (wrapper: VueWrapper) => wrapper.findAll('tbody tr').map(row => row.text())
afterEach(() => mounted.splice(0).forEach(wrapper => wrapper.unmount()))

describe('DataGrid', () => {
  it('combines filters and numeric sort without changing source data', async () => {
    const wrapper = grid()
    await wrapper.get('[aria-label="Stadt filtern"]').setValue('berLIN')
    await wrapper.get('[aria-label="Name filtern"]').setValue('a')
    await wrapper.findAll('.tx-sort')[2].trigger('click')
    expect(body(wrapper)).toEqual(['ClaraBerlin20', 'AnnaBerlin30', 'DoraBerlin40'])
    await wrapper.findAll('.tx-sort')[2].trigger('click')
    expect(body(wrapper)[0]).toBe('DoraBerlin40')
    await wrapper.findAll('.tx-sort')[2].trigger('click')
    expect(body(wrapper)[0]).toBe('AnnaBerlin30')
    expect(rows.map(row => row.id)).toEqual(['a', 'b', 'c', 'd'])
  })
  it('resets paging after filtering and clamps when data shrinks', async () => {
    const wrapper = grid({ pageSize: 2 })
    await wrapper.get('[aria-label="Nächste Seite"]').trigger('click')
    expect(body(wrapper)[0]).toContain('Clara')
    await wrapper.get('[aria-label="Name filtern"]').setValue('Ben')
    expect(body(wrapper)).toEqual(['BenHamburg10'])
    expect(wrapper.get('.tx-pager').text()).toContain('Seite 1 / 1')
    await wrapper.get('[aria-label="Name filtern"]').setValue('')
    await wrapper.get('[aria-label="Nächste Seite"]').trigger('click')
    await wrapper.setProps({ dataSource: rows.slice(0, 1) })
    expect(wrapper.get('.tx-pager').text()).toContain('Seite 1 / 1')
    expect(body(wrapper)[0]).toContain('Anna')
  })
  it('retains selection across pages and filters; selects only the visible page', async () => {
    const wrapper = grid({ pageSize: 2, selection: 'multiple' })
    await wrapper.get('thead input[type=checkbox]').setValue(true)
    await wrapper.get('[aria-label="Nächste Seite"]').trigger('click')
    await wrapper.get('[aria-label="Zeile c auswählen"]').setValue(true)
    expect(wrapper.emitted('update:selectedRowKeys')?.at(-1)).toEqual([['a', 'b', 'c']])
    await wrapper.get('[aria-label="Stadt filtern"]').setValue('Hamburg')
    expect(wrapper.get('[aria-label="Zeile b auswählen"]').element).toHaveProperty('checked', true)
    await wrapper.setProps({ dataSource: rows.filter(row => row.id !== 'b') })
    expect(wrapper.emitted('update:selectedRowKeys')?.at(-1)).toEqual([['a', 'c']])
  })
  it('supports controlled selection and single-selection mode', async () => {
    const wrapper = grid({ selection: { mode: 'single' }, selectedRowKeys: ['a'] })
    await wrapper.get('[aria-label="Zeile c auswählen"]').setValue(true)
    expect(wrapper.emitted('update:selectedRowKeys')?.at(-1)).toEqual([['c']])
    await wrapper.setProps({ selectedRowKeys: ['c'] })
    expect(wrapper.get('[aria-label="Zeile a auswählen"]').element).toHaveProperty('checked', false)
    expect(wrapper.get('[aria-label="Zeile c auswählen"]').element).toHaveProperty('checked', true)
    await wrapper.setProps({ selection: 'none' })
    expect(wrapper.find('tbody input[type=checkbox]').exists()).toBe(false)
    expect(wrapper.emitted('update:selectedRowKeys')?.at(-1)).toEqual([[]])
  })
  it('reads nested column configuration and renders cell slots', () => {
    const wrapper = grid({}, { default: () => h(Fragment, [h(TxColumn, { dataField: 'name', caption: 'Person' }), h(TxColumn, { dataField: 'amount', cellTemplate: 'money', allowSorting: false })]), money: ({ value }: { value: number }) => h('b', `${value} €`) })
    expect(wrapper.findAll('thead th')).toHaveLength(2)
    expect(wrapper.get('tbody b').text()).toBe('30 €')
    expect(wrapper.get('thead').text()).toContain('Person')
  })
  it('reacts to runtime column changes', async () => {
    const wrapper = grid({ columns: [{ dataField: 'name' }] })
    await wrapper.setProps({ columns: [{ dataField: 'city' }] })
    expect(body(wrapper)[0]).toBe('Berlin')
  })
  it('renders loading and empty states and suppresses disabled row events', async () => {
    const wrapper = grid({ loading: true, selection: 'multiple' })
    expect(wrapper.text()).toContain('Wird geladen')
    expect(wrapper.attributes('aria-busy')).toBe('true')
    expect(wrapper.get('.tx-sort').attributes('disabled')).toBeDefined()
    await wrapper.setProps({ loading: false, disabled: true })
    await wrapper.get('tbody tr').trigger('click')
    expect(wrapper.emitted('rowClick')).toBeUndefined()
    await wrapper.setProps({ disabled: false })
    await wrapper.get('tbody tr').trigger('click')
    expect(wrapper.emitted('rowClick')?.[0]?.[0]).toMatchObject({ key: 'a', rowIndex: 0, data: rows[0] })
    await wrapper.setProps({ dataSource: [] })
    expect(wrapper.text()).toContain('Keine Daten vorhanden')
  })
  it('rejects ambiguous row identities', () => {
    expect(() => grid({ dataSource: [{ name: 'Ohne ID' }] })).toThrow('keyExpr')
    expect(() => grid({ dataSource: [{ id: 1 }, { id: 1 }] })).toThrow('doppelte')
  })
  it('handles nested fields, nulls and stable equal-value sorting', async () => {
    expect(queryRows([{ id: 1, user: { city: 'Bonn' }, value: null }, { id: 2, value: 2 }, { id: 3, value: 2 }], {}, { dataField: 'value', desc: false }).map(row => row.id)).toEqual([1, 2, 3])
    expect(queryRows([{ id: 1, user: { city: 'Bonn' } }], { 'user.city': 'bon' }, null)).toHaveLength(1)
    const wrapper = grid({ pageSize: 0, pageIndex: -5 })
    await nextTick()
    expect(body(wrapper)).toHaveLength(1)
  })
})
