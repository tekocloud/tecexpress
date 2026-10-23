import type { Appointment, SchedulerDate, SchedulerView } from '../types.js'

export function calendarDate(value: SchedulerDate): Date {
  if (value instanceof Date) {
    if (Number.isFinite(value.getTime())) return new Date(value.getTime())
    throw new Error('TxScheduler: ungültiges Datum.')
  }
  // Date-only strings deliberately represent local calendar days, not UTC midnight.
  const match = /^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{1,3}))?)?(Z|[+-]\d{2}:\d{2})?)?$/.exec(value)
  if (!match) throw new Error('TxScheduler: Datum muss ein Date-Objekt oder ISO-Datumsstring sein.')
  const [, y, m, d, h = '0', min = '0', sec = '0', ms = '0', zone] = match
  const year = Number(y), month = Number(m) - 1, day = Number(d)
  const leap = year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0)
  const days = [31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  if (month < 0 || month > 11 || day < 1 || day > days[month] || Number(h) > 23 || Number(min) > 59 || Number(sec) > 59) throw new Error('TxScheduler: ungültiges Kalenderdatum oder Uhrzeit.')
  if (zone) {
    const result = new Date(value)
    if (Number.isFinite(result.getTime())) return result
    throw new Error('TxScheduler: ungültiger ISO-Zeitstempel.')
  }
  const result = new Date(0)
  result.setHours(12, 0, 0, 0)
  result.setFullYear(year, month, day)
  result.setHours(Number(h), Number(min), Number(sec), Number(ms.padEnd(3, '0')))
  if (result.getFullYear() !== year || result.getMonth() !== month || result.getDate() !== day || result.getHours() !== Number(h) || result.getMinutes() !== Number(min)) throw new Error('TxScheduler: diese lokale Uhrzeit existiert nicht (Zeitumstellung).')
  return result
}
export function dayStart(date: Date) { const result = new Date(date); result.setHours(0, 0, 0, 0); return result }
export function addDays(date: Date, count: number) { const result = new Date(date); result.setDate(result.getDate() + count); return result }
export function dateKey(date: Date) { return `${String(date.getFullYear()).padStart(4, '0')}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}` }
export function localInput(date: Date) { return `${dateKey(date)}T${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}` }
export function atMinute(day: Date, minutes: number) { const result = dayStart(day); result.setMinutes(minutes); return result }
export function weekStart(date: Date, firstDay: number) { return addDays(dayStart(date), -((date.getDay() - firstDay + 7) % 7)) }
export function calendarDays(date: Date, view: SchedulerView, firstDay: number) {
  if (view === 'day') return [dayStart(date)]
  if (view === 'week') { const start = weekStart(date, firstDay); return Array.from({ length: 7 }, (_, i) => addDays(start, i)) }
  const first = dayStart(date); first.setDate(1)
  const start = weekStart(first, firstDay)
  return Array.from({ length: 42 }, (_, i) => addDays(start, i))
}
export function navigateDate(date: Date, view: SchedulerView, direction: number) {
  if (view !== 'month') return addDays(date, direction * (view === 'week' ? 7 : 1))
  const result = dayStart(date), originalDay = result.getDate()
  result.setDate(1); result.setMonth(result.getMonth() + direction)
  const last = new Date(result); last.setMonth(last.getMonth() + 1, 0)
  result.setDate(Math.min(originalDay, last.getDate()))
  return result
}

export interface CalendarAppointment { data: Appointment; start: Date; end: Date }
export function normalizeAppointments(data: readonly Appointment[]): CalendarAppointment[] {
  const keys = new Set<string | number>()
  return data.map(appointment => {
    if ((typeof appointment.id !== 'string' && typeof appointment.id !== 'number') || (typeof appointment.id === 'number' && !Number.isFinite(appointment.id)) || keys.has(appointment.id)) throw new Error('TxScheduler: Termine benötigen eindeutige String- oder Zahl-IDs.')
    keys.add(appointment.id)
    if (typeof appointment.text !== 'string' || !appointment.text.trim()) throw new Error('TxScheduler: jeder Termin benötigt einen Titel.')
    const start = calendarDate(appointment.startDate), end = calendarDate(appointment.endDate)
    if (end <= start) throw new Error('TxScheduler: Terminende muss nach dem Beginn liegen.')
    if (appointment.allDay && (start.getTime() !== dayStart(start).getTime() || end.getTime() !== dayStart(end).getTime())) throw new Error('TxScheduler: Ganztagstermine müssen an lokalen Tagesgrenzen beginnen und enden.')
    return { data: appointment, start, end }
  })
}
export function appointmentsOnDay(appointments: CalendarAppointment[], day: Date) {
  const start = dayStart(day), end = addDays(start, 1)
  return appointments.filter(appointment => appointment.start < end && appointment.end > start)
    .sort((a, b) => Number(!!b.data.allDay) - Number(!!a.data.allDay) || a.start.getTime() - b.start.getTime())
}
export interface AppointmentSegment extends CalendarAppointment { top: number; height: number; lane: number; laneCount: number }
export function layoutAppointments(appointments: CalendarAppointment[], day: Date, startHour: number, endHour: number): AppointmentSegment[] {
  const minute = (date: Date) => date.getHours() * 60 + date.getMinutes() + date.getSeconds() / 60
  const rangeStart = startHour * 60, rangeEnd = endHour * 60, range = rangeEnd - rangeStart
  const segments = appointmentsOnDay(appointments, day).filter(appointment => !appointment.data.allDay).map(appointment => {
    const start = appointment.start < dayStart(day) ? 0 : minute(appointment.start)
    let end = appointment.end >= addDays(dayStart(day), 1) ? 1440 : minute(appointment.end)
    // The repeated DST hour shares a wall-clock lane; keep positive-duration events visible.
    if (end <= start) end = Math.min(1440, start + (appointment.end.getTime() - appointment.start.getTime()) / 60000)
    return { ...appointment, from: Math.max(rangeStart, start), to: Math.min(rangeEnd, end) }
  }).filter(segment => segment.to > segment.from).sort((a, b) => a.from - b.from || b.to - a.to)
  const output: AppointmentSegment[] = [], cluster: AppointmentSegment[] = [], laneEnds: number[] = []
  let clusterEnd = -1
  function flush() { cluster.forEach(segment => { segment.laneCount = laneEnds.length }); cluster.length = 0; laneEnds.length = 0 }
  segments.forEach(segment => {
    if (segment.from >= clusterEnd) { flush(); clusterEnd = -1 }
    let lane = laneEnds.findIndex(end => end <= segment.from)
    if (lane === -1) lane = laneEnds.length
    laneEnds[lane] = segment.to
    clusterEnd = Math.max(clusterEnd, segment.to)
    const item: AppointmentSegment = { data: segment.data, start: segment.start, end: segment.end, top: (segment.from - rangeStart) / range * 100, height: (segment.to - segment.from) / range * 100, lane, laneCount: 1 }
    cluster.push(item); output.push(item)
  })
  flush()
  return output
}

export function appointmentFingerprint(appointment: Appointment) {
  return JSON.stringify([appointment.text, calendarDate(appointment.startDate).getTime(), calendarDate(appointment.endDate).getTime(), !!appointment.allDay, appointment.description ?? ''])
}
