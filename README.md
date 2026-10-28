# My Wizz App

A [Wizz](https://github.com/duncantidd/wizz.js) application: .wizz components compiled to platform-native DOM code, server-rendered and hydrated by default, with nothing to install beyond the Wizz CLI itself.

## Prerequisites

- Node.js 18 or newer
- The Wizz CLI:

    curl -fsSL https://raw.githubusercontent.com/duncantidd/wizz.js/main/scripts/install-cli.sh | bash

## Develop

    wizz dev

Builds the project, serves it at http://localhost:3000, and watches src/**/*.wizz for changes. Pages server-render on the server and hydrate in the browser.

## Build

    wizz build

Writes the production build to dist/: compiled component modules, the copied runtime, and the extracted styles, self-contained for static deployment. dist/ is disposable generated output — everything you edit lives in index.html, App.css, and src/**/*.wizz.

## Project layout

    index.html                   Document shell
    App.css                      Global design tokens and landing-page layout
    src/App.wizz                 Landing page (served at /)
    src/pages/Home.wizz          Routed page (served at /home)
    src/components/Counter.wizz  Imported component with persistent state
    src/components/Card.wizz     Imported component
    src/server/api/health.js     Server API handler (served at /api/health)

## Server API routes

Scripts inside .wizz files compile to browser modules — anything they use,
including an API key, is visible to everyone. Code that must stay
server-side lives in src/server/api/*.js: each file's default export runs
inside the development server at its /api/* route and can call third-party
APIs with the global fetch.

Keep secrets in a gitignored .env.server file at the project root; the
development server loads it into process.env before the first request, and
handlers read keys at request time. Add .env.server to your .gitignore.

## Editor setup (VS Code)

Install the Wizz extension for .wizz syntax highlighting, compiler diagnostics, component navigation, and build commands. With the wizz CLI on your PATH, one command installs the latest release's extension package:

    wizz install-vscode-extension

Without the CLI, download the latest wizz-vscode-<version>.vsix from https://github.com/duncantidd/wizz.js/releases and install it:

    code --install-extension wizz-vscode-<version>.vsix

or from VS Code: Extensions view -> "Views and More Actions" (...) -> Install from VSIX...

The extension drives the installed wizz CLI, so keep the launcher on your PATH (or point the wizz.compilerPath setting at it).
