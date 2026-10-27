import { describe, expect, it, vi } from 'vitest'
import {
  TxArrayStore,
  TxCustomStore,
  TxDataSource,
  txQuery,
  type TxLoadResult,
} from '../src'
const rows = [
  { id: 1, name: 'Alpha', category: 'A', score: 9 },
  { id: 2, name: 'Beta', category: 'B', score: 3 },
  { id: 3, name: 'Alpine', category: 'A', score: 7 },
]
type Row = (typeof rows)[number]
describe('TxDataSource', () => {
  it('combines filters, search, stable sorts, projection and grouping', () => {
    const result = txQuery(rows, {
      filter: {
        and: [
          { selector: 'score', operator: '>=', value: 7 },
          { not: { selector: 'name', value: 'Beta' } },
        ],
      },
      searchValue: 'al',
      searchExpr: ['name'],
      sort: [{ selector: 'score' }],
      select: ['id', 'name'],
    })
    expect(result.totalCount).toBe(2)
    expect(result.data).toEqual([
      { id: 3, name: 'Alpine' },
      { id: 1, name: 'Alpha' },
    ])
    const grouped = txQuery(rows, {
      group: [{ selector: 'category' }],
      take: 1,
    })
    expect(grouped.groupCount).toBe(2)
    expect(grouped.groups?.[0]).toMatchObject({ key: 'A', count: 2 })
  })
  it('queries locally once and resets paging for search and size changes', async () => {
    const source = new TxDataSource({ store: rows, pageSize: 1, pageIndex: 2 })
    await source.load()
    expect(source.items[0].id).toBe(3)
    await source.configure({ searchExpr: ['name'], searchValue: 'al' })
    expect(source.config.pageIndex).toBe(0)
    expect(source.totalCount).toBe(2)
    await source.configure({ pageSize: 2 })
    expect(source.items).toHaveLength(2)
    source.dispose()
  })
  it('forwards server operations and does not page or filter their result twice', async () => {
    const load = vi.fn(() => ({ data: [rows[2]], totalCount: 40 }))
    const source = new TxDataSource({
      store: new TxCustomStore<Row>({ load }),
      pageSize: 1,
      pageIndex: 2,
      filter: { selector: 'id', value: 999 },
    })
    await source.load()
    expect(source.items).toEqual([rows[2]])
    expect(source.totalCount).toBe(40)
    expect(load.mock.calls[0]).toBeDefined()
    expect(load).toHaveBeenCalledWith(
      expect.objectContaining({
        skip: 2,
        take: 1,
        filter: { selector: 'id', value: 999 },
        signal: expect.any(AbortSignal),
      }),
    )
  })
  it('can process a custom raw store locally', async () => {
    const source = new TxDataSource({
      store: new TxCustomStore<Row>({ load: () => ({ data: rows }) }),
      remoteOperations: false,
      pageSize: 1,
      sort: [{ selector: 'score' }],
    })
    await source.load()
    expect(source.items).toEqual([rows[1]])
    expect(source.totalCount).toBe(3)
  })
  it('suppresses stale successes and failures even when store ignores cancellation', async () => {
    const pending: {
      resolve: (v: TxLoadResult<Row>) => void
      reject: (e: Error) => void
    }[] = []
    const source = new TxDataSource({
      store: new TxCustomStore<Row>({
        load: () =>
          new Promise((resolve, reject) => pending.push({ resolve, reject })),
      }),
    })
    const first = source.load(),
      second = source.reload()
    pending[1].resolve({ data: [rows[1]] })
    await second
    pending[0].reject(new Error('outdated'))
    await first
    expect(source.items).toEqual([rows[1]])
    expect(source.error).toBeUndefined()
    expect(source.loading).toBe(false)
  })
  it('exposes failures, retries, aborts and notifies subscribers', async () => {
    let fail = true
    const source = new TxDataSource({
        store: new TxCustomStore<Row>({
          load: () => {
            if (fail) throw Error('offline')
            return { data: rows }
          },
        }),
      }),
      listener = vi.fn(),
      unsubscribe = source.subscribe(listener)
    await expect(source.load()).rejects.toThrow('offline')
    expect(source.error).toBeInstanceOf(Error)
    expect(source.loading).toBe(false)
    fail = false
    await source.reload()
    expect(source.error).toBeUndefined()
    expect(listener).toHaveBeenCalledTimes(4)
    unsubscribe()
    source.cancel()
    expect(listener).toHaveBeenCalledTimes(4)
    source.dispose()
    await expect(source.load()).rejects.toThrow('disposed')
  })
  it('supports CRUD, byKey and batched pushes with immutable keys', async () => {
    const source = new TxDataSource({ store: rows, key: 'id', paginate: false })
    await source.load()
    await source.insert({ ...rows[0], id: 4 })
    await source.update(4, { name: 'Delta' })
    expect(await source.byKey(4)).toMatchObject({ name: 'Delta' })
    await expect(source.update(4, { id: 5 })).rejects.toThrow('immutable')
    await source.remove(4)
    expect(source.containsKey(4)).toBe(false)
    await source.push([
      { type: 'remove', key: 2 },
      { type: 'update', key: 1, data: { score: 10 } },
    ])
    expect(source.items).toHaveLength(2)
    expect(source.items[0].score).toBe(10)
  })
  it('rejects duplicate keys and unsupported mutations', async () => {
    expect(() => new TxArrayStore([rows[0], rows[0]])).toThrow('Duplicate')
    const source = new TxDataSource({
      store: new TxCustomStore<Row>({ load: () => ({ data: rows }) }),
    })
    await expect(source.remove(1)).rejects.toThrow('support')
    expect(() => source.byKey(1)).toThrow('support')
  })
})
