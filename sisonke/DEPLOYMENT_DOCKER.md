# Sisonke VPS Deployment

This deployment runs PostgreSQL, the Node backend, the Flutter Web admin dashboard, and Caddy HTTPS on one VPS.

## 1. DNS

Create an `A` record:

```text
sisonke.mmpzmne.co.zw -> YOUR_VPS_PUBLIC_IP
```

Wait until DNS resolves before starting Caddy.

## 2. VPS Setup

Install Docker and the Compose plugin:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 3. Environment

Copy the example and edit strong secrets:

```bash
cp .env.production.example .env.production
nano .env.production
```

Required values:

```text
POSTGRES_PASSWORD=<long random database password>
JWT_SECRET=<at least 32 random characters>
ADMIN_EMAIL=<your admin email>
ADMIN_PASSWORD=<strong admin password, 12+ characters>
```

## 4. Start Production

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml up -d --build
```

The first run creates the PostgreSQL database volume and runs migrations before the backend starts.

## 5. Create First Admin

After the stack is running:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml run --rm backend npm run admin:create
```

## 6. Verify

```bash
curl https://sisonke.mmpzmne.co.zw/api/health
```

Open:

```text
https://sisonke.mmpzmne.co.zw
```

Use the admin email and password from `.env.production`.

## 7. Mobile APK

Build production APK:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://sisonke.mmpzmne.co.zw/api
```

The current built APK is:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 8. Operations

View logs:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml logs -f backend
```

Restart:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml restart
```

Update after pulling new code:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml up -d --build
```

Back up PostgreSQL:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml exec postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > sisonke-backup.sql
```
