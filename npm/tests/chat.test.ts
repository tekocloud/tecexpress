import { afterEach, describe, expect, it, vi } from 'vitest'
import { mount, type VueWrapper } from '@vue/test-utils'
import { defineComponent, h, nextTick, ref } from 'vue'
import { TxChat, type ChatMessage, type ChatMessageEnteredEvent } from '../src'

const user = { id: 'me', name: 'Stefan Bess' }, other = { id: 'other', name: 'Lena Fischer' }
const initial: ChatMessage[] = [
  { id: 'a', text: 'Hallo', timestamp: '2026-10-23T09:00', author: other },
  { id: 'b', text: 'Guten Morgen', timestamp: '2026-10-23T09:01', author: user, status: 'sent' }
]
const mounted: VueWrapper[] = []
function chat(props = {}, slots = {}): VueWrapper { const wrapper = mount(TxChat, { props: { user, ...props }, slots, attachTo: document.body }); mounted.push(wrapper); return wrapper }
afterEach(() => { mounted.splice(0).forEach(wrapper => wrapper.unmount()); vi.useRealTimers(); document.body.innerHTML = '' })

describe('TxChat', () => {
  it('renders chronology, authors, own messages and local delivery states without mutation', () => {
    const wrapper = chat({ items: [initial[1], initial[0]] })
    expect(wrapper.findAll('.tx-chat-bubble').map(bubble => bubble.text())).toEqual(['Hallo', 'Guten Morgen'])
    expect(wrapper.findAll('.tx-chat-day')).toHaveLength(1)
    expect(wrapper.get('.tx-chat-own .tx-chat-author').text()).toBe('Stefan Bess')
    expect(wrapper.get('.tx-chat-own .tx-chat-message-status').text()).toBe('Lokal gesendet')
    expect(wrapper.get('time').attributes('datetime')).toContain('2026-10-23T')
    expect(initial[0].text).toBe('Hallo')
  })
  it('sends locally with Enter, trims text and clears the composer', async () => {
    const wrapper = chat()
    await wrapper.get('textarea').setValue('  Hallo Team  ')
    await wrapper.get('textarea').trigger('keydown', { key: 'Enter' })
    await nextTick()
    const message = (wrapper.emitted('update:items')?.[0]?.[0] as ChatMessage[])[0]
    expect(message).toMatchObject({ text: 'Hallo Team', author: user, status: 'sent' })
    expect(message.timestamp).toBeInstanceOf(Date)
    expect(wrapper.emitted('messageEntered')).toHaveLength(1)
    expect(wrapper.emitted('messageSent')).toHaveLength(1)
    expect(wrapper.get('textarea').element).toHaveProperty('value', '')
    expect(wrapper.get('.tx-chat-bubble').text()).toBe('Hallo Team')
  })
  it('round trips controlled items and inputFieldText', async () => {
    const items = ref<ChatMessage[]>([]), draft = ref('Vorbelegt')
    const parent = mount(defineComponent({ setup: () => () => h(TxChat, { user, items: items.value, inputFieldText: draft.value, 'onUpdate:items': next => { items.value = next }, 'onUpdate:inputFieldText': next => { draft.value = next } }) })); mounted.push(parent)
    await parent.get('textarea').setValue('Modellnachricht')
    expect(draft.value).toBe('Modellnachricht')
    await parent.get('form').trigger('submit')
    expect(items.value[0].text).toBe('Modellnachricht')
    expect(draft.value).toBe('')
    items.value = [...items.value, { ...initial[0] }]
    await nextTick()
    expect(parent.findAll('.tx-chat-message')).toHaveLength(2)
  })
  it('retains drafts on synchronous cancellation and never sends whitespace or overlong drafts', async () => {
    const wrapper = chat({ onMessageEntered: (event: ChatMessageEnteredEvent) => { event.cancel = true } })
    await wrapper.get('textarea').setValue('Nicht senden')
    await wrapper.get('form').trigger('submit')
    expect(wrapper.emitted('update:items')).toBeUndefined()
    expect(wrapper.get('textarea').element).toHaveProperty('value', 'Nicht senden')
    await wrapper.get('textarea').setValue('  ')
    await wrapper.get('form').trigger('submit')
    expect(wrapper.emitted('messageEntered')).toHaveLength(1)
    await wrapper.setProps({ maxLength: 3, inputFieldText: 'Zu lang' })
    await wrapper.get('form').trigger('submit')
    expect(wrapper.emitted('messageEntered')).toHaveLength(1)
  })
  it('does not send on Shift+Enter or during IME composition', async () => {
    const wrapper = chat()
    await wrapper.get('textarea').setValue('Text')
    await wrapper.get('textarea').trigger('keydown', { key: 'Enter', shiftKey: true })
    await wrapper.get('textarea').trigger('compositionstart')
    await wrapper.get('textarea').trigger('keydown', { key: 'Enter' })
    await wrapper.get('textarea').trigger('compositionend')
    await wrapper.get('textarea').trigger('keydown', { key: 'Enter', isComposing: true })
    expect(wrapper.emitted('messageSent')).toBeUndefined()
    await wrapper.get('textarea').trigger('keydown', { key: 'Enter' })
    expect(wrapper.emitted('messageSent')).toHaveLength(1)
  })
  it('manages typing events, inactivity timers and cleanup', async () => {
    vi.useFakeTimers()
    const typingEnd = vi.fn()
    const wrapper = chat({ onTypingEnd: typingEnd })
    await wrapper.get('textarea').setValue('H')
    await wrapper.get('textarea').setValue('Hallo')
    expect(wrapper.emitted('typingStart')).toHaveLength(1)
    vi.advanceTimersByTime(1500)
    expect(wrapper.emitted('typingEnd')).toHaveLength(1)
    await wrapper.get('textarea').setValue('Hallo!')
    expect(wrapper.emitted('typingStart')).toHaveLength(2)
    wrapper.unmount()
    expect(vi.getTimerCount()).toBe(0)
    expect(typingEnd).toHaveBeenCalledTimes(2)
  })
  it('honors disabled, read-only, loading and sending while retaining drafts', async () => {
    const wrapper = chat({ inputFieldText: 'Entwurf', disabled: true })
    await wrapper.get('form').trigger('submit')
    expect(wrapper.emitted('update:items')).toBeUndefined()
    expect(wrapper.get('textarea').attributes('disabled')).toBeDefined()
    await wrapper.setProps({ disabled: false, sending: true })
    await wrapper.get('form').trigger('submit')
    expect(wrapper.emitted('update:items')).toBeUndefined()
    expect(wrapper.get('textarea').element).toHaveProperty('value', 'Entwurf')
    await wrapper.setProps({ sending: false, loading: true })
    expect(wrapper.get('[role=log]').text()).toContain('Nachrichten werden geladen')
    await wrapper.setProps({ loading: false, readOnly: true })
    expect(wrapper.find('form').exists()).toBe(false)
  })
  it('supports typing users, status errors and template overrides', () => {
    const wrapper = chat({ typingUsers: [user, other], items: [{ ...initial[1], status: 'error' }] })
    expect(wrapper.get('.tx-chat-typing').text()).toBe('Lena Fischer schreibt …')
    expect(wrapper.get('.tx-chat-message-status').text()).toBe('Senden fehlgeschlagen')
    const custom = chat({ items: initial, showAvatar: false, showUserName: false, showDayHeaders: false, showMessageTimestamp: false }, { message: ({ message, isOwn }: { message: ChatMessage; isOwn: boolean }) => h('b', `${message.text}: ${isOwn}`) })
    expect(custom.get('.tx-chat-bubble b').text()).toBe('Hallo: false')
    expect(custom.find('time').exists()).toBe(false)
    expect(custom.find('.tx-chat-avatar').exists()).toBe(false)
  })
  it('preserves a scrolled-up position and offers navigation to newly added messages', async () => {
    const wrapper = chat({ items: initial })
    await nextTick(); await nextTick()
    const element = wrapper.get('[role=log]').element as HTMLElement
    Object.defineProperty(element, 'scrollHeight', { configurable: true, get: () => 1000 })
    Object.defineProperty(element, 'clientHeight', { configurable: true, get: () => 100 })
    element.scrollTop = 100
    await wrapper.get('[role=log]').trigger('scroll')
    await wrapper.setProps({ items: [...initial, { id: 'new', text: 'Neue Nachricht', timestamp: '2026-10-23T10:00', author: other }] })
    await nextTick()
    expect(element.scrollTop).toBe(100)
    expect(wrapper.get('.tx-chat-unread').text()).toContain('1 neue Nachricht')
    await wrapper.get('.tx-chat-unread').trigger('click')
    await nextTick()
    expect(element.scrollTop).toBe(1000)
    expect(wrapper.find('.tx-chat-unread').exists()).toBe(false)
  })
  it('rejects invalid messages and renders text without HTML interpretation', () => {
    expect(() => chat({ items: [initial[0], initial[0]] })).toThrow('eindeutige')
    expect(() => chat({ items: [{ ...initial[0], timestamp: 'ungültig' }] })).toThrow('timestamp')
    expect(() => chat({ user: { id: 1, name: '' } })).toThrow('Namen')
    const wrapper = chat({ items: [{ ...initial[0], text: '<img src=x onerror=alert(1)>' }] })
    expect(wrapper.find('img').exists()).toBe(false)
    expect(wrapper.get('.tx-chat-bubble').text()).toBe('<img src=x onerror=alert(1)>')
  })
})
