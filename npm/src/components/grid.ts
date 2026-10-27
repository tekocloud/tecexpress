import { useTxSource } from '../data/vue-source.js'
import type { TxSource } from '../data/source.js'
import {
  computed,
  defineComponent,
  Fragment,
  h,
  isVNode,
  ref,
  watch,
  type PropType,
  type VNode,
} from 'vue'
import { inferColumns, queryRows, readField } from '../data/query.js'
import type {
  Column,
  DataRow,
  RowKey,
  RowClickEvent,
  SelectionChangedEvent,
  SortDescriptor,
} from '../types.js'

export const TxColumn = defineComponent({
  name: 'TxColumn',
  props: {
    dataField: { type: String, required: true },
    caption: String,
    width: [String, Number],
    allowSorting: { type: Boolean, default: true },
    allowFiltering: { type: Boolean, default: true },
    cellTemplate: String,
    visible: { type: Boolean, default: true },
    alignment: String as PropType<Column['alignment']>,
  },
  setup() {
    return () => null
  },
})

function slotColumns(nodes: VNode[]): Column[] {
  return nodes.flatMap((node) => {
    if (node.type === Fragment && Array.isArray(node.children))
      return slotColumns(node.children.filter(isVNode))
    if (node.type !== TxColumn) return []
    const props = Object.fromEntries(
      Object.entries(node.props ?? {}).map(([key, value]) => [
        key.replace(/-([a-z])/g, (_, letter: string) => letter.toUpperCase()),
        value,
      ]),
    )
    return props.dataField ? [props as unknown as Column] : []
  })
}

