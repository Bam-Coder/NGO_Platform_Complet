# NGO Admin Web

Application Next.js (App Router) pour l'administration de l'ONG, connectee au backend NestJS `ngo-backend`.

## Prerequis

- Backend `ngo-backend` lance sur `http://localhost:3000`
- Variables d'environnement frontend:

```bash
NEXT_PUBLIC_API_URL=http://localhost:3000
```

## Lancement

```bash
npm install
npm run dev
```

Le frontend tourne sur `http://localhost:3001`.

## Notes integration

- Le login utilise `POST /auth/login` et attend `{ access_token }`.
- Le token JWT est stocke pour:
  - l'entete `Authorization: Bearer ...` via `src/lib/axios.js`
  - la protection de routes via `src/middleware.js`.
- L'application principale est dans `src/app`.
# NGO-admin-web
