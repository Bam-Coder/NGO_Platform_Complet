# NGO Platform Monorepo

Ce monorepo contient les 3 applications de la plateforme NGO:

- `ngo-backend`: API NestJS + PostgreSQL (Docker)
- `ngo-admin-web`: Back-office Next.js
- `ngo-mobile`: Application mobile Flutter

## Structure

```text
ngo-platform/
  ngo-backend/
  ngo-admin-web/
  ngo-mobile/
```

## Prerequis

- Docker + Docker Compose
- Node.js 20+
- npm
- Flutter SDK (pour mobile)

## Demarrage rapide

### 1) Backend

```bash
make dev-backend
```

API: `http://localhost:3000`
Swagger: `http://localhost:3000/api`

### 2) Web Admin

```bash
make install-web
make dev-web
```

App: `http://localhost:3001`

### 3) Mobile

```bash
make install-mobile
make dev-mobile
```

## Commandes utiles

```bash
make help
make logs-backend
make stop-backend
```
# NGO_Platform
# NGO_Platform_Complet
