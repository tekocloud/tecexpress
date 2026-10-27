import {
  computed,
  defineComponent,
  h,
  onBeforeUnmount,
  nextTick,
  ref,
  watch,
  type PropType,
} from 'vue'
import { useTxSource } from '../data/vue-source.js'
import { txRead, type TxSource } from '../data/source.js'
import { TxPopup } from './overlays.js'
export interface TxCollectionItem {
  id?: string | number
  value?: unknown
  text: string
  icon?: string
  disabled?: boolean
  group?: string
  imageUrl?: string
  items?: TxCollectionItem[]
  destructive?: boolean
  separator?: boolean
}
export type TxEntry = string | TxCollectionItem
export const txText = (item: TxEntry) =>
  typeof item === 'string' ? item : item.text
export const txValue = (item: TxEntry) =>
  typeof item === 'string' ? item : (item.value ?? item.id ?? item.text)
const off = (item: TxEntry) => typeof item !== 'string' && item.disabled
const entriesProps = {
  items: { type: Array as PropType<TxEntry[]>, default: () => [] },
  dataSource: [Array, Object] as PropType<TxSource<TxEntry>>,
  disabled: Boolean,
  label: String,
}
function choice(name: string, radio: boolean) {
  return defineComponent({
    name,
    props: {
      ...entriesProps,
      modelValue: null,
      selectionMode: {
        type: String as PropType<'none' | 'single' | 'multiple'>,
        default: 'single',
      },
      layout: { type: String, default: 'horizontal' },
    },
    emits: ['update:modelValue', 'selectionChanged', 'itemClick'],
    setup(p, { emit, slots }) {
      const binding = useTxSource(
          () => p.dataSource,
          () => p.items,
        ),
        internal = ref<unknown>(radio ? null : undefined)
      const value = computed(() =>
        p.modelValue === undefined ? internal.value : p.modelValue,
      )
      function select(item: TxEntry) {
        if (p.disabled || off(item)) return
        const key = txValue(item)
        const next =
          !radio && p.selectionMode === 'multiple'
            ? (Array.isArray(value.value) ? value.value : []).includes(key)
              ? value.value.filter((v: unknown) => v !== key)
              : [...(Array.isArray(value.value) ? value.value : []), key]
            : key
        if (radio || p.selectionMode !== 'none') {
          internal.value = next
          emit('update:modelValue', next)
          emit('selectionChanged', { value: next, itemData: item })
        }
        emit('itemClick', { itemData: item })
      }
      return () =>
        h(
          'div',
          {
            class: [
              'tx-choice',
              radio && 'tx-radio-group',
              p.layout === 'vertical' && 'tx-vertical',
            ],
            role: radio ? 'radiogroup' : 'group',
            'aria-label': p.label ?? name,
            'aria-busy': binding.loading.value,
          },
          [
            !!binding.error.value &&
              h('span', { role: 'alert' }, String(binding.error.value)),
            ...binding.items.value.map((item) => {
              const selected = Array.isArray(value.value)
                ? value.value.includes(txValue(item))
                : value.value === txValue(item)
              return h(
                'button',
                {
                  type: 'button',
                  class: ['tx-button', selected && 'tx-active'],
                  role: radio ? 'radio' : undefined,
                  'aria-checked': radio ? selected : undefined,
                  'aria-pressed':
                    !radio && p.selectionMode !== 'none' ? selected : undefined,
                  disabled: p.disabled || off(item),
                  onClick: () => select(item),
                  onKeydown: (e: KeyboardEvent) => {
                    if (
                      ![
                        'ArrowLeft',
                        'ArrowRight',
                        'ArrowUp',
                        'ArrowDown',
                        'Home',
                        'End',
                      ].includes(e.key)
                    )
                      return
                    e.preventDefault()
                    const enabled = binding.items.value.filter((v) => !off(v))
                    const index = enabled.indexOf(item)
                    const next =
                      e.key === 'Home'
                        ? enabled[0]
                        : e.key === 'End'
                          ? enabled.at(-1)
                          : enabled[
                              (index +
                                (['ArrowLeft', 'ArrowUp'].includes(e.key)
                                  ? -1
                                  : 1) +
                                enabled.length) %
                                enabled.length
                            ]
                    if (next) {
                      select(next)
                      const root = (e.currentTarget as HTMLElement)
                        .parentElement
                      ;(
                        root?.children[
                          binding.items.value.indexOf(next)
                        ] as HTMLElement
                      )?.focus()
                    }
                  },
                },
                slots.item?.({ item, selected }) ?? [
                  typeof item !== 'string' && item.icon
                    ? h('span', { 'aria-hidden': true }, item.icon)
                    : null,
                  txText(item),
                ],
              )
            }),
          ],
        )
    },
  })
}
export const TxRadioGroup = choice('TxRadioGroup', true)
export const TxButtonGroup = choice('TxButtonGroup', false)

