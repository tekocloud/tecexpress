import {
  defineComponent,
  h,
  onBeforeUnmount,
  ref,
  watch,
  type PropType,
} from 'vue'
import { TxDataSource, type TxSource } from '../data/source.js'
import {
  txFileStore,
  type TxFileEntry,
  type TxFileProvider,
  type TxUploadAdapter,
} from '../data/files.js'
import { useTxSource } from '../data/vue-source.js'
interface Upload {
  id: number
  file: File
  progress: number
  status: 'ready' | 'uploading' | 'done' | 'error' | 'cancelled'
  error?: string
  controller?: AbortController
}
export const TxFileUploader = defineComponent({
  name: 'TxFileUploader',
  props: {
    dataSource: [Array, Object] as PropType<TxSource<File>>,
    adapter: Function as PropType<TxUploadAdapter>,
    multiple: Boolean,
    accept: String,
    maxFileSize: Number,
    minFileSize: { type: Number, default: 0 },
    uploadMode: { type: String, default: 'useButtons' },
    disabled: Boolean,
    label: { type: String, default: 'Dateien hochladen' },
  },
  emits: ['valueChanged', 'uploaded', 'uploadError', 'progress'],
  setup(p, { emit, expose }) {
    const queue = ref<Upload[]>([])
    let serial = 0
    function add(files: File[]) {
      if (p.disabled) return
      const incoming = p.multiple ? files : files.slice(0, 1)
      if (!p.multiple) {
        queue.value.forEach((v) => v.controller?.abort())
        queue.value = []
      }
      for (const file of incoming) {
        const patterns = (p.accept ?? '')
          .split(',')
          .map((v) => v.trim())
          .filter(Boolean)
        const accepted =
          !patterns.length ||
          patterns.some((v) =>
            v.startsWith('.')
              ? file.name.toLowerCase().endsWith(v.toLowerCase())
              : v.endsWith('/*')
                ? file.type.startsWith(v.slice(0, -1))
                : file.type === v,
          )
        const error = !accepted
          ? 'Dateityp nicht erlaubt'
          : file.size < p.minFileSize ||
              (p.maxFileSize !== undefined && file.size > p.maxFileSize)
            ? 'Dateigröße nicht erlaubt'
            : undefined
        queue.value.push({
          id: ++serial,
          file,
          status: error ? 'error' : 'ready',
          progress: 0,
          error,
        })
        if (!error && p.uploadMode === 'instantly')
          void upload(queue.value.at(-1)!)
      }
      emit('valueChanged', { value: queue.value.map((v) => v.file) })
    }
    async function upload(item: Upload) {
      if (p.disabled || item.status === 'uploading' || item.status === 'done')
        return
      if (!p.adapter) {
        item.error = 'Uploadadapter fehlt'
        item.status = 'error'
        return
      }
      const controller = new AbortController()
      item.controller = controller
      item.status = 'uploading'
      item.error = undefined
      try {
        const result = await p.adapter(item.file, {
          signal: controller.signal,
          onProgress: (loaded, total) => {
            if (controller.signal.aborted) return
            item.progress = total ? loaded / total : 0
            emit('progress', { file: item.file, loaded, total })
          },
        })
        if (!controller.signal.aborted) {
          item.status = 'done'
          item.progress = 1
          emit('uploaded', { file: item.file, result })
        }
      } catch (error) {
        item.status = controller.signal.aborted ? 'cancelled' : 'error'
        item.error = String(error)
        if (!controller.signal.aborted)
          emit('uploadError', { file: item.file, error })
      }
    }
    const inputBinding = useTxSource(() => p.dataSource)
    let knownFiles = new Set<File>()
    watch(
      [inputBinding.items, () => p.disabled],
      ([files]) => {
        if (!p.dataSource || p.disabled) return
        const next = new Set(files)
        queue.value = queue.value.filter((item) => {
          if (!knownFiles.has(item.file) || next.has(item.file)) return true
          item.controller?.abort()
          return false
        })
        const incoming = files.filter((file) => !knownFiles.has(file))
        knownFiles = next
        if (incoming.length) add(incoming)
      },
      { immediate: true },
    )
    onBeforeUnmount(() => queue.value.forEach((v) => v.controller?.abort()))
    expose({
      upload: () =>
        Promise.all(
          queue.value.filter((v) => v.status === 'ready').map(upload),
        ),
      cancel: () => queue.value.forEach((v) => v.controller?.abort()),
    })
    return () =>
      h(
        'section',
        {
          class: 'tx-uploader',
          'aria-label': p.label,
          onDragover: (e: DragEvent) => e.preventDefault(),
          onDrop: (e: DragEvent) => {
            e.preventDefault()
            add(Array.from(e.dataTransfer?.files ?? []))
          },
        },
        [
          h('label', [
            p.label,
            h('input', {
              type: 'file',
              multiple: p.multiple,
              accept: p.accept,
              disabled: p.disabled,
              onChange: (e: Event) => {
                add(Array.from((e.target as HTMLInputElement).files ?? []))
                ;(e.target as HTMLInputElement).value = ''
              },
            }),
          ]),
          h('p', 'Dateien hier ablegen oder auswählen'),
          h(
            'ul',
            queue.value.map((item) =>
              h('li', { key: item.id }, [
                h('span', `${item.file.name} · ${item.status}`),
                h('progress', {
                  max: 1,
                  value: item.progress,
                  'aria-label': item.file.name,
                }),
                item.error && h('span', { role: 'alert' }, item.error),
                item.status === 'uploading'
                  ? h(
                      'button',
                      {
                        type: 'button',
                        onClick: () => item.controller?.abort(),
                      },
                      'Abbrechen',
                    )
                  : item.status !== 'done' &&
                    h(
                      'button',
                      {
                        type: 'button',
                        disabled:
                          p.disabled ||
                          !p.adapter ||
                          (!!item.error &&
                            item.error.includes('nicht erlaubt')),
                        onClick: () => upload(item),
                      },
                      item.status === 'ready' ? 'Hochladen' : 'Wiederholen',
                    ),
              ]),
            ),
          ),
          p.uploadMode !== 'instantly' &&
            h(
              'button',
              {
                class: 'tx-button',
                type: 'button',
                disabled: p.disabled || !p.adapter,
                onClick: () =>
                  queue.value
                    .filter((v) => v.status === 'ready')
                    .forEach((v) => void upload(v)),
              },
              'Alle hochladen',
            ),
        ],
      )
  },
})

