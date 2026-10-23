import { calendarDate } from './calendar.js'
import type { ChatMessage, ChatUser } from '../types.js'

export function validateChatUser(user: ChatUser) {
  if (!user || (typeof user.id !== 'string' && typeof user.id !== 'number') || (typeof user.id === 'number' && !Number.isFinite(user.id)) || typeof user.name !== 'string' || !user.name.trim()) throw new Error('TxChat: Nutzer benötigen eine String-/Zahl-ID und einen Namen.')
}
export function normalizeMessages(items: readonly ChatMessage[]) {
  const keys = new Set<string | number>()
  return items.map(message => {
    if ((typeof message.id !== 'string' && typeof message.id !== 'number') || (typeof message.id === 'number' && !Number.isFinite(message.id)) || keys.has(message.id)) throw new Error('TxChat: Nachrichten benötigen eindeutige String- oder Zahl-IDs.')
    keys.add(message.id); validateChatUser(message.author)
    if (typeof message.text !== 'string' || !message.text.trim()) throw new Error('TxChat: Nachrichtentext darf nicht leer sein.')
    if (message.status && !['pending', 'sent', 'error'].includes(message.status)) throw new Error('TxChat: unbekannter Nachrichtenstatus.')
    let date: Date
    try { date = calendarDate(message.timestamp) } catch { throw new Error('TxChat: timestamp muss ein gültiges Date-Objekt oder ISO-Datumsstring sein.') }
    return { message, date }
  }).sort((a, b) => a.date.getTime() - b.date.getTime())
}