function lookup(name: string, multiple: boolean) {
  return defineComponent({
    name,
    props: {
      ...entriesProps,
      modelValue: null,
      placeholder: { type: String, default: 'Auswählen …' },
      searchEnabled: { type: Boolean, default: true },
      acceptCustomValue: Boolean,
      showSelectionControls: Boolean,
      showClearButton: { type: Boolean, default: true },
      maxDisplayedTags: { type: Number, default: 4 },
      applyValueMode: { type: String, default: 'instantly' },
    },
    emits: ['update:modelValue', 'valueChanged', 'customItemCreating'],
    setup(p, { emit, slots }) {
      const b = useTxSource(
          () => p.dataSource,
          () => p.items,
        ),
        open = ref(false),
        search = ref(''),
        draft = ref<unknown[]>([]),
        custom = ref<TxEntry[]>([]),
        resolved = ref<TxEntry[]>([]),
        internal = ref<unknown>(multiple ? [] : null),
        error = ref('')
      const value = computed(() =>
          p.modelValue === undefined ? internal.value : p.modelValue,
        ),
        selected = computed<unknown[]>(() =>
          multiple
            ? Array.isArray(value.value)
              ? value.value
              : []
            : value.value == null
              ? []
              : [value.value],
        )
      const all = computed(() =>
        [...b.items.value, ...custom.value, ...resolved.value].filter(
          (v, i, a) => a.findIndex((x) => txValue(x) === txValue(v)) === i,
        ),
      )
      const filtered = computed(() =>
        b.source.value
          ? [...b.items.value, ...custom.value]
          : all.value.filter((v) =>
              txText(v)
                .toLocaleLowerCase()
                .includes(search.value.toLocaleLowerCase()),
            ),
      )
      let resolveVersion = 0
      watch(
        [selected, b.source],
        async () => {
          const version = ++resolveVersion,
            source = b.source.value
          if (!source?.store.byKey) return
          try {
            const missing = selected.value.filter(
              (k) => !all.value.some((v) => txValue(v) === k),
            )
            const items = await Promise.all(
              missing.map((k) => source.byKey(k as string | number)),
            )
            if (version === resolveVersion)
              resolved.value = items.filter(
                (v): v is TxEntry => v !== undefined,
              )
          } catch (e) {
            error.value = String(e)
          }
        },
        { immediate: true },
      )
      watch(search, (text) => {
        if (b.source.value)
          void b.source.value
            .configure({
              searchValue: text,
              searchExpr: [(v: TxEntry) => txText(v)],
            })
            .catch(() => {})
      })
      function commit(next: unknown[]) {
        const result = multiple ? next : (next[0] ?? null)
        internal.value = result
        emit('update:modelValue', result)
        emit('valueChanged', { value: result })
        if (!multiple) open.value = false
      }
      function choose(item: TxEntry) {
        if (p.disabled || off(item)) return
        const k = txValue(item),
          current =
            p.applyValueMode === 'useButtons' ? draft.value : selected.value
        const next = multiple
          ? current.includes(k)
            ? current.filter((v) => v !== k)
            : [...current, k]
          : [k]
        draft.value = next
        if (p.applyValueMode !== 'useButtons') commit(next)
      }
      const caption = (k: unknown) => {
        const item = all.value.find((v) => txValue(v) === k)
        return item ? txText(item) : String(k)
      }
      return () =>
        h('div', { class: 'tx-lookup', 'aria-busy': b.loading.value }, [
          h('div', { class: 'tx-choice' }, [
            multiple &&
              selected.value.slice(0, p.maxDisplayedTags).map((k) =>
                h('span', { class: 'tx-tag' }, [
                  caption(k),
                  h(
                    'button',
                    {
                      type: 'button',
                      disabled: p.disabled,
                      'aria-label': `${caption(k)} entfernen`,
                      onClick: () =>
                        commit(selected.value.filter((v) => v !== k)),
                    },
                    '×',
                  ),
                ]),
              ),
            multiple &&
              selected.value.length > p.maxDisplayedTags &&
              h(
                'span',
                { class: 'tx-tag' },
                `+${selected.value.length - p.maxDisplayedTags}`,
              ),
            h(
              'button',
              {
                class: 'tx-control',
                type: 'button',
                disabled: p.disabled,
                'aria-haspopup': 'dialog',
                'aria-expanded': open.value,
                onClick: () => {
                  draft.value = [...selected.value]
                  open.value = !open.value
                },
              },
              !multiple && selected.value.length
                ? caption(selected.value[0])
                : p.placeholder,
            ),
            p.showClearButton &&
              selected.value.length > 0 &&
              h(
                'button',
                {
                  type: 'button',
                  disabled: p.disabled,
                  'aria-label': 'Auswahl leeren',
                  onClick: () => commit([]),
                },
                '×',
              ),
          ]),
          h(
            TxPopup,
            {
              visible: open.value,
              title: p.label ?? p.placeholder,
              hideOnOutsideClick: true,
              'onUpdate:visible': (v: boolean) => (open.value = v),
            },
            {
              default: () => [
                p.searchEnabled &&
                  h('input', {
                    class: 'tx-control',
                    type: 'search',
                    'aria-label': 'Suchen',
                    value: search.value,
                    onInput: (e: Event) =>
                      (search.value = (e.target as HTMLInputElement).value),
                  }),
                (b.error.value || error.value) &&
                  h(
                    'div',
                    { role: 'alert' },
                    String(b.error.value || error.value),
                  ),
                b.loading.value && h('div', { role: 'status' }, 'Laden …'),
                multiple &&
                  p.showSelectionControls &&
                  h(
                    'button',
                    {
                      type: 'button',
                      onClick: () => {
                        const keys = filtered.value
                          .filter((v) => !off(v))
                          .map(txValue)
                        draft.value = keys
                        if (p.applyValueMode !== 'useButtons') commit(keys)
                      },
                    },
                    'Alle geladenen auswählen',
                  ),
                h(
                  'div',
                  {
                    role: 'listbox',
                    'aria-label': p.label ?? name,
                    'aria-multiselectable': multiple,
                    class: 'tx-options',
                  },
                  filtered.value.map((item) =>
                    h(
                      'button',
                      {
                        type: 'button',
                        role: 'option',
                        'aria-selected': (p.applyValueMode === 'useButtons'
                          ? draft.value
                          : selected.value
                        ).includes(txValue(item)),
                        disabled: off(item),
                        class: 'tx-option',
                        onClick: () => choose(item),
                      },
                      slots.item?.({ item }) ?? [
                        typeof item !== 'string' &&
                          item.group &&
                          h('small', item.group),
                        txText(item),
                      ],
                    ),
                  ),
                ),
                !filtered.value.length && h('p', 'Keine Einträge'),
                p.acceptCustomValue &&
                  search.value.trim() &&
                  h(
                    'button',
                    {
                      type: 'button',
                      onClick: () => {
                        const item = search.value.trim()
                        custom.value.push(item)
                        emit('customItemCreating', { text: item })
                        choose(item)
                        search.value = ''
                      },
                    },
                    `„${search.value}“ hinzufügen`,
                  ),
                b.source.value &&
                  b.source.value.items.length < b.source.value.totalCount &&
                  h(
                    'button',
                    {
                      type: 'button',
                      onClick: () => {
                        const s = b.source.value!
                        void s
                          .configure({
                            pageSize: (s.config.pageSize ?? 20) + 20,
                          })
                          .catch(() => {})
                      },
                    },
                    'Mehr laden',
                  ),
              ],
              footer: () =>
                p.applyValueMode === 'useButtons'
                  ? [
                      h(
                        'button',
                        {
                          type: 'button',
                          onClick: () => {
                            commit(draft.value)
                            open.value = false
                          },
                        },
                        'Übernehmen',
                      ),
                      h(
                        'button',
                        { type: 'button', onClick: () => (open.value = false) },
                        'Abbrechen',
                      ),
                    ]
                  : [],
            },
          ),
        ])
    },
  })
}
export const TxLookup = lookup('TxLookup', false)
export const TxTagBox = lookup('TxTagBox', true)

