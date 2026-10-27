import { useTxSource } from '../data/vue-source.js'
import type { TxSource } from '../data/source.js'
import { computed, defineComponent, h, ref, useId, type PropType } from 'vue'
import type { Item } from '../types.js'

function itemText(item: string | Item) {
  return typeof item === 'string' ? item : item.text
}
function disabled(item: string | Item) {
  return typeof item === 'object' && !!item.disabled
}

export const TxTabs = defineComponent({
  name: 'TxTabs',
  props: {
    dataSource: [Array, Object] as PropType<TxSource<string | Item>>,
    items: { type: Array as PropType<(string | Item)[]>, default: () => [] },
    selectedIndex: { type: Number, default: undefined },
    modelValue: { type: Number, default: undefined },
    disabled: Boolean,
    label: { type: String, default: 'Reiter' },
    orientation: { type: String, default: 'horizontal' },
    scrollByContent: { type: Boolean, default: true },
    swipeEnabled: Boolean,
  },
  emits: {
    'update:modelValue': (_index: number) => true,
    'update:selectedIndex': (_index: number) => true,
    selectionChanged: (_event: {
      selectedIndex: number
      itemData: string | Item
    }) => true,
  },
  setup(props, { emit, slots }) {
    const binding = useTxSource(
      () => props.dataSource,
      () => props.items,
    )
    const id = useId(),
      internal = ref(0),
      root = ref<HTMLElement>()
    let touchStart = 0
    const selected = computed(() => {
      const requested =
        props.modelValue ?? props.selectedIndex ?? internal.value
      return binding.items.value[requested] !== undefined &&
        !disabled(binding.items.value[requested])
        ? requested
        : binding.items.value.findIndex((item) => !disabled(item))
    })
    function select(index: number) {
      if (
        props.disabled ||
        binding.items.value[index] === undefined ||
        disabled(binding.items.value[index])
      )
        return
      internal.value = index
      emit('update:modelValue', index)
      emit('update:selectedIndex', index)
      emit('selectionChanged', {
        selectedIndex: index,
        itemData: binding.items.value[index],
      })
    }
    function keydown(event: KeyboardEvent, index: number) {
      if (
        props.disabled ||
        ![
          'ArrowLeft',
          'ArrowRight',
          'ArrowUp',
          'ArrowDown',
          'Home',
          'End',
        ].includes(event.key)
      )
        return
      event.preventDefault()
      const enabled = binding.items.value
        .map((_, i) => i)
        .filter((i) => !disabled(binding.items.value[i]))
      if (!enabled.length) return
      const current = enabled.indexOf(index)
      const next =
        event.key === 'Home'
          ? enabled[0]
          : event.key === 'End'
            ? enabled.at(-1)!
            : enabled[
                (current +
                  (['ArrowRight', 'ArrowDown'].includes(event.key) ? 1 : -1) +
                  enabled.length) %
                  enabled.length
              ]
      select(next)
      root.value
        ?.querySelectorAll<HTMLButtonElement>('[role="tab"]')
        [next]?.focus()
    }
    return () =>
      h('div', { class: 'tx-tabs', ref: root }, [
        h(
          'div',
          {
            role: 'tablist',
            'aria-label': props.label,
            'aria-orientation': props.orientation,
            class: 'tx-tablist',
            style: {
              overflowX: props.scrollByContent ? 'auto' : undefined,
              flexDirection:
                props.orientation === 'vertical' ? 'column' : undefined,
            },
          },
          binding.items.value.map((item, index) =>
            h(
              'button',
              {
                type: 'button',
                role: 'tab',
                id: `${id}-tab-${index}`,
                'aria-controls': slots.default ? `${id}-panel` : undefined,
                'aria-selected': selected.value === index,
                tabindex: selected.value === index ? 0 : -1,
                disabled: props.disabled || disabled(item),
                class: ['tx-tab', selected.value === index && 'tx-active'],
                onClick: () => select(index),
                onKeydown: (event: KeyboardEvent) => keydown(event, index),
              },
              [
                typeof item !== 'string' &&
                  item.icon &&
                  h('span', { 'aria-hidden': true }, item.icon),
                itemText(item),
              ],
            ),
          ),
        ),
        slots.default &&
          selected.value >= 0 &&
          h(
            'div',
            {
              role: 'tabpanel',
              id: `${id}-panel`,
              'aria-labelledby': `${id}-tab-${selected.value}`,
              tabindex: 0,
              class: 'tx-tabpanel',
              onTouchstart: (e: TouchEvent) =>
                (touchStart = e.touches[0].clientX),
              onTouchend: (e: TouchEvent) => {
                if (!props.swipeEnabled) return
                const delta = e.changedTouches[0].clientX - touchStart
                if (Math.abs(delta) > 40) {
                  const enabled = binding.items.value
                    .map((_, i) => i)
                    .filter((i) => !disabled(binding.items.value[i]))
                  const current = enabled.indexOf(selected.value)
                  select(
                    enabled[
                      Math.max(
                        0,
                        Math.min(
                          enabled.length - 1,
                          current + (delta < 0 ? 1 : -1),
                        ),
                      )
                    ],
                  )
                }
              },
            },
            slots.default({
              selectedIndex: selected.value,
              item: binding.items.value[selected.value],
            }),
          ),
      ])
  },
})

export const TxToolbar = defineComponent({
  name: 'TxToolbar',
  props: { label: { type: String, default: 'Werkzeugleiste' } },
  setup(props, { slots }) {
    return () =>
      h(
        'div',
        { class: 'tx-toolbar', role: 'group', 'aria-label': props.label },
        [
          h('div', { class: 'tx-toolbar-start' }, slots.default?.()),
          slots.after && h('div', { class: 'tx-toolbar-end' }, slots.after()),
        ],
      )
  },
})

export const TxMenu = defineComponent({
  name: 'TxMenu',
  props: {
    dataSource: [Array, Object] as PropType<TxSource<string | Item>>,
    items: { type: Array as PropType<(string | Item)[]>, default: () => [] },
    disabled: Boolean,
    label: { type: String, default: 'Menü' },
  },
  emits: {
    itemClick: (_event: {
      itemData: string | Item
      itemIndex: number
      event: MouseEvent
    }) => true,
  },
  setup(props, { emit }) {
    const binding = useTxSource(
      () => props.dataSource,
      () => props.items,
    )
    return () =>
      h(
        'nav',
        { class: 'tx-menu', 'aria-label': props.label },
        binding.items.value.map((item, itemIndex) =>
          h(
            'button',
            {
              type: 'button',
              class: 'tx-button',
              disabled: props.disabled || disabled(item),
              onClick: (event: MouseEvent) => {
                if (!props.disabled && !disabled(item))
                  emit('itemClick', { itemData: item, itemIndex, event })
              },
            },
            itemText(item),
          ),
        ),
      )
  },
})
