# Komponenten-Katalog · Referenz 26.1 · tecexpress 0.4.0

Referenz: [öffentliche Vue-Komponentenübersicht](https://js.devexpress.com/Vue/Documentation/ApiReference/UI_Components/) und [Suite-Übersicht](https://js.devexpress.com/Vue/Documentation/Guide/Vue_Components/DevExtreme_Vue_Components/), geprüft am 23.10.2026. Die Referenz beschreibt die Zielbereiche, keine Zusage von API- oder Funktionsgleichheit. Namen unten ohne Tx-Präfix. Keine Quelltexte oder Theme-Assets der Referenz übernommen.

| Phase / Status | Komponenten | Umfang / Abweichungen | Beispiele |
| --- | --- | --- | --- |
| 1 / verfügbar in 0.1 | Button, TextBox, TextArea, NumberBox, CheckBox, Switch, SelectBox, DateBox | Native Vue-Editoren, v-model und v-model:value; DateBox mit ISO-Datumsstring, SelectBox mit lokalen Daten | Demo: Eingaben; [API](api.md#editoren) |
| 1 / verfügbar in 0.1 | Popup, Tabs, Toolbar, Menu, Tooltip, Toast, LoadIndicator | Popup modal; flaches Menu; Tooltip umschließt Trigger; kein DevExtreme-Instanzobjekt | Demo: Oberfläche; [API](api.md#navigation) |
| 1 / verfügbar in 0.1 | DataGrid, Column (Konfiguration) | Lokale Arrays, Sortieren, Textfilter, Paging, Auswahl und Zell-Slots; keine Stores, Gruppierung oder Bearbeitung | Demo: Aufträge; [API](api.md#datagrid-und-column) |
| Vorgezogen / verfügbar in 0.2 | Scheduler | Tag/Woche/Monat, lokale Terminbearbeitung, Ganztags-/mehrtägige Termine, Überlappungen, Slot und Editierrechte. Keine Serien, Ressourcen oder Drag-and-drop. | Demo: Teamkalender; [Spezifikation und API](scheduler.md) |
| Vorgezogen / verfügbar in 0.3 | Card, CardView | Einzelkarten mit Slots; lokales Kartenraster mit Suche, Pagination und Auswahl. Kein Remote-Store oder CRUD. | Demo: Cards; [API](cards-chat.md) |
| Vorgezogen / verfügbar in 0.3 | Chat | Lokaler Verlauf, Nachrichtenmodelle, Composer, Schreibanzeige und Sendeereignisse. Kein Backend oder KI-Dienst enthalten. | Demo: Projektchat; [API](cards-chat.md) |
| 2 / geplant | Form, Validator, ValidationGroup, ValidationSummary, Autocomplete, TagBox, RadioGroup, ButtonGroup, Calendar, DateRangeBox, ColorBox, Slider, RangeSlider, Lookup, DropDownBox, DropDownButton | Vor Entwicklung Validierungs-, Wert- und Konfigurationsverträge festlegen | Noch keine |
| 3 / geplant | List, TreeList, TreeView, Accordion, Box, ResponsiveBox, ScrollView, Drawer, TabPanel, MultiView, ContextMenu, ActionSheet, Popover, LoadPanel, ProgressBar, FileUploader, FileManager, Gallery, TileView, Resizable, Draggable, Sortable, SpeedDialAction, Stepper, Pagination, Splitter | Vor Entwicklung Navigation, Fokus, Datenhierarchien und Upload-Schnittstellen spezifizieren | Noch keine |
| 4 / geplant | Chart, PieChart, PolarChart, Funnel, Sankey, Sparkline, Bullet, BarGauge, CircularGauge, LinearGauge, RangeSelector, VectorMap, Map, TreeMap | Eigene Rendering- und Datenarchitektur vor Implementierung spezifizieren | Noch keine |
| 5 / geplant | Gantt, Diagram, PivotGrid, PivotGridFieldChooser, HtmlEditor, FilterBuilder, SpeechToText | Je Komponente eigene Spezifikation mit Datenmodell, Interaktion, Performance- und Testzielen erforderlich | Noch keine |
| Folgestufe DataGrid / geplant | Bearbeitung, Validierung, Remote-Daten, Virtualisierung, Export, Gruppierung | Separater Entwurf und Abnahmekriterien vor Umsetzung | Noch keine |

Geplante Komponenten werden weder exportiert noch durch funktionslose Platzhalter simuliert. Zusätzliche Referenz-Komponenten können bei späteren Katalogprüfungen ergänzt werden. Detailverträge, Tests und Beispiele der verfügbaren Komponenten: [API](api.md). Der Katalog ist eine Ausbauplanung, kein Featuregleichheitsversprechen.
