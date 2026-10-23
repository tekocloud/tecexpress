import { afterEach, describe, expect, it, vi } from 'vitest'
import { mount, type VueWrapper } from '@vue/test-utils'
import { defineComponent, h, ref } from 'vue'
import { TxButton, TxCheckBox, TxDateBox, TxNumberBox, TxSelectBox, TxSwitch, TxTextArea, TxTextBox } from '../src'

const mounted: VueWrapper[] = []
function render(component: Parameters<typeof mount>[0], options: Record<string, unknown> = {}): VueWrapper {
  const wrapper = mount(component, options); mounted.push(wrapper); return wrapper
}
afterEach(() => { mounted.splice(0).forEach(wrapper => wrapper.unmount()) })

describe('editors', () => {
  it('keeps a parent v-model in sync and reports previous values', async () => {
    const value = ref('alt')
    const parent = render(defineComponent({ setup: () => () => h(TxTextBox, { modelValue: value.value, 'onUpdate:modelValue': next => { value.value = String(next) }, label: 'Name' }) }))
    await parent.get('input').setValue('neu')
    expect(value.value).toBe('neu')
    expect(parent.findComponent(TxTextBox).emitted('valueChanged')?.[0]?.[0]).toMatchObject({ previousValue: 'alt', value: 'neu' })
    expect(parent.get('label').attributes('for')).toBe(parent.get('input').attributes('id'))
  })
  it('supports the named value model and uncontrolled input', async () => {
    const value = ref('vorher')
    const parent = render(defineComponent({ setup: () => () => h(TxTextArea, { value: value.value, 'onUpdate:value': next => { value.value = String(next) } }) }))
    await parent.get('textarea').setValue('nachher')
    expect(value.value).toBe('nachher')
    const uncontrolled = render(TxTextBox)
    await uncontrolled.get('input').setValue('eins')
    await uncontrolled.get('input').setValue('zwei')
    expect(uncontrolled.emitted('valueChanged')?.[1]?.[0]).toMatchObject({ previousValue: 'eins', value: 'zwei' })
  })
  it('preserves numeric types and clears numbers to null', async () => {
    const wrapper = render(TxNumberBox)
    await wrapper.get('input').setValue('12.5')
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([12.5])
    await wrapper.get('input').setValue('')
    expect(wrapper.emitted('update:modelValue')?.[1]).toEqual([null])
  })
  it('uses timezone-free ISO date strings', async () => {
    const wrapper = render(TxDateBox)
    await wrapper.get('input').setValue('2026-10-23')
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['2026-10-23'])
  })
  it.each([TxCheckBox, TxSwitch])('updates boolean values', async component => {
    const wrapper = render(component, { props: { label: 'Aktiv' } })
    await wrapper.get('input').setValue(true)
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([true])
  })
  it('preserves SelectBox numeric values and supports disabled items', async () => {
    const wrapper = render(TxSelectBox, { props: { items: [{ id: 0, name: 'Null' }, { id: 7, name: 'Sieben', disabled: true }], valueExpr: 'id', displayExpr: 'name' } })
    await wrapper.get('select').setValue('0')
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([0])
    expect(wrapper.findAll('option')[2].attributes('disabled')).toBeDefined()
  })
  it.each([TxTextBox, TxTextArea, TxNumberBox, TxCheckBox, TxSwitch, TxSelectBox, TxDateBox])('blocks disabled and read-only changes', async component => {
    for (const state of ['disabled', 'readOnly']) {
      const wrapper = render(component, { props: { [state]: true, items: ['a', 'b'] } })
      const control = wrapper.get('input,select,textarea')
      await control.trigger('input')
      await control.trigger('change')
      expect(wrapper.emitted('update:modelValue')).toBeUndefined()
    }
  })
  it('links errors and forwards native accessibility attributes', () => {
    const wrapper = render(TxTextBox, { props: { label: 'E-Mail', isValid: false, validationMessage: 'Ungültige Adresse' }, attrs: { id: 'email', autocomplete: 'email' } })
    expect(wrapper.get('input').attributes()).toMatchObject({ id: 'email', autocomplete: 'email', 'aria-invalid': 'true', 'aria-describedby': 'email-error' })
    expect(wrapper.get('#email-error').text()).toBe('Ungültige Adresse')
  })
  it('forwards native input listeners alongside model updates', async () => {
    const onInput = vi.fn()
    const wrapper = render(TxTextBox, { attrs: { onInput } })
    await wrapper.get('input').setValue('Hallo')
    expect(onInput).toHaveBeenCalledOnce()
    expect(wrapper.emitted('update:modelValue')).toEqual([['Hallo']])
  })
  it('does not submit forms by default and suppresses disabled clicks', async () => {
    const wrapper = render(TxButton, { props: { text: 'Speichern', disabled: true } })
    await wrapper.get('button').trigger('click')
    expect(wrapper.emitted('click')).toBeUndefined()
    expect(wrapper.get('button').attributes('type')).toBe('button')
    await wrapper.setProps({ disabled: false, useSubmitBehavior: true })
    await wrapper.get('button').trigger('click')
    expect(wrapper.emitted('click')).toHaveLength(1)
    expect(wrapper.get('button').attributes('type')).toBe('submit')
  })
})
