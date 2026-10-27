import { useTxSource } from '../data/vue-source.js'
import type { TxSource } from '../data/source.js'
import {
  computed,
  defineComponent,
  h,
  ref,
  useId,
  watch,
  type PropType,
} from 'vue'
import { TxButton } from './editors.js'
import { TxLoadIndicator } from './overlays.js'
import { readField } from '../data/query.js'
import type {
  CardClickEvent,
  CardField,
  CardSelectionChangedEvent,
  DataRow,
  RowKey,
} from '../types.js'

export const TxCard = defineComponent({
  name: 'TxCard',
  props: {
    title: String,
    subtitle: String,
    imageUrl: String,
    imageAlt: { type: String, default: '' },
    variant: {
      type: String as PropType<'outlined' | 'elevated' | 'filled'>,
      default: 'outlined',
    },
    loading: Boolean,
  },
  setup(props, { slots, attrs }) {
    const id = useId()
    return () =>
      h(
        'article',
        {
          class: ['tx-card', `tx-card-${props.variant}`],
          'aria-busy': props.loading,
          'aria-labelledby':
            !slots.header && props.title && !attrs['aria-label']
              ? `${id}-title`
              : undefined,
        },
        [
          slots.media
            ? h('div', { class: 'tx-card-media' }, slots.media())
            : props.imageUrl &&
              h('div', { class: 'tx-card-media' }, [
                h('img', {
                  src: props.imageUrl,
                  alt: props.imageAlt,
                  loading: 'lazy',
                }),
              ]),
          (slots.header || props.title || props.subtitle || slots.actions) &&
            h('header', { class: 'tx-card-header' }, [
              h(
                'div',
                { class: 'tx-card-heading' },
                slots.header?.() ?? [
                  props.title &&
                    h(
                      'h3',
                      { id: `${id}-title`, class: 'tx-card-title' },
                      props.title,
                    ),
                  props.subtitle &&
                    h('p', { class: 'tx-card-subtitle' }, props.subtitle),
                ],
              ),
              slots.actions &&
                h('div', { class: 'tx-card-actions' }, slots.actions()),
            ]),
          h(
            'div',
            { class: 'tx-card-body' },
            props.loading
              ? [h(TxLoadIndicator, { label: 'Karte wird geladen …' })]
              : slots.default?.(),
          ),
          slots.footer &&
            h('footer', { class: 'tx-card-footer' }, slots.footer()),
        ],
      )
  },
})

