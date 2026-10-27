import { computed, defineComponent, h, ref, type PropType } from 'vue'
import { useTxSource } from '../data/vue-source.js'
import { txRead, type TxSource } from '../data/source.js'
export type TxRangeValue = number | Date
function range(name: string, selector: boolean) {
  return defineComponent({
    name,
    props: {
      modelValue: Array as unknown as PropType<[TxRangeValue, TxRangeValue]>,
      min: { type: [Number, Date], default: 0 },
      max: { type: [Number, Date], default: 100 },
      step: { type: Number, default: 1 },
      minRange: { type: Number, default: 0 },
      maxRange: Number,
      disabled: Boolean,
      readOnly: Boolean,
      label: { type: String, default: 'Bereich' },
      showLabels: { type: Boolean, default: true },
      dataSource: [Array, Object] as PropType<
        TxSource<Record<string, unknown>>
      >,
      argumentExpr: { type: String, default: 'argument' },
      valueExpr: { type: String, default: 'value' },
      seriesType: { type: String, default: 'area' },
      tickCount: { type: Number, default: 5 },
      format: Function as PropType<(v: TxRangeValue) => string>,
    },
    emits: ['update:modelValue', 'valueChanged'],
    setup(p, { emit, slots }) {
      const b = useTxSource(() => p.dataSource),
        internal = ref<[TxRangeValue, TxRangeValue]>([p.min, p.max])
      const min = computed(() => +p.min),
        max = computed(() => +p.max),
        values = computed(() => p.modelValue ?? internal.value),
        span = computed(() => max.value - min.value)
      const typed = (n: number): TxRangeValue =>
        p.min instanceof Date ? new Date(n) : n
      const label = (v: TxRangeValue) =>
        p.format?.(v) ??
        (v instanceof Date ? v.toLocaleDateString() : String(v))
      function commit(a: number, z: number) {
        if (p.disabled || p.readOnly || span.value <= 0 || p.step <= 0) return
        const next: [TxRangeValue, TxRangeValue] = [typed(a), typed(z)]
        internal.value = next
        emit('update:modelValue', next)
        emit('valueChanged', { value: next })
      }
      function change(index: number, raw: number) {
        const snap = Math.min(
          max.value,
          Math.max(
            min.value,
            min.value + Math.round((raw - min.value) / p.step) * p.step,
          ),
        )
        const a = +values.value[0],
          z = +values.value[1],
          minDistance = Math.min(p.minRange, span.value),
          maxDistance = Math.max(minDistance, p.maxRange ?? span.value)
        if (index === 0)
          commit(
            Math.max(
              min.value,
              z - maxDistance,
              Math.min(snap, z - minDistance),
            ),
            z,
          )
        else
          commit(
            a,
            Math.min(
              max.value,
              a + maxDistance,
              Math.max(snap, a + minDistance),
            ),
          )
      }
      let drag: { x: number; a: number; z: number; width: number } | undefined
      return () => {
        const a = Math.max(
            0,
            Math.min(100, ((+values.value[0] - min.value) / span.value) * 100),
          ),
          z = Math.max(
            a,
            Math.min(100, ((+values.value[1] - min.value) / span.value) * 100),
          )
        const series = b.items.value
          .map((item) => [
            +txRead(item, p.argumentExpr)!,
            +txRead(item, p.valueExpr)!,
          ])
          .filter(([x, y]) => Number.isFinite(x) && Number.isFinite(y))
        const yMax = Math.max(1, ...series.map((v) => v[1]))
        const points = series
          .map(
            ([x, y]) =>
              `${((x - min.value) / span.value) * 1000},${100 - (y / yMax) * 90}`,
          )
          .join(' ')
        return h(
          'section',
          {
            class: ['tx-range', selector && 'tx-range-selector'],
            'aria-label': p.label,
          },
          [
            selector &&
              h(
                'svg',
                {
                  viewBox: '0 0 1000 110',
                  preserveAspectRatio: 'none',
                  class: 'tx-range-chart',
                  'aria-hidden': true,
                },
                p.seriesType === 'bar'
                  ? series.map(([x, y]) =>
                      h('rect', {
                        x: ((x - min.value) / span.value) * 1000,
                        y: 100 - (y / yMax) * 90,
                        width: Math.max(2, 800 / series.length),
                        height: (y / yMax) * 90,
                        fill: 'var(--tx-accent)',
                      }),
                    )
                  : [
                      h('polyline', {
                        points:
                          p.seriesType === 'area'
                            ? `0,100 ${points} 1000,100`
                            : points,
                        fill:
                          p.seriesType === 'area'
                            ? 'var(--tx-selection)'
                            : 'none',
                        stroke: 'var(--tx-accent)',
                        'stroke-width': 2,
                      }),
                    ],
              ),
            h('div', { class: 'tx-range-track' }, [
              h('div', {
                class: 'tx-range-selection',
                style: { left: `${a}%`, width: `${z - a}%` },
                onPointerdown: (e: PointerEvent) => {
                  if (p.disabled || p.readOnly) return
                  drag = {
                    x: e.clientX,
                    a: +values.value[0],
                    z: +values.value[1],
                    width: (
                      e.currentTarget as HTMLElement
                    ).parentElement!.getBoundingClientRect().width,
                  }
                  ;(e.currentTarget as HTMLElement).setPointerCapture(
                    e.pointerId,
                  )
                },
                onPointermove: (e: PointerEvent) => {
                  if (!drag) return
                  let delta =
                    Math.round(
                      (((e.clientX - drag.x) / drag.width) * span.value) /
                        p.step,
                    ) * p.step
                  delta = Math.max(
                    min.value - drag.a,
                    Math.min(max.value - drag.z, delta),
                  )
                  commit(drag.a + delta, drag.z + delta)
                },
                onPointerup: () => (drag = undefined),
                onPointercancel: () => (drag = undefined),
              }),
              ...[0, 1].map((index) =>
                h('input', {
                  type: 'range',
                  min: min.value,
                  max: max.value,
                  step: p.step,
                  value: +values.value[index],
                  disabled: p.disabled || p.readOnly || span.value <= 0,
                  class: 'tx-range-input',
                  'aria-label': `${p.label}: ${index === 0 ? 'Anfang' : 'Ende'}`,
                  'aria-valuetext': label(values.value[index]),
                  title: label(values.value[index]),
                  onInput: (e: Event) =>
                    change(index, +(e.target as HTMLInputElement).value),
                }),
              ),
            ]),
            p.showLabels &&
              h('div', { class: 'tx-range-labels' }, [
                h('output', label(values.value[0])),
                h('output', label(values.value[1])),
              ]),
            selector &&
              h(
                'div',
                { class: 'tx-range-labels' },
                Array.from({ length: Math.max(2, p.tickCount) }, (_, i) =>
                  h(
                    'small',
                    label(
                      typed(
                        min.value +
                          (span.value * i) / (Math.max(2, p.tickCount) - 1),
                      ),
                    ),
                  ),
                ),
              ),
            slots.default?.({ value: values.value }),
          ],
        )
      }
    },
  })
}
export const TxRangeSlider = range('TxRangeSlider', false)
export const TxRangeSelector = range('TxRangeSelector', true)
