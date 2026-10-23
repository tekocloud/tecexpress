import { describe, expect, it } from 'vitest'
import { addDays, appointmentsOnDay, calendarDate, calendarDays, dateKey, layoutAppointments, navigateDate, normalizeAppointments, weekStart } from '../src/data/calendar'

describe('calendar arithmetic and date contracts', () => {
  it('reads date-only values as local dates and rejects rolled-over dates', () => {
    const date = calendarDate('2026-10-23')
    expect([date.getFullYear(), date.getMonth(), date.getDate(), date.getHours()]).toEqual([2026, 9, 23, 0])
    expect(calendarDate('2026-10-23T09:00Z').toISOString()).toBe('2026-10-23T09:00:00.000Z')
    for (const invalid of ['2026-02-29', '2026-02-30T09:00Z', '2026-13-01', '2026-01-01T24:00', 'morgen']) expect(() => calendarDate(invalid)).toThrow('TxScheduler')
    expect(() => calendarDate(new Date('invalid'))).toThrow('ungültiges Datum')
    expect(dateKey(calendarDate('2024-02-29'))).toBe('2024-02-29')
    const source = new Date(2026, 9, 23)
    expect(calendarDate(source)).not.toBe(source)
  })
  it('calculates week/month boundaries and clamps month navigation', () => {
    const date = calendarDate('2026-01-31')
    expect(dateKey(navigateDate(date, 'month', 1))).toBe('2026-02-28')
    expect(dateKey(navigateDate(calendarDate('2024-01-31'), 'month', 1))).toBe('2024-02-29')
    expect(dateKey(navigateDate(calendarDate('2026-12-31'), 'day', 1))).toBe('2027-01-01')
    expect(dateKey(navigateDate(date, 'week', 1))).toBe('2026-02-07')
    expect(dateKey(weekStart(calendarDate('2026-10-23'), 1))).toBe('2026-10-19')
    expect(dateKey(weekStart(calendarDate('2026-10-23'), 0))).toBe('2026-10-18')
    const days = calendarDays(calendarDate('2026-02-01'), 'month', 1)
    expect(days).toHaveLength(42)
    expect(dateKey(days[0])).toBe('2026-01-26')
    expect(dateKey(days.at(-1)!)).toBe('2026-03-08')
    expect(dateKey(date)).toBe('2026-01-31')
  })
  it('uses exclusive end boundaries and renders overnight appointments on each affected day', () => {
    const data = normalizeAppointments([
      { id: 1, text: 'Ganztag', startDate: '2026-10-23', endDate: '2026-10-24', allDay: true },
      { id: 2, text: 'Über Nacht', startDate: '2026-10-23T17:00', endDate: '2026-10-24T10:00' }
    ])
    expect(appointmentsOnDay(data, calendarDate('2026-10-23')).map(item => item.data.id)).toEqual([1, 2])
    expect(appointmentsOnDay(data, calendarDate('2026-10-24')).map(item => item.data.id)).toEqual([2])
    expect(appointmentsOnDay(data, calendarDate('2026-10-25'))).toHaveLength(0)
    expect(layoutAppointments(data, calendarDate('2026-10-23'), 8, 18)[0]).toMatchObject({ top: 90, height: 10 })
    expect(layoutAppointments(data, calendarDate('2026-10-24'), 8, 18)[0]).toMatchObject({ top: 0, height: 20 })
  })
  it('lays out overlapping clusters without treating touching events as overlaps', () => {
    const data = normalizeAppointments([
      { id: 1, text: 'A', startDate: '2026-10-23T09:00', endDate: '2026-10-23T10:30' },
      { id: 2, text: 'B', startDate: '2026-10-23T09:30', endDate: '2026-10-23T11:00' },
      { id: 3, text: 'C', startDate: '2026-10-23T11:00', endDate: '2026-10-23T12:00' },
      { id: 4, text: 'Outside', startDate: '2026-10-23T19:00', endDate: '2026-10-23T20:00' }
    ])
    expect(layoutAppointments(data, calendarDate('2026-10-23'), 8, 18).map(item => [item.data.id, item.lane, item.laneCount])).toEqual([[1, 0, 2], [2, 1, 2], [3, 0, 1]])
  })
  it('rejects invalid appointments and duplicate identities', () => {
    const item = { id: 1, text: 'A', startDate: '2026-10-23T09:00', endDate: '2026-10-23T10:00' }
    expect(() => normalizeAppointments([item, item])).toThrow('eindeutige')
    expect(() => normalizeAppointments([{ ...item, text: ' ' }])).toThrow('Titel')
    expect(() => normalizeAppointments([{ ...item, endDate: item.startDate }])).toThrow('nach dem Beginn')
    expect(() => normalizeAppointments([{ ...item, allDay: true }])).toThrow('Tagesgrenzen')
    expect(() => normalizeAppointments([{ ...item, id: NaN }])).toThrow('eindeutige')
  })
  it('preserves local midnight over daylight saving changes', () => {
    for (const value of ['2026-03-28', '2026-10-24']) {
      const start = calendarDate(value), days = Array.from({ length: 4 }, (_, index) => addDays(start, index))
      expect(days.every(day => day.getHours() === 0)).toBe(true)
      expect(new Set(days.map(dateKey)).size).toBe(4)
    }
  })
})
