# tecexpress Dokumentation / Documentation

PHP-Portal und echte Vue-/Flutter-Web-Demos. Das Portal liegt auf separatem PHP-Webspace; Portainer betreibt das Demo-Image unter **https://tecexpress.tekoserver.cloud**.

## PHP-Portal

PHP **8.1+**, keine Datenbank und kein Composer nötig. Folgende Dateien und Ordner aus `_web` in den gewünschten Webspace-Unterordner kopieren:

```text
index.php
config.php
includes/
assets/
content/
```

`content/catalog.json` wird mitgeliefert. `index.php` funktioniert auch in Unterordnern ohne Rewrite-Regeln. Für eigene Einstellungen optional `config.local.php` erstellen:

```php
<?php
return ['demo_base_url' => 'https://tecexpress.tekoserver.cloud'];
```

Lokal aus dem Repository-Stamm starten:

```sh
php -S 127.0.0.1:8090 -t _web
```

Portal: http://127.0.0.1:8090/. Dokumentationsnavigation und Suche funktionieren auch ohne Demo-Container. Die Vorschau startet beim Öffnen einer Komponentenseite automatisch und kann über „Erneut laden“ neu gestartet werden. Bei Verbindungsproblemen gibt es einen Hinweis und einen direkten Demo-Link.

## Docker-Image bauen

### Automatisch mit GitHub Actions

Der Workflow **Build and publish demo image** (`.github/workflows/publish-demos.yml`) baut das Image bei relevanten Pushes auf `main`, bei Tags `v*` und manuell über **Actions → Build and publish demo image → Run workflow**. Pull Requests werden gebaut und getestet, veröffentlichen aber kein Image.

Auf `main` entstehen `ghcr.io/tekocloud/tecexpress-demos:latest`, `:main` und ein `:sha-…`-Tag. Ein Versions-Tag wie `v0.7.1` erzeugt `:0.7.1` und aktualisiert `:latest`. Portainer verwendet standardmäßig `:latest`; für festgelegte Releases `TECEXPRESS_IMAGE` auf einen Versions- oder SHA-Tag setzen. Das Paket wird mit dem Repository verknüpft. Der Workflow verwendet `GITHUB_TOKEN` mit `packages: write`; ein zusätzliches Push-Secret ist nicht nötig.

Vor dem Push werden Dokumentationskatalog, API-Abdeckung und Demo-Server geprüft. Der Docker-Build prüft Flutter mit Analyzer und Widgettests. Anschließend startet die Action den fertigen Container und prüft Healthcheck, beide Apps, Kartenkachel und Upload. Erst nach erfolgreichen Prüfungen wird nach GHCR veröffentlicht. Ein bestehendes GHCR-Paket muss dem Repository Schreibzugriff erlauben. Nach der ersten Veröffentlichung die gewünschte Paketsichtbarkeit in GitHub einstellen.

Die Action veröffentlicht das Image in die Registry. Das Aktualisieren deines laufenden Portainer-Stacks erfolgt anschließend dort über erneutes Pullen und Redeploy; Portainer-Zugangsdaten oder Webhooks sind nicht erforderlich.

### Alternativ lokal

Docker Desktop/Engine mit Linux-Containern auf **amd64** verwenden. Aus dem Repository-Stamm:

```sh
docker build -f _web/docker/Dockerfile -t ghcr.io/tekocloud/tecexpress-demos:0.7.1 .
docker login ghcr.io
docker push ghcr.io/tekocloud/tecexpress-demos:0.7.1
```

Bei privatem GHCR-Paket in Portainer eine Registry mit Leseberechtigung hinterlegen oder das Image öffentlich stellen. Der Name ist eine Vorgabe für das zu erstellende Paket; es wird nichts automatisch veröffentlicht. Für eine andere Registry denselben Namen beim Build, Push und in `TECEXPRESS_IMAGE` verwenden.

Das mehrstufige Image baut Vue mit Node 24.15 und Flutter Web mit Flutter 3.47.7. Zur Laufzeit liefert ein Node-Server beide statischen Builds und den temporären Upload-Test aus. Flutter/Node-Entwicklungsserver werden nicht gestartet. Der Build lädt das Flutter-SDK vom offiziellen Git-Tag und die zugehörigen SDK-Artefakte; der erste Build benötigt Internet und mehrere GB Platz. Das Image unterstützt zunächst amd64.

## Portainer

