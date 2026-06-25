# Shared Docker Compose

This compose file connects all services. It provides shared infrastructure (RabbitMQ, Valkey/Redis, PostgreSQL) that each service can depend on without running its own copy.

## How it works

- **Infra services** (`rabbitmq`, `cache`, `db`, etc.) have **no profile** — they always start. Run `docker compose up -d` to start the shared infra.
- **Application services** (`client`, `fragment-composer`, etc.) are **profile-gated**. Opt in to the ones you need via `--profile`, or use `--profile full` for everything.
- **Each service's own compose file** has a `shared` profile that connects to the external `shared` network created here, allowing local hot-reload development against the shared infra.

## Usage examples

## Seed data

Populate the `video-editor` database with development seed data (user, devices, projects, fragments).

Requires the shared infra **and all services** to be running (migrations are applied on service startup).

```sh
./seed.sh
```

## Everything (shared compose, pre-built images)

```sh
docker compose --profile full up
```

## Just fragment-composer + infra

```sh
docker compose --profile fragment-composer up
```

## Develop multiple services in dev mode with shared infra

```sh
docker compose up -d                                                           # Infra in background
docker compose -f ../client/docker-compose.yml --profile shared up             # Client with hot-reload
docker compose -f ../fragment-composer/docker-compose.yml --profile shared up  # Fragment-Composer with hot-reload
...
```

## Develop client in dev mode with shared infra

```sh
docker compose up -d                                                # Infra in background
docker compose -f ../client/docker-compose.yml --profile shared up  # Client with hot-reload
```

## Develop client in dev mode (with local infra)

```sh
docker compose -f ../client/docker-compose.yml --profile dev up
```