export const TxList = defineComponent({
  name: 'TxList',
  props: {
    ...entriesProps,
    modelValue: { type: Array as PropType<unknown[]>, default: () => [] },
    selectionMode: { type: String, default: 'none' },
    searchEnabled: Boolean,
    grouped: Boolean,
    allowDeleting: Boolean,
    allowReordering: Boolean,
    virtual: Boolean,
    itemHeight: { type: Number, default: 44 },
    height: { type: Number, default: 300 },
  },
  emits: ['update:modelValue', 'itemClick', 'itemDeleted', 'itemReordered'],
  setup(p, { emit, slots }) {
    const b = useTxSource(
        () => p.dataSource,
        () => p.items,
      ),
      search = ref(''),
      scroll = ref(0),
      deleted = ref<unknown[]>([]),
      order = ref<TxEntry[]>()
    const groupOf = (item: TxEntry | undefined) =>
      item && typeof item !== 'string' ? (item.group ?? '') : ''
    const filtered = computed(() => {
      const result = (order.value ?? b.items.value).filter(
        (v) =>
          !deleted.value.includes(txValue(v)) &&
          (b.source.value ||
            txText(v)
              .toLocaleLowerCase()
              .includes(search.value.toLocaleLowerCase())),
      )
      return p.grouped && !b.source.value
        ? result.sort((a, b) => groupOf(a).localeCompare(groupOf(b)))
        : result
    })
    watch(search, (text) => {
      if (b.source.value)
        void b.source.value
          .configure({
            searchValue: text,
            searchExpr: [(v: TxEntry) => txText(v)],
          })
          .catch(() => {})
    })
    const start = computed(() =>
        p.virtual
          ? Math.max(0, Math.floor(scroll.value / p.itemHeight) - 3)
          : 0,
      ),
      end = computed(() =>
        p.virtual
          ? Math.min(
              filtered.value.length,
              start.value + Math.ceil(p.height / p.itemHeight) + 6,
            )
          : filtered.value.length,
      )
    return () =>
      h(
        'section',
        {
          class: 'tx-list',
          'aria-label': p.label ?? 'Liste',
          'aria-busy': b.loading.value,
        },
        [
          p.searchEnabled &&
            h('input', {
              class: 'tx-control',
              type: 'search',
              'aria-label': 'Liste durchsuchen',
              value: search.value,
              onInput: (e: Event) =>
                (search.value = (e.target as HTMLInputElement).value),
            }),
          !!b.error.value && h('p', { role: 'alert' }, String(b.error.value)),
          h(
            'div',
            {
              style: { height: `${p.height}px`, overflow: 'auto' },
              onScroll: (e: Event) =>
                (scroll.value = (e.target as HTMLElement).scrollTop),
            },
            [
              h(
                'div',
                {
                  role: 'list',
                  style: {
                    paddingTop: `${start.value * p.itemHeight}px`,
                    paddingBottom: `${(filtered.value.length - end.value) * p.itemHeight}px`,
                  },
                },
                filtered.value
                  .slice(start.value, end.value)
                  .map((item, local) => {
                    const index = start.value + local,
                      selected = p.modelValue.includes(txValue(item))
                    return h(
                      'div',
                      {
                        role: 'listitem',
                        class: 'tx-list-row',
                        style: p.virtual
                          ? {
                              height: `${p.itemHeight}px`,
                              boxSizing: 'border-box',
                            }
                          : undefined,
                      },
                      [
                        p.grouped &&
                          groupOf(item) &&
                          (index === 0 ||
                            groupOf(filtered.value[index - 1]) !==
                              groupOf(item)) &&
                          h(
                            'small',
                            {
                              class: 'tx-list-group',
                              role: 'heading',
                              'aria-level': 3,
                            },
                            groupOf(item),
                          ),
                        h(
                          'button',
                          {
                            class: 'tx-option',
                            type: 'button',
                            disabled: p.disabled || off(item),
                            'aria-pressed':
                              p.selectionMode !== 'none' ? selected : undefined,
                            onClick: () => {
                              emit('itemClick', {
                                itemData: item,
                                itemIndex: index,
                              })
                              if (p.selectionMode !== 'none')
                                emit(
                                  'update:modelValue',
                                  p.selectionMode === 'single'
                                    ? [txValue(item)]
                                    : selected
                                      ? p.modelValue.filter(
                                          (v) => v !== txValue(item),
                                        )
                                      : [...p.modelValue, txValue(item)],
                                )
                            },
                          },
                          slots.item?.({ item, index, selected }) ??
                            txText(item),
                        ),
                        p.allowDeleting &&
                          h(
                            'button',
                            {
                              type: 'button',
                              disabled: p.disabled,
                              'aria-label': `${txText(item)} löschen`,
                              onClick: async () => {
                                try {
                                  if (b.source.value)
                                    await b.source.value.remove(
                                      txValue(item) as string | number,
                                    )
                                  else deleted.value.push(txValue(item))
                                  emit('itemDeleted', { itemData: item })
                                  emit(
                                    'update:modelValue',
                                    p.modelValue.filter(
                                      (v) => v !== txValue(item),
                                    ),
                                  )
                                } catch {
                                  /* source exposes the failure */
                                }
                              },
                            },
                            '×',
                          ),
                        p.allowReordering &&
                          h(
                            'button',
                            {
                              type: 'button',
                              disabled: p.disabled || index === 0,
                              'aria-label': 'Nach oben',
                              onClick: () => {
                                const next = [...filtered.value]
                                ;[next[index - 1], next[index]] = [
                                  next[index],
                                  next[index - 1],
                                ]
                                order.value = next
                                emit('itemReordered', {
                                  itemData: item,
                                  fromIndex: index,
                                  toIndex: index - 1,
                                  items: next,
                                })
                              },
                            },
                            '↑',
                          ),
                      ],
                    )
                  }),
              ),
            ],
          ),
          !filtered.value.length && h('p', 'Keine Einträge'),
          b.source.value &&
            h('div', { class: 'tx-choice' }, [
              h(
                'button',
                {
                  type: 'button',
                  disabled:
                    b.loading.value || !(b.source.value.config.pageIndex ?? 0),
                  onClick: () =>
                    void b.source
                      .value!.configure({
                        pageIndex: (b.source.value!.config.pageIndex ?? 0) - 1,
                      })
                      .catch(() => {}),
                },
                'Zurück',
              ),
              h(
                'button',
                {
                  type: 'button',
                  disabled:
                    b.loading.value ||
                    ((b.source.value.config.pageIndex ?? 0) + 1) *
                      (b.source.value.config.pageSize ?? 20) >=
                      b.source.value.totalCount,
                  onClick: () =>
                    void b.source
                      .value!.configure({
                        pageIndex: (b.source.value!.config.pageIndex ?? 0) + 1,
                      })
                      .catch(() => {}),
                },
                'Weiter',
              ),
            ]),
        ],
      )
  },
})

