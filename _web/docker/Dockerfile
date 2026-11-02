FROM node:24.15.0-bookworm-slim AS vue-build
WORKDIR /app
COPY package.json package-lock.json ./
COPY npm/package.json npm/package.json
RUN npm ci
COPY npm npm
COPY flutter/README.md flutter/README.md
COPY flutter/MIGRATION-0.7.md flutter/MIGRATION-0.7.md
COPY _web _web
RUN node _web/tools/build-content.mjs && node _web/tools/build-tile.mjs && npm run build && npx vite build --config _web/demos/vue/vite.config.ts

FROM debian:bookworm-slim AS flutter-build
ARG FLUTTER_VERSION=3.47.7
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils libglu1-mesa && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN git config --global --add safe.directory /opt/flutter && flutter config --no-analytics --enable-web
WORKDIR /app
COPY flutter flutter
COPY --from=vue-build /app/_web/demos/flutter _web/demos/flutter
WORKDIR /app/_web/demos/flutter
RUN flutter pub get && flutter analyze && flutter test && flutter build web --release --base-href /flutter/ --no-web-resources-cdn

FROM node:24.15.0-alpine AS runtime
ENV NODE_ENV=production PORT=8080 PORTAL_ORIGINS="https://www.tekocloud.de https://tekocloud.de"
WORKDIR /app
COPY _web/docker/server.mjs ./server.mjs
COPY --from=vue-build /app/_web/demos/vue/dist public/vue
COPY --from=flutter-build /app/_web/demos/flutter/build/web public/flutter
COPY --from=vue-build /app/_web/demos/manifest.json public/manifest.json
COPY --from=vue-build /app/_web/demos/tiles public/tiles
USER node
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 CMD node -e "fetch('http://127.0.0.1:8080/healthz').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "server.mjs"]
