import { defineComponent, h, nextTick, onBeforeUnmount, ref, useId, watch, type PropType } from 'vue'
import { TxButton } from './editors.js'

// The stack ensures Escape and focus trapping act only on the topmost popup.
const popupStack: symbol[] = []
export const TxPopup = defineComponent({
  name: 'TxPopup',
  props: { visible: Boolean, title: { type: String, default: 'Dialog' }, showCloseButton: { type: Boolean, default: true }, hideOnOutsideClick: Boolean, width: { type: [Number, String], default: 480 } },
  emits: { 'update:visible': (_visible: boolean) => true, shown: () => true, hidden: () => true },
  setup(props, { emit, slots }) {
    const id = useId(), dialog = ref<HTMLElement>(), token = Symbol('popup')
    let previousFocus: HTMLElement | null = null, active = false
    const focusable = () => Array.from(dialog.value?.querySelectorAll<HTMLElement>('button:not(:disabled), input:not(:disabled), select:not(:disabled), textarea:not(:disabled), a[href], [tabindex]:not([tabindex="-1"])') ?? []).filter(el => el.getAttribute('aria-hidden') !== 'true' && !el.hidden)
    function close() { emit('update:visible', false) }
    function keydown(event: KeyboardEvent) {
      if (popupStack.at(-1) !== token) return
      if (event.key === 'Escape') { event.preventDefault(); close() }
      if (event.key === 'Tab') {
        const elements = focusable(), first = elements[0], last = elements.at(-1)
        if (!first) { event.preventDefault(); dialog.value?.focus(); return }
        if (event.shiftKey && (document.activeElement === first || !dialog.value?.contains(document.activeElement))) { event.preventDefault(); last?.focus() }
        else if (!event.shiftKey && (document.activeElement === last || !dialog.value?.contains(document.activeElement))) { event.preventDefault(); first.focus() }
      }
    }
    function containFocus(event: FocusEvent) {
      if (popupStack.at(-1) === token && !dialog.value?.contains(event.target as Node)) (focusable()[0] ?? dialog.value)?.focus()
    }
    function deactivate() {
      if (!active) return
      active = false
      const index = popupStack.indexOf(token)
      if (index >= 0) popupStack.splice(index, 1)
      document.removeEventListener('keydown', keydown)
      document.removeEventListener('focusin', containFocus)
      if (previousFocus?.isConnected) previousFocus.focus()
    }
    watch(() => props.visible, async visible => {
      if (typeof document === 'undefined') return
      if (visible) {
        previousFocus = document.activeElement as HTMLElement
        active = true; popupStack.push(token)
        document.addEventListener('keydown', keydown)
        document.addEventListener('focusin', containFocus)
        await nextTick()
        if (!props.visible || !active) return
        ;(focusable()[0] ?? dialog.value)?.focus()
        emit('shown')
      } else { const wasActive = active; deactivate(); if (wasActive) emit('hidden') }
    }, { immediate: true, flush: 'post' })
    onBeforeUnmount(deactivate)
    return () => props.visible ? h('div', { class: 'tx-backdrop', onClick: (event: MouseEvent) => { if (event.target === event.currentTarget && props.hideOnOutsideClick && popupStack.at(-1) === token) close() } }, [
      h('section', { class: 'tx-popup', role: 'dialog', 'aria-modal': 'true', 'aria-labelledby': `${id}-title`, tabindex: -1, ref: dialog,
        style: { width: typeof props.width === 'number' ? `${props.width}px` : props.width } }, [
        h('header', { class: 'tx-popup-header' }, [h('h2', { id: `${id}-title` }, props.title), props.showCloseButton && h(TxButton, { text: '×', 'aria-label': 'Dialog schließen', onClick: close })]),
        h('div', { class: 'tx-popup-content' }, slots.default?.()),
        slots.footer && h('footer', { class: 'tx-popup-footer' }, slots.footer())
      ])
    ]) : null
  }
})

export const TxTooltip = defineComponent({
  name: 'TxTooltip', props: { text: { type: String, required: true }, disabled: Boolean },
  setup(props, { slots }) {
    const id = useId(), open = ref(false)
    return () => h('span', {
      class: 'tx-tooltip-anchor', tabindex: props.disabled ? undefined : 0, 'aria-describedby': !props.disabled ? id : undefined,
      onMouseenter: () => { open.value = true }, onMouseleave: () => { open.value = false },
      onFocusin: () => { open.value = true }, onFocusout: () => { open.value = false },
      onKeydown: (event: KeyboardEvent) => { if (event.key === 'Escape') open.value = false }
    }, [slots.default?.(), h('span', { role: 'tooltip', id, class: 'tx-tooltip', hidden: !open.value || props.disabled }, props.text)])
  }
})

export const TxToast = defineComponent({
  name: 'TxToast',
  props: { visible: Boolean, message: String, type: { type: String as PropType<'info' | 'success' | 'error'>, default: 'info' }, displayTime: { type: Number, default: 3500 } },
  emits: { 'update:visible': (_visible: boolean) => true },
  setup(props, { emit, slots }) {
    let timer: ReturnType<typeof setTimeout> | undefined
    const clear = () => { if (timer !== undefined) clearTimeout(timer) }
    watch([() => props.visible, () => props.displayTime, () => props.message], () => {
      clear()
      if (props.visible && props.displayTime > 0) timer = setTimeout(() => emit('update:visible', false), props.displayTime)
    }, { immediate: true })
    onBeforeUnmount(clear)
    return () => h('div', { class: ['tx-toast-host', `tx-toast-${props.type}`], role: props.type === 'error' ? 'alert' : 'status', 'aria-atomic': 'true' }, props.visible ? [
      h('div', { class: 'tx-toast' }, [h('span', slots.default?.() ?? props.message), h(TxButton, { text: '×', 'aria-label': 'Meldung schließen', onClick: () => emit('update:visible', false) })])
    ] : [])
  }
})

export const TxLoadIndicator = defineComponent({
  name: 'TxLoadIndicator', props: { visible: { type: Boolean, default: true }, label: { type: String, default: 'Wird geladen …' } },
  setup(props) { return () => props.visible ? h('span', { class: 'tx-load-indicator', role: 'status' }, [h('span', { class: 'tx-spinner', 'aria-hidden': 'true' }), props.label]) : null }
})