export const TxGallery = defineComponent({
  name: 'TxGallery',
  props: {
    ...entriesProps,
    selectedIndex: { type: Number, default: undefined },
    loop: Boolean,
    slideshowDelay: { type: Number, default: 0 },
    showIndicator: { type: Boolean, default: true },
    height: { type: Number, default: 240 },
  },
  emits: ['update:selectedIndex'],
  setup(p, { emit, slots }) {
    const b = useTxSource(
        () => p.dataSource,
        () => p.items,
      ),
      internal = ref(0),
      paused = ref(false),
      index = computed(() =>
        Math.max(
          0,
          Math.min(p.selectedIndex ?? internal.value, b.items.value.length - 1),
        ),
      )
    function go(i: number) {
      if (p.disabled || !b.items.value.length) return
      const n = b.items.value.length
      internal.value = p.loop ? (i + n) % n : Math.max(0, Math.min(i, n - 1))
      emit('update:selectedIndex', internal.value)
    }
    let timer: ReturnType<typeof setInterval> | undefined,
      touch = 0
    watch(
      () => p.slideshowDelay,
      (delay) => {
        clearInterval(timer)
        if (delay > 0)
          timer = setInterval(() => {
            if (
              !paused.value &&
              !matchMedia('(prefers-reduced-motion: reduce)').matches
            )
              go(index.value + 1)
          }, delay)
      },
      { immediate: true },
    )
    onBeforeUnmount(() => clearInterval(timer))
    return () => {
      const item = b.items.value[index.value]
      return h(
        'section',
        {
          class: 'tx-gallery',
          role: 'region',
          'aria-roledescription': 'Karussell',
          'aria-label': p.label ?? 'Galerie',
          tabindex: 0,
          onMouseenter: () => (paused.value = true),
          onMouseleave: () => (paused.value = false),
          onFocusin: () => (paused.value = true),
          onFocusout: () => (paused.value = false),
          onKeydown: (e: KeyboardEvent) => {
            if (e.key === 'ArrowLeft' || e.key === 'ArrowRight') {
              e.preventDefault()
              go(index.value + (e.key === 'ArrowRight' ? 1 : -1))
            }
          },
          onTouchstart: (e: TouchEvent) => (touch = e.touches[0].clientX),
          onTouchend: (e: TouchEvent) => {
            const dx = e.changedTouches[0].clientX - touch
            if (Math.abs(dx) > 40) go(index.value + (dx > 0 ? -1 : 1))
          },
        },
        [
          h(
            'div',
            {
              key: index.value,
              class: 'tx-gallery-stage',
              style: { height: `${p.height}px` },
            },
            item === undefined
              ? 'Keine Bilder'
              : (slots.item?.({ item, index: index.value }) ??
                  h('img', {
                    src: typeof item === 'string' ? item : item.imageUrl,
                    alt: txText(item),
                  })),
          ),
          h('div', { class: 'tx-choice' }, [
            h(
              'button',
              {
                type: 'button',
                disabled: p.disabled || (!p.loop && index.value === 0),
                onClick: () => go(index.value - 1),
                'aria-label': 'Vorheriges Bild',
              },
              '‹',
            ),
            p.showIndicator &&
              b.items.value.map((_, i) =>
                h(
                  'button',
                  {
                    type: 'button',
                    disabled: p.disabled,
                    'aria-label': `Bild ${i + 1}`,
                    'aria-current': i === index.value,
                    onClick: () => go(i),
                  },
                  i === index.value ? '●' : '○',
                ),
              ),
            h(
              'button',
              {
                type: 'button',
                disabled:
                  p.disabled ||
                  (!p.loop && index.value >= b.items.value.length - 1),
                onClick: () => go(index.value + 1),
                'aria-label': 'Nächstes Bild',
              },
              '›',
            ),
          ]),
        ],
      )
    }
  },
})

