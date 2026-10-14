# Order Service

The Order Service accepts `POST /orders` and queues orders in RabbitMQ. It retains the reliability and environment configuration introduced in Labs 1 and 2: a durable `order_queue`, persistent messages, publisher confirmations, error handling, and connection cleanup. It returns `Order received` only after the broker confirms the message. There is no order-processing consumer in this lab.

## Requirements

- Node.js 24 LTS and npm (`.nvmrc` selects 24 when using nvm)
- A running RabbitMQ broker; the Lab 5 examples use RabbitMQ 4.3.6

For Ubuntu, install Node.js 24 as in Lab 1:

```bash
sudo apt update
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt install -y nodejs
node --version
npm --version
```

If using nvm, run `nvm install` and `nvm use` from this repository instead.

## Local Setup

Run commands from this repository root:

```bash
npm ci
cp .env.example .env
```

Edit `.env` before starting. Match the RabbitMQ host, username, and password to your broker. The example uses the application account from the earlier labs; replace `CHANGE_ME` with its URL-encoded password. For a broker on another VM, use its reachable IP rather than localhost. The default `guest` account cannot connect remotely.

| Variable | Default | Purpose |
| --- | --- | --- |
| `RABBITMQ_CONNECTION_STRING` | `amqp://localhost` | AMQP connection URI |
| `PORT` | `3000` | HTTP listening port |

The optional `.env` file loads at startup. Existing environment variables take precedence; restart after editing configuration. Local environment files are ignored by Git and Docker. Commit `package.json`, `package-lock.json`, and `.env.example`.

```bash
npm test
npm start
```

The 17 tests exercise broker confirmations, failures, and cleanup without requiring a live broker. The service listens on all interfaces. Keep its terminal open and verify the running service from another terminal:

```bash
curl -i -X POST http://localhost:3000/orders \
  -H 'Content-Type: application/json' \
  -d '{"product":{"id":1,"name":"Dog Food","price":19.99},"quantity":2,"totalPrice":39.98}'
```

Expect HTTP 200 and `Order received`, with the message count increasing in the durable `order_queue`. A broker or queue failure returns HTTP 500 instead of reporting success. The same request is in `test-order-service.http` for the VS Code REST Client extension.

On a RabbitMQ VM, check the queue with:

```bash
sudo rabbitmqctl list_queues name durable messages
```

For the Lab 5 Compose broker, run this from the parent directory containing the Compose file:

```bash
docker compose exec rabbitmq rabbitmqctl list_queues name durable messages
```

An old non-durable `order_queue` conflicts with the new durable declaration. Preserve any needed messages before removing the old lab queue. The next accepted order creates the durable queue.

## Lab 5 Containers

Create the Dockerfile using the Lab 5 instructions. Use `node:24-alpine`, copy both npm dependency files, and install with `npm ci`. The supplied `.dockerignore` excludes local dependencies, Git metadata, and environment files.

Pass broker configuration when the container starts. Within Compose, the broker host is `rabbitmq`; a container's localhost refers to that container. The lab provides a working Docker-network example for testing this service on its own, followed by the full Compose stack.

The tested dependency baseline is Express 5.3.0, amqplib 2.2.0, cors 2.8.6, and dotenv 18.0.7. `package-lock.json` records exact resolved versions.
