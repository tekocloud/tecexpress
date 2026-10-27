import {
  createApp,
  defineComponent,
  h,
  onBeforeUnmount,
  ref,
  watch,
  type PropType,
} from 'vue'
import { TxDataSource } from '../data/source.js'
import { TxLoadIndicator } from './overlays.js'
import { TxTabs } from './navigation.js'
export const TxTabPanel = defineComponent({
  name: 'TxTabPanel',
  props: TxTabs.props,
  emits: ['update:modelValue', 'update:selectedIndex', 'selectionChanged'],
  setup(props, { slots, emit }) {
    return () =>
      h(
        TxTabs,
        {
          ...props,
          'onUpdate:modelValue': (i: number) => emit('update:modelValue', i),
          'onUpdate:selectedIndex': (i: number) =>
            emit('update:selectedIndex', i),
          onSelectionChanged: (event: unknown) =>
            emit('selectionChanged', event),
        },
        slots,
      )
  },
})
export const TxLoadPanel = defineComponent({
  name: 'TxLoadPanel',
  props: {
    visible: { type: Boolean, default: undefined },
    dataSource: Object as PropType<
      Pick<TxDataSource<unknown>, 'loading' | 'subscribe'>
    >,
    message: { type: String, default: 'Wird geladen …' },
    delay: { type: Number, default: 0 },
    shading: { type: Boolean, default: true },
    fullScreen: Boolean,
  },
  setup(p) {
    const revision = ref(0)
    let unsubscribe: (() => void) | undefined,
      timer: ReturnType<typeof setTimeout> | undefined
    const shown = ref(false)
    watch(
      [() => p.dataSource, () => p.visible, () => p.delay],
      () => {
        unsubscribe?.()
        const update = () => {
          revision.value++
          clearTimeout(timer)
          const visible = p.visible ?? p.dataSource?.loading ?? false
          if (!visible) shown.value = false
          else timer = setTimeout(() => (shown.value = true), p.delay)
        }
        unsubscribe = p.dataSource?.subscribe(update)
        update()
      },
      { immediate: true },
    )
    onBeforeUnmount(() => {
      unsubscribe?.()
      clearTimeout(timer)
    })
    return () => {
      void revision.value
      return shown.value
        ? h(
            'div',
            {
              class: [
                'tx-load-panel',
                p.shading && 'tx-load-shading',
                p.fullScreen && 'tx-load-fullscreen',
              ],
              role: 'status',
              'aria-live': 'polite',
            },
            [
              h('div', { class: 'tx-load-content' }, [
                h(TxLoadIndicator),
                p.message,
              ]),
            ],
          )
        : null
    }
  },
})
export interface TxNotifyOptions {
  message: string
  type?: 'info' | 'success' | 'warning' | 'error'
  displayTime?: number
  position?: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left'
  action?: { text: string; onClick: () => void }
}
export interface TxNotifyHandle {
  close(): void
  update(changes: Partial<TxNotifyOptions>): void
}
export function notify(options: string | TxNotifyOptions): TxNotifyHandle {
  if (typeof document === 'undefined') return { close() {}, update() {} }
  const state = ref<TxNotifyOptions>(
      typeof options === 'string' ? { message: options } : options,
    ),
    host = document.createElement('div')
  const position = state.value.position ?? 'bottom-right'
  let stack = document.querySelector<HTMLElement>(
    `.tx-notification-stack[data-position="${position}"]`,
  )
  if (!stack) {
    stack = document.createElement('div')
    stack.className = `tx-notification-stack tx-${position}`
    stack.dataset.position = position
    document.body.append(stack)
  }
  stack.append(host)
  let timer: ReturnType<typeof setTimeout> | undefined,
    closed = false
  const close = () => {
    if (closed) return
    closed = true
    clearTimeout(timer)
    app.unmount()
    host.remove()
    if (!stack!.childElementCount) stack!.remove()
  }
  const schedule = () => {
    clearTimeout(timer)
    if ((state.value.displayTime ?? 3500) > 0)
      timer = setTimeout(close, state.value.displayTime ?? 3500)
  }
  const app = createApp({
    setup: () => () =>
      h(
        'div',
        {
          class: ['tx-notification', `tx-toast-${state.value.type ?? 'info'}`],
          role: state.value.type === 'error' ? 'alert' : 'status',
        },
        [
          state.value.message,
          state.value.action &&
            h(
              'button',
              { type: 'button', onClick: state.value.action.onClick },
              state.value.action.text,
            ),
          h(
            'button',
            {
              type: 'button',
              'aria-label': 'Meldung schließen',
              onClick: close,
            },
            '×',
          ),
        ],
      ),
  })
  app.mount(host)
  schedule()
  return {
    close,
    update(changes) {
      if (!closed) {
        state.value = { ...state.value, ...changes }
        schedule()
      }
    },
  }
}
