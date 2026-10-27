export type TxKey = string | number
export type TxSelector<T> = string | ((item: T) => unknown)
export interface TxSort<T> {
  selector: TxSelector<T>
  desc?: boolean
}
export type TxFilter<T> =
  | {
      selector: TxSelector<T>
      operator?:
        | '='
        | '<>'
        | '>'
        | '>='
        | '<'
        | '<='
        | 'contains'
        | 'startswith'
        | 'endswith'
      value: unknown
    }
  | { and: TxFilter<T>[] }
  | { or: TxFilter<T>[] }
  | { not: TxFilter<T> }
export interface TxGroup<T> {
  key: unknown
  items: T[] | TxGroup<T>[]
  count: number
}
export interface TxLoadOptions<T> {
  sort?: TxSort<T>[]
  filter?: TxFilter<T>
  searchExpr?: TxSelector<T>[]
  searchValue?: string
  group?: TxSort<T>[]
  skip?: number
  take?: number
  select?: string[]
  requireTotalCount?: boolean
  requireGroupCount?: boolean
  signal?: AbortSignal
}
export interface TxLoadResult<T> {
  data: T[]
  groups?: TxGroup<T>[]
  totalCount?: number
  groupCount?: number
}
export interface TxStore<T> {
  load(options: TxLoadOptions<T>): Promise<TxLoadResult<T>> | TxLoadResult<T>
  byKey?(key: TxKey): Promise<T | undefined> | T | undefined
  insert?(item: T): Promise<T> | T
  update?(key: TxKey, changes: Partial<T>): Promise<T> | T
  remove?(key: TxKey): Promise<void> | void
}
export interface TxDataSourceConfig<T> extends Omit<
  TxLoadOptions<T>,
  'skip' | 'take' | 'signal'
> {
  store: TxStore<T> | T[]
  key?: TxSelector<T>
  pageSize?: number
  pageIndex?: number
  paginate?: boolean
  remoteOperations?: boolean
  map?: (item: T) => T
}
export type TxSource<T> = T[] | TxDataSourceConfig<T> | TxDataSource<T>
export type TxPush<T> =
  | { type: 'insert'; data: T }
  | { type: 'update'; key: TxKey; data: Partial<T> }
  | { type: 'remove'; key: TxKey }