1. Stack anlegen und Inhalt von `docker/compose.yaml` einsetzen.
2. Bei Bedarf Stack-Variablen setzen: `TECEXPRESS_IMAGE`, `DEMO_PORT` (Standard `8088`) und `PORTAL_ORIGINS`.
3. `PORTAL_ORIGINS` enthält die exakten Origins des PHP-Portals, durch Leerzeichen getrennt. Standard: `https://www.tekocloud.de https://tekocloud.de`. Kein Pfad, kein abschließender Slash. Bei einer anderen Portal-Domain diese unbedingt ergänzen.
4. Stack starten. Ein vorhandener Reverse Proxy leitet **tecexpress.tekoserver.cloud** per HTTPS an Port `8088` des Docker-Hosts (oder im gemeinsamen Docker-Netz an `tecexpress-demos:8080`) weiter. WebSockets sind nicht erforderlich. Keine zusätzliche `X-Frame-Options: SAMEORIGIN`-Regel am Proxy setzen; sie würde die Einbettung verhindern.
5. DNS-A/AAAA-Eintrag und TLS-Zertifikat am eigenen Reverse Proxy konfigurieren. Das Image verwaltet DNS und Zertifikate nicht selbst.

Prüfpunkte:

```text
https://tecexpress.tekoserver.cloud/healthz
https://tecexpress.tekoserver.cloud/vue/?component=txdatagrid&lang=de&theme=light
https://tecexpress.tekoserver.cloud/flutter/?component=txdatagrid&lang=en&theme=dark
```

Ein Image-Update erfolgt durch erneuten Build/Push mit neuem Tag und Aktualisierung des Stacks. Zurückrollen: vorherigen Image-Tag einsetzen. Der Container besitzt keine dauerhaften Daten.

## Dokumentation und Demos pflegen

Aus dem Repository-Stamm:

```sh
npm ci
node _web/tools/build-content.mjs
npm run build
npx vite build --config _web/demos/vue/vite.config.ts
cd _web/demos/flutter
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href /flutter/ --no-web-resources-cdn
```

Die vorhandenen zweisprachigen Paket-READMEs sind die Referenzquelle. Der Generator erstellt daraus den versionierten PHP-Katalog sowie ignorierte Vue-SFCs und Flutter-Widgetbeispiele. Bei Paketänderungen zunächst die vorhandene Dokumentationspipeline unter `tools/documentation/README.md` ausführen, dann den Web-Katalog erneuern und das Image neu bauen. Zusatzanleitungen bleiben in ihrer jeweiligen Quellsprache.

Die Demo-URL akzeptiert `component` (kleingeschriebener API-Name), `lang=de|en` und `theme=light|dark`. Eine nicht vorhandene Seite ergibt im PHP-Portal HTTP 404. Ein Frameworkwechsel bleibt auf derselben API-Seite, sofern vorhanden.

Beide Frameworks nutzen echte Bibliothekskomponenten. Der Code auf den Seiten wird aus denselben Beispielen generiert. Paketinterne Flutter-Bedientexte sind entsprechend dem aktuellen Paket teilweise deutsch, auch bei englischer Material-Lokalisierung. Typen und Konfigurationen ohne eigene Oberfläche werden als API dokumentiert. Chat, DataSource und Dateiverwaltung verwenden lokale Daten, keinen produktiven Backenddienst.

Der Upload-Demodienst nimmt maximal rund 1 MiB plus Multipart-Header an, verwirft die Daten direkt und legt keine Dateien an. Er ist ausschließlich ein Testziel. Die Karte verwendet lokale synthetische Beispielkacheln, keine echten Geodaten oder fremden Kartendienste.

## Prüfungen

```sh
node _web/tools/verify.mjs
node --test _web/docker/server.test.mjs
php _web/tools/verify.php
```

Browser-Smoke-Test bei laufendem PHP- und Demo-Server:

```sh
node _web/tools/browser-check.mjs
```

Optional `PORTAL_URL` und `DEMO_URL` als Umgebungsvariablen setzen (Standard `http://127.0.0.1:8090` und `http://127.0.0.1:8080`). Für lokale Vorschauen im ignorierten `config.local.php` die lokale Demo-URL setzen. Die Demo-Domain ist im ausgelieferten Portal fest vorbelegt und weiterhin konfigurierbar.

## English deployment summary

Upload `index.php`, `config.php`, `includes/`, `assets/` and `content/` to PHP 8.1+ hosting. Build and push the image from the repository root, then import `docker/compose.yaml` as a Portainer stack. Point your HTTPS reverse proxy for `tecexpress.tekoserver.cloud` to the published container port. Set `PORTAL_ORIGINS` to the exact origin(s) of your separate PHP site. Rebuild the content catalog and demo image when the package documentation changes. Nothing is published automatically.
