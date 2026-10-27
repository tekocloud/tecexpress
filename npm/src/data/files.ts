import { TxCustomStore, txQuery, type TxStore } from './source.js'
export interface TxFileEntry {
  id: string
  parentId: string | null
  name: string
  isDirectory: boolean
  size?: number
  modified?: Date
  content?: Blob
}
export interface TxFileProvider {
  list(parentId: string | null, signal?: AbortSignal): Promise<TxFileEntry[]>
  createDirectory?(parentId: string | null, name: string): Promise<TxFileEntry>
  rename?(id: string, name: string): Promise<void>
  copy?(id: string, target: string | null): Promise<void>
  move?(id: string, target: string | null): Promise<void>
  remove?(id: string): Promise<void>
  upload?(
    parentId: string | null,
    file: File,
    signal?: AbortSignal,
  ): Promise<TxFileEntry>
  download?(id: string): Promise<Blob>
}
function validName(name: string) {
  if (!name.trim() || /[\\/]/.test(name) || name === '.' || name === '..')
    throw new Error('Ungültiger Dateiname')
  return name.trim()
}
export class TxMemoryFileProvider implements TxFileProvider {
  private entries: TxFileEntry[]
  private serial = 0
  constructor(entries: TxFileEntry[] = []) {
    this.entries = entries.map((v) => ({ ...v }))
    if (new Set(entries.map((v) => v.id)).size !== entries.length)
      throw new Error('Duplicate file IDs')
    for (const entry of this.entries) {
      validName(entry.name)
      this.target(entry.parentId, entry.name, entry.id)
      const visited = new Set<string>([entry.id])
      for (
        let parent = entry.parentId;
        parent !== null;
        parent = this.get(parent).parentId
      ) {
        if (visited.has(parent)) throw new Error('Cyclic directory tree')
        visited.add(parent)
      }
    }
  }
  private get(id: string) {
    const entry = this.entries.find((v) => v.id === id)
    if (!entry) throw new Error('Datei nicht gefunden')
    return entry
  }
  private id() {
    let id: string
    do {
      id = `tx-file-${++this.serial}`
    } while (this.entries.some((v) => v.id === id))
    return id
  }
  private target(parent: string | null, name: string, exclude?: string) {
    if (parent !== null && !this.get(parent).isDirectory)
      throw new Error('Kein Ordner')
    if (
      this.entries.some(
        (v) => v.parentId === parent && v.name === name && v.id !== exclude,
      )
    )
      throw new Error('Name bereits vorhanden')
  }
  async list(parentId: string | null, signal?: AbortSignal) {
    signal?.throwIfAborted()
    return this.entries
      .filter((v) => v.parentId === parentId)
      .map((v) => ({ ...v }))
  }
  async createDirectory(parentId: string | null, name: string) {
    name = validName(name)
    this.target(parentId, name)
    const entry: TxFileEntry = {
      id: this.id(),
      parentId,
      name,
      isDirectory: true,
      modified: new Date(),
    }
    this.entries.push(entry)
    return { ...entry }
  }
  async rename(id: string, name: string) {
    const item = this.get(id)
    name = validName(name)
    this.target(item.parentId, name, id)
    item.name = name
    item.modified = new Date()
  }
  private ensureMove(id: string, target: string | null) {
    for (
      let current = target;
      current !== null;
      current = this.get(current).parentId
    )
      if (current === id)
        throw new Error(
          'Ordner kann nicht in sich selbst verschoben/kopiert werden',
        )
  }
  async move(id: string, target: string | null) {
    const item = this.get(id)
    this.ensureMove(id, target)
    this.target(target, item.name, id)
    item.parentId = target
  }
  async copy(id: string, target: string | null) {
    this.ensureMove(id, target)
    const item = this.get(id)
    this.target(target, item.name)
    const clone = (entry: TxFileEntry, parent: string | null) => {
      const next = { ...entry, id: this.id(), parentId: parent }
      this.entries.push(next)
      for (const child of [...this.entries].filter(
        (v) => v.parentId === entry.id,
      ))
        clone(child, next.id)
    }
    clone(item, target)
  }
  async remove(id: string) {
    this.get(id)
    const ids = new Set([id])
    for (let changed = true; changed;) {
      changed = false
      for (const item of this.entries)
        if (item.parentId && ids.has(item.parentId) && !ids.has(item.id)) {
          ids.add(item.id)
          changed = true
        }
    }
    this.entries = this.entries.filter((v) => !ids.has(v.id))
  }
  async upload(parentId: string | null, file: File, signal?: AbortSignal) {
    signal?.throwIfAborted()
    const name = validName(file.name)
    this.target(parentId, name)
    const item = {
      id: this.id(),
      parentId,
      name,
      size: file.size,
      isDirectory: false,
      content: file as Blob,
      modified: new Date(),
    }
    this.entries.push(item)
    return { ...item }
  }
  async download(id: string) {
    const item = this.get(id)
    if (item.isDirectory)
      throw new Error('Ordner kann nicht heruntergeladen werden')
    return item.content ?? new Blob([])
  }
}
export function txFileStore(
  provider: TxFileProvider,
  parent: () => string | null,
): TxStore<TxFileEntry> {
  return new TxCustomStore({
    load: async (options) =>
      txQuery(await provider.list(parent(), options.signal), options),
    remove: provider.remove?.bind(provider),
    update: provider.rename
      ? async (id, changes) => {
          if (changes.name) await provider.rename!(String(id), changes.name)
          const item = (await provider.list(parent())).find((v) => v.id === id)
          if (!item) throw new Error('Datei nicht gefunden')
          return item
        }
      : undefined,
  })
}
export interface TxUploadContext {
  signal: AbortSignal
  onProgress: (loaded: number, total: number) => void
}
export type TxUploadAdapter = (
  file: File,
  context: TxUploadContext,
) => Promise<unknown>
export interface TxHttpUploadConfig {
  url: string
  fieldName?: string
  headers?: Record<string, string>
  withCredentials?: boolean
  fields?: Record<string, string>
  chunkSize?: number
  chunkFields?: (
    file: File,
    index: number,
    count: number,
  ) => Record<string, string>
}
export function txHttpUpload(config: TxHttpUploadConfig): TxUploadAdapter {
  return async (file, context) => {
    const size = config.chunkSize ?? Math.max(1, file.size)
    if (size <= 0) throw new Error('chunkSize must be positive')
    const count = Math.max(1, Math.ceil(file.size / size))
    let response: unknown
    for (let index = 0; index < count; index++) {
      context.signal.throwIfAborted()
      const start = index * size,
        chunk = file.slice(start, Math.min(file.size, start + size))
      response = await new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest(),
          form = new FormData()
        const abort = () => {
          xhr.abort()
          reject(new DOMException('Aborted', 'AbortError'))
        }
        context.signal.addEventListener('abort', abort, { once: true })
        const cleanup = () => context.signal.removeEventListener('abort', abort)
        xhr.open('POST', config.url)
        xhr.withCredentials = config.withCredentials ?? false
        for (const [key, value] of Object.entries(config.headers ?? {}))
          xhr.setRequestHeader(key, value)
        for (const [key, value] of Object.entries({
          ...config.fields,
          ...config.chunkFields?.(file, index, count),
        }))
          form.append(key, value)
        form.append(config.fieldName ?? 'file', chunk, file.name)
        xhr.upload.onprogress = (e) =>
          context.onProgress(
            Math.min(
              file.size,
              start +
                (e.lengthComputable ? (e.loaded / e.total) * chunk.size : 0),
            ),
            file.size,
          )
        xhr.onload = () => {
          cleanup()
          xhr.status >= 200 && xhr.status < 300
            ? resolve(xhr.responseText)
            : reject(new Error(`HTTP ${xhr.status}: ${xhr.statusText}`))
        }
        xhr.onerror = () => {
          cleanup()
          reject(new Error('Netzwerkfehler'))
        }
        xhr.onabort = () => {
          cleanup()
          reject(new DOMException('Aborted', 'AbortError'))
        }
        xhr.send(form)
      })
      context.onProgress(Math.min(file.size, start + chunk.size), file.size)
    }
    return response
  }
}
