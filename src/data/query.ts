import type { Column, DataRow, SortDescriptor } from '../types.js'

export function readField(row: DataRow, field: string): unknown {
  return field.split('.').reduce<unknown>((value, key) => value !== null && typeof value === 'object' ? (value as DataRow)[key] : undefined, row)
}
export function queryRows(rows: readonly DataRow[], filters: Record<string, string>, sort: SortDescriptor | null) {
  const entries = Object.entries(filters).filter(([, value]) => value !== '')
  const result = rows.filter(row => entries.every(([field, value]) => String(readField(row, field) ?? '').toLocaleLowerCase().includes(value.toLocaleLowerCase())))
  if (sort) result.sort((a, b) => {
    const left = readField(a, sort.dataField), right = readField(b, sort.dataField)
    const compared = left == null ? right == null ? 0 : -1 : right == null ? 1 : typeof left === 'number' && typeof right === 'number' ? left - right : String(left).localeCompare(String(right), undefined, { numeric: true })
    return sort.desc ? -compared : compared
  })
  return result
}
export function inferColumns(rows: readonly DataRow[]): Column[] {
  return Object.keys(rows[0] ?? {}).map(dataField => ({ dataField }))
}
