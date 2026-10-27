import {
  defineComponent,
  h,
  nextTick,
  onBeforeUnmount,
  ref,
  useId,
  watch,
  type PropType,
} from 'vue'
import { TxButton } from './editors.js'

// The stack ensures Escape and focus trapping act only on the topmost popup.
const popupStack: symbol[] = []
export const TxPopup = defineComponent({
  name: 'TxPopup',
  props: {
    visible: Boolean,
    title: { type: String, default: 'Dialog' },
    showCloseButton: { type: Boolean, default: true },
    hideOnOutsideClick: Boolean,
    width: { type: [Number, String], default: 480 },
    height: [Number, String],
    fullScreen: Boolean,
    dragEnabled: Boolean,
    resizeEnabled: Boolean,
    position: { type: String, default: 'center' },
  },
  emits: {
    'update:visible': (_visible: boolean) => true,
    showing: (_event: { cancel: boolean }) => true,
    hiding: (_event: { cancel: boolean }) => true,
    shown: () => true,
    hidden: () => true,
  },
  setup(props, { emit, slots }) {
    const id = useId(),
      dialog = ref<HTMLElement>(),
      token = Symbol('popup')
    let previousFocus: HTMLElement | null = null,
      active = false
    const focusable = () =>
      Array.from(
        dialog.value?.querySelectorAll<HTMLElement>(
          'button:not(:disabled), input:not(:disabled), select:not(:disabled), textarea:not(:disabled), a[href], [tabindex]:not([tabindex="-1"])',
        ) ?? [],
      ).filter((el) => el.getAttribute('aria-hidden') !== 'true' && !el.hidden)
    const offset = ref({ x: 0, y: 0 }),
      cancelled = ref(false)
    let drag: { x: number; y: number; left: number; top: number } | undefined
    function close() {
      const event = { cancel: false }
      emit('hiding', event)
      if (!event.cancel) emit('update:visible', false)
    }
    function keydown(event: KeyboardEvent) {
      if (popupStack.at(-1) !== token) return
      if (event.key === 'Escape') {
        event.preventDefault()
        close()
      }
      if (event.key === 'Tab') {
        const elements = focusable(),
          first = elements[0],
          last = elements.at(-1)
        if (!first) {
          event.preventDefault()
          dialog.value?.focus()
          return
        }
        if (
          event.shiftKey &&
          (document.activeElement === first ||
            !dialog.value?.contains(document.activeElement))
        ) {
          event.preventDefault()
          last?.focus()
        } else if (
          !event.shiftKey &&
          (document.activeElement === last ||
            !dialog.value?.contains(document.activeElement))
        ) {
          event.preventDefault()
          first.focus()
        }
      }
    }
    function containFocus(event: FocusEvent) {
      if (
        popupStack.at(-1) === token &&
        !dialog.value?.contains(event.target as Node)
      )
        (focusable()[0] ?? dialog.value)?.focus()
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
    watch(
      () => props.visible,
      async (visible) => {
        if (typeof document === 'undefined') return
        if (visible) {
          const event = { cancel: false }
          emit('showing', event)
          cancelled.value = event.cancel
          if (event.cancel) return
          previousFocus = document.activeElement as HTMLElement
          active = true
          popupStack.push(token)
          document.addEventListener('keydown', keydown)
          document.addEventListener('focusin', containFocus)
          await nextTick()
          if (!props.visible || !active) return
          ;(focusable()[0] ?? dialog.value)?.focus()
          emit('shown')
        } else {
          const wasActive = active
          deactivate()
          if (wasActive) emit('hidden')
        }
      },
      { immediate: true, flush: 'post' },
    )
    onBeforeUnmount(deactivate)
    return () =>
      props.visible && !cancelled.value
        ? h(
            'div',
            {
              class: ['tx-backdrop', `tx-popup-${props.position}`],
              onClick: (event: MouseEvent) => {
                if (
                  event.target === event.currentTarget &&
                  props.hideOnOutsideClick &&
                  popupStack.at(-1) === token
                )
                  close()
              },
            },
            [
              h(
                'section',
                {
                  class: 'tx-popup',
                  role: 'dialog',
                  'aria-modal': 'true',
                  'aria-labelledby': `${id}-title`,
                  tabindex: -1,
                  ref: dialog,
                  style: {
                    width: props.fullScreen
                      ? '100vw'
                      : typeof props.width === 'number'
                        ? `${props.width}px`
                        : props.width,
                    height: props.fullScreen
                      ? '100dvh'
                      : typeof props.height === 'number'
                        ? `${props.height}px`
                        : props.height,
                    maxHeight: props.fullScreen ? '100dvh' : undefined,
                    maxWidth: props.fullScreen ? '100vw' : undefined,
                    resize: props.resizeEnabled ? 'both' : undefined,
                    overflow: props.resizeEnabled ? 'auto' : undefined,
                    transform: `translate(${offset.value.x}px, ${offset.value.y}px)`,
                  },
                },
                [
                  h(
                    'header',
                    {
                      class: 'tx-popup-header',
                      style: {
                        cursor: props.dragEnabled ? 'move' : undefined,
                        touchAction: props.dragEnabled ? 'none' : undefined,
                      },
                      onPointerdown: (event: PointerEvent) => {
                        if (
                          !props.dragEnabled ||
                          props.fullScreen ||
                          (event.target as HTMLElement).closest('button')
                        )
                          return
                        drag = {
                          x: event.clientX,
                          y: event.clientY,
                          left: offset.value.x,
                          top: offset.value.y,
                        }
                        ;(event.currentTarget as HTMLElement).setPointerCapture(
                          event.pointerId,
                        )
                      },
                      onPointermove: (event: PointerEvent) => {
                        if (drag)
                          offset.value = {
                            x: drag.left + event.clientX - drag.x,
                            y: drag.top + event.clientY - drag.y,
                          }
                      },
                      onPointerup: () => (drag = undefined),
                      onPointercancel: () => (drag = undefined),
                    },
                    [
                      h('h2', { id: `${id}-title` }, props.title),
                      props.showCloseButton &&
                        h(TxButton, {
                          text: '×',
                          'aria-label': 'Dialog schließen',
                          onClick: close,
                        }),
                    ],
                  ),
                  h('div', { class: 'tx-popup-content' }, slots.default?.()),
                  slots.footer &&
                    h('footer', { class: 'tx-popup-footer' }, slots.footer()),
                ],
              ),
            ],
          )
        : null
  },
})

export const TxTooltip = defineComponent({
  name: 'TxTooltip',
  props: {
    text: { type: String, default: '' },
    disabled: Boolean,
    visible: { type: Boolean, default: undefined },
    showDelay: { type: Number, default: 0 },
    hideDelay: { type: Number, default: 0 },
    position: { type: String, default: 'top' },
    showOn: { type: String, default: 'hover' },
  },
  emits: ['update:visible', 'shown', 'hidden'],
  setup(props, { slots, emit }) {
    const id = useId(),
      open = ref(false),
      anchor = ref<HTMLElement>(),
      tooltip = ref<HTMLElement>(),
      position = ref({ left: 0, top: 0 })
    let timer: ReturnType<typeof setTimeout> | undefined
    const change = (value: boolean) => {
      clearTimeout(timer)
      const apply = () => {
        open.value = value
        emit('update:visible', value)
        emit(value ? 'shown' : 'hidden')
        if (value)
          void nextTick(() => {
            const a = anchor.value?.getBoundingClientRect(),
              t = tooltip.value?.getBoundingClientRect()
            if (!a || !t) return
            let top =
              props.position === 'bottom' ? a.bottom + 6 : a.top - t.height - 6
            if (top < 4) top = a.bottom + 6
            position.value = {
              left: Math.max(
                4,
                Math.min(
                  window.innerWidth - t.width - 4,
                  a.left + (a.width - t.width) / 2,
                ),
              ),
              top: Math.max(
                4,
                Math.min(window.innerHeight - t.height - 4, top),
              ),
            }
          })
      }
      const delay = value ? props.showDelay : props.hideDelay
      if (delay > 0) timer = setTimeout(apply, delay)
      else apply()
    }
    watch(
      () => props.visible,
      (v) => {
        if (v !== undefined) change(v)
      },
      { immediate: true },
    )
    onBeforeUnmount(() => clearTimeout(timer))
    return () =>
      h(
        'span',
        {
          ref: anchor,
          class: 'tx-tooltip-anchor',
          tabindex: props.disabled ? undefined : 0,
          'aria-describedby': !props.disabled ? id : undefined,
          onMouseenter: () => {
            if (props.showOn === 'hover') change(true)
          },
          onMouseleave: () => {
            if (props.showOn === 'hover') change(false)
          },
          onClick: () => {
            if (props.showOn === 'click') change(!open.value)
          },
          onFocusin: () => change(true),
          onFocusout: () => change(false),
          onKeydown: (event: KeyboardEvent) => {
            if (event.key === 'Escape') change(false)
          },
        },
        [
          slots.default?.(),
          h(
            'span',
            {
              ref: tooltip,
              role: 'tooltip',
              id,
              class: 'tx-tooltip tx-tooltip-positioned',
              style: {
                position: 'fixed',
                left: `${position.value.left}px`,
                top: `${position.value.top}px`,
                transform: 'none',
                bottom: 'auto',
              },
              hidden: !(props.visible ?? open.value) || props.disabled,
            },
            slots.content?.() ?? props.text,
          ),
        ],
      )
  },
})

export const TxToast = defineComponent({
  name: 'TxToast',
  props: {
    visible: Boolean,
    message: String,
    position: { type: String, default: 'bottom-right' },
    type: {
      type: String as PropType<'info' | 'success' | 'warning' | 'error'>,
      default: 'info',
    },
    displayTime: { type: Number, default: 3500 },
  },
  emits: { 'update:visible': (_visible: boolean) => true },
  setup(props, { emit, slots }) {
    let timer: ReturnType<typeof setTimeout> | undefined
    const clear = () => {
      if (timer !== undefined) clearTimeout(timer)
    }
    watch(
      [() => props.visible, () => props.displayTime, () => props.message],
      () => {
        clear()
        if (props.visible && props.displayTime > 0)
          timer = setTimeout(
            () => emit('update:visible', false),
            props.displayTime,
          )
      },
      { immediate: true },
    )
    onBeforeUnmount(clear)
    return () =>
      h(
        'div',
        {
          class: [
            'tx-toast-host',
            `tx-toast-${props.type}`,
            `tx-${props.position}`,
          ],
          role: props.type === 'error' ? 'alert' : 'status',
          'aria-atomic': 'true',
        },
        props.visible
          ? [
              h('div', { class: 'tx-toast' }, [
                h('span', slots.default?.() ?? props.message),
                slots.actions?.(),
                h(TxButton, {
                  text: '×',
                  'aria-label': 'Meldung schließen',
                  onClick: () => emit('update:visible', false),
                }),
              ]),
            ]
          : [],
      )
  },
})

export const TxLoadIndicator = defineComponent({
  name: 'TxLoadIndicator',
  props: {
    visible: { type: Boolean, default: true },
    label: { type: String, default: 'Wird geladen …' },
  },
  setup(props) {
    return () =>
      props.visible
        ? h('span', { class: 'tx-load-indicator', role: 'status' }, [
            h('span', { class: 'tx-spinner', 'aria-hidden': 'true' }),
            props.label,
          ])
        : null
  },
})