export const TxFloatingActionButton = defineComponent({
  name: 'TxFloatingActionButton',
  props: {
    ...entriesProps,
    icon: { type: String, default: '+' },
    position: { type: String, default: 'bottom-right' },
  },
  emits: ['itemClick'],
  setup(p, { emit }) {
    const b = useTxSource(
        () => p.dataSource,
        () => p.items,
      ),
      open = ref(false)
    return () =>
      h('div', { class: ['tx-fab', `tx-${p.position}`] }, [
        open.value &&
          b.items.value.map((item) =>
            h(
              'button',
              {
                class: 'tx-button',
                type: 'button',
                disabled: p.disabled || off(item),
                onClick: () => {
                  emit('itemClick', { itemData: item })
                  open.value = false
                },
              },
              txText(item),
            ),
          ),
        h(
          'button',
          {
            class: 'tx-fab-trigger',
            type: 'button',
            disabled: p.disabled,
            'aria-label': p.label ?? 'Aktionen',
            'aria-expanded': open.value,
            onClick: () => {
              if (b.items.value.length === 1)
                emit('itemClick', { itemData: b.items.value[0] })
              else open.value = !open.value
            },
          },
          open.value ? '×' : p.icon,
        ),
      ])
  },
})

export const TxActionSheet = defineComponent({
  name: 'TxActionSheet',
  props: {
    ...entriesProps,
    visible: Boolean,
    title: String,
    cancelText: { type: String, default: 'Abbrechen' },
  },
  emits: ['update:visible', 'itemClick'],
  setup(p, { emit, slots }) {
    const b = useTxSource(
      () => p.dataSource,
      () => p.items,
    )
    return () =>
      h(
        TxPopup,
        {
          visible: p.visible,
          title: p.title ?? 'Aktionen',
          position: 'bottom',
          hideOnOutsideClick: true,
          'onUpdate:visible': (v: boolean) => emit('update:visible', v),
        },
        {
          default: () =>
            h('div', { class: 'tx-choice tx-vertical' }, [
              ...b.items.value.map((item) =>
                h(
                  'button',
                  {
                    class: [
                      'tx-button',
                      typeof item !== 'string' &&
                        item.destructive &&
                        'tx-button-danger',
                    ],
                    type: 'button',
                    disabled: p.disabled || off(item),
                    onClick: () => {
                      emit('itemClick', { itemData: item })
                      emit('update:visible', false)
                    },
                  },
                  slots.item?.({ item }) ?? txText(item),
                ),
              ),
              h(
                'button',
                {
                  type: 'button',
                  onClick: () => emit('update:visible', false),
                },
                p.cancelText,
              ),
            ]),
        },
      )
  },
})

