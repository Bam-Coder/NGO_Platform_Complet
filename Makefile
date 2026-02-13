.PHONY: help dev-backend stop-backend logs-backend install-web dev-web install-mobile dev-mobile

help:
	@echo "Available commands:"
	@echo "  make dev-backend    - Start backend + db with Docker"
	@echo "  make stop-backend   - Stop backend + db"
	@echo "  make logs-backend   - Tail backend logs"
	@echo "  make install-web    - Install web dependencies"
	@echo "  make dev-web        - Start Next.js admin web"
	@echo "  make install-mobile - Install Flutter dependencies"
	@echo "  make dev-mobile     - Run Flutter app"

dev-backend:
	cd ngo-backend && docker compose up -d

stop-backend:
	cd ngo-backend && docker compose down

logs-backend:
	cd ngo-backend && docker logs --tail=120 -f ngo_api

install-web:
	cd ngo-admin-web && npm install

dev-web:
	cd ngo-admin-web && npm run dev

install-mobile:
	cd ngo-mobile && flutter pub get

dev-mobile:
	cd ngo-mobile && flutter run