export const TxCardView = defineComponent({
  name: 'TxCardView',
  props: {
    dataSource: {
      type: [Array, Object] as PropType<TxSource<DataRow>>,
      default: () => [],
    },
    keyExpr: { type: String, default: 'id' },
    titleExpr: { type: String, default: 'title' },
    subtitleExpr: { type: String, default: 'subtitle' },
    imageExpr: { type: String, default: 'imageUrl' },
    imageAltExpr: { type: String, default: 'imageAlt' },
    columns: { type: Array as PropType<CardField[]>, default: () => [] },
    searchEnabled: { type: Boolean, default: true },
    searchExpr: [String, Array] as PropType<string | string[]>,
    pageSize: { type: Number, default: 6 },
    pageIndex: { type: Number, default: undefined },
    selection: {
      type: String as PropType<'none' | 'single' | 'multiple'>,
      default: 'none',
    },
    selectedCardKeys: { type: Array as PropType<RowKey[]>, default: undefined },
    disabled: Boolean,
    loading: Boolean,
    noDataText: { type: String, default: 'Keine Karten vorhanden.' },
    label: { type: String, default: 'Kartenansicht' },
  },
  emits: {
    cardClick: (_event: CardClickEvent) => true,
    selectionChanged: (_event: CardSelectionChangedEvent) => true,
    'update:selectedCardKeys': (_keys: RowKey[]) => true,
    'update:pageIndex': (_index: number) => true,
    searchChanged: (_text: string) => true,
  },
  setup(props, { emit, slots }) {
    const binding = useTxSource<DataRow>(() => props.dataSource)

    const search = ref(''),
      page = ref(0),
      internalKeys = ref<RowKey[]>([])
    function key(row: DataRow): RowKey {
      const value = readField(row, props.keyExpr)
      if (
        (typeof value !== 'string' && typeof value !== 'number') ||
        (typeof value === 'number' && !Number.isFinite(value))
      )
        throw new Error(
          'TxCardView: keyExpr muss eindeutige Strings oder endliche Zahlen liefern.',
        )
      return value
    }
    const rows = computed(() => {
      const keys = binding.items.value.map(key)
      if (new Set(keys).size !== keys.length)
        throw new Error(
          'TxCardView: doppelte Kartenschlüssel sind nicht erlaubt.',
        )
      return binding.items.value
    })
    const filtered = computed(() => {
      if (binding.source.value) return rows.value
      const fields = props.searchExpr
        ? typeof props.searchExpr === 'string'
          ? [props.searchExpr]
          : props.searchExpr
        : [
            props.titleExpr,
            props.subtitleExpr,
            ...props.columns.map((column) => column.dataField),
          ]
      const query = props.searchEnabled
        ? search.value.toLocaleLowerCase().trim()
        : ''
      return rows.value.filter(
        (row) =>
          !query ||
          fields.some((field) =>
            String(readField(row, field) ?? '')
              .toLocaleLowerCase()
              .includes(query),
          ),
      )
    })
    const size = computed(() => {
      void binding.revision.value
      return (
        binding.source.value?.config.pageSize ??
        (Number.isFinite(props.pageSize)
          ? Math.max(1, Math.floor(props.pageSize))
          : 6)
      )
    })
    const pageCount = computed(() => {
      void binding.revision.value
      return Math.max(
        1,
        Math.ceil(
          (binding.source.value
            ? binding.source.value.totalCount
            : filtered.value.length) / size.value,
        ),
      )
    })
    const current = computed(() => {
      void binding.revision.value
      const requested =
        props.pageIndex ?? binding.source.value?.config.pageIndex ?? page.value
      return Math.min(
        pageCount.value - 1,
        Math.max(0, Number.isFinite(requested) ? Math.floor(requested) : 0),
      )
    })
    const selected = computed(() => {
      if (props.selection === 'none') return []
      const existing = new Set(rows.value.map(key))
      const values = [
        ...new Set(props.selectedCardKeys ?? internalKeys.value),
      ].filter((value) =>
        binding.source.value
          ? binding.source.value.containsKey(value) !== false
          : existing.has(value),
      )
      return props.selection === 'single' ? values.slice(0, 1) : values
    })
    function setPage(value: number) {
      page.value = value
      emit('update:pageIndex', value)
      if (
        binding.source.value &&
        binding.source.value.config.pageIndex !== value
      )
        void binding.source.value
          .configure({ pageIndex: value })
          .catch(() => {})
    }
    watch(search, (value) => {
      if (binding.source.value)
        void binding.source.value
          .configure({
            searchValue: value,
            searchExpr: props.searchExpr
              ? typeof props.searchExpr === 'string'
                ? [props.searchExpr]
                : props.searchExpr
              : [props.titleExpr, props.subtitleExpr],
            pageIndex: 0,
          })
          .catch(() => {})
    })
    watch(
      () => props.pageSize,
      (value) => {
        if (binding.source.value)
          void binding.source.value
            .configure({ pageSize: value })
            .catch(() => {})
      },
    )
    watch(
      () => props.pageIndex,
      (value) => {
        if (value !== undefined) setPage(value)
      },
    )
    function select(values: RowKey[]) {
      internalKeys.value = values
      emit('update:selectedCardKeys', [...values])
      emit('selectionChanged', {
        selectedCardKeys: [...values],
        selectedCardsData: rows.value.filter((row) =>
          values.includes(key(row)),
        ),
      })
    }
    watch([search, size, () => props.searchEnabled], () => setPage(0))
    watch(pageCount, () => {
      if ((props.pageIndex ?? page.value) !== current.value)
        setPage(current.value)
    })
    watch(
      [
        binding.items,
        () => props.dataSource,
        () => props.keyExpr,
        () => props.selection,
      ],
      () => {
        if (binding.loading.value) return
        const before = props.selectedCardKeys ?? internalKeys.value,
          next = selected.value
        if (
          before.length !== next.length ||
          before.some((value, i) => value !== next[i])
        )
          select(next)
      },
      { deep: true },
    )
    return () => {
      const blocked = props.disabled || props.loading || binding.loading.value
      const text = (row: DataRow, expr: string) =>
        String(readField(row, expr) ?? '')
      return h(
        'section',
        {
          class: 'tx-cardview',
          'aria-label': props.label,
          'aria-busy': props.loading || binding.loading.value,
        },
        [
          props.searchEnabled &&
            h('div', { class: 'tx-cardview-toolbar' }, [
              h('input', {
                type: 'search',
                class: 'tx-control',
                placeholder: 'Karten durchsuchen …',
                'aria-label': 'Karten durchsuchen',
                value: search.value,
                disabled: blocked,
                onInput: (event: Event) => {
                  if (!blocked) {
                    search.value = (event.target as HTMLInputElement).value
                    emit('searchChanged', search.value)
                  }
                },
              }),
            ]),
          props.loading || binding.loading.value
            ? h('div', { class: 'tx-cardview-empty' }, [
                h(TxLoadIndicator, { label: 'Karten werden geladen …' }),
              ])
            : filtered.value.length
              ? h(
                  'ul',
                  { class: 'tx-cardview-grid' },
                  (binding.source.value
                    ? filtered.value
                    : filtered.value.slice(
                        current.value * size.value,
                        (current.value + 1) * size.value,
                      )
                  ).map((row, i) => {
                    const rowKey = key(row),
                      index = current.value * size.value + i,
                      isSelected = selected.value.includes(rowKey)
                    const scope = {
                      data: row,
                      key: rowKey,
                      index,
                      selected: isSelected,
                    }
                    return h(
                      'li',
                      {
                        key: rowKey,
                        class: [
                          'tx-cardview-item',
                          isSelected && 'tx-cardview-selected',
                          props.selection !== 'none' &&
                            'tx-cardview-selectable',
                        ],
                      },
                      [
                        props.selection !== 'none' &&
                          h('label', { class: 'tx-cardview-selection' }, [
                            h('input', {
                              type: 'checkbox',
                              checked: isSelected,
                              disabled: blocked,
                              'aria-label': `Karte ${text(row, props.titleExpr) || rowKey} auswählen`,
                              onChange: (event: Event) => {
                                if (blocked) return
                                const checked = (
                                  event.target as HTMLInputElement
                                ).checked
                                select(
                                  props.selection === 'single'
                                    ? checked
                                      ? [rowKey]
                                      : []
                                    : checked
                                      ? [
                                          ...new Set([
                                            ...selected.value,
                                            rowKey,
                                          ]),
                                        ]
                                      : selected.value.filter(
                                          (value) => value !== rowKey,
                                        ),
                                )
                              },
                            }),
                          ]),
                        slots.item?.(scope) ??
                          h(
                            TxCard,
                            {
                              title: text(row, props.titleExpr),
                              subtitle: text(row, props.subtitleExpr),
                              imageUrl: text(row, props.imageExpr),
                              imageAlt: text(row, props.imageAltExpr),
                            },
                            {
                              ...(slots.media
                                ? { media: () => slots.media!(scope) }
                                : {}),
                              default: () =>
                                slots.content?.(scope) ?? [
                                  h(
                                    'dl',
                                    { class: 'tx-card-fields' },
                                    props.columns.map((column) =>
                                      h('div', { key: column.dataField }, [
                                        h(
                                          'dt',
                                          column.caption ?? column.dataField,
                                        ),
                                        h(
                                          'dd',
                                          slots.field?.({
                                            data: row,
                                            column,
                                            value: readField(
                                              row,
                                              column.dataField,
                                            ),
                                          }) ??
                                            String(
                                              readField(
                                                row,
                                                column.dataField,
                                              ) ?? '',
                                            ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ],
                              footer: () =>
                                slots.footer?.(scope) ?? [
                                  h(TxButton, {
                                    text: 'Details →',
                                    disabled: blocked,
                                    'aria-label': `Details: ${text(row, props.titleExpr) || rowKey}`,
                                    onClick: (event: MouseEvent) => {
                                      if (!blocked)
                                        emit('cardClick', {
                                          data: row,
                                          key: rowKey,
                                          index,
                                          event,
                                        })
                                    },
                                  }),
                                ],
                            },
                          ),
                      ],
                    )
                  }),
                )
              : h(
                  'div',
                  { class: 'tx-cardview-empty', role: 'status' },
                  props.noDataText,
                ),
          h('footer', { class: 'tx-cardview-footer' }, [
            h(
              'span',
              { role: 'status' },
              `${binding.source.value?.totalCount ?? filtered.value.length} Karten${props.selection !== 'none' ? ` · ${selected.value.length} ausgewählt` : ''}`,
            ),
            h('nav', { class: 'tx-pager', 'aria-label': 'Kartenseiten' }, [
              h(TxButton, {
                text: '←',
                'aria-label': 'Vorherige Kartenseite',
                disabled: blocked || current.value === 0,
                onClick: () => setPage(current.value - 1),
              }),
              h('span', `Seite ${current.value + 1} / ${pageCount.value}`),
              h(TxButton, {
                text: '→',
                'aria-label': 'Nächste Kartenseite',
                disabled: blocked || current.value === pageCount.value - 1,
                onClick: () => setPage(current.value + 1),
              }),
            ]),
          ]),
        ],
      )
    }
  },
})
