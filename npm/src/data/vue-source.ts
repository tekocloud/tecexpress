import {
  computed,
  onBeforeUnmount,
  onServerPrefetch,
  shallowRef,
  watch,
} from 'vue'
import { TxDataSource, type TxSource } from './source.js'
/** Arrays stay synchronous; externally supplied sources retain their ownership. */
export function useTxSource<T>(
  getSource: () => TxSource<T> | undefined,
  fallback: () => T[] = () => [],
) {
  const source = shallowRef<TxDataSource<T>>(),
    revision = shallowRef(0)
  let unsubscribe: (() => void) | undefined,
    owned = false
  let pending: Promise<unknown> | undefined
  function release() {
    unsubscribe?.()
    if (owned) source.value?.dispose()
    source.value = undefined
  }
  watch(
    getSource,
    (value) => {
      release()
      if (value && !Array.isArray(value)) {
        owned = !(value instanceof TxDataSource)
        source.value =
          value instanceof TxDataSource ? value : new TxDataSource(value)
        unsubscribe = source.value.subscribe(() => revision.value++)
        if (!source.value.loaded && !source.value.loading)
          pending = source.value.load().catch(() => {})
        else pending = source.value.pendingLoad?.catch(() => {})
      }
      revision.value++
    },
    { immediate: true },
  )
  onBeforeUnmount(release)
  onServerPrefetch(() => pending)
  const items = computed(() => {
    void revision.value
    const value = getSource()
    return Array.isArray(value)
      ? value
      : source.value
        ? [...source.value.items]
        : fallback()
  })
  const loading = computed(() => {
    void revision.value
    return source.value?.loading ?? false
  })
  const error = computed(() => {
    void revision.value
    return source.value?.error
  })
  return { items, source, loading, error, revision }
}