export function txRead<T>(item: T, selector: TxSelector<T>): unknown {
  return typeof selector === 'function'
    ? selector(item)
    : selector
        .split('.')
        .reduce<unknown>(
          (v, k) =>
            v != null && typeof v === 'object'
              ? (v as Record<string, unknown>)[k]
              : undefined,
          item,
        )
}
function compare(a: unknown, b: unknown): number {
  return a == null
    ? b == null
      ? 0
      : -1
    : b == null
      ? 1
      : a instanceof Date && b instanceof Date
        ? +a - +b
        : typeof a === 'number' && typeof b === 'number'
          ? a - b
          : String(a).localeCompare(String(b), undefined, { numeric: true })
}
export function txMatches<T>(item: T, f: TxFilter<T>): boolean {
  if ('and' in f) return f.and.every((v) => txMatches(item, v))
  if ('or' in f) return f.or.some((v) => txMatches(item, v))
  if ('not' in f) return !txMatches(item, f.not)
  const a = txRead(item, f.selector),
    b = f.value,
    c = compare(a, b),
    text = String(a ?? '').toLocaleLowerCase(),
    value = String(b ?? '').toLocaleLowerCase()
  switch (f.operator ?? '=') {
    case '=':
      return (
        Object.is(a, b) || (a instanceof Date && b instanceof Date && +a === +b)
      )
    case '<>':
      return !(
        Object.is(a, b) ||
        (a instanceof Date && b instanceof Date && +a === +b)
      )
    case '>':
      return c > 0
    case '>=':
      return c >= 0
    case '<':
      return c < 0
    case '<=':
      return c <= 0
    case 'contains':
      return text.includes(value)
    case 'startswith':
      return text.startsWith(value)
    case 'endswith':
      return text.endsWith(value)
  }
}
export function txQuery<T>(
  input: readonly T[],
  o: TxLoadOptions<T>,
): TxLoadResult<T> {
  let data = input.filter(
    (item) =>
      (!o.filter || txMatches(item, o.filter)) &&
      (!o.searchValue ||
        (
          o.searchExpr ?? [
            (v: T) =>
              typeof v === 'object' ? Object.values(v as object).join(' ') : v,
          ]
        ).some((s) =>
          String(txRead(item, s) ?? '')
            .toLocaleLowerCase()
            .includes(o.searchValue!.toLocaleLowerCase()),
        )),
  )
  const sort = [...(o.group ?? []), ...(o.sort ?? [])]
  if (sort.length)
    data.sort((a, b) => {
      for (const s of sort) {
        const c = compare(txRead(a, s.selector), txRead(b, s.selector))
        if (c) return s.desc ? -c : c
      }
      return 0
    })
  const totalCount = data.length
  function group(rows: T[], level: number): TxGroup<T>[] {
    const buckets = new Map<unknown, T[]>()
    for (const row of rows) {
      const k = txRead(row, o.group![level].selector)
      const b = buckets.get(k) ?? []
      b.push(row)
      buckets.set(k, b)
    }
    return [...buckets].map(([key, items]) => ({
      key,
      count: items.length,
      items: level + 1 < o.group!.length ? group(items, level + 1) : items,
    }))
  }
  const allGroups = o.group?.length ? group(data, 0) : undefined
  const skip = Math.max(0, o.skip ?? 0),
    end = o.take === undefined ? undefined : skip + Math.max(0, o.take)
  data = data.slice(skip, end)
  if (o.select)
    data = data.map(
      (item) =>
        Object.fromEntries(
          o.select!.map((field) => [field, txRead(item, field)]),
        ) as T,
    )
  return {
    data,
    totalCount,
    groups: allGroups?.slice(skip, end),
    groupCount: allGroups?.length,
  }
}
export class TxArrayStore<T> implements TxStore<T> {
  readonly data: T[]
  constructor(
    data: readonly T[] = [],
    readonly key: TxSelector<T> = 'id',
  ) {
    this.data = [...data]
    this.validate()
  }
  private validate() {
    const keys = this.data
      .map((v) => txRead(v, this.key))
      .filter((v) => v !== undefined)
    if (new Set(keys).size !== keys.length)
      throw new Error('Duplicate store keys')
  }
  load(o: TxLoadOptions<T>) {
    return txQuery(this.data, o)
  }
  byKey(key: TxKey) {
    return this.data.find((item) => txRead(item, this.key) === key)
  }
  insert(item: T) {
    const key = txRead(item, this.key)
    if (key === undefined || this.byKey(key as TxKey))
      throw new Error('A unique key is required')
    this.data.push(item)
    return item
  }
  update(key: TxKey, changes: Partial<T>) {
    const i = this.data.findIndex((v) => txRead(v, this.key) === key)
    if (i < 0) throw new Error('Unknown key')
    const next = { ...this.data[i], ...changes }
    if (txRead(next, this.key) !== key) throw new Error('Keys are immutable')
    this.data[i] = next
    return next
  }
  remove(key: TxKey) {
    const i = this.data.findIndex((v) => txRead(v, this.key) === key)
    if (i < 0) throw new Error('Unknown key')
    this.data.splice(i, 1)
  }
}
export class TxCustomStore<T> implements TxStore<T> {
  readonly load: TxStore<T>['load']
  readonly byKey?: TxStore<T>['byKey']
  readonly insert?: TxStore<T>['insert']
  readonly update?: TxStore<T>['update']
  readonly remove?: TxStore<T>['remove']
  constructor(callbacks: TxStore<T>) {
    this.load = callbacks.load.bind(callbacks)
    this.byKey = callbacks.byKey?.bind(callbacks)
    this.insert = callbacks.insert?.bind(callbacks)
    this.update = callbacks.update?.bind(callbacks)
    this.remove = callbacks.remove?.bind(callbacks)
  }
}
export class TxDataSource<T> {
  readonly store: TxStore<T>
  readonly key: TxSelector<T>
  items: T[] = []
  groups?: TxGroup<T>[]
  totalCount = 0
  groupCount?: number
  loading = false
  error: unknown
  loaded = false
  private listeners = new Set<() => void>()
  private controller?: AbortController
  private generation = 0
  private disposed = false
  readonly config: TxDataSourceConfig<T>
  private removedKeys = new Set<TxKey>()
  containsKey(key: TxKey): boolean | undefined {
    return this.removedKeys.has(key)
      ? false
      : this.store instanceof TxArrayStore
        ? this.store.byKey(key) !== undefined
        : undefined
  }
  constructor(config: TxDataSourceConfig<T> | T[]) {
    this.config = Array.isArray(config) ? { store: config } : { ...config }
    this.key = this.config.key ?? 'id'
    if (
      (this.config.pageSize !== undefined &&
        (!Number.isInteger(this.config.pageSize) ||
          this.config.pageSize < 1)) ||
      (this.config.pageIndex !== undefined &&
        (!Number.isInteger(this.config.pageIndex) || this.config.pageIndex < 0))
    )
      throw new Error('Invalid paging configuration')
    this.store = Array.isArray(this.config.store)
      ? new TxArrayStore(this.config.store, this.key)
      : this.config.store
  }
  subscribe(listener: () => void) {
    this.listeners.add(listener)
    return () => {
      this.listeners.delete(listener)
    }
  }
  private notify() {
    for (const listener of this.listeners) listener()
  }
  private pending?: Promise<T[]>
  get pendingLoad() {
    return this.pending
  }
  load(): Promise<T[]> {
    this.pending = this.performLoad()
    return this.pending
  }
  private async performLoad(): Promise<T[]> {
    if (this.disposed) throw new Error('DataSource disposed')
    this.controller?.abort()
    const generation = ++this.generation
    const controller = (this.controller = new AbortController())
    this.loading = true
    this.error = undefined
    this.notify()
    const c = this.config,
      options: TxLoadOptions<T> = {
        ...c,
        requireTotalCount: c.requireTotalCount ?? true,
        requireGroupCount: c.requireGroupCount ?? !!c.group?.length,
        skip:
          c.paginate === false
            ? undefined
            : (c.pageIndex ?? 0) * (c.pageSize ?? 20),
        take: c.paginate === false ? undefined : (c.pageSize ?? 20),
        signal: controller.signal,
      }
    try {
      const remote = c.remoteOperations ?? !(this.store instanceof TxArrayStore)
      const raw = await this.store.load(
        remote || this.store instanceof TxArrayStore
          ? options
          : { signal: controller.signal },
      )
      if (generation !== this.generation || controller.signal.aborted)
        return this.items
      const result =
        remote || this.store instanceof TxArrayStore
          ? raw
          : txQuery(raw.data, options)
      this.items = c.map ? result.data.map(c.map) : result.data
      this.groups = result.groups
      this.totalCount = result.totalCount ?? result.data.length
      this.groupCount = result.groupCount
      this.loaded = true
      return this.items
    } catch (error) {
      if (generation === this.generation && !controller.signal.aborted) {
        this.error = error
        throw error
      }
      return this.items
    } finally {
      if (generation === this.generation) {
        this.loading = false
        this.notify()
      }
    }
  }
  reload() {
    return this.load()
  }
  configure(changes: Partial<TxDataSourceConfig<T>>) {
    if (
      (changes.pageSize !== undefined &&
        (!Number.isInteger(changes.pageSize) || changes.pageSize < 1)) ||
      (changes.pageIndex !== undefined &&
        (!Number.isInteger(changes.pageIndex) || changes.pageIndex < 0))
    )
      throw new Error('Invalid paging configuration')
    if ('store' in changes || 'key' in changes)
      throw new Error('Create a new DataSource to replace its store or key')
    const reset = ['filter', 'searchValue', 'searchExpr', 'pageSize'].some(
      (k) => k in changes,
    )
    Object.assign(this.config, changes)
    if (reset && !('pageIndex' in changes)) this.config.pageIndex = 0
    return this.load()
  }
  cancel() {
    this.generation++
    this.controller?.abort()
    this.loading = false
    this.notify()
  }
  byKey(key: TxKey) {
    if (!this.store.byKey) throw new Error('Store does not support byKey')
    return Promise.resolve(this.store.byKey(key))
  }
  private async write<R>(operation: () => R | Promise<R>): Promise<R> {
    try {
      const result = await operation()
      await this.reload()
      return result
    } catch (error) {
      this.error = error
      this.notify()
      throw error
    }
  }
  insert(item: T) {
    return this.write(async () => {
      if (!this.store.insert) throw new Error('Store does not support insert')
      const result = await this.store.insert(item)
      this.removedKeys.delete(txRead(result, this.key) as TxKey)
      return result
    })
  }
  update(key: TxKey, changes: Partial<T>) {
    return this.write(async () => {
      if (!this.store.update) throw new Error('Store does not support update')
      return this.store.update(key, changes)
    })
  }
  remove(key: TxKey) {
    return this.write(async () => {
      if (!this.store.remove) throw new Error('Store does not support remove')
      await this.store.remove(key)
      this.removedKeys.add(key)
    })
  }
  async push(changes: TxPush<T>[]) {
    await this.write(async () => {
      for (const change of changes) {
        if (change.type === 'insert') {
          if (!this.store.insert)
            throw new Error('Store does not support insert')
          const result = await this.store.insert(change.data)
          this.removedKeys.delete(txRead(result, this.key) as TxKey)
        } else if (change.type === 'update') {
          if (!this.store.update)
            throw new Error('Store does not support update')
          await this.store.update(change.key, change.data)
        } else {
          if (!this.store.remove)
            throw new Error('Store does not support remove')
          await this.store.remove(change.key)
          this.removedKeys.add(change.key)
        }
      }
    })
    return this.items
  }
  dispose() {
    this.cancel()
    this.disposed = true
    this.listeners.clear()
  }
}
