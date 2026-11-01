# syntax=docker/dockerfile:1

# ---- Build stage: install the Wizz CLI and compile the site ----------------
FROM node:22-alpine AS build

# Pin the CLI so a new Wizz release never changes a deploy silently.
ARG WIZZ_VERSION=1.17.1

# The installer is a bash script that downloads and checksums the release.
RUN apk add --no-cache bash curl
RUN curl -fsSL "https://raw.githubusercontent.com/duncantidd/wizz.js/v${WIZZ_VERSION}/scripts/install-cli.sh" \
      | bash -s -- "https://github.com/duncantidd/wizz.js/releases/download/v${WIZZ_VERSION}/wizz-${WIZZ_VERSION}.tgz"
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app
COPY . .
RUN wizz build --adapter node \
 && cp llms.txt llms-full.txt dist/

# ---- Runtime stage: only the self-contained dist/ and Node -----------------
FROM node:22-alpine AS runtime

ENV NODE_ENV=production \
    PORT=8080
WORKDIR /app

COPY --from=build --chown=node:node /app/dist ./
USER node

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:' + process.env.PORT + '/api/health').then((r) => process.exit(r.ok ? 0 : 1), () => process.exit(1))"

CMD ["node", "server.mjs"]
