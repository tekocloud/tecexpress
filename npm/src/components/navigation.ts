import { computed, defineComponent, h, ref, useId, type PropType } from 'vue'
import type { Item } from '../types.js'

function itemText(item: string | Item) { return typeof item === 'string' ? item : item.text }
function disabled(item: string | Item) { return typeof item === 'object' && !!item.disabled }

export const TxTabs = defineComponent({
  name: 'TxTabs',
  props: {
    items: { type: Array as PropType<(string | Item)[]>, default: () => [] },
    selectedIndex: { type: Number, default: undefined },
    modelValue: { type: Number, default: undefined }, disabled: Boolean,
    label: { type: String, default: 'Reiter' }
  },
  emits: { 'update:modelValue': (_index: number) => true, 'update:selectedIndex': (_index: number) => true, selectionChanged: (_event: { selectedIndex: number; itemData: string | Item }) => true },
  setup(props, { emit, slots }) {
    const id = useId(), internal = ref(0), root = ref<HTMLElement>()
    const selected = computed(() => {
      const requested = props.modelValue ?? props.selectedIndex ?? internal.value
      return props.items[requested] !== undefined && !disabled(props.items[requested]) ? requested : props.items.findIndex(item => !disabled(item))
    })
    function select(index: number) {
      if (props.disabled || props.items[index] === undefined || disabled(props.items[index])) return
      internal.value = index
      emit('update:modelValue', index); emit('update:selectedIndex', index)
      emit('selectionChanged', { selectedIndex: index, itemData: props.items[index] })
    }
    function keydown(event: KeyboardEvent, index: number) {
      if (props.disabled || !['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) return
      event.preventDefault()
      const enabled = props.items.map((_, i) => i).filter(i => !disabled(props.items[i]))
      if (!enabled.length) return
      const current = enabled.indexOf(index)
      const next = event.key === 'Home' ? enabled[0] : event.key === 'End' ? enabled.at(-1)! : enabled[(current + (event.key === 'ArrowRight' ? 1 : -1) + enabled.length) % enabled.length]
      select(next)
      root.value?.querySelectorAll<HTMLButtonElement>('[role="tab"]')[next]?.focus()
    }
    return () => h('div', { class: 'tx-tabs', ref: root }, [
      h('div', { role: 'tablist', 'aria-label': props.label, class: 'tx-tablist' }, props.items.map((item, index) => h('button', {
        type: 'button', role: 'tab', id: `${id}-tab-${index}`, 'aria-controls': slots.default ? `${id}-panel` : undefined,
        'aria-selected': selected.value === index, tabindex: selected.value === index ? 0 : -1,
        disabled: props.disabled || disabled(item), class: ['tx-tab', selected.value === index && 'tx-active'],
        onClick: () => select(index), onKeydown: (event: KeyboardEvent) => keydown(event, index)
      }, itemText(item)))),
      slots.default && selected.value >= 0 && h('div', { role: 'tabpanel', id: `${id}-panel`, 'aria-labelledby': `${id}-tab-${selected.value}`, tabindex: 0, class: 'tx-tabpanel' }, slots.default({ selectedIndex: selected.value, item: props.items[selected.value] }))
    ])
  }
})

export const TxToolbar = defineComponent({
  name: 'TxToolbar', props: { label: { type: String, default: 'Werkzeugleiste' } },
  setup(props, { slots }) {
    return () => h('div', { class: 'tx-toolbar', role: 'group', 'aria-label': props.label }, [
      h('div', { class: 'tx-toolbar-start' }, slots.default?.()),
      slots.after && h('div', { class: 'tx-toolbar-end' }, slots.after())
    ])
  }
})

export const TxMenu = defineComponent({
  name: 'TxMenu',
  props: { items: { type: Array as PropType<(string | Item)[]>, default: () => [] }, disabled: Boolean, label: { type: String, default: 'Menü' } },
  emits: { itemClick: (_event: { itemData: string | Item; itemIndex: number; event: MouseEvent }) => true },
  setup(props, { emit }) {
    return () => h('nav', { class: 'tx-menu', 'aria-label': props.label }, props.items.map((item, itemIndex) => h('button', {
      type: 'button', class: 'tx-button', disabled: props.disabled || disabled(item),
      onClick: (event: MouseEvent) => { if (!props.disabled && !disabled(item)) emit('itemClick', { itemData: item, itemIndex, event }) }
    }, itemText(item))))
  }
})
