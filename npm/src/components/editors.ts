import { computed, defineComponent, h, mergeProps, ref, useId, type PropType } from 'vue'
import type { EditorValue, ValueChangedEvent } from '../types.js'

const editorProps = {
  modelValue: { type: [String, Number, Boolean] as PropType<EditorValue>, default: undefined },
  value: { type: [String, Number, Boolean] as PropType<EditorValue>, default: undefined },
  label: String,
  name: String,
  placeholder: String,
  disabled: Boolean,
  readOnly: Boolean,
  required: Boolean,
  isValid: { type: Boolean, default: true },
  validationMessage: { type: String, default: 'Bitte Eingabe prüfen.' },
  min: [Number, String],
  max: [Number, String],
  step: { type: [Number, String], default: 1 },
  rows: { type: Number, default: 3 },
  items: { type: Array as PropType<unknown[]>, default: () => [] },
  displayExpr: { type: String, default: 'text' },
  valueExpr: { type: String, default: 'value' },
  type: { type: String, default: 'text' }
}

function createEditor(name: string, kind: 'text' | 'textarea' | 'number' | 'checkbox' | 'switch' | 'select' | 'date') {
  return defineComponent({
    name, inheritAttrs: false, props: editorProps,
    emits: {
      'update:modelValue': (_value: EditorValue) => true,
      'update:value': (_value: EditorValue) => true,
      valueChanged: (_event: ValueChangedEvent) => true
    },
    setup(props, { emit, attrs }) {
      const id = useId()
      const toggle = kind === 'checkbox' || kind === 'switch'
      const fallback = toggle ? false : kind === 'number' ? null : ''
      const internal = ref<EditorValue>(fallback)
      const current = computed(() => props.modelValue !== undefined ? props.modelValue : props.value !== undefined ? props.value : internal.value)
      function change(value: EditorValue, event: Event) {
        if (props.disabled || props.readOnly) return
        const previousValue = current.value
        internal.value = value
        emit('update:modelValue', value)
        emit('update:value', value)
        if (!Object.is(value, previousValue)) emit('valueChanged', { value, previousValue, event })
      }
      function itemValue(item: unknown): EditorValue {
        return (item !== null && typeof item === 'object' ? (item as Record<string, EditorValue>)[props.valueExpr] : item) as EditorValue
      }
      function itemText(item: unknown) {
        return String(item !== null && typeof item === 'object' ? (item as Record<string, unknown>)[props.displayExpr] ?? '' : item)
      }
      return () => {
        const inputId = String(attrs.id ?? id)
        const inputProps = mergeProps(attrs, {
          id: inputId, class: ['tx-control', toggle && 'tx-toggle-input'],
          name: props.name, disabled: props.disabled, readonly: props.readOnly, required: props.required,
          'aria-label': props.label || attrs['aria-label'],
          'aria-invalid': !props.isValid || undefined,
          'aria-describedby': !props.isValid ? `${inputId}-error` : attrs['aria-describedby'],
          placeholder: props.placeholder
        })
        let control
        if (toggle) {
          control = h('input', mergeProps(inputProps, { type: 'checkbox', role: kind === 'switch' ? 'switch' : undefined,
            checked: Boolean(current.value), 'aria-checked': Boolean(current.value), 'aria-readonly': props.readOnly || undefined,
            onClick: (event: Event) => { if (props.readOnly) event.preventDefault() },
            onChange: (event: Event) => change((event.target as HTMLInputElement).checked, event) }))
        } else if (kind === 'select') {
          const selected = props.items.findIndex(item => Object.is(itemValue(item), current.value))
          control = h('select', mergeProps(inputProps, { value: selected < 0 ? '' : String(selected),
            'aria-readonly': props.readOnly || undefined,
            onChange: (event: Event) => {
              const target = event.target as HTMLSelectElement
              const value = target.value === '' ? null : itemValue(props.items[Number(target.value)])
              change(value, event)
              if (props.readOnly) target.value = selected < 0 ? '' : String(selected)
            }
          }), [h('option', { value: '', disabled: props.required }, props.placeholder ?? 'Bitte wählen'), ...props.items.map((item, index) => h('option', {
            value: String(index), disabled: !!(item && typeof item === 'object' && (item as Record<string, unknown>).disabled)
          }, itemText(item)))])
        } else {
          control = h(kind === 'textarea' ? 'textarea' : 'input', mergeProps(inputProps, {
            value: current.value ?? '', rows: kind === 'textarea' ? props.rows : undefined,
            type: kind === 'textarea' ? undefined : kind === 'text' ? props.type : kind,
            min: props.min, max: props.max, step: props.step,
            onInput: (event: Event) => {
              const input = event.target as HTMLInputElement
              const value = kind === 'number' ? input.value === '' || !Number.isFinite(input.valueAsNumber) ? null : input.valueAsNumber : input.value
              change(value, event)
            }
          }))
        }
        return h('div', { class: ['tx-field', toggle && 'tx-toggle', kind === 'switch' && 'tx-switch', props.disabled && 'tx-disabled', !props.isValid && 'tx-invalid'] }, [
          toggle ? h('label', { for: inputId, class: 'tx-toggle-label' }, [control, kind === 'switch' && h('span', { class: 'tx-switch-track', 'aria-hidden': 'true' }), h('span', props.label)]) : [props.label && h('label', { for: inputId, class: 'tx-label' }, props.label), control],
          !props.isValid && h('span', { id: `${inputId}-error`, class: 'tx-error' }, props.validationMessage)
        ])
      }
    }
  })
}

export const TxTextBox = createEditor('TxTextBox', 'text')
export const TxTextArea = createEditor('TxTextArea', 'textarea')
export const TxNumberBox = createEditor('TxNumberBox', 'number')
export const TxCheckBox = createEditor('TxCheckBox', 'checkbox')
export const TxSwitch = createEditor('TxSwitch', 'switch')
export const TxSelectBox = createEditor('TxSelectBox', 'select')
export const TxDateBox = createEditor('TxDateBox', 'date')

export const TxButton = defineComponent({
  name: 'TxButton',
  props: { text: String, disabled: Boolean, type: { type: String as PropType<'normal' | 'default' | 'danger' | 'success'>, default: 'normal' }, useSubmitBehavior: Boolean },
  emits: { click: (_event: MouseEvent) => true },
  setup(props, { emit, slots }) {
    return () => h('button', {
      class: ['tx-button', `tx-button-${props.type}`], type: props.useSubmitBehavior ? 'submit' : 'button', disabled: props.disabled,
      onClick: (event: MouseEvent) => { if (!props.disabled) emit('click', event) }
    }, slots.default?.() ?? props.text)
  }
})