export const TxContextMenu = defineComponent({
  name: 'TxContextMenu',
  props: { ...entriesProps, visible: Boolean },
  emits: ['update:visible', 'itemClick'],
  setup(p, { emit, slots }) {
    const b = useTxSource(
        () => p.dataSource,
        () => p.items,
      ),
      open = ref(false),
      x = ref(0),
      y = ref(0),
      root = ref<HTMLElement>()
    let previousFocus: HTMLElement | undefined
    let timer: ReturnType<typeof setTimeout> | undefined
    const close = () => {
      if (!open.value) return
      open.value = false
      emit('update:visible', false)
      previousFocus?.focus()
    }
    watch(
      () => p.visible,
      (v) => (open.value = v),
    )
    onBeforeUnmount(() => clearTimeout(timer))
    function show(e: MouseEvent | PointerEvent) {
      if (p.disabled) return
      e.preventDefault()
      x.value = Math.max(0, Math.min(e.clientX, window.innerWidth - 250))
      y.value = Math.max(0, Math.min(e.clientY, window.innerHeight - 320))
      open.value = true
      previousFocus = document.activeElement as HTMLElement
      emit('update:visible', true)
      void nextTick(() =>
        root.value
          ?.querySelector<HTMLElement>('[role="menuitem"]:not(:disabled)')
          ?.focus(),
      )
    }
    function menu(items: TxEntry[]): ReturnType<typeof h> {
      return h(
        'div',
        { role: 'menu', class: 'tx-options' },
        items.map((item) =>
          typeof item !== 'string' && item.separator
            ? h('hr', { role: 'separator' })
            : typeof item !== 'string' && !item.disabled && item.items?.length
              ? h('details', [h('summary', txText(item)), menu(item.items)])
              : h(
                  'button',
                  {
                    type: 'button',
                    role: 'menuitem',
                    disabled: off(item),
                    class: 'tx-option',
                    onClick: () => {
                      emit('itemClick', { itemData: item })
                      close()
                    },
                  },
                  txText(item),
                ),
        ),
      )
    }
    return () =>
      h(
        'div',
        {
          ref: root,
          onContextmenu: show,
          onPointerdown: (e: PointerEvent) => {
            if (e.pointerType === 'touch')
              timer = setTimeout(() => show(e), 600)
          },
          onPointerup: () => clearTimeout(timer),
          onPointermove: () => clearTimeout(timer),
          onPointercancel: () => clearTimeout(timer),
          onKeydown: (e: KeyboardEvent) => {
            if (e.key === 'ContextMenu' || (e.key === 'F10' && e.shiftKey)) {
              e.preventDefault()
              const box = root.value?.getBoundingClientRect()
              if (box)
                show(
                  new MouseEvent('contextmenu', {
                    clientX: box.left,
                    clientY: box.top,
                  }),
                )
            }
            if (e.key === 'Escape') close()
            if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
              const buttons = Array.from(
                (
                  e.currentTarget as HTMLElement
                ).querySelectorAll<HTMLButtonElement>(
                  '[role="menuitem"]:not(:disabled)',
                ),
              )
              if (buttons.length) {
                e.preventDefault()
                buttons[
                  (buttons.indexOf(
                    document.activeElement as HTMLButtonElement,
                  ) +
                    (e.key === 'ArrowDown' ? 1 : -1) +
                    buttons.length) %
                    buttons.length
                ].focus()
              }
            }
          },
        },
        [
          slots.default?.(),
          open.value &&
            h('div', { class: 'tx-context-backdrop', onClick: close }, [
              h(
                'div',
                {
                  class: 'tx-context-menu',
                  style: { left: `${x.value}px`, top: `${y.value}px` },
                  onClick: (e: Event) => e.stopPropagation(),
                },
                [
                  menu(b.items.value),
                  h('button', { type: 'button', onClick: close }, 'Schließen'),
                ],
              ),
            ]),
        ],
      )
  },
})