export const TxDataGrid = defineComponent({
  name: 'TxDataGrid',
  props: {
    dataSource: {
      type: [Array, Object] as PropType<TxSource<DataRow>>,
      default: () => [],
    },
    keyExpr: { type: String, default: 'id' },
    columns: Array as PropType<Column[]>,
    filterRow: {
      type: [Boolean, Object] as PropType<boolean | { visible: boolean }>,
      default: true,
    },
    pageSize: { type: Number, default: 10 },
    pageIndex: { type: Number, default: undefined },
    selection: {
      type: [String, Object] as PropType<
        | 'none'
        | 'single'
        | 'multiple'
        | { mode: 'none' | 'single' | 'multiple' }
      >,
      default: 'none',
    },
    selectedRowKeys: { type: Array as PropType<RowKey[]>, default: undefined },
    loading: Boolean,
    disabled: Boolean,
    noDataText: { type: String, default: 'Keine Daten vorhanden.' },
    label: { type: String, default: 'Datentabelle' },
  },
  emits: {
    rowClick: (_event: RowClickEvent) => true,
    selectionChanged: (_event: SelectionChangedEvent) => true,
    'update:selectedRowKeys': (_keys: RowKey[]) => true,
    'update:pageIndex': (_pageIndex: number) => true,
    sortChanged: (_sort: SortDescriptor | null) => true,
    filterChanged: (_filters: Record<string, string>) => true,
  },
  setup(props, { emit, slots }) {
    const binding = useTxSource<DataRow>(() => props.dataSource)

    const filters = ref<Record<string, string>>({}),
      sort = ref<SortDescriptor | null>(null),
      page = ref(0),
      internalKeys = ref<RowKey[]>([])
    const mode = computed(() =>
      typeof props.selection === 'string'
        ? props.selection
        : props.selection.mode,
    )
    function key(row: DataRow): RowKey {
      const value = readField(row, props.keyExpr)
      if (
        (typeof value !== 'string' && typeof value !== 'number') ||
        (typeof value === 'number' && !Number.isFinite(value))
      )
        throw new Error(
          `TxDataGrid: keyExpr "${props.keyExpr}" muss je Zeile einen eindeutigen String oder eine endliche Zahl liefern.`,
        )
      return value
    }
    const rows = computed(() => {
      const keys = binding.items.value.map(key)
      if (new Set(keys).size !== keys.length)
        throw new Error(
          'TxDataGrid: doppelte Zeilenschlüssel sind nicht erlaubt.',
        )
      return binding.items.value
    })
    const selectedKeys = computed(() => {
      if (mode.value === 'none') return []
      const existing = new Set(rows.value.map(key))
      const selected = [
        ...new Set(props.selectedRowKeys ?? internalKeys.value),
      ].filter((value) =>
        binding.source.value
          ? binding.source.value.containsKey(value) !== false
          : existing.has(value),
      )
      return mode.value === 'single' ? selected.slice(0, 1) : selected
    })
    function updateSelection(keys: RowKey[]) {
      internalKeys.value = keys
      emit('update:selectedRowKeys', [...keys])
      emit('selectionChanged', {
        selectedRowKeys: [...keys],
        selectedRowsData: rows.value.filter((row) => keys.includes(key(row))),
      })
    }
    watch(
      [binding.items, () => props.dataSource, () => props.keyExpr, mode],
      () => {
        if (binding.loading.value) return
        const before = props.selectedRowKeys ?? internalKeys.value
        const next = selectedKeys.value
        if (
          before.length !== next.length ||
          before.some((value, index) => value !== next[index])
        )
          updateSelection(next)
      },
      { deep: true },
    )
    const filtered = computed(() =>
      binding.source.value
        ? rows.value
        : queryRows(rows.value, filters.value, sort.value),
    )
    const size = computed(() => {
      void binding.revision.value
      return (
        binding.source.value?.config.pageSize ??
        (Number.isFinite(props.pageSize)
          ? Math.max(1, Math.floor(props.pageSize))
          : 10)
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
    const currentPage = computed(() => {
      void binding.revision.value
      const requested =
        props.pageIndex ?? binding.source.value?.config.pageIndex ?? page.value
      return Math.min(
        Math.max(0, Number.isFinite(requested) ? Math.floor(requested) : 0),
        pageCount.value - 1,
      )
    })
    const visibleRows = computed(() =>
      binding.source.value
        ? filtered.value
        : filtered.value.slice(
            currentPage.value * size.value,
            (currentPage.value + 1) * size.value,
          ),
    )
    function setPage(value: number, load = true) {
      page.value = value
      emit('update:pageIndex', value)
      if (
        load &&
        binding.source.value &&
        binding.source.value.config.pageIndex !== value
      )
        void binding.source.value
          .configure({ pageIndex: value })
          .catch(() => {})
    }
    watch([filters, size], () => setPage(0, !binding.source.value), {
      deep: true,
    })
    watch(pageCount, () => {
      if ((props.pageIndex ?? page.value) !== currentPage.value)
        setPage(currentPage.value)
    })
    watch(
      [filters, sort],
      () => {
        const source = binding.source.value
        if (source)
          void source
            .configure({
              filter: Object.values(filters.value).some(Boolean)
                ? {
                    and: Object.entries(filters.value)
                      .filter(([, value]) => value)
                      .map(([selector, value]) => ({
                        selector,
                        operator: 'contains' as const,
                        value,
                      })),
                  }
                : undefined,
              sort: sort.value
                ? [{ selector: sort.value.dataField, desc: sort.value.desc }]
                : [],
              pageIndex: 0,
            })
            .catch(() => {})
      },
      { deep: true },
    )
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
    function selectRow(row: DataRow, checked: boolean) {
      if (props.disabled || props.loading || binding.loading.value) return
      const rowKey = key(row)
      updateSelection(
        mode.value === 'single'
          ? checked
            ? [rowKey]
            : []
          : checked
            ? [...new Set([...selectedKeys.value, rowKey])]
            : selectedKeys.value.filter((value) => value !== rowKey),
      )
    }
    function sortBy(column: Column) {
      if (
        props.disabled ||
        props.loading ||
        binding.loading.value ||
        column.allowSorting === false
      )
        return
      sort.value =
        sort.value?.dataField !== column.dataField
          ? { dataField: column.dataField, desc: false }
          : !sort.value.desc
            ? { dataField: column.dataField, desc: true }
            : null
      emit('sortChanged', sort.value)
      setPage(0, !binding.source.value)
    }
    return () => {
      const declared = slotColumns(slots.default?.() ?? [])
      const columns = (
        declared.length ? declared : (props.columns ?? inferColumns(rows.value))
      ).filter((column) => column.visible !== false)
      const selectable = mode.value !== 'none',
        blocked = props.disabled || props.loading || binding.loading.value
      const showFilters =
        typeof props.filterRow === 'boolean'
          ? props.filterRow
          : props.filterRow.visible
      const allVisibleSelected =
        visibleRows.value.length > 0 &&
        visibleRows.value.every((row) => selectedKeys.value.includes(key(row)))
      return h(
        'section',
        {
          class: ['tx-grid', props.disabled && 'tx-disabled'],
          'aria-label': props.label,
          'aria-busy': props.loading || binding.loading.value,
        },
        [
          !!binding.error.value &&
            h('p', { role: 'alert' }, String(binding.error.value)),
          h('div', { class: 'tx-grid-scroll' }, [
            h('table', { class: 'tx-table' }, [
              h('caption', { class: 'tx-sr-only' }, props.label),
              h('thead', [
                h('tr', [
                  selectable &&
                    h(
                      'th',
                      { scope: 'col', class: 'tx-selection-cell' },
                      mode.value === 'multiple'
                        ? h('input', {
                            type: 'checkbox',
                            'aria-label': 'Alle Zeilen dieser Seite auswählen',
                            checked: allVisibleSelected,
                            indeterminate:
                              !allVisibleSelected &&
                              visibleRows.value.some((row) =>
                                selectedKeys.value.includes(key(row)),
                              ),
                            disabled: blocked || !visibleRows.value.length,
                            onChange: (event: Event) => {
                              if (blocked) return
                              const pageKeys = visibleRows.value.map(key)
                              updateSelection(
                                (event.target as HTMLInputElement).checked
                                  ? [
                                      ...new Set([
                                        ...selectedKeys.value,
                                        ...pageKeys,
                                      ]),
                                    ]
                                  : selectedKeys.value.filter(
                                      (value) => !pageKeys.includes(value),
                                    ),
                              )
                            },
                          })
                        : h('span', { class: 'tx-sr-only' }, 'Auswahl'),
                    ),
                  ...columns.map((column) =>
                    h(
                      'th',
                      {
                        scope: 'col',
                        key: column.dataField,
                        style: {
                          width:
                            typeof column.width === 'number'
                              ? `${column.width}px`
                              : column.width,
                          textAlign: column.alignment,
                        },
                        'aria-sort':
                          sort.value?.dataField === column.dataField
                            ? sort.value.desc
                              ? 'descending'
                              : 'ascending'
                            : column.allowSorting === false
                              ? undefined
                              : 'none',
                      },
                      column.allowSorting === false
                        ? (column.caption ?? column.dataField)
                        : h(
                            'button',
                            {
                              type: 'button',
                              class: 'tx-sort',
                              disabled: blocked,
                              onClick: () => sortBy(column),
                            },
                            [
                              column.caption ?? column.dataField,
                              h(
                                'span',
                                {
                                  'aria-hidden': 'true',
                                  class: 'tx-sort-icon',
                                },
                                sort.value?.dataField === column.dataField
                                  ? sort.value.desc
                                    ? '↓'
                                    : '↑'
                                  : '↕',
                              ),
                            ],
                          ),
                    ),
                  ),
                ]),
                showFilters &&
                  h('tr', { class: 'tx-filter-row' }, [
                    selectable && h('td'),
                    ...columns.map((column) =>
                      h(
                        'td',
                        { key: column.dataField },
                        column.allowFiltering === false
                          ? []
                          : [
                              h('input', {
                                class: 'tx-control',
                                type: 'search',
                                'aria-label': `${column.caption ?? column.dataField} filtern`,
                                placeholder: 'Filtern …',
                                value: filters.value[column.dataField] ?? '',
                                disabled: blocked,
                                onInput: (event: Event) => {
                                  if (blocked) return
                                  filters.value = {
                                    ...filters.value,
                                    [column.dataField]: (
                                      event.target as HTMLInputElement
                                    ).value,
                                  }
                                  emit('filterChanged', { ...filters.value })
                                },
                              }),
                            ],
                      ),
                    ),
                  ]),
              ]),
              h(
                'tbody',
                props.loading || binding.loading.value
                  ? [
                      h('tr', [
                        h(
                          'td',
                          {
                            colspan: Math.max(
                              1,
                              columns.length + Number(selectable),
                            ),
                            class: 'tx-grid-empty',
                            role: 'status',
                          },
                          'Wird geladen …',
                        ),
                      ]),
                    ]
                  : visibleRows.value.length
                    ? visibleRows.value.map((row, index) =>
                        h(
                          'tr',
                          {
                            key: key(row),
                            class:
                              selectedKeys.value.includes(key(row)) &&
                              'tx-row-selected',
                            onClick: (event: MouseEvent) => {
                              if (!blocked)
                                emit('rowClick', {
                                  data: row,
                                  key: key(row),
                                  rowIndex:
                                    currentPage.value * size.value + index,
                                  event,
                                })
                            },
                          },
                          [
                            selectable &&
                              h('td', { class: 'tx-selection-cell' }, [
                                h('input', {
                                  type: 'checkbox',
                                  checked: selectedKeys.value.includes(
                                    key(row),
                                  ),
                                  disabled: blocked,
                                  'aria-label': `Zeile ${key(row)} auswählen`,
                                  onClick: (event: MouseEvent) =>
                                    event.stopPropagation(),
                                  onChange: (event: Event) =>
                                    selectRow(
                                      row,
                                      (event.target as HTMLInputElement)
                                        .checked,
                                    ),
                                }),
                              ]),
                            ...columns.map((column) =>
                              h(
                                'td',
                                {
                                  key: column.dataField,
                                  style: { textAlign: column.alignment },
                                },
                                slots[
                                  column.cellTemplate ??
                                    `cell-${column.dataField}`
                                ]?.({
                                  data: row,
                                  value: readField(row, column.dataField),
                                  column,
                                  rowIndex:
                                    currentPage.value * size.value + index,
                                }) ??
                                  String(
                                    readField(row, column.dataField) ?? '',
                                  ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : [
                        h('tr', [
                          h(
                            'td',
                            {
                              colspan: Math.max(
                                1,
                                columns.length + Number(selectable),
                              ),
                              class: 'tx-grid-empty',
                            },
                            props.noDataText,
                          ),
                        ]),
                      ],
              ),
            ]),
          ]),
          h('footer', { class: 'tx-grid-footer' }, [
            h(
              'span',
              { role: 'status' },
              `${binding.source.value?.totalCount ?? filtered.value.length} Einträge${selectable ? ` · ${selectedKeys.value.length} ausgewählt` : ''}`,
            ),
            h('nav', { class: 'tx-pager', 'aria-label': 'Tabellenseiten' }, [
              h(
                'button',
                {
                  class: 'tx-button',
                  type: 'button',
                  disabled: blocked || currentPage.value === 0,
                  'aria-label': 'Vorherige Seite',
                  onClick: () => setPage(currentPage.value - 1),
                },
                '←',
              ),
              h('span', `Seite ${currentPage.value + 1} / ${pageCount.value}`),
              h(
                'button',
                {
                  class: 'tx-button',
                  type: 'button',
                  disabled: blocked || currentPage.value >= pageCount.value - 1,
                  'aria-label': 'Nächste Seite',
                  onClick: () => setPage(currentPage.value + 1),
                },
                '→',
              ),
            ]),
          ]),
        ],
      )
    }
  },
})
