# Repository Guidelines

## Project Structure & Module Organization
- `frontend/`: Vue 3 + Vite app (components, views, services, router). Env files: `.env.development`, `.env.production`.
- `backend/`: Node/Express API (routes, controllers, services, models, workers). Entry: `src/server.js`.
- `database/`: init SQL and backups used by `docker-compose.yml`.
- `tests/`: cross‑repo tests; backend also has `backend/tests/` and Jest in `backend/`.
- `docs/`, `scripts/`, `logs/`: documentation, helper scripts, runtime logs.

## Build, Test, and Development Commands
- Install all: `npm run install:all` (root → frontend → backend).
- Dev servers: `npm run dev` (runs backend + frontend concurrently).
- Production preview: `npm run start` (backend start + `frontend` preview).
- Backend only: `cd backend && npm run dev` | `npm run start`.
- Backend tests: `cd backend && npm test` | `npm run test:watch`.
- Backend lint: `cd backend && npm run lint`.
- DB migrations: `cd backend && npm run migrate`.
- Docker stack: `./docker-services.sh up` or `docker compose up -d` (preferred; starts `db`, `redis`, `backend`, `frontend`).
- Frontend HMR: configure via `VITE_HMR_ENABLED`, `VITE_HMR_HOST`, `VITE_HMR_PORT`, `VITE_HMR_CLIENT_PORT`, `VITE_DEV_ORIGIN` (in `frontend/.env.development` or compose env). Apply with `docker compose restart frontend`.

## Coding Style & Naming Conventions
- Indentation: 2 spaces; prefer single quotes; end statements with semicolons.
- Frontend components: PascalCase `.vue` in `src/components` and `src/views`.
- Frontend services: `*.service.js` in `src/services` (e.g., `projects.service.js`).
- Backend layers: `*.routes.js`, `*.controller.js`, `*Service.js`, `models/*.js` (Sequelize).
- Linting: Frontend uses ESLint (`plugin:vue/vue3-recommended`) and a custom `no-hardcoded-api` rule; backend `npm run lint` checks Node code.

## Testing Guidelines
- Backend: Jest + Supertest for routes. Place tests as `*.test.js` under `backend/tests` or root `tests/` (e.g., `tests/catalog.service.test.js`).
- Aim for meaningful integration tests around controllers/routes and services; add unit tests for pure utilities.
- Run: `cd backend && npm test`. Prefer `--watch` during development.
- Frontend E2E: Cypress specs live under `frontend/cypress/e2e/` (run if Cypress is installed).

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `build:`.
- Keep subjects imperative and ≤72 chars; add scoped areas (e.g., `feat(backend/routes): add invoice endpoint`).
- PRs: include purpose, linked issues, setup notes (env/migrations), and screenshots for UI changes. Ensure CI/lint/tests pass and migrations are reversible.

## Security & Configuration Tips
- Never commit secrets. Use `.env` files (`backend/.env`, `frontend/.env.*`) and Docker envs.
- Use `docker compose` (with a space) for container commands; dev images use Debian-based Node for native binary stability. Run `npm run migrate` after first boot.

## Agent Workflow
- When the task involves non-trivial UI work, unfamiliar APIs, debugging uncertainty, or you need inspiration for component usage, consult Context7 MCP docs (e.g., PrimeVue, Headless UI) before implementing.
- Prefer Context7 lookups for component capabilities, props, and patterns instead of guessing; reuse for debugging to confirm expected behaviors.
- Frontend dev server runs inside Docker during normal work; skip `npm run dev` locally and use the already running container endpoints when testing.
- Lean on the Chrome DevTools MCP to exercise the running frontend: navigate with `chrome-devtools__navigate_page`, capture DOM state via `...__take_snapshot`, and drive forms with `...__fill`/`...__click` when verifying new features or reproducing UI bugs (e.g., authenticating at `http://localhost:5173/login` with username `Admin` (capital A) and password `hammer3`).
- For regression testing conversations, script critical paths the same way—log in, traverse nav links, submit forms—and report back the resulting snapshot so future agents see the exact UI state.
- When troubleshooting, grab snapshots before and after attempting a fix so you and the user can compare states without manually describing every element.
- When data issues surface, inspect PostgreSQL directly via Docker: `docker compose exec db psql -U postgres -d management_db -c "<SQL or meta command>"` (e.g., `\dt` for tables, `\d users`, `SELECT * FROM users LIMIT 5;`). Confirm the container is running first with `docker compose ps`.
- Validate backend behavior in isolation with `curl http://localhost:3000/api/health` (or targeted endpoints) and keep Jest tests (`cd backend && npm test`) in the loop when shipping new API work.
- Pull container logs when debugging (`docker compose logs backend`, `docker compose logs frontend`) to capture stack traces or runtime warnings before diving into code changes.
