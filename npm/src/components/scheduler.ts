import { useTxSource } from '../data/vue-source.js'
import type { TxSource } from '../data/source.js'
import {
  computed,
  defineComponent,
  h,
  nextTick,
  ref,
  useId,
  type PropType,
} from 'vue'
import { TxButton } from './editors.js'
import { TxPopup, TxLoadIndicator } from './overlays.js'
import {
  addDays,
  appointmentFingerprint,
  appointmentsOnDay,
  atMinute,
  calendarDate,
  calendarDays,
  dateKey,
  dayStart,
  layoutAppointments,
  localInput,
  navigateDate,
  normalizeAppointments,
  type CalendarAppointment,
} from '../data/calendar.js'
import type {
  Appointment,
  AppointmentChangeEvent,
  AppointmentClickEvent,
  AppointmentEvent,
  AppointmentUpdatedEvent,
  AppointmentUpdatingEvent,
  SchedulerCellClickEvent,
  SchedulerDate,
  SchedulerEditing,
  SchedulerView,
} from '../types.js'

const viewNames: Record<SchedulerView, string> = {
  day: 'Tag',
  week: 'Woche',
  month: 'Monat',
}
export const TxScheduler = defineComponent({
  name: 'TxScheduler',
  props: {
    dataSource: {
      type: [Array, Object] as PropType<TxSource<Appointment>>,
      default: undefined,
    },
    currentDate: {
      type: [Date, String] as PropType<SchedulerDate>,
      default: undefined,
    },
    currentView: {
      type: String as PropType<SchedulerView>,
      default: undefined,
    },
    views: {
      type: Array as PropType<SchedulerView[]>,
      default: () => ['day', 'week', 'month'],
    },
    firstDayOfWeek: { type: Number, default: 1 },
    startDayHour: { type: Number, default: 8 },
    endDayHour: { type: Number, default: 18 },
    cellDuration: { type: Number, default: 30 },
    editing: {
      type: [Boolean, Object] as PropType<boolean | SchedulerEditing>,
      default: true,
    },
    disabled: Boolean,
    readOnly: Boolean,
    loading: Boolean,
    locale: { type: String, default: 'de-DE' },
    label: { type: String, default: 'Terminplaner' },
  },
  emits: {
    'update:dataSource': (_data: Appointment[]) => true,
    'update:currentDate': (_date: Date) => true,
    'update:currentView': (_view: SchedulerView) => true,
    appointmentClick: (_event: AppointmentClickEvent) => true,
    cellClick: (_event: SchedulerCellClickEvent) => true,
    appointmentAdding: (_event: AppointmentChangeEvent) => true,
    appointmentAdded: (_event: AppointmentEvent) => true,
    appointmentUpdating: (_event: AppointmentUpdatingEvent) => true,
    appointmentUpdated: (_event: AppointmentUpdatedEvent) => true,
    appointmentDeleting: (_event: AppointmentChangeEvent) => true,
    appointmentDeleted: (_event: AppointmentEvent) => true,
  },
  setup(props, { emit, slots }) {
    const binding = useTxSource<Appointment>(() => props.dataSource)

    const id = useId(),
      root = ref<HTMLElement>(),
      internalDate = ref(dayStart(new Date())),
      internalView = ref<SchedulerView>(),
      internalData = ref<Appointment[]>([])
    const open = ref(false),
      error = ref(''),
      deleteConfirmation = ref(false),
      editingId = ref<string | number | null>(null)
    const draft = ref({
      text: '',
      start: '',
      end: '',
      allDay: false,
      description: '',
    })
    let originalFingerprint = '',
      counter = 0
    const focusedCell = ref({ day: 0, slot: 0 })
    const configuration = computed(() => {
      if (
        !props.views.length ||
        props.views.some((view) => !['day', 'week', 'month'].includes(view))
      )
        throw new Error(
          'TxScheduler: views muss day, week oder month enthalten und darf nicht leer sein.',
        )
      if (
        !Number.isInteger(props.firstDayOfWeek) ||
        props.firstDayOfWeek < 0 ||
        props.firstDayOfWeek > 6
      )
        throw new Error(
          'TxScheduler: firstDayOfWeek muss zwischen 0 und 6 liegen.',
        )
      if (
        !Number.isInteger(props.startDayHour) ||
        !Number.isInteger(props.endDayHour) ||
        props.startDayHour < 0 ||
        props.endDayHour > 24 ||
        props.endDayHour <= props.startDayHour
      )
        throw new Error(
          'TxScheduler: Stundenbereich muss 0 ≤ startDayHour < endDayHour ≤ 24 erfüllen.',
        )
      if (![15, 30, 60].includes(props.cellDuration))
        throw new Error('TxScheduler: cellDuration muss 15, 30 oder 60 sein.')
      if (props.currentView && !props.views.includes(props.currentView))
        throw new Error(
          'TxScheduler: currentView muss in views enthalten sein.',
        )
      return {
        slotCount:
          ((props.endDayHour - props.startDayHour) * 60) / props.cellDuration,
      }
    })
    const view = computed(() => {
      configuration.value
      return (
        props.currentView ??
        (internalView.value && props.views.includes(internalView.value)
          ? internalView.value
          : props.views.includes('week')
            ? 'week'
            : props.views[0])
      )
    })
    const date = computed(() =>
      calendarDate(props.currentDate ?? internalDate.value),
    )
    const days = computed(() =>
      calendarDays(date.value, view.value, props.firstDayOfWeek),
    )
    const data = computed(() =>
      props.dataSource === undefined ? internalData.value : binding.items.value,
    )
    const appointments = computed(() => normalizeAppointments(data.value))
    const blocked = computed(
      () => props.disabled || props.loading || binding.loading.value,
    )
    function allowed(action: keyof SchedulerEditing) {
      return (
        !blocked.value &&
        !props.readOnly &&
        (typeof props.editing === 'boolean'
          ? props.editing
          : props.editing[action] !== false)
      )
    }
    const canSave = computed(() =>
      allowed(editingId.value === null ? 'allowAdding' : 'allowUpdating'),
    )
    const format = (value: Date, options: Intl.DateTimeFormatOptions) =>
      new Intl.DateTimeFormat(props.locale, options).format(value)
    const fullDate = (value: Date) =>
      format(value, {
        weekday: 'long',
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      })
    const time = (value: Date) =>
      format(value, { hour: '2-digit', minute: '2-digit', hourCycle: 'h23' })
    function setDate(value: Date) {
      if (blocked.value) return
      internalDate.value = dayStart(value)
      focusedCell.value = { day: 0, slot: 0 }
      emit('update:currentDate', new Date(internalDate.value))
    }
    function setView(value: SchedulerView) {
      if (blocked.value) return
      internalView.value = value
      focusedCell.value = { day: 0, slot: 0 }
      emit('update:currentView', value)
    }
    function beginCreate(start: Date, end: Date, allDay: boolean) {
      if (!allowed('allowAdding')) return
      editingId.value = null
      originalFingerprint = ''
      error.value = ''
      deleteConfirmation.value = false
      draft.value = {
        text: '',
        start: allDay ? dateKey(start) : localInput(start),
        end: allDay ? dateKey(end) : localInput(end),
        allDay,
        description: '',
      }
      open.value = true
    }
    function cellClick(
      day: Date,
      minute: number,
      allDay: boolean,
      event: MouseEvent,
    ) {
      if (blocked.value) return
      const startDate = allDay ? dayStart(day) : atMinute(day, minute)
      const endDate = allDay
        ? addDays(startDate, 1)
        : atMinute(day, minute + props.cellDuration)
      emit('cellClick', {
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        allDay,
        event,
      })
      // Skip nonexistent spring-forward wall-clock slots instead of creating a different time.
      if (
        !allDay &&
        (startDate.getHours() * 60 + startDate.getMinutes() !== minute ||
          endDate <= startDate)
      )
        return
      beginCreate(startDate, endDate, allDay)
    }
    function appointmentClick(item: CalendarAppointment, event: MouseEvent) {
      if (blocked.value) return
      emit('appointmentClick', { appointmentData: item.data, event })
      editingId.value = item.data.id
      originalFingerprint = appointmentFingerprint(item.data)
      draft.value = {
        text: item.data.text,
        start: item.data.allDay ? dateKey(item.start) : localInput(item.start),
        end: item.data.allDay ? dateKey(item.end) : localInput(item.end),
        allDay: !!item.data.allDay,
        description: item.data.description ?? '',
      }
      error.value = ''
      deleteConfirmation.value = false
      open.value = true
    }
    function toggleAllDay(value: boolean) {
      if (!canSave.value) return
      try {
        const start = calendarDate(draft.value.start),
          end = calendarDate(draft.value.end)
        if (value) {
          const first = dayStart(start),
            last = dayStart(end)
          draft.value.start = dateKey(first)
          draft.value.end = dateKey(last > first ? last : addDays(first, 1))
        } else {
          draft.value.start = localInput(
            atMinute(start, props.startDayHour * 60),
          )
          draft.value.end = localInput(
            atMinute(
              addDays(end, -1),
              Math.min(24 * 60, props.startDayHour * 60 + 60),
            ),
          )
        }
      } catch {
        /* Keep invalid text for the user to correct in the new input mode. */
      }
      draft.value.allDay = value
    }
    function existingAppointment() {
      const existing = data.value.find((item) => item.id === editingId.value)
      if (!existing || appointmentFingerprint(existing) !== originalFingerprint)
        throw new Error(
          'Der Termin wurde zwischenzeitlich geändert oder entfernt. Bitte schließen und erneut öffnen.',
        )
      return existing
    }
    async function commit(next: Appointment[]) {
      normalizeAppointments(next)
      const source = binding.source.value
      if (source) {
        const previous = [...data.value]
        for (const item of previous)
          if (!next.some((v) => v.id === item.id)) await source.remove(item.id)
        for (const item of next) {
          const old = previous.find((v) => v.id === item.id)
          if (!old) await source.insert(item)
          else if (appointmentFingerprint(old) !== appointmentFingerprint(item))
            await source.update(item.id, item)
        }
      }
      internalData.value = next
      emit('update:dataSource', next)
      open.value = false
    }
    async function save(event: Event) {
      event.preventDefault()
      if (!canSave.value) return
      try {
        if (!draft.value.text.trim())
          throw new Error('Bitte einen Titel eingeben.')
        const startDate = calendarDate(draft.value.start),
          endDate = calendarDate(draft.value.end)
        const oldData = editingId.value === null ? null : existingAppointment()
        let appointmentId = oldData?.id
        if (appointmentId === undefined) {
          do {
            appointmentId = `tx-${id}-${++counter}`
          } while (data.value.some((item) => item.id === appointmentId))
        }
        const next: Appointment = {
          ...oldData,
          id: appointmentId,
          text: draft.value.text.trim(),
          startDate,
          endDate,
          allDay: draft.value.allDay,
          description: draft.value.description,
        }
        normalizeAppointments([next])
        if (oldData) {
          const change = {
            oldData: { ...oldData },
            newData: next,
            cancel: false,
          }
          emit('appointmentUpdating', change)
          if (change.cancel) {
            error.value = 'Die Änderung wurde von der Anwendung abgebrochen.'
            return
          }
          await commit(
            data.value.map((item) => (item.id === oldData.id ? next : item)),
          )
          emit('appointmentUpdated', { oldData, newData: next })
        } else {
          const change = { appointmentData: next, cancel: false }
          emit('appointmentAdding', change)
          if (change.cancel) {
            error.value = 'Das Anlegen wurde von der Anwendung abgebrochen.'
            return
          }
          commit([...data.value, next])
          emit('appointmentAdded', { appointmentData: next })
        }
      } catch (reason) {
        error.value =
          reason instanceof Error
            ? reason.message
            : 'Der Termin konnte nicht gespeichert werden.'
      }
    }
    async function remove() {
      if (editingId.value === null || !allowed('allowDeleting')) return
      if (!deleteConfirmation.value) {
        deleteConfirmation.value = true
        return
      }
      try {
        const appointmentData = existingAppointment(),
          change = { appointmentData: { ...appointmentData }, cancel: false }
        emit('appointmentDeleting', change)
        if (change.cancel) {
          error.value = 'Das Löschen wurde von der Anwendung abgebrochen.'
          return
        }
        await commit(
          data.value.filter((item) => item.id !== appointmentData.id),
        )
        emit('appointmentDeleted', { appointmentData })
      } catch (reason) {
        error.value =
          reason instanceof Error ? reason.message : 'Löschen fehlgeschlagen.'
      }
    }
    async function moveCell(event: KeyboardEvent, day: number, slot: number) {
      if (blocked.value) return
      const count = configuration.value.slotCount
      const target = { day, slot }
      if (event.key === 'ArrowUp') target.slot--
      else if (event.key === 'ArrowDown') target.slot++
      else if (event.key === 'ArrowLeft') target.day--
      else if (event.key === 'ArrowRight') target.day++
      else if (event.key === 'Home') target.slot = 0
      else if (event.key === 'End') target.slot = count - 1
      else return
      event.preventDefault()
      target.day = Math.max(0, Math.min(days.value.length - 1, target.day))
      target.slot = Math.max(0, Math.min(count - 1, target.slot))
      focusedCell.value = target
      await nextTick()
      root.value
        ?.querySelector<HTMLButtonElement>(
          `[data-day="${target.day}"][data-slot="${target.slot}"]`,
        )
        ?.focus()
    }
    function appointmentButton(
      item: CalendarAppointment,
      compact = false,
      style = {},
      day?: Date,
    ) {
      const nextDay = day ? addDays(dayStart(day), 1) : null
      const timeLabel = item.data.allDay
        ? 'Ganztägig'
        : `${day && item.start < dayStart(day) ? '↤' : time(item.start)}–${nextDay && item.end >= nextDay ? (item.end > nextDay ? '↦' : '24:00') : time(item.end)}`
      const description = item.data.allDay
        ? `${fullDate(item.start)}, Ganztägig`
        : `${fullDate(item.start)} ${time(item.start)} bis ${fullDate(item.end)} ${time(item.end)}`
      return h(
        'button',
        {
          key: `${typeof item.data.id}:${item.data.id}`,
          type: 'button',
          class: [
            'tx-appointment',
            compact && 'tx-appointment-compact',
            item.data.allDay && 'tx-appointment-allday',
          ],
          style,
          disabled: blocked.value,
          'aria-label': `${item.data.text}, ${description}`,
          title: `${item.data.text} · ${description}`,
          onClick: (event: MouseEvent) => appointmentClick(item, event),
        },
        slots.appointment?.({
          appointmentData: item.data,
          startDate: new Date(item.start),
          endDate: new Date(item.end),
          view: view.value,
        }) ?? [h('strong', item.data.text), h('span', timeLabel)],
      )
    }
    function inputField(
      label: string,
      field: 'text' | 'start' | 'end' | 'description',
      type = 'text',
    ) {
      const inputId = `${id}-${field}`
      return h('div', { class: 'tx-field' }, [
        h('label', { class: 'tx-label', for: inputId }, label),
        h(field === 'description' ? 'textarea' : 'input', {
          id: inputId,
          class: 'tx-control',
          type: field === 'description' ? undefined : type,
          rows: field === 'description' ? 3 : undefined,
          value: draft.value[field],
          readonly: !canSave.value,
          required: field !== 'description',
          onInput: (event: Event) => {
            if (canSave.value)
              draft.value[field] = (event.target as HTMLInputElement).value
          },
        }),
      ])
    }
    return () => {
      const slotCount = configuration.value.slotCount,
        currentDays = days.value
      const allAppointments = appointments.value
      const today = dateKey(new Date())
      const period =
        view.value === 'month'
          ? format(date.value, { month: 'long', year: 'numeric' })
          : view.value === 'day'
            ? fullDate(date.value)
            : `${format(currentDays[0], { day: 'numeric', month: 'short' })} – ${format(currentDays[6], { day: 'numeric', month: 'short', year: 'numeric' })}`
      return h(
        'section',
        {
          class: ['tx-scheduler', props.disabled && 'tx-disabled'],
          ref: root,
          'aria-label': props.label,
          'aria-busy': props.loading || binding.loading.value,
        },
        [
          h('header', { class: 'tx-scheduler-toolbar' }, [
            h('div', { class: 'tx-scheduler-navigation' }, [
              h(TxButton, {
                text: '←',
                'aria-label': 'Vorheriger Zeitraum',
                disabled: blocked.value,
                onClick: () =>
                  setDate(navigateDate(date.value, view.value, -1)),
              }),
              h(TxButton, {
                text: 'Heute',
                disabled: blocked.value,
                onClick: () => setDate(new Date()),
              }),
              h(TxButton, {
                text: '→',
                'aria-label': 'Nächster Zeitraum',
                disabled: blocked.value,
                onClick: () => setDate(navigateDate(date.value, view.value, 1)),
              }),
              h('label', { class: 'tx-scheduler-date' }, [
                h('span', { class: 'tx-sr-only' }, 'Kalenderdatum'),
                h('input', {
                  type: 'date',
                  class: 'tx-control',
                  value: dateKey(date.value),
                  disabled: blocked.value,
                  'aria-label': 'Kalenderdatum',
                  onChange: (event: Event) => {
                    const value = (event.target as HTMLInputElement).value
                    if (value) setDate(calendarDate(value))
                  },
                }),
              ]),
            ]),
            h('div', { class: 'tx-scheduler-actions' }, [
              h(
                'div',
                {
                  class: 'tx-scheduler-views',
                  role: 'group',
                  'aria-label': 'Kalenderansicht',
                },
                [...new Set(props.views)].map((item) =>
                  h(
                    'button',
                    {
                      type: 'button',
                      class: [
                        'tx-button',
                        view.value === item && 'tx-button-default',
                      ],
                      'aria-pressed': view.value === item,
                      disabled: blocked.value,
                      onClick: () => setView(item),
                    },
                    viewNames[item],
                  ),
                ),
              ),
              allowed('allowAdding') &&
                h(TxButton, {
                  text: '＋ Neuer Termin',
                  type: 'default',
                  onClick: () =>
                    beginCreate(
                      atMinute(date.value, props.startDayHour * 60),
                      atMinute(
                        date.value,
                        Math.min(
                          props.endDayHour * 60,
                          props.startDayHour * 60 + 60,
                        ),
                      ),
                      false,
                    ),
                }),
            ]),
          ]),
          h('div', { class: 'tx-scheduler-period', role: 'status' }, period),
          props.loading || binding.loading.value
            ? h('div', { class: 'tx-scheduler-loading' }, [
                h(TxLoadIndicator, { label: 'Termine werden geladen …' }),
              ])
            : h('div', { class: 'tx-scheduler-scroll' }, [
                view.value === 'month'
                  ? h('div', { key: 'month', class: 'tx-scheduler-month' }, [
                      ...currentDays.slice(0, 7).map((day) =>
                        h(
                          'div',
                          {
                            key: `weekday-${dateKey(day)}`,
                            class: 'tx-scheduler-weekday',
                          },
                          format(day, { weekday: 'short' }),
                        ),
                      ),
                      ...currentDays.map((day) =>
                        h(
                          'section',
                          {
                            key: dateKey(day),
                            class: [
                              'tx-scheduler-month-day',
                              day.getMonth() !== date.value.getMonth() &&
                                'tx-scheduler-outside',
                              dateKey(day) === today && 'tx-scheduler-today',
                            ],
                            'aria-label': fullDate(day),
                          },
                          [
                            h(
                              'button',
                              {
                                type: 'button',
                                class: 'tx-scheduler-day-number',
                                disabled:
                                  blocked.value || !allowed('allowAdding'),
                                'aria-label': `Ganztagstermin erstellen: ${fullDate(day)}`,
                                onClick: (event: MouseEvent) =>
                                  cellClick(day, 0, true, event),
                              },
                              String(day.getDate()),
                            ),
                            ...appointmentsOnDay(allAppointments, day).map(
                              (item) => appointmentButton(item, true, {}, day),
                            ),
                          ],
                        ),
                      ),
                    ])
                  : h(
                      'div',
                      {
                        key: 'time',
                        class: [
                          'tx-scheduler-time',
                          view.value === 'day' && 'tx-scheduler-single',
                        ],
                        style: {
                          gridTemplateColumns: `64px repeat(${currentDays.length}, minmax(110px, 1fr))`,
                          '--tx-scheduler-slot-count': slotCount,
                        },
                      },
                      [
                        h(
                          'div',
                          {
                            class:
                              'tx-scheduler-day-header tx-scheduler-time-label',
                          },
                          'Zeit',
                        ),
                        ...currentDays.map((day) =>
                          h(
                            'div',
                            {
                              key: `header-${dateKey(day)}`,
                              class: [
                                'tx-scheduler-day-header',
                                dateKey(day) === today && 'tx-scheduler-today',
                              ],
                            },
                            [
                              h('span', format(day, { weekday: 'short' })),
                              h(
                                'strong',
                                format(day, { day: 'numeric', month: 'short' }),
                              ),
                            ],
                          ),
                        ),
                        h(
                          'div',
                          { class: 'tx-scheduler-allday-label' },
                          'Ganztägig',
                        ),
                        ...currentDays.map((day) =>
                          h(
                            'div',
                            {
                              key: `allday-${dateKey(day)}`,
                              class: 'tx-scheduler-allday-cell',
                            },
                            [
                              ...appointmentsOnDay(allAppointments, day)
                                .filter((item) => item.data.allDay)
                                .map((item) => appointmentButton(item, true)),
                              allowed('allowAdding') &&
                                h(
                                  'button',
                                  {
                                    type: 'button',
                                    class: 'tx-scheduler-allday-add',
                                    'aria-label': `Ganztagstermin erstellen: ${fullDate(day)}`,
                                    onClick: (event: MouseEvent) =>
                                      cellClick(day, 0, true, event),
                                  },
                                  '+',
                                ),
                            ],
                          ),
                        ),
                        h(
                          'div',
                          {
                            class: 'tx-scheduler-hours',
                            'aria-hidden': 'true',
                          },
                          Array.from({ length: slotCount }, (_, index) =>
                            h(
                              'div',
                              { class: 'tx-scheduler-hour' },
                              (index * props.cellDuration) % 60 === 0
                                ? time(
                                    atMinute(
                                      currentDays[0],
                                      props.startDayHour * 60 +
                                        index * props.cellDuration,
                                    ),
                                  )
                                : '',
                            ),
                          ),
                        ),
                        ...currentDays.map((day, dayIndex) =>
                          h(
                            'div',
                            {
                              key: `column-${dateKey(day)}`,
                              class: 'tx-scheduler-day-column',
                            },
                            [
                              ...Array.from(
                                { length: slotCount },
                                (_, index) => {
                                  const minute =
                                    props.startDayHour * 60 +
                                    index * props.cellDuration
                                  return h('button', {
                                    type: 'button',
                                    class: 'tx-scheduler-cell',
                                    'data-day': dayIndex,
                                    'data-slot': index,
                                    tabindex:
                                      Math.min(
                                        focusedCell.value.day,
                                        currentDays.length - 1,
                                      ) === dayIndex &&
                                      Math.min(
                                        focusedCell.value.slot,
                                        slotCount - 1,
                                      ) === index
                                        ? 0
                                        : -1,
                                    disabled: blocked.value,
                                    'aria-label': `Zeitfenster: ${fullDate(day)}, ${time(atMinute(day, minute))}`,
                                    onFocus: () => {
                                      focusedCell.value = {
                                        day: dayIndex,
                                        slot: index,
                                      }
                                    },
                                    onKeydown: (event: KeyboardEvent) =>
                                      moveCell(event, dayIndex, index),
                                    onClick: (event: MouseEvent) =>
                                      cellClick(day, minute, false, event),
                                  })
                                },
                              ),
                              ...layoutAppointments(
                                allAppointments,
                                day,
                                props.startDayHour,
                                props.endDayHour,
                              ).map((item) =>
                                appointmentButton(
                                  item,
                                  false,
                                  {
                                    position: 'absolute',
                                    top: `${item.top}%`,
                                    height: `${item.height}%`,
                                    left: `calc(${(item.lane / item.laneCount) * 100}% + 3px)`,
                                    width: `calc(${100 / item.laneCount}% - 6px)`,
                                  },
                                  day,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              ]),
          h('footer', { class: 'tx-scheduler-footer' }, [
            h(
              'span',
              `${allAppointments.filter((item) => item.start < addDays(currentDays.at(-1)!, 1) && item.end > currentDays[0]).length} Termine im Zeitraum`,
            ),
            h(
              'span',
              props.readOnly || props.editing === false
                ? 'Nur lesen'
                : allowed('allowAdding')
                  ? 'Zeitzelle wählen, um einen Termin anzulegen'
                  : 'Termine zur Ansicht auswählen',
            ),
          ]),
          h(
            TxPopup,
            {
              visible: open.value,
              'onUpdate:visible': (value: boolean) => {
                open.value = value
              },
              title:
                editingId.value === null
                  ? 'Termin anlegen'
                  : canSave.value
                    ? 'Termin bearbeiten'
                    : 'Termindetails',
              width: 540,
            },
            {
              default: () =>
                h(
                  'form',
                  {
                    id: `${id}-form`,
                    class: 'tx-scheduler-form',
                    onSubmit: save,
                  },
                  [
                    inputField('Titel', 'text'),
                    h('label', { class: 'tx-toggle-label' }, [
                      h('input', {
                        type: 'checkbox',
                        checked: draft.value.allDay,
                        disabled: !canSave.value,
                        onChange: (event: Event) =>
                          toggleAllDay(
                            (event.target as HTMLInputElement).checked,
                          ),
                      }),
                      'Ganztägig',
                    ]),
                    h('div', { class: 'tx-scheduler-form-dates' }, [
                      inputField(
                        'Beginn',
                        'start',
                        draft.value.allDay ? 'date' : 'datetime-local',
                      ),
                      inputField(
                        draft.value.allDay ? 'Ende (exklusiv)' : 'Ende',
                        'end',
                        draft.value.allDay ? 'date' : 'datetime-local',
                      ),
                    ]),
                    inputField('Beschreibung', 'description'),
                    error.value &&
                      h('p', { class: 'tx-error', role: 'alert' }, error.value),
                    deleteConfirmation.value &&
                      h(
                        'p',
                        { role: 'alert' },
                        'Diesen Termin endgültig löschen?',
                      ),
                  ],
                ),
              footer: () => [
                editingId.value !== null &&
                  allowed('allowDeleting') &&
                  h(TxButton, {
                    text: deleteConfirmation.value
                      ? 'Endgültig löschen'
                      : 'Termin löschen',
                    type: 'danger',
                    onClick: remove,
                  }),
                deleteConfirmation.value
                  ? h(TxButton, {
                      text: 'Löschen abbrechen',
                      onClick: () => {
                        deleteConfirmation.value = false
                      },
                    })
                  : h(TxButton, {
                      text: 'Schließen',
                      onClick: () => {
                        open.value = false
                      },
                    }),
                canSave.value &&
                  !deleteConfirmation.value &&
                  h(TxButton, {
                    text: 'Speichern',
                    type: 'default',
                    useSubmitBehavior: true,
                    form: `${id}-form`,
                  }),
              ],
            },
          ),
        ],
      )
    }
  },
})