export const TxFileManager = defineComponent({
  name: 'TxFileManager',
  props: {
    dataSource: [Array, Object] as PropType<TxSource<TxFileEntry>>,
    provider: { type: Object as PropType<TxFileProvider>, required: true },
    disabled: Boolean,
    view: { type: String, default: 'details' },
    label: { type: String, default: 'Dateimanager' },
  },
  emits: ['selectionChanged', 'fileOpened', 'error'],
  setup(p, { emit }) {
    const parent = ref<string | null>(null),
      crumbs = ref<TxFileEntry[]>([]),
      selection = ref<TxFileEntry[]>([]),
      name = ref(''),
      target = ref(''),
      error = ref(''),
      view = ref(p.view)
    const source = ref(
        new TxDataSource({
          store: txFileStore(p.provider, () => parent.value),
          key: 'id',
          paginate: false,
          sort: [{ selector: 'isDirectory', desc: true }, { selector: 'name' }],
        }),
      ),
      binding = useTxSource(() => p.dataSource ?? source.value)
    const directories = ref<Record<string, TxFileEntry[]>>({}),
      expanded = ref<string[]>([])
    async function loadFolders(id: string | null) {
      try {
        directories.value = {
          ...directories.value,
          [id ?? '$root']: (await p.provider.list(id)).filter(
            (v) => v.isDirectory,
          ),
        }
      } catch (e) {
        error.value = String(e)
      }
    }
    watch(
      () => p.provider,
      () => {
        directories.value = {}
        expanded.value = []
        void loadFolders(null)
      },
      { immediate: true },
    )
    function tree(
      id: string | null,
      path: TxFileEntry[] = [],
    ): ReturnType<typeof h> {
      return h(
        'ul',
        {
          role: id === null ? 'tree' : 'group',
          'aria-label': id === null ? 'Ordnerbaum' : undefined,
          class: 'tx-directory-tree',
        },
        (directories.value[id ?? '$root'] ?? [])
          .filter((folder) => !path.some((v) => v.id === folder.id))
          .map((folder) =>
            h(
              'li',
              {
                role: 'treeitem',
                'aria-expanded': expanded.value.includes(folder.id),
              },
              [
                h(
                  'button',
                  {
                    type: 'button',
                    disabled: p.disabled,
                    'aria-label': `${folder.name} ${expanded.value.includes(folder.id) ? 'zuklappen' : 'aufklappen'}`,
                    onClick: async () => {
                      if (expanded.value.includes(folder.id))
                        expanded.value = expanded.value.filter(
                          (v) => v !== folder.id,
                        )
                      else {
                        await loadFolders(folder.id)
                        expanded.value.push(folder.id)
                      }
                    },
                  },
                  expanded.value.includes(folder.id) ? '▾' : '▸',
                ),
                h(
                  'button',
                  {
                    type: 'button',
                    disabled: p.disabled,
                    onClick: () => {
                      crumbs.value = path
                      navigate(folder)
                    },
                  },
                  folder.name,
                ),
                expanded.value.includes(folder.id) &&
                  tree(folder.id, [...path, folder]),
              ],
            ),
          ),
      )
    }
    watch(
      () => p.provider,
      () => {
        source.value.dispose()
        parent.value = null
        crumbs.value = []
        source.value = new TxDataSource({
          store: txFileStore(p.provider, () => parent.value),
          paginate: false,
        })
      },
    )
    onBeforeUnmount(() => source.value.dispose())
    async function action(fn: () => Promise<unknown>) {
      if (p.disabled) return
      error.value = ''
      try {
        await fn()
        selection.value = []
        emit('selectionChanged', [])
        await (binding.source.value ?? source.value).reload()
        await loadFolders(null)
        for (const id of expanded.value) await loadFolders(id)
      } catch (e) {
        error.value = String(e)
        emit('error', e)
      }
    }
    function navigate(folder: TxFileEntry | null) {
      if (p.disabled) return
      parent.value = folder?.id ?? null
      crumbs.value = folder
        ? [
            ...crumbs.value.slice(
              0,
              Math.max(
                0,
                crumbs.value.findIndex((v) => v.id === folder.id) + 1,
              ) || crumbs.value.length,
            ),
            ...(crumbs.value.some((v) => v.id === folder.id) ? [] : [folder]),
          ]
        : []
      selection.value = []
      void (binding.source.value ?? source.value).reload().catch(() => {})
    }
    return () =>
      h(
        'section',
        {
          class: 'tx-file-manager',
          'aria-label': p.label,
          'aria-busy': binding.loading.value,
        },
        [
          tree(null),
          h('nav', { 'aria-label': 'Ordnerpfad', class: 'tx-choice' }, [
            h(
              'button',
              { type: 'button', onClick: () => navigate(null) },
              'Dateien',
            ),
            ...crumbs.value.map((v) =>
              h(
                'button',
                { type: 'button', onClick: () => navigate(v) },
                v.name,
              ),
            ),
          ]),
          h('div', { class: 'tx-choice' }, [
            h('input', {
              class: 'tx-control',
              'aria-label': 'Dateiname',
              placeholder: 'Name',
              value: name.value,
              onInput: (e: Event) =>
                (name.value = (e.target as HTMLInputElement).value),
            }),
            p.provider.createDirectory &&
              h(
                'button',
                {
                  type: 'button',
                  disabled: p.disabled || !name.value.trim(),
                  onClick: () =>
                    action(() =>
                      p.provider.createDirectory!(parent.value, name.value),
                    ),
                },
                'Neuer Ordner',
              ),
            p.provider.rename &&
              h(
                'button',
                {
                  type: 'button',
                  disabled:
                    p.disabled ||
                    selection.value.length !== 1 ||
                    !name.value.trim(),
                  onClick: () =>
                    action(() =>
                      p.provider.rename!(selection.value[0].id, name.value),
                    ),
                },
                'Umbenennen',
              ),
            p.provider.remove &&
              h(
                'button',
                {
                  type: 'button',
                  disabled: p.disabled || !selection.value.length,
                  onClick: () =>
                    action(async () => {
                      for (const item of selection.value)
                        await p.provider.remove!(item.id)
                    }),
                },
                'Löschen',
              ),
            h('input', {
              class: 'tx-control',
              'aria-label': 'Zielordner-ID, leer für Stammordner',
              placeholder: 'Zielordner-ID',
              value: target.value,
              onInput: (e: Event) =>
                (target.value = (e.target as HTMLInputElement).value),
            }),
            ...(['copy', 'move'] as const).map(
              (op) =>
                p.provider[op] &&
                h(
                  'button',
                  {
                    type: 'button',
                    disabled: p.disabled || !selection.value.length,
                    onClick: () =>
                      action(async () => {
                        for (const item of selection.value)
                          await p.provider[op]!(item.id, target.value || null)
                      }),
                  },
                  op === 'copy' ? 'Kopieren' : 'Verschieben',
                ),
            ),
            h(
              'button',
              {
                type: 'button',
                onClick: () =>
                  (view.value = view.value === 'details' ? 'tiles' : 'details'),
              },
              view.value === 'details' ? 'Kacheln' : 'Details',
            ),
          ]),
          !!(error.value || binding.error.value) &&
            h(
              'p',
              { role: 'alert' },
              String(error.value || binding.error.value),
            ),
          h(
            'div',
            { class: view.value === 'tiles' ? 'tx-file-tiles' : 'tx-options' },
            binding.items.value.map((item) =>
              h('div', { class: 'tx-file-entry', key: item.id }, [
                h('input', {
                  type: 'checkbox',
                  checked: selection.value.some((v) => v.id === item.id),
                  disabled: p.disabled,
                  'aria-label': `${item.name} auswählen`,
                  onChange: (e: Event) => {
                    selection.value = (e.target as HTMLInputElement).checked
                      ? [...selection.value, item]
                      : selection.value.filter((v) => v.id !== item.id)
                    emit('selectionChanged', selection.value)
                  },
                }),
                h(
                  'button',
                  {
                    class: 'tx-option',
                    type: 'button',
                    disabled: p.disabled,
                    onClick: () =>
                      item.isDirectory
                        ? navigate(item)
                        : emit('fileOpened', item),
                  },
                  `${item.isDirectory ? '📁' : '📄'} ${item.name}`,
                ),
                !item.isDirectory &&
                  view.value === 'details' &&
                  h('small', `${item.size ?? 0} Bytes`),
                !item.isDirectory &&
                  p.provider.download &&
                  h(
                    'button',
                    {
                      type: 'button',
                      disabled: p.disabled,
                      onClick: () =>
                        action(async () => {
                          const blob = await p.provider.download!(item.id),
                            url = URL.createObjectURL(blob),
                            a = document.createElement('a')
                          a.href = url
                          a.download = item.name
                          a.click()
                          setTimeout(() => URL.revokeObjectURL(url), 1000)
                        }),
                    },
                    'Download',
                  ),
              ]),
            ),
          ),
          !binding.items.value.length &&
            !binding.loading.value &&
            h('p', 'Ordner ist leer'),
          p.provider.upload &&
            h(TxFileUploader, {
              multiple: true,
              disabled: p.disabled,
              adapter: async (file: File, context: { signal: AbortSignal }) => {
                const result = await p.provider.upload!(
                  parent.value,
                  file,
                  context.signal,
                )
                await source.value.reload()
                return result
              },
            }),
        ],
      )
  },
})
