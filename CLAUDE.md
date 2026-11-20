## Domain Skills & Modern Standards

Before writing, refactoring, or reviewing frontend styling or architecture, you MUST consult the skills library in `.skills/`:

1. **CSS Tasks**: Consult `.skills/css/README.md` to identify the relevant guide (e.g. layout, colors, typography, state).
2. **JavaScript Tasks**: Consult `.skills/javascript/README.md` for standard library utilities, async patterns, DOM/events, and error causation.
3. **Wizz.js Tasks**: Consult `.skills/wizz/README.md` for component architecture, reactivity, template directives, and deployment.
4. **Design Systems (Neumorphism, Swiss Grid, Neo-Brutalism, Claymorphism, Japandi & Glassmorphism)**: Consult `.skills/design_principles/README.md` (`.skills/design_principles/neumorphism/`, `.skills/design_principles/swiss_grid/`, `.skills/design_principles/neo_brutalism/`, `.skills/design_principles/claymorphism/`, `.skills/design_principles/japandi/`, or `.skills/design_principles/glassmorphism/`) and inspect the co-located `images/` specification sheets.
5. **Testing, Benchmarking, Regression & Review Loops**: Consult `.skills/testing/README.md` (`.skills/testing/javascript/` for `node:test`, V8 benchmarking, and regression suites; `.skills/testing/workflows/` for adversarial code review and closed-loop test/review cycles).
6. **Decision Matrix**: Use the guide's Decision Matrix to choose the right platform-native feature.
7. **Anti-Pattern Audit**: Check the guide's **Do Not** table to ensure no obsolete patterns (e.g. `!important`, physical coordinates, lodash imports, `forEach(async)`, cold `Date.now()` benchmarks) are introduced.

---

## What This Project Is (`WHAT`)

