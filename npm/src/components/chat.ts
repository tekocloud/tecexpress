import { computed, defineComponent, h, nextTick, onBeforeUnmount, onMounted, ref, useId, watch, type PropType } from 'vue'
import { TxButton } from './editors.js'
import { TxLoadIndicator } from './overlays.js'
import { dateKey } from '../data/calendar.js'
import { normalizeMessages, validateChatUser } from '../data/chat.js'
import type { ChatMessage, ChatMessageEnteredEvent, ChatMessageEvent, ChatTypingEvent, ChatUser } from '../types.js'

export const TxChat = defineComponent({
  name: 'TxChat',
  props: {
    user: { type: Object as PropType<ChatUser>, required: true }, items: { type: Array as PropType<ChatMessage[]>, default: undefined },
    inputFieldText: { type: String, default: undefined }, title: { type: String, default: 'Chat' }, subtitle: { type: String, default: '' },
    label: { type: String, default: 'Chat' }, placeholder: { type: String, default: 'Nachricht schreiben …' },
    emptyText: { type: String, default: 'Noch keine Nachrichten. Starte die Unterhaltung.' },
    disabled: Boolean, readOnly: Boolean, loading: Boolean, sending: Boolean,
    maxLength: { type: Number, default: 4000 }, typingUsers: { type: Array as PropType<ChatUser[]>, default: () => [] },
    showAvatar: { type: Boolean, default: true }, showUserName: { type: Boolean, default: true },
    showDayHeaders: { type: Boolean, default: true }, showMessageTimestamp: { type: Boolean, default: true },
    locale: { type: String, default: 'de-DE' }
  },
  emits: {
    'update:items': (_items: ChatMessage[]) => true,
    'update:inputFieldText': (_text: string) => true,
    messageEntered: (_event: ChatMessageEnteredEvent) => true,
    messageSent: (_event: ChatMessageEvent) => true,
    typingStart: (_event: ChatTypingEvent) => true, typingEnd: (_event: ChatTypingEvent) => true
  },
  setup(props, { emit, slots }) {
    const id = useId(), internalItems = ref<ChatMessage[]>([]), internalText = ref(''), list = ref<HTMLElement>()
    const composing = ref(false), atBottom = ref(true), unread = ref(0), error = ref('')
    let counter = 0, typing = false, typingTimer: ReturnType<typeof setTimeout> | undefined, alive = true
    const input = computed(() => props.inputFieldText ?? internalText.value)
    const items = computed(() => props.items ?? internalItems.value)
    const messages = computed(() => {
      validateChatUser(props.user)
      if (!Number.isInteger(props.maxLength) || props.maxLength < 1) throw new Error('TxChat: maxLength muss eine positive ganze Zahl sein.')
      return normalizeMessages(items.value)
    })
    const blocked = computed(() => props.disabled || props.readOnly || props.loading || props.sending)
    const canSend = computed(() => !blocked.value && !!input.value.trim() && input.value.length <= props.maxLength)
    const formatDate = (date: Date) => new Intl.DateTimeFormat(props.locale, { day: 'numeric', month: 'long', year: 'numeric' }).format(date)
    const formatTime = (date: Date) => new Intl.DateTimeFormat(props.locale, { hour: '2-digit', minute: '2-digit', hourCycle: 'h23' }).format(date)
    function setText(value: string) { internalText.value = value; emit('update:inputFieldText', value) }
    function endTyping() {
      if (typingTimer !== undefined) { clearTimeout(typingTimer); typingTimer = undefined }
      if (typing) { typing = false; emit('typingEnd', { user: props.user }) }
    }
    function handleInput(event: Event) {
      if (props.disabled || props.readOnly || props.loading) return
      const value = (event.target as HTMLTextAreaElement).value
      setText(value); error.value = ''
      if (!value.trim() || props.sending) { endTyping(); return }
      if (!typing) { typing = true; emit('typingStart', { user: props.user }) }
      if (typingTimer !== undefined) clearTimeout(typingTimer)
      typingTimer = setTimeout(endTyping, 1500)
    }
    async function scrollToEnd() {
      await nextTick()
      if (!alive) return
      if (list.value) list.value.scrollTop = list.value.scrollHeight
      atBottom.value = true; unread.value = 0
    }
    function onScroll() {
      const element = list.value
      if (!element) return
      atBottom.value = element.scrollHeight - element.clientHeight - element.scrollTop < 48
      if (atBottom.value) unread.value = 0
    }
    watch(() => messages.value.map(item => ({ id: item.message.id, text: item.message.text, status: item.message.status, time: item.date.getTime() })), async (next, before) => {
      const shouldScroll = atBottom.value, height = list.value?.scrollHeight ?? 0, top = list.value?.scrollTop ?? 0
      const oldKeys = new Set(before.map(item => item.id)), latestTime = before.reduce((latest, item) => Math.max(latest, item.time), -Infinity)
      const added = next.filter(item => !oldKeys.has(item.id) && item.time >= latestTime).length
      if (!shouldScroll) unread.value += added
      await nextTick()
      if (!alive) return
      if (shouldScroll) await scrollToEnd()
      else if (list.value && before.length && next.at(-1)?.id === before.at(-1)?.id && next[0]?.id !== before[0]?.id) list.value.scrollTop = top + list.value.scrollHeight - height
    })
    watch([() => props.disabled, () => props.readOnly, () => props.loading, () => props.sending], () => { if (blocked.value) endTyping() })
    watch(() => props.loading, value => { if (!value && atBottom.value) void scrollToEnd() })
    function send(event: Event) {
      event.preventDefault()
      if (!canSend.value || composing.value) return
      let messageId: string
      do { messageId = `tx-chat-${id}-${++counter}` } while (items.value.some(item => item.id === messageId))
      const message: ChatMessage = { id: messageId, text: input.value.trim(), timestamp: new Date(), author: { ...props.user }, status: 'sent' }
      try {
        const entered = { message, cancel: false, event }
        emit('messageEntered', entered)
        if (entered.cancel) return
        const next = [...items.value, message]
        normalizeMessages(next)
        internalItems.value = next; emit('update:items', next)
        setText(''); endTyping(); error.value = ''; void scrollToEnd()
        emit('messageSent', { message })
      } catch (reason) { error.value = reason instanceof Error ? reason.message : 'Nachricht konnte nicht aufgenommen werden.' }
    }
    function keydown(event: KeyboardEvent) {
      if (event.key === 'Enter' && !event.shiftKey && !event.isComposing && event.keyCode !== 229 && !composing.value) send(event)
    }
    onMounted(() => { void scrollToEnd() })
    onBeforeUnmount(() => { alive = false; endTyping() })
    return () => {
      const parsed = messages.value
      const typers = props.typingUsers.filter(user => user.id !== props.user.id)
      const statusLabels = { pending: 'Wird gesendet', sent: 'Lokal gesendet', error: 'Senden fehlgeschlagen' }
      return h('section', { class: ['tx-chat', props.disabled && 'tx-disabled'], 'aria-label': props.label, 'aria-busy': props.loading }, [
        h('header', { class: 'tx-chat-header' }, slots.header?.({ user: props.user }) ?? [h('span', { class: 'tx-chat-symbol', 'aria-hidden': 'true' }, '☷'), h('div', [h('h3', props.title), props.subtitle && h('p', props.subtitle)]), h('span', { class: 'tx-chat-local-user' }, props.user.name)]),
        h('div', { class: 'tx-chat-conversation' }, [
          h('div', { class: 'tx-chat-log', role: 'log', 'aria-label': 'Nachrichtenverlauf', 'aria-live': 'polite', 'aria-relevant': 'additions text', tabindex: 0, ref: list, onScroll }, props.loading ? [h('div', { class: 'tx-chat-empty' }, [h(TxLoadIndicator, { label: 'Nachrichten werden geladen …' })])] : parsed.length ? parsed.flatMap(({ message, date }, index) => {
            const isOwn = message.author.id === props.user.id, day = dateKey(date)
            const initials = message.author.name.trim().split(/\s+/).slice(0, 2).map(part => Array.from(part)[0]).join('').toLocaleUpperCase()
            return [props.showDayHeaders && (index === 0 || dateKey(parsed[index - 1].date) !== day) && h('div', { key: `day-${day}`, class: 'tx-chat-day' }, h('span', formatDate(date))),
              h('article', { key: `message-${typeof message.id}:${message.id}`, class: ['tx-chat-message', isOwn && 'tx-chat-own', message.status === 'error' && 'tx-chat-message-error'], 'aria-label': `${message.author.name}, ${formatDate(date)}, ${formatTime(date)}` }, [
                props.showAvatar && (message.author.avatarUrl ? h('img', { class: 'tx-chat-avatar', src: message.author.avatarUrl, alt: '', loading: 'lazy' }) : h('span', { class: 'tx-chat-avatar', 'aria-hidden': 'true' }, initials)),
                h('div', { class: 'tx-chat-message-content' }, [props.showUserName && h('span', { class: 'tx-chat-author' }, message.author.name), h('div', { class: 'tx-chat-bubble' }, slots.message?.({ message, isOwn }) ?? [h('p', message.text)]),
                  h('div', { class: 'tx-chat-message-meta' }, [props.showMessageTimestamp && h('time', { datetime: date.toISOString(), title: `${formatDate(date)} ${formatTime(date)}` }, formatTime(date)), isOwn && message.status && h('span', { class: 'tx-chat-message-status' }, statusLabels[message.status])])])
              ])]
          }) : [h('div', { class: 'tx-chat-empty' }, slots.empty?.() ?? [h('span', { 'aria-hidden': 'true' }, '◇'), h('p', props.emptyText)])]),
          unread.value > 0 && h(TxButton, { class: 'tx-chat-unread', text: `${unread.value} ${unread.value === 1 ? 'neue Nachricht' : 'neue Nachrichten'} ↓`, onClick: () => { void scrollToEnd() } })
        ]),
        h('div', { class: 'tx-chat-typing', role: 'status' }, typers.length ? `${typers.map(user => user.name).join(', ')} ${typers.length === 1 ? 'schreibt' : 'schreiben'} …` : ''),
        !props.readOnly && h('form', { class: 'tx-chat-composer', onSubmit: send }, [h('label', { class: 'tx-sr-only', for: `${id}-message` }, 'Nachricht'), h('textarea', {
          id: `${id}-message`, class: 'tx-control tx-chat-input', rows: 2, value: input.value, placeholder: props.placeholder,
          maxlength: props.maxLength, disabled: props.disabled || props.loading, 'aria-describedby': `${id}-hint`, onInput: handleInput, onKeydown: keydown,
          onCompositionstart: () => { composing.value = true }, onCompositionend: () => { composing.value = false }, onBlur: endTyping
        }), h(TxButton, { text: props.sending ? 'Wird gesendet …' : 'Senden ↑', type: 'default', useSubmitBehavior: true, disabled: !canSend.value, 'aria-label': 'Nachricht senden' }),
          h('div', { class: 'tx-chat-composer-hint', id: `${id}-hint` }, [h('span', 'Enter senden · Shift+Enter neue Zeile'), h('span', `${input.value.length} / ${props.maxLength}`)])]),
        error.value && h('p', { class: 'tx-error tx-chat-error', role: 'alert' }, error.value)
      ])
    }
  }
})
