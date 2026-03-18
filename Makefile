include .env
export

export PROJECT_ROOT=$(CURDIR)

env-up:
	docker compose up -d todoapp-postgres

env-down:
	docker compose down todoapp-postgres

env-cleanup:
	@powershell -NoProfile -Command "[Console]::InputEncoding = [System.Text.UTF8Encoding]::new(); [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(); $$ans = Read-Host 'Очистить все volume файлы приложения? [y/N]'; if ($$ans -eq 'y') { docker compose down; if (Test-Path 'out/pgdata') { Remove-Item 'out/pgdata' -Recurse -Force }; Write-Host 'Файлы окружения очищены' } else { Write-Host 'Очистка отменена' }"

migrate-create:
	@powershell -NoProfile -Command "if (-not '$(name)') { Write-Host 'Укажи имя миграции: make migrate-create name=init'; exit 1 }"
	@echo Creating migration: $(name)
	@docker compose run --rm todoapp-postgres-migrate create -ext sql -dir /migrations -seq $(name)

migrate-up:
	@echo Applying migrations...
	make migrate-action action=up
migrate-down:
	@echo Rolling back last migration...
	make migrate-action action=down

migrate-action:
	@echo Applying migrations...
	@docker compose run --rm todoapp-postgres-migrate -path /migrations -database "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable" $(action)

env-port-forward:
	@echo Starting port forwarding for PostgreSQL...
	docker compose up -d port-forwarder

env-port-forward-stop:
	@echo Stopping port forwarding for PostgreSQL...
	docker compose down port-forwarder	