**`wizz-documentation`** is the official, in-depth documentation website for **[Wizz.js](https://github.com/duncantidd/wizz.js)**—built and dogfooded entirely with Wizz.js itself.

- **About Wizz.js**: A zero-dependency, compiled component framework. Single-file `.wizz` components compile ahead-of-time to platform-native DOM creation/update instructions and static scoped CSS. Pages server-render (SSR) by default and hydrate in the browser with no Virtual DOM, no external npm runtime dependencies, and integrated backend API routes.
- **Repository Layout**:
  ```text
  wizz-documentation/
  ├── index.html                   # Document shell (<div id="app"></div> + /runtime/main.js)
  ├── App.css                      # Global design tokens (:root), reset, and shell layout
  ├── llms.txt                     # LLM-facing index of the docs (llmstxt.org format)
  ├── llms-full.txt                # Self-contained LLM reference: full .wizz contract, rules, codes, example
  ├── .mcp.json                    # Wizz MCP server config (compiler & project tools via WSL)
  ├── .skills/                     # Authoritative skill guides (Wizz, CSS, JS, Design Systems, Testing)
  ├── src/
  │   ├── App.wizz                 # Root landing page (served at /)
  │   ├── pages/                   # File-system routed documentation pages (e.g. Home.wizz -> /home)
  │   ├── components/              # Reusable .wizz UI components (e.g. Card.wizz, Counter.wizz)
  │   └── server/
  │       └── api/                 # Server-side API handlers (e.g. health.js -> /api/health)
  └── dist/                        # Disposable build output emitted by `wizz build` (never edit directly)
  ```

---

## Why This Architecture Exists (`WHY`)

1. **Zero-Dependency Dogfooding**: The documentation site serves as both the reference manual and a live architectural proof of Wizz.js. Every interactive widget, navigation bar, search filter, and live demo on the site runs natively on Wizz.js with zero third-party runtime packages.
2. **Compile-Time Guarantees Over Runtime Bloat**: Wizz.js enforces strict structural rules at compile time (single native root element, restricted template expressions, constrained `{#each}` loops, and static `[data-wizz-s]` attribute CSS scoping) so the browser executes minimal, predictable DOM operations without a Virtual DOM diffing engine.
3. **Eliminating Framework Hallucinations**: AI agents frequently assume React, Vue, or Svelte idioms (such as arbitrary JS inside `{...}`, `<slot>` children, `on:` events on component tags, or components nested inside `{#each}`). Adhering strictly to `.skills/wizz/` and the compiler contracts below prevents `WIZZ-P###` and `WIZZ-G###` compiler errors.

---

## How to Work on This Project (`HOW`)

### 1. CLI, Build & MCP Tooling
- **Use the Wizz MCP Server**: This workspace defines a `wizz` MCP server in `.mcp.json` (`wizz mcp --allow-write`). Prefer Wizz MCP tools when available to validate, compile, and inspect diagnostics.
- **Development Server**: Run `wizz dev` (or via WSL `wsl.exe -d Ubuntu -- /home/duncantidd/.local/bin/wizz dev`) to compile, serve at `http://localhost:3000`, watch `src/**/*.wizz`, server-render pages, and live-reload in the browser.
- **Production Build & Verification**:
  - `wizz build` — Emits compiled component modules, runtime, and extracted styles to `dist/`.
  - `wizz build --adapter node` — Emits a standalone Node SSR + API server at `dist/server.mjs` (run via `node dist/server.mjs`).
  - `wizz build --json` — Emits machine-parsable `wizz-build-diagnostics@1` JSON (`WIZZ-P###` parser, `WIZZ-G###` generator, `WIZZ-A###` analyzer diagnostics). Always verify builds cleanly after creating or editing `.wizz` files.

### 2. Non-Negotiable `.wizz` Compiler Contracts
Consult `.skills/wizz/README.md` and its 4 sub-guides before writing `.wizz` files. Every component MUST obey these compiler rules:

- **Single Native Root Element (`WIZZ-P001`)**:
  - Every `.wizz` template must have **exactly one native HTML element** at its root (e.g. `<main>`, `<div class="...">`, `<section>`). Top-level sibling elements are a compile error.
  - Each `.wizz` file may contain at most **one** `<script>`, **one** `<wizz:head>`, and **one** `<wizz:style>` block.
- **Safe Template Expressions Only**:
  - `{...}` interpolations allow (Wizz 1.23.0+):
    1. Identifiers and member access chains (`{title}`, `{doc.section.title}`)
    2. Number, string, `true`/`false`/`null` literals (`{"v1.0"}`, `{42}`, `{1.5}`)
    3. Arithmetic `+ - * /` and parentheses (`{count + 1}`, `{"card " + kind}`)
    4. Comparisons `=== !== < > <= >=`, `&&`/`||`, unary `!`/`-`
    5. The conditional (`{activeTab === "api" ? "tab is-active" : "tab"}`)
    6. Calls of a script function or method (`{plural(count)}`, `{name.trim()}`); a call re-renders only when a reactive name passed to it changes
  - **FORBIDDEN in `{...}`**: indexing (`{a[0]}`), `==`/`!=`, `??`, `?.`, `++`/`--`, template literals, arrow functions, array or object literals. Compute those in `<script>`.
  - **Two-way inputs**: `bind:value={name}` on `<input>`/`<textarea>`/`<select>` and `bind:checked={done}` on checkboxes, with a top-level `let`. Not on component tags or inside `{#each}` bodies.
  - **Warnings**: an assignment nested in an expression or an unbraced `if` body is warning `WIZZ-G026` and does not update the DOM. Builds must stay warning-free: make each assignment its own statement and brace control-flow bodies.
- **Component Imports & Composition**:
  - Use default imports only: `import Counter from "./components/Counter.wizz";`
  - Render imported components as **self-closing tags** inside a native DOM parent: `<Counter showReset={true} />`.
  - **No children or slots**: Never write `<Card><p>Child</p></Card>`. Pass content via props (`<Card title="Intro" body="..." />`) or compose using native elements.
  - **No `on:` directives on component tags**: `on:<event>` works only on native HTML elements. Pass callback functions as props instead (`<SearchBar onSearch={handleSearch} />`).
- **Reactivity, Props, Persistence & Lifecycle**:
  - **Reactive State**: Top-level `let` variables in `<script>` are reactive and batch DOM updates on the next microtask. Reassign arrays/objects immutably (`items = [...items, newItem]` or `items = items.filter(...)`), never via in-place mutation (`.push()`, `.splice()`).
  - **Read-Only Props**: Declare props with `export let propName = defaultValue;`. Never mutate an `export let` prop inside the child component.
  - **Cross-Tab Persistent State**: Declare `let theme = persist("wizz_docs_theme", "dark");` at the **top level** of `<script>` for automatic `localStorage` persistence and cross-tab `storage` synchronization.
  - **Lifecycle Hooks**: Call `onMount(() => { ... })` and `onDestroy(() => { ... })` directly in `<script>` **without importing them** (they are compiler globals). Always read browser-only APIs (`window`, `document`, `URLSearchParams(document.location.search)`) inside `onMount` so SSR output matches initial hydration.
  - **Events**: Bind native events with `on:<event>={namedHandler}` (e.g., `on:click={toggleSidebar}`). House style for this site: prefer named handlers over inline arrows (`on:click={() => ...}`) so templates stay scannable. This is a style rule, not a compiler limit: from Wizz 1.17.1, assignments inside inline arrows update the DOM.
- **Control Flow (`{#if}` and `{#each}`)**:
  - **Branching**: `{#if condition} ... {:else} ... {/if}` uses safe expressions (or precomputed booleans) and re-evaluates whenever a reactive `let` or prop read by `condition` changes, swapping branches in place.
  - **`{#each}` 4 Strict Constraints**:
    1. Must be immediately enclosed inside a native HTML element (`<ul>`, `<div>`, `<nav>`).
    2. Loop body must have **exactly one native root element** (`<li data-id={item.id}>...</li>`).
    3. Iterated collection must be a top-level reactive `let` variable.
    4. Loop body **MUST NOT** contain imported components (`WIZZ-G004`) or nested `{#if}` / `{#each}` blocks (`WIZZ-G005`). (`on:<event>` directives inside `{#each}` bodies are supported in Wizz 1.22.0+ with the item variable in scope.)
  - **List Interactions**: Use `on:click={() => handleRow(item.id)}` on native elements inside `{#each}` (1.22.0+), or attach `on:click={handleListClick}` to the parent container outside `{#each}` and resolve the clicked item via `event.target.closest('[data-id]')`.
  - **List Conditionals**: Write per-row classes inline (`class={item.id === currentId ? "nav-item is-active" : "nav-item"}`, 1.23.0+) or precompute them inside `<script>` (`item.activeClass = ...`) and bind unquoted: `class={"nav-item " + item.activeClass}`. Row text and attributes refresh when the collection is reassigned, so a row that reads outer state such as `currentId` needs the collection rebuilt after it changes. A quoted `class="nav-item {item.activeClass}"` fails with WIZZ-P055 (1.22.1+; older compilers rendered the braces literally).

### 3. Routing, Server APIs & Styling Conventions
- **Pages & Routing**:
  - `src/App.wizz` is the root landing page (`/`).
  - Files in `src/pages/*.wizz` automatically get routes from their path (e.g., `src/pages/Home.wizz` $\rightarrow$ `/home`).
- **Server API Handlers (`src/server/api/*.js`)**:
  - Export `export default async function handler(request)` which runs server-side at `/api/<name>`.
  - `request` is a frozen object (`method`, `path`, `query` as `URLSearchParams`, lowercased `headers`, raw `body`, and `await request.json()`).
  - Keep secrets strictly in a gitignored `.env.server` at the project root—never inside `src/` or `.wizz` files.
- **Head Metadata (`<wizz:head>`)**:
  - Use `<wizz:head>` for per-page `<title>`, `<meta>`, and `<link>` tags (no `<script>` or other tags inside `<wizz:head>`).
- **Styling (`App.css` & `<wizz:style>`)**:
  - Define global custom properties (`:root`), resets, color palettes (OKLCH / `light-dark()`), and ambient background substrates in `App.css`.
  - Write component-scoped CSS inside `<wizz:style>` (automatically scoped via `[data-wizz-s]` and isolated `@keyframes`).
  - Use flow-relative logical properties (`inline-size`, `block-size`, `padding-inline`, `padding-block`, `margin-inline`, `inset`) and composite-only GPU animations (`transform`, `opacity`, `clip-path`, `filter`) with `@media (prefers-reduced-motion: reduce)` and `@media (prefers-reduced-transparency: reduce)` safeguards.

### 4. Keep `llms.txt` and `llms-full.txt` in Sync (Mandatory)
`llms.txt` and `llms-full.txt` at the project root are the agent-facing copies of this documentation. AI agents read them instead of the rendered pages, so a stale entry teaches agents the wrong framework.
- **Every change to the docs content must be reflected in both files in the same change.** This includes adding, removing, renaming, or moving a page in `src/pages/docs/`; changing any documented behavior, rule, API, CLI flag, diagnostic code, or code example; and bumping the documented Wizz version triple.
- **`llms.txt`**: Keep one link per docs page with an accurate one-line summary, grouped as Getting started / Core concepts / Reference / Optional. Update the "rules that trip agents up" list if a compiler rule changes.
- **`llms-full.txt`**: Update the matching numbered section, the diagnostic code tables (section 18), and the "Habits from other frameworks" table (section 19) when relevant. Keep it self-contained: no "see the website" for anything an agent needs to write correct code.
- **Verify the complete example (section 20) still compiles** after any compiler-rule or version change, by passing its source to the Wizz MCP `component_diagnostics` tool or building it in a scratch project.
- Pure styling or layout changes to the site (CSS, animations, navigation chrome) do not need an update.
