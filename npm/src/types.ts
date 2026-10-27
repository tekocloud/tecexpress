export type EditorValue = string | number | boolean | null
export interface ValueChangedEvent<T = EditorValue> {
  value: T
  previousValue: T
  event: Event
}
export interface Item {
  text: string
  icon?: string
  visible?: boolean
  disabled?: boolean
  id?: string | number
}
export type RowKey = string | number
export type DataRow = Record<string, unknown>
export interface Column {
  dataField: string
  caption?: string
  width?: string | number
  allowSorting?: boolean
  allowFiltering?: boolean
  cellTemplate?: string
  visible?: boolean
  alignment?: 'left' | 'center' | 'right'
}
export interface SortDescriptor {
  dataField: string
  desc: boolean
}
export interface RowClickEvent {
  data: DataRow
  key: RowKey
  rowIndex: number
  event: MouseEvent
}
export interface SelectionChangedEvent {
  selectedRowKeys: RowKey[]
  selectedRowsData: DataRow[]
}

export type SchedulerView = 'day' | 'week' | 'month'
export type SchedulerDate = Date | string
export interface Appointment {
  id: RowKey
  text: string
  startDate: SchedulerDate
  endDate: SchedulerDate
  allDay?: boolean
  description?: string
}
export interface SchedulerEditing {
  allowAdding?: boolean
  allowUpdating?: boolean
  allowDeleting?: boolean
}
export interface AppointmentEvent {
  appointmentData: Appointment
}
export interface AppointmentChangeEvent extends AppointmentEvent {
  cancel: boolean
}
export interface AppointmentUpdatingEvent {
  oldData: Appointment
  newData: Appointment
  cancel: boolean
}
export interface AppointmentUpdatedEvent {
  oldData: Appointment
  newData: Appointment
}
export interface AppointmentClickEvent extends AppointmentEvent {
  event: MouseEvent
}
export interface SchedulerCellClickEvent {
  startDate: Date
  endDate: Date
  allDay: boolean
  event: MouseEvent
}

export interface CardField {
  dataField: string
  caption?: string
}
export interface CardClickEvent {
  data: DataRow
  key: RowKey
  index: number
  event: MouseEvent
}
export interface CardSelectionChangedEvent {
  selectedCardKeys: RowKey[]
  selectedCardsData: DataRow[]
}
export interface ChatUser {
  id: RowKey
  name: string
  avatarUrl?: string
}
export interface ChatMessage {
  id: RowKey
  text: string
  timestamp: Date | string
  author: ChatUser
  status?: 'pending' | 'sent' | 'error'
}
export interface ChatMessageEvent {
  message: ChatMessage
}
export interface ChatMessageEnteredEvent extends ChatMessageEvent {
  cancel: boolean
  event: Event
}
export interface ChatTypingEvent {
  user: ChatUser
}
