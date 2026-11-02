import { createApp, defineComponent, h, ref } from 'vue'
import examples from './generated/registry'
import '@tekocloud.de/tecexpress/themes/index.css'
import './style.css'
const query = new URLSearchParams(location.search)
const en = query.get('lang') === 'en'
document.documentElement.lang = en ? 'en' : 'de'
document.documentElement.dataset.txTheme = query.get('theme') === 'dark' ? 'dark' : 'light'
const id = query.get('component') || 'txdatagrid'
const example = examples[id as keyof typeof examples]
createApp(defineComponent({ setup() {
  const revision = ref(0), error = ref('')
  return () => h('main', [h('header', [h('strong', `Vue 3 / ${id}`), h('button', { onClick: () => { revision.value++; error.value = '' } }, en ? 'Reset demo' : 'Demo zurücksetzen')]), h('p', { class: 'hint' }, en ? 'Interactive local example · Changes are not saved.' : 'Interaktives lokales Beispiel · Änderungen werden nicht gespeichert.'), error.value ? h('p', { role: 'alert' }, error.value) : example ? h('section', { class: 'stage', key: revision.value }, [h(example)]) : h('p', en ? 'Unknown example.' : 'Unbekanntes Beispiel.')])
}})).mount('#app')
