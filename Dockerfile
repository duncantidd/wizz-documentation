# syntax=docker/dockerfile:1

# Where the Wizz CLI comes from:
#   release (default) - the pinned GitHub release below. Render deploys use this.
#   local             - a wizz.js working tree passed as the named build context
#                       "wizz", for checking the site against an unreleased compiler:
#     docker build --build-arg WIZZ_SOURCE=local --build-context wizz=../wizzjs .
# BuildKit only builds the stage the build stage selects, so a release build
# never needs the "wizz" context.
ARG WIZZ_SOURCE=release

# ---- CLI from the pinned release --------------------------------------------
FROM node:22-alpine AS cli-release

# Pin the CLI so a new Wizz release never changes a deploy silently.
ARG WIZZ_VERSION=1.26.0

# The installer is a bash script that downloads and checksums the release.
RUN apk add --no-cache bash curl
RUN curl -fsSL "https://raw.githubusercontent.com/duncantidd/wizz.js/v${WIZZ_VERSION}/scripts/install-cli.sh" \
      | bash -s -- "https://github.com/duncantidd/wizz.js/releases/download/v${WIZZ_VERSION}/wizz-${WIZZ_VERSION}.tgz" \
 && /root/.local/bin/wizz --version
ENV PATH="/root/.local/bin:${PATH}"

# ---- CLI from a local wizz.js working tree ----------------------------------
FROM node:22-alpine AS cli-local

RUN apk add --no-cache bash
# Only what `install-cli.sh --local` reads, so the tree's .git and
# node_modules are never sent to the builder.
COPY --from=wizz build.js /wizz/build.js
COPY --from=wizz src /wizz/src
COPY --from=wizz scripts /wizz/scripts
RUN bash /wizz/scripts/install-cli.sh --local \
 && /root/.local/bin/wizz --version
ENV PATH="/root/.local/bin:${PATH}"

# ---- Build stage: compile the site with the selected CLI --------------------
FROM cli-${WIZZ_SOURCE} AS build

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
