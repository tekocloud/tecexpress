import type { App, Plugin } from 'vue'
import {
  TxButton,
  TxTextBox,
  TxTextArea,
  TxNumberBox,
  TxCheckBox,
  TxSwitch,
  TxSelectBox,
  TxDateBox,
} from './components/editors.js'
import { TxTabs, TxToolbar, TxMenu } from './components/navigation.js'
import {
  TxPopup,
  TxTooltip,
  TxToast,
  TxLoadIndicator,
} from './components/overlays.js'
import { TxDataGrid, TxColumn } from './components/grid.js'
import { TxScheduler } from './components/scheduler.js'
import { TxCard, TxCardView } from './components/cards.js'
import { TxChat } from './components/chat.js'
import {
  TxRadioGroup,
  TxButtonGroup,
  TxLookup,
  TxTagBox,
  TxList,
  TxGallery,
  TxFloatingActionButton,
  TxContextMenu,
  TxActionSheet,
} from './components/collections.js'
import { TxRangeSlider, TxRangeSelector } from './components/ranges.js'
import { TxFileManager, TxFileUploader } from './components/files.js'
import { TxMap } from './components/map.js'
import { TxTabPanel, TxLoadPanel } from './components/services.js'
export {
  TxRadioGroup,
  TxButtonGroup,
  TxLookup,
  TxTagBox,
  TxList,
  TxGallery,
  TxFloatingActionButton,
  TxContextMenu,
  TxActionSheet,
  TxRangeSlider,
  TxRangeSelector,
  TxFileManager,
  TxFileUploader,
  TxMap,
  TxTabPanel,
  TxLoadPanel,
}
export * from './data/source.js'
export * from './data/files.js'
export { useTxSource } from './data/vue-source.js'
export {
  notify,
  type TxNotifyOptions,
  type TxNotifyHandle,
} from './components/services.js'
export type { TxCollectionItem, TxEntry } from './components/collections.js'
export type { TxRangeValue } from './components/ranges.js'
export {
  txProject,
  txUnproject,
  type TxCoordinate,
  type TxMapMarker,
  type TxMapRoute,
  type TxGeoAdapter,
} from './components/map.js'

export {
  TxButton,
  TxTextBox,
  TxTextArea,
  TxNumberBox,
  TxCheckBox,
  TxSwitch,
  TxSelectBox,
  TxDateBox,
  TxTabs,
  TxToolbar,
  TxMenu,
  TxPopup,
  TxTooltip,
  TxToast,
  TxLoadIndicator,
  TxDataGrid,
  TxColumn,
  TxScheduler,
  TxCard,
  TxCardView,
  TxChat,
}
export type {
  EditorValue,
  ValueChangedEvent,
  Item,
  RowKey,
  DataRow,
  Column,
  SortDescriptor,
  RowClickEvent,
  SelectionChangedEvent,
} from './types.js'
export type {
  Appointment,
  SchedulerView,
  SchedulerDate,
  SchedulerEditing,
  AppointmentEvent,
  AppointmentChangeEvent,
  AppointmentClickEvent,
  AppointmentUpdatingEvent,
  AppointmentUpdatedEvent,
  SchedulerCellClickEvent,
} from './types.js'
export type {
  CardField,
  CardClickEvent,
  CardSelectionChangedEvent,
  ChatUser,
  ChatMessage,
  ChatMessageEvent,
  ChatMessageEnteredEvent,
  ChatTypingEvent,
} from './types.js'

const components = {
  TxButton,
  TxTextBox,
  TxTextArea,
  TxNumberBox,
  TxCheckBox,
  TxSwitch,
  TxSelectBox,
  TxDateBox,
  TxTabs,
  TxToolbar,
  TxMenu,
  TxPopup,
  TxTooltip,
  TxToast,
  TxLoadIndicator,
  TxDataGrid,
  TxColumn,
  TxScheduler,
  TxCard,
  TxCardView,
  TxChat,
  TxRadioGroup,
  TxButtonGroup,
  TxLookup,
  TxTagBox,
  TxList,
  TxGallery,
  TxFloatingActionButton,
  TxContextMenu,
  TxActionSheet,
  TxRangeSlider,
  TxRangeSelector,
  TxFileManager,
  TxFileUploader,
  TxMap,
  TxTabPanel,
  TxLoadPanel,
}
export const Tecexpress: Plugin = {
  install(app: App) {
    Object.entries(components).forEach(([name, component]) =>
      app.component(name, component),
    )
  },
}
export default Tecexpress
