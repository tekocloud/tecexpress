import type { App, Plugin } from 'vue'
import { TxButton, TxTextBox, TxTextArea, TxNumberBox, TxCheckBox, TxSwitch, TxSelectBox, TxDateBox } from './components/editors.js'
import { TxTabs, TxToolbar, TxMenu } from './components/navigation.js'
import { TxPopup, TxTooltip, TxToast, TxLoadIndicator } from './components/overlays.js'
import { TxDataGrid, TxColumn } from './components/grid.js'
import { TxScheduler } from './components/scheduler.js'
import { TxCard, TxCardView } from './components/cards.js'
import { TxChat } from './components/chat.js'

export { TxButton, TxTextBox, TxTextArea, TxNumberBox, TxCheckBox, TxSwitch, TxSelectBox, TxDateBox, TxTabs, TxToolbar, TxMenu, TxPopup, TxTooltip, TxToast, TxLoadIndicator, TxDataGrid, TxColumn, TxScheduler, TxCard, TxCardView, TxChat }
export type { EditorValue, ValueChangedEvent, Item, RowKey, DataRow, Column, SortDescriptor, RowClickEvent, SelectionChangedEvent } from './types.js'
export type { Appointment, SchedulerView, SchedulerDate, SchedulerEditing, AppointmentEvent, AppointmentChangeEvent, AppointmentClickEvent, AppointmentUpdatingEvent, AppointmentUpdatedEvent, SchedulerCellClickEvent } from './types.js'
export type { CardField, CardClickEvent, CardSelectionChangedEvent, ChatUser, ChatMessage, ChatMessageEvent, ChatMessageEnteredEvent, ChatTypingEvent } from './types.js'

const components = { TxButton, TxTextBox, TxTextArea, TxNumberBox, TxCheckBox, TxSwitch, TxSelectBox, TxDateBox, TxTabs, TxToolbar, TxMenu, TxPopup, TxTooltip, TxToast, TxLoadIndicator, TxDataGrid, TxColumn, TxScheduler, TxCard, TxCardView, TxChat }
export const Tecexpress: Plugin = { install(app: App) { Object.entries(components).forEach(([name, component]) => app.component(name, component)) } }
export default Tecexpress
