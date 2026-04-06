.PHONY: dev dev-backend dev-frontend build collect cli install

install:
	npm install

dev:
	npx concurrently "make dev-backend" "make dev-frontend"

dev-backend:
	cd backend && npm run dev

dev-frontend:
	cd frontend && npm run dev

build:
	cd core && npm run build
	cd backend && npm run build
	cd frontend && npm run build
	cd cli && npm run build

collect:
	cd cli && npx tsx src/index.ts today

cli:
	cd cli && npx tsx src/index.ts
