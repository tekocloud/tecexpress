import {
  computed,
  defineComponent,
  h,
  ref,
  watch,
  onMounted,
  onBeforeUnmount,
  type PropType,
} from 'vue'
import { useTxSource } from '../data/vue-source.js'
import type { TxSource } from '../data/source.js'
export interface TxCoordinate {
  lat: number
  lng: number
}
export interface TxMapMarker extends TxCoordinate {
  id: string | number
  text?: string
  color?: string
}
export interface TxMapRoute {
  id: string | number
  points: TxCoordinate[]
  color?: string
  width?: number
}
export interface TxGeoAdapter {
  geocode?(query: string, signal?: AbortSignal): Promise<TxCoordinate[]>
  route?(points: TxCoordinate[], signal?: AbortSignal): Promise<TxCoordinate[]>
}
export function txProject(point: TxCoordinate, zoom: number) {
  const scale = 256 * 2 ** zoom,
    lat =
      (Math.max(-85.05112878, Math.min(85.05112878, point.lat)) * Math.PI) / 180
  return {
    x: ((point.lng + 180) / 360) * scale,
    y:
      ((1 - Math.log(Math.tan(lat) + 1 / Math.cos(lat)) / Math.PI) / 2) * scale,
  }
}
export function txUnproject(x: number, y: number, zoom: number): TxCoordinate {
  const scale = 256 * 2 ** zoom
  return {
    lng: (((((x / scale) * 360) % 360) + 360) % 360) - 180,
    lat:
      (Math.atan(Math.sinh(Math.PI * (1 - (2 * y) / scale))) * 180) / Math.PI,
  }
}
export const TxMap = defineComponent({
  name: 'TxMap',
  props: {
    center: {
      type: Object as PropType<TxCoordinate>,
      default: () => ({ lat: 52.52, lng: 13.405 }),
    },
    zoom: { type: Number, default: 5 },
    minZoom: { type: Number, default: 1 },
    maxZoom: { type: Number, default: 19 },
    tileUrl: String,
    attribution: String,
    width: { type: Number, default: 640 },
    height: { type: Number, default: 360 },
    dataSource: [Array, Object] as PropType<TxSource<TxMapMarker>>,
    markers: { type: Array as PropType<TxMapMarker[]>, default: () => [] },
    routes: { type: Array as PropType<TxMapRoute[]>, default: () => [] },
    routeDataSource: [Array, Object] as PropType<TxSource<TxMapRoute>>,
    disabled: Boolean,
  },
  emits: ['update:center', 'update:zoom', 'markerClick', 'tileError'],
  setup(p, { emit }) {
    const b = useTxSource(
        () => p.dataSource,
        () => p.markers,
      ),
      routes = useTxSource(
        () => p.routeDataSource,
        () => p.routes,
      ),
      center = ref(p.center),
      zoom = ref(p.zoom),
      selected = ref<TxMapMarker>(),
      viewport = ref<HTMLElement>(),
      actualWidth = ref(p.width)
    watch(
      () => p.center,
      (value) => (center.value = value),
      { deep: true },
    )
    watch(
      () => p.zoom,
      (value) => (zoom.value = value),
    )
    let observer: ResizeObserver | undefined
    onMounted(() => {
      if (typeof ResizeObserver !== 'undefined') {
        observer = new ResizeObserver((entries) => {
          actualWidth.value = entries[0].contentRect.width
        })
        if (viewport.value) observer.observe(viewport.value)
      }
    })
    onBeforeUnmount(() => observer?.disconnect())
    const current = computed(() => center.value),
      level = computed(() =>
        Math.round(Math.max(p.minZoom, Math.min(p.maxZoom, zoom.value))),
      )
    const pixel = (point: TxCoordinate) => {
      const c = txProject(current.value, level.value),
        v = txProject(point, level.value)
      return {
        x: v.x - c.x + actualWidth.value / 2,
        y: v.y - c.y + p.height / 2,
      }
    }
    let drag: { x: number; y: number; cx: number; cy: number } | undefined
    function setZoom(value: number) {
      if (p.disabled) return
      center.value = current.value
      zoom.value = Math.min(p.maxZoom, Math.max(p.minZoom, value))
      emit('update:zoom', zoom.value)
    }
    return () => {
      const c = txProject(current.value, level.value),
        n = 2 ** level.value,
        left = c.x - actualWidth.value / 2,
        top = c.y - p.height / 2,
        tiles = []
      if (p.tileUrl)
        for (
          let x = Math.floor(left / 256);
          x <= Math.floor((left + actualWidth.value) / 256);
          x++
        )
          for (
            let y = Math.max(0, Math.floor(top / 256));
            y <= Math.min(n - 1, Math.floor((top + p.height) / 256));
            y++
          )
            tiles.push(
              h('img', {
                alt: '',
                draggable: false,
                class: 'tx-map-tile',
                style: {
                  left: `${x * 256 - left}px`,
                  top: `${y * 256 - top}px`,
                },
                src: p.tileUrl
                  .replace('{z}', String(level.value))
                  .replace('{x}', String(((x % n) + n) % n))
                  .replace('{y}', String(y)),
                onError: () => emit('tileError', { x, y, zoom: level.value }),
              }),
            )
      return h(
        'section',
        {
          class: 'tx-map',
          ref: viewport,
          role: 'region',
          'aria-label': 'Karte',
          tabindex: 0,
          style: {
            width: `${p.width}px`,
            maxWidth: '100%',
            height: `${p.height}px`,
          },
          onKeydown: (e: KeyboardEvent) => {
            if (p.disabled) return
            if (e.key === '+' || e.key === '-') {
              e.preventDefault()
              setZoom(level.value + (e.key === '+' ? 1 : -1))
            }
            if (
              ['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'].includes(
                e.key,
              )
            ) {
              e.preventDefault()
              const c = txProject(current.value, level.value)
              center.value = txUnproject(
                c.x +
                  (e.key === 'ArrowRight'
                    ? 50
                    : e.key === 'ArrowLeft'
                      ? -50
                      : 0),
                c.y +
                  (e.key === 'ArrowDown' ? 50 : e.key === 'ArrowUp' ? -50 : 0),
                level.value,
              )
              emit('update:center', center.value)
            }
          },
          onPointerdown: (e: PointerEvent) => {
            if (p.disabled || (e.target as HTMLElement).closest('button'))
              return
            const c = txProject(current.value, level.value)
            drag = { x: e.clientX, y: e.clientY, cx: c.x, cy: c.y }
            ;(e.currentTarget as HTMLElement).setPointerCapture(e.pointerId)
          },
          onPointermove: (e: PointerEvent) => {
            if (!drag) return
            center.value = txUnproject(
              drag.cx - e.clientX + drag.x,
              drag.cy - e.clientY + drag.y,
              level.value,
            )
            zoom.value = level.value
            emit('update:center', center.value)
          },
          onPointerup: () => (drag = undefined),
          onPointercancel: () => (drag = undefined),
        },
        [
          ...tiles,
          !p.tileUrl &&
            h(
              'p',
              { class: 'tx-map-placeholder' },
              'Kachelquelle konfigurieren',
            ),
          h(
            'svg',
            {
              width: actualWidth.value,
              height: p.height,
              class: 'tx-map-routes',
              'aria-hidden': true,
            },
            routes.items.value.map((route) =>
              h('polyline', {
                points: route.points
                  .map((v) => {
                    const point = pixel(v)
                    return `${point.x},${point.y}`
                  })
                  .join(' '),
                fill: 'none',
                stroke: route.color ?? 'var(--tx-accent)',
                'stroke-width': route.width ?? 3,
              }),
            ),
          ),
          ...b.items.value.map((marker) => {
            const v = pixel(marker)
            return h(
              'button',
              {
                type: 'button',
                class: 'tx-map-marker',
                style: {
                  left: `${v.x}px`,
                  top: `${v.y}px`,
                  color: marker.color,
                },
                'aria-label': marker.text ?? String(marker.id),
                disabled: p.disabled,
                onClick: () => {
                  selected.value = marker
                  emit('markerClick', marker)
                },
              },
              '●',
            )
          }),
          h('div', { class: 'tx-map-controls' }, [
            h(
              'button',
              {
                type: 'button',
                disabled: p.disabled,
                'aria-label': 'Vergrößern',
                onClick: () => setZoom(level.value + 1),
              },
              '+',
            ),
            h(
              'button',
              {
                type: 'button',
                disabled: p.disabled,
                'aria-label': 'Verkleinern',
                onClick: () => setZoom(level.value - 1),
              },
              '−',
            ),
          ]),
          selected.value &&
            h('div', { class: 'tx-map-popup' }, [
              selected.value.text,
              h(
                'button',
                {
                  type: 'button',
                  'aria-label': 'Schließen',
                  onClick: () => (selected.value = undefined),
                },
                '×',
              ),
            ]),
          p.attribution &&
            h('small', { class: 'tx-map-attribution' }, p.attribution),
        ],
      )
    }
  },
})
