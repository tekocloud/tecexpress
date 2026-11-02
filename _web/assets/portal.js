(() => {
  const en = document.body.dataset.language === 'en';
  const text = (de, english) => en ? english : de;
  const root = document.documentElement;
  const stored = key => { try { return localStorage.getItem(key); } catch { return null; } };
  const save = (key, value) => { try { localStorage.setItem(key, value); } catch {} };
  root.dataset.theme = stored('tx-docs-theme') || (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  const frame = document.querySelector('[data-demo-frame]');
  const demoLink = document.querySelector('[data-demo-link]');
  const updateDemoUrl = () => {
    if (!frame) return;
    const url = new URL(frame.dataset.src);
    url.searchParams.set('theme', root.dataset.theme);
    demoLink.href = url.href;
    if (frame.src) frame.src = url.href;
  };
  updateDemoUrl();
  document.querySelector('button[data-theme]').addEventListener('click', () => {
    root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
    save('tx-docs-theme', root.dataset.theme);
    updateDemoUrl();
  });
  const menu = document.querySelector('[data-menu]');
  menu.addEventListener('click', () => {
    const open = document.querySelector('#sidebar').classList.toggle('is-open');
    menu.setAttribute('aria-expanded', String(open));
  });
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape') { document.querySelector('#sidebar').classList.remove('is-open'); menu.setAttribute('aria-expanded', 'false'); }
    if (event.key === '/' && !/INPUT|TEXTAREA|SELECT/.test(document.activeElement.tagName)) { event.preventDefault(); document.querySelector('#sidebar').classList.add('is-open'); menu.setAttribute('aria-expanded', 'true'); document.querySelector('[data-search]').focus(); }
  });
  const index = JSON.parse(document.querySelector('#search-index').textContent);
  const search = document.querySelector('[data-search]');
  const results = document.querySelector('[data-results]');
  search.addEventListener('input', () => {
    const q = search.value.trim().toLocaleLowerCase();
    results.replaceChildren(); results.hidden = !q;
    document.querySelector('.side-nav').hidden = Boolean(q);
    if (!q) return;
    const matches = index.filter(e => `${e.title} ${e.summary}`.toLocaleLowerCase().includes(q)).sort((a, b) => Number(b.title.toLocaleLowerCase().includes(q)) - Number(a.title.toLocaleLowerCase().includes(q)));
    if (!matches.length) results.textContent = text('Keine Ergebnisse.', 'No results.');
    for (const entry of matches.slice(0, 35)) {
      const a = document.createElement('a'); a.href = entry.url;
      const title = document.createElement('strong'); title.textContent = entry.title;
      const summary = document.createElement('small'); summary.textContent = entry.summary;
      a.append(title, summary); results.append(a);
    }
  });
  document.querySelectorAll('[data-copy]').forEach(button => button.addEventListener('click', async () => {
    const code = button.closest('.code-block').querySelector('code').textContent;
    try {
      if (navigator.clipboard && window.isSecureContext) await navigator.clipboard.writeText(code);
      else { const input = document.createElement('textarea'); input.value = code; document.body.append(input); input.select(); const copied = document.execCommand('copy'); input.remove(); if (!copied) throw new Error('copy failed'); }
      button.textContent = text('Kopiert ✓', 'Copied ✓');
    } catch { button.textContent = text('Bitte Code markieren', 'Please select code'); }
    setTimeout(() => { button.textContent = text('Kopieren', 'Copy'); }, 2200);
  }));
  const cardSearch = document.querySelector('[data-card-search]');
  cardSearch?.addEventListener('input', () => {
    const q = cardSearch.value.toLocaleLowerCase().trim();
    let count = 0;
    document.querySelectorAll('[data-card]').forEach(card => { card.hidden = !card.dataset.searchText.includes(q); if (!card.hidden) count++; });
    document.querySelectorAll('.catalog-group').forEach(group => { group.hidden = ![...group.querySelectorAll('[data-card]')].some(card => !card.hidden); });
    document.querySelector('[data-card-empty]').hidden = count !== 0;
  });
  let loading = false, timer;
  const status = document.querySelector('[data-demo-status]');
  document.querySelectorAll('[data-load-demo]').forEach(button => button.addEventListener('click', () => {
    if (loading) return;
    loading = true;
    document.querySelector('[data-demo-placeholder]').hidden = true;
    frame.hidden = false;
    frame.src = demoLink.href;
    status.hidden = false;
    status.textContent = text('Demo wird geladen …', 'Loading demo …');
    clearTimeout(timer);
    timer = setTimeout(() => { status.textContent = text('Falls die Vorschau nicht erscheint, prüfe die Verbindung oder öffne die Demo separat. Du kannst das Laden erneut versuchen.', 'If the preview does not appear, check your connection or open the demo separately. You can retry loading.'); loading = false; }, 18000);
  }));
  frame?.addEventListener('load', () => { clearTimeout(timer); loading = false; status.textContent = text('Vorschau geöffnet. Bei einer leeren Anzeige bitte separat öffnen oder erneut laden.', 'Preview opened. If it remains blank, open it separately or reload.'); });
})();
